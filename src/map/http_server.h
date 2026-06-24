/*
===========================================================================

  Copyright (c) 2025 LandSandBoat Dev Teams

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see http://www.gnu.org/licenses/

===========================================================================
*/

#pragma once

#include "common/logging.h"
#include "common/timer.h"

#include <atomic>
#include <functional>
#include <mutex>
#include <queue>

#include <httplib.h>

// HTTP liveness/readiness + bot API server for the map process. Always on.
//
// Endpoints:
//
//   GET  /healthz           -> 200 if the main loop has ticked within the
//                              staleness threshold, 503 otherwise. Use as a
//                              k8s livenessProbe.
//   GET  /readyz            -> 200 once initialization has completed and
//                              the main loop has started ticking, 503
//                              otherwise. Use as a k8s readinessProbe /
//                              startupProbe.
//   GET  /api               -> Plain-text "alive" banner.
//   POST /api/bot/grant_gil -> Bot-authenticated currency grant. Gated on
//                              network.MAP_BOT_API_ENABLED + valid
//                              X-Bot-Token header. Returns 202 on accept;
//                              the actual grant runs on the next main-loop
//                              tick via the pending-action queue.
//
// Liveness/readiness intended for in-cluster probing only — no auth on
// those. The bot API requires the X-Bot-Token shared secret and should be
// firewalled to the bot orchestrator's egress IPs in production.
class MapHTTPServer
{
public:
    MapHTTPServer();
    ~MapHTTPServer();

    MapHTTPServer(const MapHTTPServer&)            = delete;
    MapHTTPServer& operator=(const MapHTTPServer&) = delete;
    MapHTTPServer(MapHTTPServer&&)                 = delete;
    MapHTTPServer& operator=(MapHTTPServer&&)      = delete;

    // Called from the main loop on every tick to mark the process as alive.
    void recordTick();

    // Called once initialization is complete and gameLoop() is running.
    void markReady();

    // Drains the bot-API action queue on the main thread. HTTP handlers
    // run on an Async worker and cannot touch CCharEntity safely, so they
    // push closures here for the main loop to execute. Called every tick.
    void processPendingActions();

private:
    httplib::Server                m_httpServer;
    std::atomic<timer::time_point> m_lastTick;
    std::atomic<bool>              m_ready;

    // Bot-API action queue. HTTP handlers enqueue; main loop drains.
    std::mutex                        m_actionsMutex;
    std::queue<std::function<void()>> m_pendingActions;
};
