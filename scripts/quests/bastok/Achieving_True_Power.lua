-----------------------------------
-- Achieving True Power
-----------------------------------
-- Log ID: 1, Quest ID: 85
-- Shamarhaan : Bastok Markets (F-9), default event 433
-- Decorative Bronze Gate : Navukgo Execution Chamber
-----------------------------------
-- Retail: PUP job-specific level-cap quest. 10-min BCNM vs Shamarhaan +
-- Automaton Valkeng (Maat-style, reduce to -20% HP). Requires Puppetmaster's
-- Testimony farmed from Trolls + TAU expansion + prior Puppetmaster Blues.
--
-- Simplified for 4-player server: trade Testimony to Shamarhaan, receive
-- title + cap flag. No BCNM yet — Navukgo Execution Chamber doesn't have
-- an instance for this fight on our server. Revisit when that BC is built.
-- CSIDs best-guess; verify with !cs in-game.
-----------------------------------
local quest = Quest:new(xi.questLog.BASTOK, xi.quest.id.bastok.ACHIEVING_TRUE_POWER)

quest.reward =
{
    fame     = 50,
    fameArea = xi.fameArea.BASTOK,
    title    = xi.title.MASTER_OF_MANIPULATION,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getMainJob() == xi.job.PUP and
                player:getMainLvl() >= 66 and
                player:hasCompletedQuest(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.PUPPETMASTER_BLUES)
        end,

        [xi.zone.BASTOK_MARKETS] =
        {
            ['Shamarhaan'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.PUPPETMASTERS_TESTIMONY) then
                        return quest:progressEvent(434)
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:progressEvent(435)
                end,
            },

            onEventFinish =
            {
                [434] = function(player, csid, option, npc)
                    player:confirmTrade()
                    quest:begin(player)
                    quest:complete(player)
                end,

                [435] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },
}

return quest
