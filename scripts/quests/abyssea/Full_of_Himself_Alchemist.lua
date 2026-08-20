-----------------------------------
-- Full-of-Himself Alchemist
-----------------------------------
-- Log ID: 8, Quest ID: 13
-- Julio : Abyssea - Konschtat (F-10), entity 16839222
-- !addquest 8 13
-----------------------------------
-- Retail (bg-wiki "Full-of-Himself Alchemist").
-- |Start=Julio (A) (F-10), Abyssea - Konschtat  |Previous=Rose on the Heath
-- |Item Reqs=Purple Polypore x3  |Reward=Soothing Potion x2  |Repeatable=Yes
--   1. Speak to Julio (A) at (F-10), northwest of Conflux #02.
--   2. He asks for 3 Purple Polypores. They drop from Shadow Funguars around
--      (G-8)/(H-8) next to Conflux #04; the drop rate is fairly low.
--   3. Trade them to receive 2 Soothing Potions.
--
-- CSIDS DECODED, NOT GUESSED. Julio is 16839222 (zone 15 idx 566);
-- `xi-dat events 15` gives him 207, 244, 245, 246, 247, 248, 249, resolved with
-- csidscan.py against `xi-dat dialog 15`:
--   244 -> 7928-7934  THE OFFER. 7930 "this is private property", 7931 "You
--          fetch me my materials, and I'll let you have one of the[m]", and 7932
--          is the accept prompt: "Bring Julio his materials? ${selection-lines}
--          Why not? / Maybe another time." -- the affirmative is FIRST, so
--          OPTION 0 ACCEPTS, and 7934 is the brush-off.
--   245 -> 7935       the reminder: "What's that? Ya don't have my ${number: 1}
--          ${item-given-plurality: 1[2], 0[2]}?" -- count is param 1.
--   246 -> 7936-7938  THE TURN-IN.
--   249 -> 7928       his idle boast while working.
--
-- THE PARAM QUESTION IS SETTLED: THIS EVENT TAKES NO ITEM PARAMS AT ALL.
-- Param 0 appeared to carry the potion in 7928/7929 ("This ${item-singular:
-- 0[2]}'s not for you") but the polypores in 7933 ("${number: 1}
-- ${item-given-plurality: 1[2], 0[2]}, I'll be needin'"), which cannot both be
-- true of one startEvent call. Loading the entity block with csidmsg.load()
-- resolves it -- the block carries its own data[] table and the event reads the
-- ids from there, not from the caller:
--     data[] = [5716, 7928, 7929, 7930, 7931, 7932, 0, 5682, 3, 7933, 1,
--               7934, 7935, 7936, 7937, 7938, 201, 7939, 4]
--     csid -> entry offsets = { 244: 1, 245: 76, 246: 97, 247: 164,
--                               248: 194, 249: 256, 207: 267 }
-- data[0] = 5716 Soothing Potion (what he brews), data[7] = 5682 Purple
-- Polypore (what he wants), data[8] = 3 (how many). Two separate slots, so
-- there was never a collision -- and nothing needs to be passed from Lua.
--
-- WHY THIS ONE MATTERS BEYOND ITSELF: Julio is the in-game source of Soothing
-- Potions, and The_Walking_Wounded.lua needs five of them. That quest's
-- bg-wiki |Previous= is this quest, so this fills the chain head its header
-- called out as still missing.
--
-- ITEM: Purple Polypore is id 5682 (`item_basic`), which had no enum name and
-- was added as PURPLE_POLYPORE after checking the id was unused. Soothing
-- Potion is SOOTHING_POTION (5716), added earlier for The Walking Wounded.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.FULL_OF_HIMSELF_ALCHEMIST)

local polyporeCount = 3
local potionReward  = 2

quest.sections =
{
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE or
                    status == xi.questStatus.QUEST_COMPLETED) and
                player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.ROSE_ON_THE_HEATH)
        end,

        [xi.zone.ABYSSEA_KONSCHTAT] =
        {
            ['Julio'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(244)
                end,
            },

            onEventFinish =
            {
                [244] = function(player, csid, option, npc)
                    -- 7932: 0 "Why not?", 1 "Maybe another time."
                    if option ~= 0 then
                        return
                    end

                    if player:getQuestStatus(xi.questLog.ABYSSEA, xi.quest.id.abyssea.FULL_OF_HIMSELF_ALCHEMIST) == xi.questStatus.QUEST_COMPLETED then
                        player:addQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.FULL_OF_HIMSELF_ALCHEMIST)
                    else
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_KONSCHTAT] =
        {
            ['Julio'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, { { xi.item.PURPLE_POLYPORE, polyporeCount } }) then
                        return quest:progressEvent(246)
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(245)
                end,
            },

            onEventFinish =
            {
                [246] = function(player, csid, option, npc)
                    if npcUtil.giveItem(player, { { xi.item.SOOTHING_POTION, potionReward } }) then
                        player:confirmTrade()
                        quest:complete(player)
                    end
                end,
            },
        },
    },
}

return quest
