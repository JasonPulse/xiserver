-----------------------------------
-- Family Ties
-----------------------------------
-- Log ID: 8, Quest ID: 34
-- Teigero-Bangero : Abyssea - Vunkerl (E-7), entity 17666765
-- Naruru          : Abyssea - Attohwa, entity 17658619
-- Panta-Putta     : Abyssea - Misareaux, entity 17662777
-- !addquest 8 34
-----------------------------------
-- Retail (bg-wiki "Family Ties").
-- |Start=Teigero-Bangero (A) (E-7), Abyssea - Vunkerl  |Fame=avun |FLevel=4
-- |Previous=For Want of a Pot  |Repeatable= (blank, so once only)
-- |Reward=Taru Tot Toyset. Optional: Jester's Hat
--   "The quest For Want of a Pot in Abyssea - Attohwa must be completed in order to
--    start this quest. That being said, fame level 3 in Abyssea - Attohwa is also
--    required."
--   1. "Speak to Teigero-Bangero (A) at (E-7) to begin the quest. You will receive a
--      KI Smudged letter."
--   2. "Travel to Abyssea - Attohwa and deliver the KI Smudged letter to Naruru (A)
--      at the entrance. She will give you a KI Yellow linkpearl."
--   3. "Return to Teigero-Bangero (A) in Abyssea - Vunkerl and speak to him to
--      complete the quest."
--   Further, optional rewards:
--   4. "Trade Panta-Putta (A) in Abyssea - Misareaux the Taru Tot Toyset to receive a
--      KI Jester's hat. The Taru Tot Toyset will not be lost."
--   5. "Finally return to Naruru (A) in Abyssea - Attohwa to trade the KI Jester's hat
--      for a Jester's Hat."
--
-- CSIDS DECODED, NOT GUESSED. Per-csid attribution from each entity's byte ranges:
--   Teigero-Bangero 1083 -> 8421/8422  his idle lament, "My beloved Naruru... My
--          dearest little Panta-Putta..."
--   Teigero-Bangero 1084 -> 8421-8427  THE OFFER. 8426 is the two-way menu ("Just a
--          little..." / "I'd rather not."), 8427 "Hand over the lettaru, you say, and
--          you'll deliver it for me?"
--   Teigero-Bangero 1085 -> 8430  the reminder, "Any luck with that letter, friend?"
--   Teigero-Bangero 1086 -> 8430-8436  THE TURN-IN, the linkpearl call itself:
--          "You delivered the letter? Get outaru of here!" through "But what of our
--          precious-wecious Panta-Putta? ...Safe in Jeuno, you say!?"
--   Teigero-Bangero 1087 -> 8439  his post-completion thanks.
--   Naruru 395 -> 8375/8376  THE DELIVERY. "What's this? A letter?" / "Why,
--          whoever-wever could it be from?"
--   Naruru 373 -> 8384/8385  the optional hat exchange, "you're back? Why, whatever
--          is that you have with you?"
--   Naruru 374 -> 8397-8399  her line as she gives the hat up, "The hat, you can keep.
--          Panta-Putta always said he wanted to be an adventurer when he grew up."
--   Panta-Putta 259 -> his single 16-byte block, the toyset exchange.
--
-- NARURU'S 366-372 ARE A DIFFERENT QUEST. They decode to the stewpot chain (8241
-- "I seem to have misplaced my favoritaru stewpot", 8246 "I'd recognize my favorite
-- stewpot anywhere!"), which is For Want of a Pot, this quest's |Previous=. They are
-- deliberately untouched here.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.FAMILY_TIES)

quest.reward =
{
    item     = xi.item.TARU_TOT_TOYSET,
    fameArea = xi.fameArea.ABYSSEA_VUNKERL,
}

quest.sections =
{
    -- bg-wiki gates on the previous quest AND on Attohwa fame 3, not Vunkerl's.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.FOR_WANT_OF_A_POT) and
                player:getFameLevel(xi.fameArea.ABYSSEA_ATTOHWA) >= 3
        end,

        [xi.zone.ABYSSEA_VUNKERL] =
        {
            ['Teigero-Bangero'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(1084)
                end,
            },

            onEventFinish =
            {
                [1084] = function(player, csid, option, npc)
                    -- 8426's second line, "I'd rather not.", declines.
                    if option ~= 0 then
                        return
                    end

                    quest:begin(player)
                    npcUtil.giveKeyItem(player, xi.ki.SMUDGED_LETTER)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_VUNKERL] =
        {
            ['Teigero-Bangero'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.YELLOW_LINKPEARL) then
                        return quest:progressEvent(1086)
                    end

                    return quest:event(1085)
                end,
            },

            onEventFinish =
            {
                [1086] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.YELLOW_LINKPEARL)
                    end
                end,
            },
        },

        [xi.zone.ABYSSEA_ATTOHWA] =
        {
            ['Naruru'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.SMUDGED_LETTER) then
                        return quest:progressEvent(395, xi.ki.SMUDGED_LETTER)
                    end
                end,
            },

            onEventFinish =
            {
                [395] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.SMUDGED_LETTER)
                    npcUtil.giveKeyItem(player, xi.ki.YELLOW_LINKPEARL)
                end,
            },
        },
    },

    -- The optional hat chain runs entirely after completion.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_VUNKERL] =
        {
            ['Teigero-Bangero'] = quest:event(1087):replaceDefault(),
        },

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['Panta-Putta'] =
            {
                onTrade = function(player, npc, trade)
                    if
                        player:hasKeyItem(xi.ki.JESTERS_HAT) or
                        not npcUtil.tradeHasExactly(trade, xi.item.TARU_TOT_TOYSET)
                    then
                        return
                    end

                    return quest:progressEvent(259, xi.item.TARU_TOT_TOYSET)
                end,
            },

            onEventFinish =
            {
                [259] = function(player, csid, option, npc)
                    -- bg-wiki: "The Taru Tot Toyset will not be lost", so the trade
                    -- is deliberately never confirmed.
                    npcUtil.giveKeyItem(player, xi.ki.JESTERS_HAT)
                end,
            },
        },

        [xi.zone.ABYSSEA_ATTOHWA] =
        {
            ['Naruru'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.JESTERS_HAT) then
                        return quest:progressEvent(373, xi.ki.JESTERS_HAT)
                    end
                end,
            },

            onEventFinish =
            {
                [373] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.JESTERS_HAT)
                    npcUtil.giveItem(player, xi.item.JESTERS_HAT)
                end,
            },
        },
    },
}

return quest
