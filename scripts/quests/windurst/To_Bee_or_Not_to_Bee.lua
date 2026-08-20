-----------------------------------
-- To Bee or Not to Bee?
-----------------------------------
-- Log ID: 2, Quest ID: 35
-- Raamimi          : Windurst Walls (F-7), entity 17756213
-- Zayhi-Bauhi      : Windurst Walls, entity 17756210
-- Rutango-Botango  : Windurst Walls, entity 17756211
-- Kalupa-Tawalupa  : Windurst Walls, entity 17756212
-- !addquest 2 35
-----------------------------------
-- Retail (bg-wiki "To Bee or Not to Bee?").
-- |Start=Raamimi, Windurst Walls (F-7)  |Previous=The Postman Always K.O.s Twice
-- |Fame=Windurst  |FLevel=2  |Quest Reqs=Honey x4  |Reward=Mulsum x3
--   1. "If Zayhi-Bauhi speaks normally rather than coughing, try speaking to
--      Kalupa-Tawalupa and Rutango-Botango in front of him to receive the quest."
--   2. Speak to Raamimi to receive Honey.
--   3. Trade Honey to Zayhi-Bauhi, then speak to Kalupa-Tawalupa and
--      Rutango-Botango.
--   4. Trade 4 more Honey, one at a time, to Zayhi-Bauhi.
--   5. Return to Raamimi to receive 3 Mulsum.
--
-- CSIDS DECODED, NOT GUESSED. Raamimi is 17756213 -> zone 239 idx 53 (0x010EF035),
-- with the old speaker and his two pupils on the three preceding indices. `xi-dat
-- events 239` plus csidscan.py against `xi-dat dialog 239` gives a clean five-stage
-- progression -- Windurst's dialog dump needs no offset correction, unlike the
-- Adoulin zones:
--   Zayhi-Bauhi 61 -> 7243/7244  HIS NORMAL SPEECH, before he loses his voice: "That
--          we can now live here in peace...under the blessed shadow of the Great Star
--          Tree...is all thanks to the great hero, Karaha-Baruha...!" This is exactly
--          bg-wiki's "If Zayhi-Bauhi speaks normally rather than coughing".
--   Zayhi-Bauhi 64 -> 7247/7248  the collapse: "Ha-hummm...we...arrrk...owe...our...
--          <Cough>...peace..." -- he has lost his voice.
--   Rutango 65 -> 7249  "The great, old teacher has lost his voice before he could
--          deliver his famous public speech!"
--   Kalupa  66 -> 7250  "Are you all right, sir? Don't try and force yourself."
--   Raamimi 67 -> 7251/7252  THE OFFER, and where the first honey comes from: "I
--          guess this will have to make do... Here, give the old gent this."
--   Raamimi 68 -> 7253  the reminder: "If he swallows some of that honey, honey, it
--          should fix his sore throat right up."
--   Zayhi 70 -> 7254, Rutango 71 -> 7255, Kalupa 72 -> 7256  AFTER THE FIRST HONEY.
--          7256 "did that honey help you to talk a little just now? Then it must be
--          effective. Quick, bring him as much honey as we can find!"
--   Zayhi 73 -> 7257  "That's a little better... Quick! Need more honey!"
--   Zayhi 74 -> 7258  "Feels like it's getting a lot better! But there's still some
--          irritation..." -- the last honey before the toothache.
--   csid 75 -> 7259-7266  THE PAYOFF, and it is a GROUP scene: all three entities own
--          csid 75 and each carries its own lines of it (Zayhi 7259/7262/7263/7264
--          "My...tooth... / ...hurths...!", Kalupa 7260/7265 "Your tooth...?",
--          Rutango 7261/7266 "Hurts...?"). Fired from Zayhi-Bauhi, who holds the most
--          of it.
--   Rutango 76 -> 7267/7268  he recites the speech from memory and mangles it: "That
--          we can now leave here in pieces...under the messed shadow of the Grated
--          Star Tree...easel tanks to the great zero, Kalhua-Milkhua...!"
--   Kalupa  77 -> 7269  "a tooth-ache or two is to be expected when you go around
--          eating that much honey."
--   Zayhi   78 -> 7270  "Ouch...! My tooth hurths..."
--   Raamimi 80 -> 7272/7273  THE TURN-IN. "Just how much honey did you give the old
--          guy? He must have sure enjoyed that honey if he ate so much it rotted his
--          teeth!" / "Here, these will cheer you up..." -- the Mulsum.
--   Raamimi 79 -> 7271  her post-completion line.
--
-- FIVE HONEY, NOT FOUR. bg-wiki's |Quest Reqs= says Honey x4 while the walkthrough
-- says trade one, then "4 more...one at a time" -- those agree: Raamimi supplies the
-- first (7252), so the player only has to find four. The counter below runs 0..5 for
-- what the speaker has swallowed, which is what the dialogue stages key on.
--
-- ITEMS: both are the container word trap -- item_basic holds them as
-- `pot_of_honey` (4370) and `bottle_of_mulsum` (4156), and both enums already
-- existed as POT_OF_HONEY and BOTTLE_OF_MULSUM. Checked by id, not by name.
--
-- PREREQUISITE: The Postman Always K.O.s Twice IS implemented, in
-- scripts/zones/Windurst_Walls/npcs/Ambrosius.lua -- it is an older-style NPC file
-- rather than an Interaction Framework quest, which is why a file-based coverage
-- scan reports it missing. The gate below is therefore live, not aspirational.
-----------------------------------

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.TO_BEE_OR_NOT_TO_BEE)

local honeyNeeded = 5 -- Raamimi supplies the first; the player finds four

quest.reward =
{
    item     = { { xi.item.BOTTLE_OF_MULSUM, 3 } },
    fameArea = xi.fameArea.WINDURST,
}

quest.sections =
{
    -- Available: the pupils fussing over the speaker is what flags it, per bg-wiki.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.WINDURST, xi.quest.id.windurst.THE_POSTMAN_ALWAYS_KOS_TWICE) and
                player:getFameLevel(xi.fameArea.WINDURST) >= 2
        end,

        [xi.zone.WINDURST_WALLS] =
        {
            -- 61 is his normal speech; 64 is the collapse that starts the story.
            ['Zayhi-Bauhi'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Prog') == 0 then
                        quest:setVar(player, 'Prog', 1)
                        return quest:event(61)
                    end

                    return quest:event(64)
                end,
            },

            ['Rutango-Botango'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(65)
                end,
            },

            ['Kalupa-Tawalupa'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(66)
                end,
            },

            ['Raamimi'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(67)
                end,
            },

            onEventFinish =
            {
                [67] = function(player, csid, option, npc)
                    quest:begin(player)
                    quest:setVar(player, 'Prog', 0)
                    quest:setVar(player, 'Honey', 0)

                    -- 7252: "Here, give the old gent this."
                    npcUtil.giveItem(player, xi.item.POT_OF_HONEY)
                end,
            },
        },
    },

    -- Accepted: feed the speaker honey until his voice returns -- and his tooth goes.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.WINDURST_WALLS] =
        {
            ['Zayhi-Bauhi'] =
            {
                onTrade = function(player, npc, trade)
                    local fed = quest:getVar(player, 'Honey')

                    if fed >= honeyNeeded then
                        return
                    end

                    if not npcUtil.tradeHasExactly(trade, xi.item.POT_OF_HONEY) then
                        return
                    end

                    player:confirmTrade()
                    fed = fed + 1
                    quest:setVar(player, 'Honey', fed)

                    -- The stages the dialogue itself lays out.
                    if fed >= honeyNeeded then
                        return quest:event(75)   -- the toothache group scene
                    elseif fed == honeyNeeded - 1 then
                        return quest:event(74)   -- "getting a lot better"
                    elseif fed == 1 then
                        return quest:event(70)   -- "Ack...what's this?"
                    end

                    return quest:event(73)       -- "a little better...more!"
                end,

                onTrigger = function(player, npc)
                    local fed = quest:getVar(player, 'Honey')

                    if fed >= honeyNeeded then
                        return quest:event(78)
                    elseif fed == 0 then
                        return quest:event(64)
                    end

                    return quest:event(73)
                end,
            },

            ['Rutango-Botango'] =
            {
                onTrigger = function(player, npc)
                    local fed = quest:getVar(player, 'Honey')

                    if fed >= honeyNeeded then
                        return quest:event(76)
                    elseif fed == 0 then
                        return quest:event(65)
                    end

                    return quest:event(71)
                end,
            },

            ['Kalupa-Tawalupa'] =
            {
                onTrigger = function(player, npc)
                    local fed = quest:getVar(player, 'Honey')

                    if fed >= honeyNeeded then
                        return quest:event(77)
                    elseif fed == 0 then
                        return quest:event(66)
                    end

                    return quest:event(72)
                end,
            },

            ['Raamimi'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Honey') >= honeyNeeded then
                        return quest:progressEvent(80)
                    end

                    return quest:event(68)
                end,
            },

            onEventFinish =
            {
                [80] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Honey', 0)
                    end
                end,
            },
        },
    },

    -- Completed: 7271, the square is quieter now.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.WINDURST_WALLS] =
        {
            ['Raamimi'] = quest:event(79):replaceDefault(),
        },
    },
}

return quest
