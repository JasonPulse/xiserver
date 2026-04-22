-----------------------------------
-- Escort for Hire (San d'Oria)
-----------------------------------
-- Log ID: 0, Quest ID: 103
-- Rondipur : Northern San d'Oria (F-6), event 721 default
-- Cannau   : The Eldieme Necropolis (F-8), event 51 default
-----------------------------------
-- Retail: 30-min timed escort through Eldieme Necropolis undead. Weekly
-- Conquest Tally gated; any nation's version blocks the others.
--
-- Simplified for 4-player private server: no timer, no pathing. Accept
-- from Rondipur, zone into Eldieme Necropolis, speak to Cannau for the
-- Completion certificate KI, return to Rondipur. First clear pays
-- 10,000 gil; repeats pay Miratete's Memoirs only. No hard weekly gate —
-- quest can be re-accepted from Rondipur immediately after completion.
-- CSIDs are best-guess from client event dump; verify with !cs in-game.
-----------------------------------
local miratetesMemoirs = xi.item.MIRATETES_MEMOIRS

local quest = Quest:new(xi.questLog.SANDORIA, xi.quest.id.sandoria.ESCORT_FOR_HIRE)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.SANDORIA,
}

local function grantReward(player)
    if player:getCharVar('EscortForHireCleared') == 0 then
        player:setCharVar('EscortForHireCleared', 1)
        player:addGil(10000)
        player:messageSpecial(zones[xi.zone.NORTHERN_SAN_DORIA].text.GIL_OBTAINED, 10000)
    end

    player:addItem(miratetesMemoirs)
    player:messageSpecial(zones[xi.zone.NORTHERN_SAN_DORIA].text.ITEM_OBTAINED, miratetesMemoirs)
end

local function canAccept(player)
    return player:getFameLevel(xi.fameArea.SANDORIA) >= 6
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE or status == xi.questStatus.QUEST_COMPLETED) and
                canAccept(player) and
                not player:hasKeyItem(xi.ki.COMPLETION_CERTIFICATE)
        end,

        [xi.zone.NORTHERN_SAN_DORIA] =
        {
            ['Rondipur'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(722)
                end,
            },

            onEventFinish =
            {
                [722] = function(player, csid, option, npc)
                    if option == 1 then
                        if player:getQuestStatus(xi.questLog.SANDORIA, xi.quest.id.sandoria.ESCORT_FOR_HIRE) == xi.questStatus.QUEST_COMPLETED then
                            -- Re-accept for another run
                            player:addQuest(xi.questLog.SANDORIA, xi.quest.id.sandoria.ESCORT_FOR_HIRE)
                        else
                            quest:begin(player)
                        end
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.THE_ELDIEME_NECROPOLIS] =
        {
            ['Cannau'] =
            {
                onTrigger = function(player, npc)
                    if not player:hasKeyItem(xi.ki.COMPLETION_CERTIFICATE) then
                        return quest:progressEvent(52)
                    else
                        return quest:event(51)
                    end
                end,
            },

            onEventFinish =
            {
                [52] = function(player, csid, option, npc)
                    npcUtil.giveKeyItem(player, xi.ki.COMPLETION_CERTIFICATE)
                end,
            },
        },

        [xi.zone.NORTHERN_SAN_DORIA] =
        {
            ['Rondipur'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.COMPLETION_CERTIFICATE) then
                        return quest:progressEvent(723)
                    else
                        return quest:event(724)
                    end
                end,
            },

            onEventFinish =
            {
                [723] = function(player, csid, option, npc)
                    if player:getFreeSlotsCount() > 0 then
                        player:delKeyItem(xi.ki.COMPLETION_CERTIFICATE)
                        grantReward(player)
                        -- addFame handled via quest.reward table on first completion only;
                        -- for repeats we pay the item directly above.
                        if
                            player:getQuestStatus(xi.questLog.SANDORIA, xi.quest.id.sandoria.ESCORT_FOR_HIRE) == xi.questStatus.QUEST_ACCEPTED and
                            player:getCharVar('EscortForHireCleared') == 1
                        then
                            -- first completion goes through the framework reward
                            quest:complete(player)
                        else
                            player:completeQuest(xi.questLog.SANDORIA, xi.quest.id.sandoria.ESCORT_FOR_HIRE)
                            player:addFame(xi.fameArea.SANDORIA, 10)
                        end
                    end
                end,
            },
        },
    },
}

return quest
