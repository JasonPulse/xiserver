-----------------------------------
-- Trial by Wind
-----------------------------------
-- Log ID: 5, Quest ID: 194
-- Agado-Pugado !pos -17 7 -10 247
-----------------------------------
local rabaoID = zones[xi.zone.RABAO]
-----------------------------------

local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.TRIAL_BY_WIND)

local function rewardMask(player)
    local mask = 0

    if player:hasItem(xi.item.GARUDAS_DAGGER) then
        mask = mask + 1
    end

    if player:hasItem(xi.item.WIND_BELT) then
        mask = mask + 2
    end

    if player:hasItem(xi.item.WIND_RING) then
        mask = mask + 4
    end

    if player:hasItem(xi.item.BOTTLE_OF_BUBBLY_WATER) then
        mask = mask + 8
    end

    if player:hasSpell(xi.magic.spell.GARUDA) then
        mask = mask + 32
    end

    return mask
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE and player:getFameLevel(xi.fameArea.SELBINA_RABAO) >= 5) or
                (status == xi.questStatus.QUEST_COMPLETED and GetSystemTime() > player:getCharVar('TrialByWind_date'))
        end,

        [xi.zone.RABAO] =
        {
            ['Agado-Pugado'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(66, 0, 331)
                end,
            },

            onEventFinish =
            {
                [66] = function(player, csid, option, npc)
                    if option == 1 then
                        if player:getQuestStatus(xi.questLog.OUTLANDS, xi.quest.id.outlands.TRIAL_BY_WIND) == xi.questStatus.QUEST_COMPLETED then
                            player:delQuest(xi.questLog.OUTLANDS, xi.quest.id.outlands.TRIAL_BY_WIND)
                        end

                        quest:begin(player)
                        player:setCharVar('TrialByWind_date', 0)
                        npcUtil.giveKeyItem(player, xi.ki.TUNING_FORK_OF_WIND)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.RABAO] =
        {
            ['Agado-Pugado'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.WHISPER_OF_GALES) then
                        return quest:progressEvent(69, 0, 331, 3, 0, rewardMask(player))
                    elseif player:hasKeyItem(xi.ki.TUNING_FORK_OF_WIND) then
                        return quest:progressEvent(67, 0, 331, 3)
                    else
                        return quest:progressEvent(107, 0, 331)
                    end
                end,
            },

            onEventFinish =
            {
                [69] = function(player, csid, option, npc)
                    local item = 0

                    if option == 1 then
                        item = xi.item.GARUDAS_DAGGER
                    elseif option == 2 then
                        item = xi.item.WIND_BELT
                    elseif option == 3 then
                        item = xi.item.WIND_RING
                    elseif option == 4 then
                        item = xi.item.BOTTLE_OF_BUBBLY_WATER
                    end

                    if option < 5 and player:getFreeSlotsCount() == 0 then
                        player:messageSpecial(rabaoID.text.ITEM_CANNOT_BE_OBTAINED, item)
                        return
                    end

                    if option == 5 then
                        npcUtil.giveCurrency(player, 'gil', 10000)
                    elseif option == 6 then
                        player:addSpell(xi.magic.spell.GARUDA)
                        player:messageSpecial(rabaoID.text.GARUDA_UNLOCKED, 0, 0, 3)
                    elseif item ~= 0 then
                        player:addItem(item)
                        player:messageSpecial(rabaoID.text.ITEM_OBTAINED, item)
                    end

                    player:addTitle(xi.title.HEIR_OF_THE_GREAT_WIND)
                    player:delKeyItem(xi.ki.WHISPER_OF_GALES)
                    player:setCharVar('TrialByWind_date', JstMidnight())
                    player:addFame(xi.fameArea.SELBINA_RABAO, 30)
                    quest:complete(player)
                end,

                [107] = function(player, csid, option, npc)
                    npcUtil.giveKeyItem(player, xi.ki.TUNING_FORK_OF_WIND)
                end,
            },
        },
    },
}

return quest
