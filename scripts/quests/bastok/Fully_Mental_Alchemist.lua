-----------------------------------
-- Fully Mental Alchemist
-----------------------------------
-- Log ID: 1, Quest ID: 88
-- Titus : Bastok Mines 2F Alchemy Guild (L-7) — has existing NPC script
-- Grauberg (S) Riverbed : F-13 — examine spots to pan for gold
-----------------------------------
-- Retail: randomized pan/wash loops to accumulate 20 grains of gold dust,
-- progress lost on zoning. Simplified for 4-player server: accept from
-- Titus → zone into Grauberg [S] with Prospector's Pan → on zone-in flag
-- 'Panned' and grant Ampoule of Gold Dust KI → return to Titus.
-- Not alchemy-exclusive despite the name — Alchemy Guild register not
-- required on this server.
-- CSIDs best-guess; verify with !cs in-game.
-----------------------------------
local quest = Quest:new(xi.questLog.BASTOK, xi.quest.id.bastok.FULLY_MENTAL_ALCHEMIST)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.BASTOK,
    item     = xi.item.TRAINEE_SWORD,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.BASTOK) >= 1
        end,

        [xi.zone.BASTOK_MINES] =
        {
            ['Titus'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(900)
                end,
            },

            onEventFinish =
            {
                [900] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                        npcUtil.giveKeyItem(player, xi.ki.PROSPECTORS_PAN)
                        npcUtil.giveKeyItem(player, xi.ki.CORKED_AMPOULE)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.GRAUBERG_S] =
        {
            onZoneIn = function(player, prevZone)
                if
                    player:hasKeyItem(xi.ki.PROSPECTORS_PAN) and
                    not player:hasKeyItem(xi.ki.AMPOULE_OF_GOLD_DUST)
                then
                    player:delKeyItem(xi.ki.CORKED_AMPOULE)
                    npcUtil.giveKeyItem(player, xi.ki.AMPOULE_OF_GOLD_DUST)
                end

                return -1
            end,
        },

        [xi.zone.BASTOK_MINES] =
        {
            ['Titus'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.AMPOULE_OF_GOLD_DUST) then
                        return quest:progressEvent(901)
                    else
                        return quest:event(902)
                    end
                end,
            },

            onEventFinish =
            {
                [901] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.AMPOULE_OF_GOLD_DUST)
                        player:delKeyItem(xi.ki.PROSPECTORS_PAN)
                    end
                end,
            },
        },
    },
}

return quest
