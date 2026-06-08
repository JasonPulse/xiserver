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

#include "http_server.h"

#include "common/async.h"
#include "common/logging.h"
#include "common/settings.h"

MapHTTPServer::MapHTTPServer()
: m_lastTick(timer::now())
, m_ready(false)
{
    const auto host = settings::get<std::string>("network.MAP_HTTP_HOST");
    const auto port = settings::get<uint16>("network.MAP_HTTP_PORT");
    const auto staleMs =
        settings::get<uint32>("network.MAP_HEALTHCHECK_STALE_THRESHOLD_MS");

    ShowInfoFmt("Starting Map HTTP Server on http://{}:{}/healthz", host, port);

    Async::getInstance()->submit(
        [this, host, port, staleMs]()
        {
            m_httpServer.Get(
                "/api",
                [&](const httplib::Request& /*req*/, httplib::Response& res)
                {
                    res.set_content("xi_map alive", "text/plain");
                });

            m_httpServer.Get(
                "/healthz",
                [this, staleMs](const httplib::Request& /*req*/, httplib::Response& res)
                {
                    const auto now      = timer::now();
                    const auto lastTick = m_lastTick.load();
                    const auto sinceMs  = timer::count_milliseconds(now - lastTick);

                    if (!m_ready.load())
                    {
                        res.status = 503;
                        res.set_content("not ready", "text/plain");
                        return;
                    }

                    if (static_cast<uint64>(sinceMs) > staleMs)
                    {
                        res.status = 503;
                        res.set_content(
                            fmt::format("stale ({}ms since last tick)", sinceMs),
                            "text/plain");
                        return;
                    }

                    res.status = 200;
                    res.set_content(
                        fmt::format("ok ({}ms)", sinceMs),
                        "text/plain");
                });

            m_httpServer.Get(
                "/readyz",
                [this](const httplib::Request& /*req*/, httplib::Response& res)
                {
                    if (m_ready.load())
                    {
                        res.status = 200;
                        res.set_content("ready", "text/plain");
                    }
                    else
                    {
                        res.status = 503;
                        res.set_content("not ready", "text/plain");
                    }
                });

            m_httpServer.set_error_handler(
                [](const httplib::Request& /*req*/, httplib::Response& res)
                {
                    res.set_content(
                        fmt::format("{} {}", res.status, httplib::status_message(res.status)),
                        "text/plain");
                });

            // Blocking call; runs on the Async thread pool until ~MapHTTPServer.
            m_httpServer.listen(host, port);
        });
}

MapHTTPServer::~MapHTTPServer()
{
    m_httpServer.stop();
}

void MapHTTPServer::recordTick()
{
    m_lastTick.store(timer::now(), std::memory_order_relaxed);
}

void MapHTTPServer::markReady()
{
    m_ready.store(true, std::memory_order_release);
}
