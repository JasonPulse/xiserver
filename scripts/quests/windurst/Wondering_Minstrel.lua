-----------------------------------
-- Wondering Minstrel
-----------------------------------
-- Log ID: 2, Quest ID: 6
-- Jatan-Paratan : Windurst Waters North (F-10), entity 17752143
-- Yuli_Yaam     : Windurst Waters, entity 17752144
-- Yung_Yaam     : Windurst Waters, entity 17752145
-- Aramu-Paramu  : Windurst Waters, entity 17752142
-- Ruslan        : Lower Jeuno (I-8), entity 17780768
-- !addquest 2 6
-----------------------------------
-- Retail (bg-wiki "Wondering Minstrel").
-- |Start=Jatan-Paratan, Windurst Waters North (F-10)  |Fame=Windurst  |FLevel=5
-- |Item Reqs=Rosewood Lumber  |Reward=Faerie Piccolo
-- |Title=Down Piper Pipe-upperer
--   1. In Windurst Waters (North), go into the Timbre Timbers tavern (F-10) and
--      speak to Yuli Yaam, Yung Yaam, then Jatan-Paratan.
--      "Respond with 'I have no recollection at all' to continue, then speak with
--      him again. The quest will now appear in your quest log."
--   2. Speak to Aramu-Paramu.
--   3. Head to Lower Jeuno and speak to Ruslan (I-8) in the Merry Minstrel tavern.
--   4. Trade a piece of Rosewood Lumber to Jatan-Paratan for your reward.
--
-- CSIDS DECODED, NOT GUESSED. Jatan-Paratan is 17752143 -> zone 238 idx 79
-- (0x010EE04F) with his neighbours on the surrounding indices, and Ruslan is
-- 17780768 -> zone 245 idx 32. Windurst's and Jeuno's dialog dumps need no offset
-- correction, unlike the Adoulin zones. The quest csid was pinned by CONTENT rather
-- than by guessing: `xi-dat find "no recollection"` lands on
-- Windurst_Waters[8906], which is bg-wiki's exact required response, and 8906 sits
-- inside csid 633. From there csidscan.py against `xi-dat dialog 238`/`245`:
--   Yung Yaam    636 -> 8919-8921  "a barrrd from Jeuno came herrre to stay forrr a
--          spell... everrr since that barrrd arrrrived, Jatan-Paratan has been
--          acting all strrrange."
--   Yuli Yaam    637 -> 8922/8923  "I worrrry about Jatan-Paratan lately. He only
--          performs quiet numbers now... he used to play cheerful tunes."
--   Jatan 633 -> 8905-8912  THE OPINION PROMPT. 8906: "How did you like his
--          performance? ${selection-lines} It was like music to my ears. / Face the
--          music! It wasn't so good. / I have no recollection at all." -- bg-wiki
--          requires the THIRD line, so OPTION 2 is the one that advances; 8911/8912
--          are his reply to it ("as a restaurant performer, it is the greatest of
--          praises").
--   Jatan 634 -> 8913-8917  THE CONFESSION, which is what puts the quest in the log:
--          8915 "I just love the tastes and atmosphere of this restaurant", 8916
--          "I simply forced the proprietor into allowing me to have a position
--          here. Alas...but then...", 8917 "I'm sorry. I don't know what came over
--          me... Please forget it."
--   Jatan 635 -> 8918       the one-line version of that retraction.
--   Aramu-Paramu 683 -> 8924/8925  "That bard who came from Jeuno the other day
--          appears to be an old traveling companion of his."
--   Ruslan 10008 -> 6733    his intro before you raise Jatan-Paratan.
--   Ruslan 10009 -> 6734-6740  THE ASK. 6734 "I know a Jatan-Paratan, as a matter of
--          fact", 6739 "You say the great Jatan-Paratan is worried? I think I know
--          what troubles him", and 6740 "Find ${article} ${item-article: 1[2]}, and
--          present it to him. Seeing that may rekindle the enthusiasm of his younger
--          days." -- the lumber is param 1.
--   Ruslan 10010 -> 6741/6742  his reminder.
--   Ruslan 10011 -> 6743/6744  after the quest: "Perhaps it would behoove me to
--          rethink the true meaning of music."
--   Jatan 638 -> 8926-8940  THE TURN-IN. 8927 "Don't tell me you traveled all the way
--          to Jeuno to meet Ruslan!", 8933 "he couldn't remember the slightest thing
--          about the restaurant's cooking", 8934 "my flamboyant performance itself
--          was detracting from the tastes and atmosphere of this tavern", 8938 "this
--          was once the goal I sought after. I shall gladly accept it from you.
--          However, let me pay you back with this...", and 8940 "if one were to sell
--          it, it would fetch quite a sum" -- the Faerie Piccolo.
--   Jatan 639 -> 8941-8944  post-completion: "could we kindly keep this between you
--          and me, and not bother Yung and Yuli Yaam with my problems?"
--
-- WHY THE QUEST ONLY ENTERS THE LOG AT 634: bg-wiki is explicit that the log entry
-- appears after you answer 8906 and then speak to him a SECOND time. Everything
-- before that is pre-quest, so the run-up is tracked in a quest var (which is a
-- CharVar keyed by the quest and works before addQuest) rather than by quest status.
--
-- ITEMS: Rosewood Lumber is the container word trap -- item_basic holds it as
-- `piece_of_rosewood_lumber` with sort name `rosewood_lbr.` (which is what bg-wiki's
-- icon shows), and the existing enum is PIECE_OF_ROSEWOOD_LUMBER (718). Note
-- rosewood_log (701) is a DIFFERENT item. Faerie Piccolo already had
-- FAERIE_PICCOLO (17349). Both checked by id.
-----------------------------------

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.WONDERING_MINSTREL)

quest.reward =
{
    item     = xi.item.FAERIE_PICCOLO,
    title    = xi.title.DOWN_PIPER_PIPE_UPPERER,
    fameArea = xi.fameArea.WINDURST,
}

quest.sections =
{
    -- Pre-quest: the tavern regulars, then the opinion prompt, then his confession.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.WINDURST) >= 5
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Yung_Yaam'] =
            {
                onTrigger = function(player, npc)
                    quest:setVar(player, 'Yung', 1)
                    return quest:event(636)
                end,
            },

            ['Yuli_Yaam'] =
            {
                onTrigger = function(player, npc)
                    quest:setVar(player, 'Yuli', 1)
                    return quest:event(637)
                end,
            },

            ['Jatan-Paratan'] =
            {
                onTrigger = function(player, npc)
                    -- Only after both regulars have voiced their worry.
                    if
                        quest:getVar(player, 'Yung') ~= 1 or
                        quest:getVar(player, 'Yuli') ~= 1
                    then
                        return
                    end

                    -- He confesses on the SECOND visit, once 8906 has been answered.
                    if quest:getVar(player, 'Prog') == 1 then
                        return quest:progressEvent(634)
                    end

                    return quest:progressEvent(633)
                end,
            },

            onEventFinish =
            {
                [633] = function(player, csid, option, npc)
                    -- 8906: 0 "It was like music to my ears.", 1 "Face the music!
                    -- It wasn't so good.", 2 "I have no recollection at all."
                    if option ~= 2 then
                        return
                    end

                    quest:setVar(player, 'Prog', 1)
                end,

                [634] = function(player, csid, option, npc)
                    quest:begin(player)
                    quest:setVar(player, 'Prog', 0)
                end,
            },
        },
    },

    -- Accepted: Aramu-Paramu, then Ruslan in Jeuno, then the lumber.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Aramu-Paramu'] =
            {
                onTrigger = function(player, npc)
                    quest:setVar(player, 'Aramu', 1)
                    return quest:event(683)
                end,
            },

            ['Jatan-Paratan'] =
            {
                onTrade = function(player, npc, trade)
                    -- Ruslan has to have named the lumber first.
                    if quest:getVar(player, 'Ruslan') ~= 1 then
                        return
                    end

                    if npcUtil.tradeHasExactly(trade, xi.item.PIECE_OF_ROSEWOOD_LUMBER) then
                        return quest:progressEvent(638, { [1] = xi.item.PIECE_OF_ROSEWOOD_LUMBER })
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(635)
                end,
            },

            ['Yung_Yaam'] = quest:event(636):replaceDefault(),
            ['Yuli_Yaam'] = quest:event(637):replaceDefault(),

            onEventFinish =
            {
                [638] = function(player, csid, option, npc)
                    player:confirmTrade()

                    if quest:complete(player) then
                        quest:setVar(player, 'Yung', 0)
                        quest:setVar(player, 'Yuli', 0)
                        quest:setVar(player, 'Aramu', 0)
                        quest:setVar(player, 'Ruslan', 0)
                    end
                end,
            },
        },

        [xi.zone.LOWER_JEUNO] =
        {
            ['Ruslan'] =
            {
                onTrigger = function(player, npc)
                    -- 10008 is his generic introduction; he only recognises the
                    -- problem once Aramu-Paramu has named him as the old companion.
                    if quest:getVar(player, 'Aramu') ~= 1 then
                        return quest:event(10008)
                    end

                    if quest:getVar(player, 'Ruslan') == 1 then
                        return quest:event(10010, { [1] = xi.item.PIECE_OF_ROSEWOOD_LUMBER })
                    end

                    return quest:progressEvent(10009, { [1] = xi.item.PIECE_OF_ROSEWOOD_LUMBER })
                end,
            },

            onEventFinish =
            {
                [10009] = function(player, csid, option, npc)
                    quest:setVar(player, 'Ruslan', 1)
                end,
            },
        },
    },

    -- Completed: his request to keep it between the two of you, and Ruslan's rethink.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Jatan-Paratan'] = quest:event(639):replaceDefault(),
        },

        [xi.zone.LOWER_JEUNO] =
        {
            ['Ruslan'] = quest:event(10011):replaceDefault(),
        },
    },
}

return quest
