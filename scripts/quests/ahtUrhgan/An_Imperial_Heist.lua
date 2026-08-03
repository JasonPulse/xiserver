-----------------------------------
-- An Imperial Heist
-----------------------------------
-- Log ID: 6, Quest ID: 70
-- Naja_Salaheem : Aht Urhgan Whitegate (I-10)
-----------------------------------
-- Mythic chain #1. Unlocks Duties, Tasks, and Deeds.
--
-- Retail prerequisites (bg-wiki): Captain Wildcat badge KI (top mercenary
-- rank) + Runic key KI (Nyzul Isle) + ToAU Mission 48 complete. The offer
-- is gated on all three so it cannot pre-empt the ToAU mission line.
--
-- The offer uses printToPlayer rather than an event: the real offer CSID
-- has not been decoded, and event 200 in this zone is the Mhaura ferry
-- departure cutscene, which Zone.lua warps on.
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.AN_IMPERIAL_HEIST)

quest.reward =
{
    fame     = 60,
    fameArea = xi.fameArea.WINDURST,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasKeyItem(xi.ki.CAPTAIN_WILDCAT_BADGE) and
                player:hasKeyItem(xi.ki.RUNIC_KEY) and
                player:hasCompletedMission(xi.mission.log_id.TOAU, xi.mission.id.toau.ETERNAL_MERCENARY)
        end,

        [xi.zone.AHT_URHGAN_WHITEGATE] =
        {
            ['Naja_Salaheem'] =
            {
                onTrigger = function(player, npc)
                    player:printToPlayer('Naja Salaheem: Those ancient weapons lifted from the Imperial Treasury are in the depths of Nyzul Isle. Go get \'em, and the bounty is ours!', xi.msg.channel.NS_SAY)
                    quest:begin(player)
                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
