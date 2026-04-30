-----------------------------------
-- The Old Man and the Harpoon
-----------------------------------
-- Log ID: 9, Quest ID: 77
-- Jorin     !pos 92 32 152 256
-- Shipilolo !pos 84 0 -60 256
-----------------------------------
local westernAdoulinID = zones[xi.zone.WESTERN_ADOULIN]
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.THE_OLD_MAN_AND_THE_HARPOON)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Jorin'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2540)
                end,
            },

            onEventFinish =
            {
                [2540] = function(player, csid, option, npc)
                    quest:begin(player)
                    npcUtil.giveKeyItem(player, xi.ki.BROKEN_HARPOON)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                player:getCurrentMission(xi.mission.log_id.SOA) >= xi.mission.id.soa.LIFE_ON_THE_FRONTIER
        end,

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Jorin'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.EXTRAVAGANT_HARPOON) then
                        return quest:progressEvent(2542)
                    else
                        return quest:progressEvent(2541)
                    end
                end,
            },

            ['Shipilolo'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.BROKEN_HARPOON) then
                        return quest:progressEvent(2543)
                    end
                end,
            },

            onEventFinish =
            {
                [2542] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:addExp(500 * xi.settings.main.EXP_RATE)
                        player:addCurrency('bayld', 300 * xi.settings.main.BAYLD_RATE)
                        player:messageSpecial(westernAdoulinID.text.BAYLD_OBTAINED, 300 * xi.settings.main.BAYLD_RATE)
                        player:delKeyItem(xi.ki.EXTRAVAGANT_HARPOON)
                        player:addFame(xi.fameArea.ADOULIN, 30)
                    end
                end,

                [2543] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.BROKEN_HARPOON)
                    npcUtil.giveKeyItem(player, xi.ki.EXTRAVAGANT_HARPOON)
                end,
            },
        },
    },
}

return quest
