-----------------------------------
-- Trial by Lightning
-----------------------------------
-- Log ID: 4, Quest ID: 27
-- Ripapa !pos 29 -15 55 249
-----------------------------------
local mhauraID = zones[xi.zone.MHAURA]
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.TRIAL_BY_LIGHTNING)

local function rewardMask(player)
    local mask = 0

    if player:hasItem(xi.item.RAMUHS_STAFF) then
        mask = mask + 1
    end

    if player:hasItem(xi.item.LIGHTNING_BELT) then
        mask = mask + 2
    end

    if player:hasItem(xi.item.LIGHTNING_RING) then
        mask = mask + 4
    end

    if player:hasItem(xi.item.ELDER_BRANCH) then
        mask = mask + 8
    end

    if player:hasSpell(xi.magic.spell.RAMUH) then
        mask = mask + 32
    end

    return mask
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE and player:getFameLevel(xi.fameArea.WINDURST) >= 6) or
                (status == xi.questStatus.QUEST_COMPLETED and GetSystemTime() > player:getCharVar('TrialByLightning_date'))
        end,

        [xi.zone.MHAURA] =
        {
            ['Ripapa'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10016, 0, xi.ki.TUNING_FORK_OF_LIGHTNING)
                end,
            },

            onEventFinish =
            {
                [10016] = function(player, csid, option, npc)
                    if option == 1 then
                        if player:getQuestStatus(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.TRIAL_BY_LIGHTNING) == xi.questStatus.QUEST_COMPLETED then
                            player:delQuest(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.TRIAL_BY_LIGHTNING)
                        end

                        quest:begin(player)
                        player:setCharVar('TrialByLightning_date', 0)
                        npcUtil.giveKeyItem(player, xi.ki.TUNING_FORK_OF_LIGHTNING)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.MHAURA] =
        {
            ['Ripapa'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.WHISPER_OF_STORMS) then
                        return quest:progressEvent(10019, 0, xi.ki.TUNING_FORK_OF_LIGHTNING, 5, 0, rewardMask(player))
                    elseif player:hasKeyItem(xi.ki.TUNING_FORK_OF_LIGHTNING) then
                        return quest:progressEvent(10017, 0, xi.ki.TUNING_FORK_OF_LIGHTNING, 5)
                    else
                        return quest:progressEvent(10024, 0, xi.ki.TUNING_FORK_OF_LIGHTNING)
                    end
                end,
            },

            onEventFinish =
            {
                [10019] = function(player, csid, option, npc)
                    local item = 0

                    if option == 1 then
                        item = xi.item.RAMUHS_STAFF
                    elseif option == 2 then
                        item = xi.item.LIGHTNING_BELT
                    elseif option == 3 then
                        item = xi.item.LIGHTNING_RING
                    elseif option == 4 then
                        item = xi.item.ELDER_BRANCH
                    end

                    if option < 5 and player:getFreeSlotsCount() == 0 then
                        player:messageSpecial(mhauraID.text.ITEM_CANNOT_BE_OBTAINED, item)
                        return
                    end

                    if option == 5 then
                        npcUtil.giveCurrency(player, 'gil', 10000)
                    elseif option == 6 then
                        player:addSpell(xi.magic.spell.RAMUH)
                        player:messageSpecial(mhauraID.text.RAMUH_UNLOCKED, 0, 0, 5)
                    elseif item ~= 0 then
                        player:addItem(item)
                        player:messageSpecial(mhauraID.text.ITEM_OBTAINED, item)
                    end

                    player:addTitle(xi.title.HEIR_OF_THE_GREAT_LIGHTNING)
                    player:delKeyItem(xi.ki.WHISPER_OF_STORMS)
                    player:setCharVar('TrialByLightning_date', JstMidnight())
                    player:addFame(xi.fameArea.WINDURST, 30)
                    quest:complete(player)
                end,

                [10024] = function(player, csid, option, npc)
                    npcUtil.giveKeyItem(player, xi.ki.TUNING_FORK_OF_LIGHTNING)
                end,
            },
        },
    },
}

return quest
