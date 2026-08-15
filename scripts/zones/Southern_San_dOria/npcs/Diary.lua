-----------------------------------
-- Area: South San d'Oria
--  NPC: Diary
-- Involved in Quest: To Cure a Cough, Over The Hills And Far Away
-- !pos -75 -12 65 230
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local aSquiresTestII = player:getQuestStatus(xi.questLog.SANDORIA, xi.quest.id.sandoria.A_SQUIRES_TEST_II)
    local medicineWoman = player:getQuestStatus(xi.questLog.SANDORIA, xi.quest.id.sandoria.THE_MEDICINE_WOMAN)
    local toCureaCough = player:getQuestStatus(xi.questLog.SANDORIA, xi.quest.id.sandoria.TO_CURE_A_COUGH)
    local diaryPage = player:getCharVar('DiaryPage')

    if diaryPage == 0 then
        player:startEvent(639)          -- see diary, option to read (reads page 1)
    elseif diaryPage == 1 then
        player:startEvent(640)          -- reads page 2
    elseif diaryPage == 2 then
        -- DEADLOCK REMOVED. This used to require toCureaCough == QUEST_ACCEPTED to
        -- advance past page 2, but the quest does not reach ACCEPTED until Amaura
        -- fires 645, and Amaura.lua only offers 645 when `DiaryPage >= 3 or
        -- toCureaCough == QUEST_ACCEPTED`. Neither side could ever go first, so
        -- the diary stopped at page 2, Amaura never asked for the thyme moss, and
        -- To Cure a Cough was unfinishable -- which in turn left Over the Hills
        -- and Far Away permanently unstartable, since its check needs DiaryPage>=4.
        -- bg-wiki "To Cure a Cough" puts the diary BEFORE Amaura and attaches no
        -- condition to it: "Once you have heard Nenne's story, go into the first
        -- house on Watchdog Alley (G-7) ... Finish reading the diary entirely
        -- (continue paging through) to continue to the next portion." Nenne's 538
        -- is what "heard Nenne's story" means, and it sets charvar toCureaCough=1.
        -- COMPLETED is accepted too so the last pages stay readable afterwards;
        -- Over the Hills is flagged from the diary long after this quest is done.
        if
            player:getCharVar('toCureaCough') == 1 or
            toCureaCough == xi.questStatus.QUEST_ACCEPTED or
            toCureaCough == xi.questStatus.QUEST_COMPLETED or
            (medicineWoman == xi.questStatus.QUEST_AVAILABLE and
            aSquiresTestII == xi.questStatus.QUEST_AVAILABLE)
        then
            player:startEvent(641)      -- reads page 3
        else
            player:startEvent(640)      -- reads page 2
        end
    elseif diaryPage >= 3 then
        player:startEvent(722)          -- reads page 4
    --elseif diaryPage >= 4 then
    --    player:startEvent(723)        -- read last page
    end
end

entity.onEventFinish = function(player, csid, option, npc)
    local diaryPage = player:getCharVar('DiaryPage')

    if option >= diaryPage then
        if csid == 639 and option == 0 then
            player:setCharVar('DiaryPage', 1)    -- has read page 1
        elseif csid == 640 and option == 2 then
            player:setCharVar('DiaryPage', 2)    -- has read page 2
        elseif csid == 641 and option == 3 then
            player:setCharVar('DiaryPage', 3)    -- has read page 3
        elseif csid == 722 and option == 4 then
            player:setCharVar('DiaryPage', 4)    -- has read page 4
        --elseif csid == 723 and option == 5 then
        --    player:setCharVar('DiaryPage', 5)    -- has read the last page
        end
    end
end

return entity
