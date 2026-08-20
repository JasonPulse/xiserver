-----------------------------------
-- Cook's Pride
-----------------------------------
-- Log ID: 3, Quest ID: 16
-- Naruru : Lower Jeuno (H-10), entity 17780757
-- !addquest 3 16
-----------------------------------
-- Retail (bg-wiki "Cook's Pride").
-- |Start=Naruru, Lower Jeuno (H-10)  |Previous=The Wonder Magic Set
-- |Item Reqs=Super soup pot  |Reward=Mythril Ring, 3,000 gil
--   1. Speak to Naruru to begin this quest. She cannot find her Super soup pot
--      and wants you to bring her a new one from the Culinarians' Guild.
--   2. Return to her with it.
--
-- CSIDS DECODED, NOT GUESSED. Naruru is 17780757 (zone 245 idx 917). She holds
-- a lot of events; csidmsg.load() gives the block's csid->entry offsets
-- {98:4, 34:31, 16:32, 32:55, 35:56, 189:57, 188:58, 186:159, 187:175, 29:275,
-- 31:276, 71:287, 72:298, 10053:549, 10094:577}, and find_msg against
-- `xi-dat dialog 245` isolates this quest's three:
--   188 -> 7330/7331/7333/7334  THE OFFER. 7330 is the accept prompt: "Will you
--          do Naruru this favor? ${selection-lines} Of course. / I can't right
--          now." -- the affirmative is FIRST, so OPTION 0 ACCEPTS, and 7333 is
--          the decline ("Well, I hope you change your mind."). 7334 states the
--          errand: "could you go grab me ${keyitem-article: 7[2]} just like my
--          old one".
--   186 -> 7332  the reminder, which is also the directions: "I think the
--          Culinarians' Guild in Windurst should have ${keyitem-article: 7[2]}."
--   187 -> 7335-7337  THE TURN-IN. 7335 "It turned out my ${keyitem-singular:
--          7[2]} had a big hole in it!", 7336 "Now, here's a little something
--          for your trouble."
--
-- THE KEY ITEM IS PARAM 7, not param 0 -- every message above spells it
-- ${...: 7[2]}. Worth stating because the id (57) also appears at data[2] in the
-- block's own table, so it is partly self-supplied; passing it explicitly at
-- slot 7 is what the messages actually read.
--
-- ITEM RESOLUTION: bg-wiki's "Super soup pot" is NOT in item_basic at all -- it
-- is a KEY item, xi.ki.SUPER_SOUP_POT (57). Grepping item_basic alone reports it
-- absent, which is exactly the false negative that had this quest deferred;
-- tools/coverage/resolve_item.py exists to stop that recurring. The reward
-- Mythril Ring is a normal item, MYTHRIL_RING (13446).
--
-- WHY THERE IS NO onTrade: the soup pot is a key item, so it cannot be traded.
-- The turn-in fires on possession instead.
-----------------------------------

local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.COOKS_PRIDE)

quest.reward =
{
    item = xi.item.MYTHRIL_RING,
    gil  = 3000,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.THE_WONDER_MAGIC_SET)
        end,

        [xi.zone.LOWER_JEUNO] =
        {
            ['Naruru'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(188, { [7] = xi.ki.SUPER_SOUP_POT })
                end,
            },

            onEventFinish =
            {
                [188] = function(player, csid, option, npc)
                    -- 7330: 0 "Of course.", 1 "I can't right now."
                    if option == 0 then
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

        [xi.zone.LOWER_JEUNO] =
        {
            ['Naruru'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.SUPER_SOUP_POT) then
                        return quest:progressEvent(187, { [7] = xi.ki.SUPER_SOUP_POT })
                    end

                    return quest:event(186, { [7] = xi.ki.SUPER_SOUP_POT })
                end,
            },

            onEventFinish =
            {
                [187] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.SUPER_SOUP_POT)
                    end
                end,
            },
        },
    },
}

return quest
