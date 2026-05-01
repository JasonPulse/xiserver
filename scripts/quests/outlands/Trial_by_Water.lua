-----------------------------------
-- Trial by Water
-----------------------------------
-- Log ID: 5, Quest ID: 133
-- Edal-Tahdal !pos -13 1 -20 252
-----------------------------------
local norgID = zones[xi.zone.NORG]
-----------------------------------

local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.TRIAL_BY_WATER)

local function rewardMask(player)
    local mask = 0

    if player:hasItem(xi.item.LEVIATHANS_ROD) then
        mask = mask + 1
    end

    if player:hasItem(xi.item.WATER_BELT) then
        mask = mask + 2
    end

    if player:hasItem(xi.item.WATER_RING) then
        mask = mask + 4
    end

    if player:hasItem(xi.item.EYE_OF_NEPT) then
        mask = mask + 8
    end

    if player:hasSpell(xi.magic.spell.LEVIATHAN) then
        mask = mask + 32
    end

    return mask
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE and player:getFameLevel(xi.fameArea.NORG) >= 4) or
                (status == xi.questStatus.QUEST_COMPLETED and GetSystemTime() > player:getCharVar('TrialByWater_date'))
        end,

        [xi.zone.NORG] =
        {
            ['Edal-Tahdal'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(109, 0, xi.ki.TUNING_FORK_OF_WATER)
                end,
            },

            onEventFinish =
            {
                [109] = function(player, csid, option, npc)
                    if option == 1 then
                        if player:getQuestStatus(xi.questLog.OUTLANDS, xi.quest.id.outlands.TRIAL_BY_WATER) == xi.questStatus.QUEST_COMPLETED then
                            player:delQuest(xi.questLog.OUTLANDS, xi.quest.id.outlands.TRIAL_BY_WATER)
                        end

                        quest:begin(player)
                        player:setCharVar('TrialByWater_date', 0)
                        npcUtil.giveKeyItem(player, xi.ki.TUNING_FORK_OF_WATER)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.NORG] =
        {
            ['Edal-Tahdal'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.WHISPER_OF_TIDES) then
                        return quest:progressEvent(112, 0, xi.ki.TUNING_FORK_OF_WATER, 2, 0, rewardMask(player))
                    elseif player:hasKeyItem(xi.ki.TUNING_FORK_OF_WATER) then
                        return quest:progressEvent(110, 0, xi.ki.TUNING_FORK_OF_WATER, 2)
                    else
                        return quest:progressEvent(190, 0, xi.ki.TUNING_FORK_OF_WATER)
                    end
                end,
            },

            onEventFinish =
            {
                [112] = function(player, csid, option, npc)
                    local item = 0

                    if option == 1 then
                        item = xi.item.LEVIATHANS_ROD
                    elseif option == 2 then
                        item = xi.item.WATER_BELT
                    elseif option == 3 then
                        item = xi.item.WATER_RING
                    elseif option == 4 then
                        item = xi.item.EYE_OF_NEPT
                    end

                    if option < 5 and player:getFreeSlotsCount() == 0 then
                        player:messageSpecial(norgID.text.ITEM_CANNOT_BE_OBTAINED, item)
                        return
                    end

                    if option == 5 then
                        npcUtil.giveCurrency(player, 'gil', 10000)
                    elseif option == 6 then
                        player:addSpell(xi.magic.spell.LEVIATHAN)
                        player:messageSpecial(norgID.text.AVATAR_UNLOCKED, 0, 0, 2)
                    elseif item ~= 0 then
                        player:addItem(item)
                        player:messageSpecial(norgID.text.ITEM_OBTAINED, item)
                    end

                    player:addTitle(xi.title.HEIR_OF_THE_GREAT_WATER)
                    player:delKeyItem(xi.ki.WHISPER_OF_TIDES)
                    player:setCharVar('TrialByWater_date', JstMidnight())
                    player:addFame(xi.fameArea.NORG, 30)
                    quest:complete(player)
                end,

                [190] = function(player, csid, option, npc)
                    npcUtil.giveKeyItem(player, xi.ki.TUNING_FORK_OF_WATER)
                end,
            },
        },
    },
}

return quest
