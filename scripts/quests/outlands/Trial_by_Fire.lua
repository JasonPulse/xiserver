-----------------------------------
-- Trial by Fire
-----------------------------------
-- Log ID: 5, Quest ID: 12
-- Ronta-Onta !pos 100 -15 -97 250
-----------------------------------
local kazhamID = zones[xi.zone.KAZHAM]
-----------------------------------

local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.TRIAL_BY_FIRE)

local function rewardMask(player)
    local mask = 0

    if player:hasItem(xi.item.IFRITS_BLADE) then
        mask = mask + 1
    end

    if player:hasItem(xi.item.FIRE_BELT) then
        mask = mask + 2
    end

    if player:hasItem(xi.item.FIRE_RING) then
        mask = mask + 4
    end

    if player:hasItem(xi.item.EGILS_TORCH) then
        mask = mask + 8
    end

    if player:hasSpell(xi.magic.spell.IFRIT) then
        mask = mask + 32
    end

    return mask
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE and player:getFameLevel(xi.fameArea.WINDURST) >= 6) or
                (status == xi.questStatus.QUEST_COMPLETED and GetSystemTime() > player:getCharVar('TrialByFire_date'))
        end,

        [xi.zone.KAZHAM] =
        {
            ['Ronta-Onta'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(270, 0, xi.ki.TUNING_FORK_OF_FIRE)
                end,
            },

            onEventFinish =
            {
                [270] = function(player, csid, option, npc)
                    if option == 1 then
                        if player:getQuestStatus(xi.questLog.OUTLANDS, xi.quest.id.outlands.TRIAL_BY_FIRE) == xi.questStatus.QUEST_COMPLETED then
                            player:delQuest(xi.questLog.OUTLANDS, xi.quest.id.outlands.TRIAL_BY_FIRE)
                        end

                        quest:begin(player)
                        player:setCharVar('TrialByFire_date', 0)
                        npcUtil.giveKeyItem(player, xi.ki.TUNING_FORK_OF_FIRE)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.KAZHAM] =
        {
            ['Ronta-Onta'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.WHISPER_OF_FLAMES) then
                        return quest:progressEvent(273, 0, xi.ki.TUNING_FORK_OF_FIRE, 0, 0, rewardMask(player))
                    elseif player:hasKeyItem(xi.ki.TUNING_FORK_OF_FIRE) then
                        return quest:progressEvent(271, 0, xi.ki.TUNING_FORK_OF_FIRE, 0)
                    else
                        return quest:progressEvent(285, 0, xi.ki.TUNING_FORK_OF_FIRE)
                    end
                end,
            },

            onEventFinish =
            {
                [273] = function(player, csid, option, npc)
                    local item = 0

                    if option == 1 then
                        item = xi.item.IFRITS_BLADE
                    elseif option == 2 then
                        item = xi.item.FIRE_BELT
                    elseif option == 3 then
                        item = xi.item.FIRE_RING
                    elseif option == 4 then
                        item = xi.item.EGILS_TORCH
                    end

                    if option < 5 and player:getFreeSlotsCount() == 0 then
                        player:messageSpecial(kazhamID.text.ITEM_CANNOT_BE_OBTAINED, item)
                        return
                    end

                    if option == 5 then
                        npcUtil.giveCurrency(player, 'gil', 10000)
                    elseif option == 6 then
                        player:addSpell(xi.magic.spell.IFRIT)
                        player:messageSpecial(kazhamID.text.IFRIT_UNLOCKED, 0, 0, 0)
                    elseif item ~= 0 then
                        player:addItem(item)
                        player:messageSpecial(kazhamID.text.ITEM_OBTAINED, item)
                    end

                    player:addTitle(xi.title.HEIR_OF_THE_GREAT_FIRE)
                    player:delKeyItem(xi.ki.WHISPER_OF_FLAMES)
                    player:setCharVar('TrialByFire_date', JstMidnight())
                    player:addFame(xi.fameArea.WINDURST, 30)
                    quest:complete(player)
                end,

                [285] = function(player, csid, option, npc)
                    npcUtil.giveKeyItem(player, xi.ki.TUNING_FORK_OF_FIRE)
                end,
            },
        },
    },
}

return quest
