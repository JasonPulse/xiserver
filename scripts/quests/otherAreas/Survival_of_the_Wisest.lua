-----------------------------------
-- Survival of the Wisest
-----------------------------------
-- Log ID: 4, Quest ID: 33
-- Xarcabard [S] : zone-in trigger (SCH 66+, all SCH AF complete)
-- Indescript_Markings : Pashhow Marshlands [S] (via audit memory) or
-- Xarcabard [S]. Simplified here: Xarcabard [S] zone-in auto-accepts.
-----------------------------------
-- SCH Genkai 5 (lv75 cap). Retail: farm Scholar's Testimony from Orcs
-- [S] zones, trade to Indescript Markings, fight Gunther + Crimson
-- Grimoire BCNM. Simplified for 4-player server: trade testimony to
-- Indescript_Markings, complete. BCNM abstracted — revisit if wanted.
-----------------------------------
local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.SURVIVAL_OF_THE_WISEST)

quest.reward =
{
    fame     = 60,
    fameArea = xi.fameArea.OTHER_AREAS,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getMainJob() == xi.job.SCH and
                player:getMainLvl() >= 66 and
                player:hasCompletedQuest(xi.questLog.WINDURST, xi.quest.id.windurst.APOCALYPSE_NIGH)
        end,

        [xi.zone.XARCABARD_S] =
        {
            onZoneIn = function(player, prevZone)
                if quest:getVar(player, 'Accepted') == 0 then
                    quest:begin(player)
                    quest:setVar(player, 'Accepted', 1)
                end

                return -1
            end,
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.PASHHOW_MARSHLANDS_S] =
        {
            ['Indescript_Markings'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.SCHOLARS_TESTIMONY) then
                        return quest:progressEvent(200)
                    end
                end,
            },

            onEventFinish =
            {
                [200] = function(player, csid, option, npc)
                    player:confirmTrade()
                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
