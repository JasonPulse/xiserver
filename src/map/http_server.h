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

#include <httplib.h>

// HTTP liveness/readiness server for the map process. Always on.
//
// Endpoints:
//
//   GET /healthz   -> 200 if the main loop has ticked within the staleness
//                     threshold, 503 otherwise. Use as a k8s livenessProbe.
//   GET /readyz    -> 200 once initialization has completed and the main
//                     loop has started ticking, 503 otherwise. Use as a
//                     k8s readinessProbe / startupProbe.
//   GET /api       -> Plain-text "alive" banner.
//
// Intended for in-cluster probing only. Do not expose externally — there
// is no authentication.
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

private:
    httplib::Server                m_httpServer;
    std::atomic<timer::time_point> m_lastTick;
    std::atomic<bool>              m_ready;
};
