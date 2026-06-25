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

#include "entities/charentity.h"
#include "utils/charutils.h"
#include "utils/zoneutils.h"

#include <algorithm>
#include <cstddef>
#include <cstdint>
#include <exception>
#include <functional>
#include <string>
#include <vector>

#include <nlohmann/json.hpp>

namespace
{
// Constant-time string comparison so token check doesn't leak timing.
bool constantTimeEquals(const std::string& a, const std::string& b)
{
    if (a.size() != b.size())
    {
        return false;
    }

    unsigned char accum = 0;
    for (std::size_t i = 0; i < a.size(); ++i)
    {
        accum |= static_cast<unsigned char>(a[i] ^ b[i]);
    }

    return accum == 0;
}

bool botApiEnabledAndAuthed(const httplib::Request& req, httplib::Response& res)
{
    if (!settings::get<bool>("network.MAP_BOT_API_ENABLED"))
    {
        res.status = 404;
        res.set_content("{\"error\":\"bot api disabled\"}", "application/json");
        return false;
    }

    const auto configured = settings::get<std::string>("network.MAP_BOT_API_TOKEN");
    if (configured.empty())
    {
        // Refuse rather than accept an unauthenticated call when the
        // operator forgot to set a token. Fail closed.
        res.status = 503;
        res.set_content("{\"error\":\"bot api token not configured\"}", "application/json");
        return false;
    }

    const auto provided = req.get_header_value("X-Bot-Token");
    if (provided.empty() || !constantTimeEquals(provided, configured))
    {
        res.status = 401;
        res.set_content("{\"error\":\"bad token\"}", "application/json");
        return false;
    }

    return true;
}
} // namespace

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

            // POST /api/bot/grant_gil
            //   Headers: X-Bot-Token: <shared secret>
            //   Body:    {"player":"<name>", "amount":<int32>, "reason":"..."}
            //
            // Validates token + payload, then enqueues an action onto the
            // main-loop queue. Returns 202 Accepted with a body shape:
            //   {"queued": true, "player":"<name>", "amount":N}
            // The actual addGil happens on the next main-loop tick when
            // processPendingActions() drains the queue. If the player is
            // not online on this map process when the queued action runs,
            // the action no-ops (no retry, no DB write) — the caller is
            // responsible for verifying via /api/zones or session lookup
            // that the player is here before calling.
            m_httpServer.Post(
                "/api/bot/grant_gil",
                [this](const httplib::Request& req, httplib::Response& res)
                {
                    if (!botApiEnabledAndAuthed(req, res))
                    {
                        return;
                    }

                    nlohmann::json body;
                    try
                    {
                        body = nlohmann::json::parse(req.body);
                    }
                    catch (const std::exception&)
                    {
                        res.status = 400;
                        res.set_content("{\"error\":\"invalid json body\"}", "application/json");
                        return;
                    }

                    auto playerIt = body.find("player");
                    if (playerIt == body.end() || !playerIt->is_string())
                    {
                        res.status = 400;
                        res.set_content("{\"error\":\"missing player\"}", "application/json");
                        return;
                    }

                    auto amountIt = body.find("amount");
                    if (amountIt == body.end() || !amountIt->is_number_integer())
                    {
                        res.status = 400;
                        res.set_content("{\"error\":\"missing amount (int32)\"}", "application/json");
                        return;
                    }

                    const std::string playerName = playerIt->get<std::string>();
                    const int32       amount     = amountIt->get<int32>();

                    if (amount <= 0 || amount > 999999999)
                    {
                        res.status = 400;
                        res.set_content("{\"error\":\"amount out of range (1..999999999)\"}",
                                        "application/json");
                        return;
                    }

                    std::string reason   = "unspecified";
                    auto        reasonIt = body.find("reason");
                    if (reasonIt != body.end() && reasonIt->is_string())
                    {
                        reason = reasonIt->get<std::string>();
                    }

                    {
                        std::lock_guard<std::mutex> lk(m_actionsMutex);
                        m_pendingActions.emplace(
                            [playerName, amount, reason]()
                            {
                                auto* PChar = zoneutils::GetCharByName(playerName);
                                if (!PChar)
                                {
                                    ShowDebugFmt(
                                        "[BotAPI] grant_gil skipped: {} not online on this map "
                                        "(amount={}, reason={})",
                                        playerName,
                                        amount,
                                        reason);
                                    return;
                                }

                                charutils::UpdateItem(PChar, LOC_INVENTORY, 0, amount);
                                ShowInfoFmt(
                                    "[BotAPI] grant_gil: {} +{} gil (reason={})",
                                    playerName,
                                    amount,
                                    reason);
                            });
                    }

                    nlohmann::json out;
                    out["queued"] = true;
                    out["player"] = playerName;
                    out["amount"] = amount;
                    res.status    = 202;
                    res.set_content(out.dump(), "application/json");
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

void MapHTTPServer::processPendingActions()
{
    // Drain the queue under lock into a local, then run actions outside
    // the lock — actions may take time and must not block HTTP handler
    // enqueue. Cap per-tick drain so a flood of requests can't stall the
    // main loop; remainder runs next tick.
    constexpr std::size_t kMaxPerTick = 32;

    std::vector<std::function<void()>> batch;
    {
        std::lock_guard<std::mutex> lk(m_actionsMutex);
        const std::size_t           take = std::min(kMaxPerTick, m_pendingActions.size());
        batch.reserve(take);
        for (std::size_t i = 0; i < take; ++i)
        {
            batch.emplace_back(std::move(m_pendingActions.front()));
            m_pendingActions.pop();
        }
    }

    for (auto& action : batch)
    {
        try
        {
            action();
        }
        catch (const std::exception& e)
        {
            ShowErrorFmt("[BotAPI] action threw: {}", e.what());
        }
        catch (...)
        {
            ShowError("[BotAPI] action threw unknown exception");
        }
    }
}
