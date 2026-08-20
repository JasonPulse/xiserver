-----------------------------------
-- An Offer You Can't Refuse
-----------------------------------
-- Log ID: 8, Quest ID: 43
-- Garnev : Abyssea - Attohwa (F-9), entity 17658614
-- !addquest 8 43
-----------------------------------
-- Retail (bg-wiki "An Offer You Can't Refuse").
-- |Start=Garnev (A) (F-9), Abyssea - Attohwa  |Repeatable=Yes  |Previous= none
-- |Reward=Elite Beret with random augment
--   1. Speak to Garnev (A) in Abyssea - Attohwa (F-9), at Veridical Conflux #00.
--   2. Trade a Malachite to Garnev (A) for your reward and to complete the quest.
--      Malachite comes from Gold Sturdy Pyxis and Attohwa NMs like Maahes.
--   "Zoning is required to repeat this quest."
--
-- CSIDS DECODED, NOT GUESSED. Garnev is 17658614; (17658614-16777216) = 881398,
-- 881398//4096 = 215 rem 758 -> Abyssea - Attohwa, 0x010D72F6. `xi-dat events 215`
-- gives him exactly five: 343, 344, 345, 346, 347. Resolved with csidscan.py
-- against `xi-dat dialog 215`:
--   343 -> 8140       "What am I doing here, you ask? I could ask you the same.
--          Now get lost, stranger." -- his pre-quest brush-off.
--   344 -> 8141-8150  THE OFFER. 8142 "I'm looking to make a transaction. For
--          ${item-plural: 0[2]}, to be precise", 8147 "our intelligence reports
--          say that ${item-plural: 0[2]} can be found inside the pyxides",
--          closing on 8150 "Track down one of those ${item-plural: 0[2]} and
--          bring it back to me". The item is param 0, and there is no ${number:}
--          slot anywhere in the block -- which is why this asks for exactly one.
--   345 -> 8147/8148/8150  the reminder, the same request without the preamble.
--   346 -> 8151/8152  THE TURN-IN. "Let's see that. Hmm, yes, ${article}
--          ${item-article: 0[2]}, there's no mistaking it. Looks like we have a
--          deal." / "doing business with me is well worth your while."
--   347 -> 8152       the post-completion line.
--
-- ITEM: bg-wiki calls it "Malachite"; item_basic's name is `piece_of_malachite`
-- (2951) with `malachite` only as its sort name -- the same trap as
-- torigashiranotachi and vial_of_tincture. Checked by id, added as
-- PIECE_OF_MALACHITE after confirming 2951 was unused. Note item 9856
-- `malachite_crystal` is a different item and is not accepted.
--
-- REWARD STRUCTURE (owner-supplied, from FFXIclopedia/BG-Wiki community tracking;
-- bg-wiki's own page states only "Elite Beret with random augment"):
--   * The Elite Beret itself is GUARANTEED -- 100% on every turn-in.
--   * Its augment rolls a combination from a fixed pool:
--       HP +1..7, MP +1..7, Conserve MP +1..4, INT +1..5, Magic Crit. Hit Rate +1..5
--     The pool and its caps are known; the exact statistical WEIGHTS are not, so
--     the selection below is deliberately simple and is flagged as unverified
--     rather than dressed up as researched. It is the one part of this file that
--     is a modelling choice rather than decoded data.
--   * Separately, ~20-25% overall to also receive one Empyrean head seal, split
--     evenly between four jobs at ~5% each: Goetia (BLM), Iga (NIN), Lancer's
--     (DRG), Navarch's (COR). Rolled as four independent 5% checks that stop at
--     the first hit, so at most one seal is ever granted, matching "0 or 1".
--
-- AUGMENT IDS come from `augments.sql` (augmentId -> modId), not from mod ids
-- directly -- they are separate id spaces. HP+1 = 1, MP+1 = 9, Conserve MP+1 =
-- 141, INT+1 = 516, Magic crit. hit rate+1% = 57. addItem's augment table sets
-- the magnitude, per lua_baseentity.cpp:4059.
-----------------------------------
local attohwaID = zones[xi.zone.ABYSSEA_ATTOHWA]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.AN_OFFER_YOU_CANT_REFUSE)

-- augmentId -> { min, max }. augmentIds are from augments.sql; see header.
local augmentPool =
{
    { augment =   1, min = 1, max = 7 }, -- HP
    { augment =   9, min = 1, max = 7 }, -- MP
    { augment = 141, min = 1, max = 4 }, -- Conserve MP
    { augment = 516, min = 1, max = 5 }, -- INT
    { augment =  57, min = 1, max = 5 }, -- Magic Crit. Hit Rate
}

local headSeals =
{
    xi.item.GOETIA_SEAL_HEAD,   -- Black Mage
    xi.item.IGA_SEAL_HEAD,      -- Ninja
    xi.item.LANCERS_SEAL_HEAD,  -- Dragoon
    xi.item.NAVARCHS_SEAL_HEAD, -- Corsair
}

local sealChance = 5 -- percent, per job; ~20% overall across the four

quest.sections =
{
    -- bg-wiki lists no |Previous= and no |Quest Reqs=, so availability is
    -- unqualified. COMPLETED is accepted because |Repeatable=Yes.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE or
                status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_ATTOHWA] =
        {
            ['Garnev'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(344, { [0] = xi.item.PIECE_OF_MALACHITE })
                end,
            },

            onEventFinish =
            {
                [344] = function(player, csid, option, npc)
                    if player:getQuestStatus(xi.questLog.ABYSSEA, xi.quest.id.abyssea.AN_OFFER_YOU_CANT_REFUSE) == xi.questStatus.QUEST_COMPLETED then
                        player:addQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.AN_OFFER_YOU_CANT_REFUSE)
                    else
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    -- Accepted: he wants one Malachite.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_ATTOHWA] =
        {
            ['Garnev'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.PIECE_OF_MALACHITE) then
                        return quest:progressEvent(346, { [0] = xi.item.PIECE_OF_MALACHITE })
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(345, { [0] = xi.item.PIECE_OF_MALACHITE })
                end,
            },

            onEventFinish =
            {
                [346] = function(player, csid, option, npc)
                    -- One free slot for the beret, plus one for a possible seal.
                    if player:getFreeSlotsCount() == 0 then
                        player:messageSpecial(attohwaID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.ELITE_BERET)
                        return
                    end

                    player:confirmTrade()

                    local roll = augmentPool[math.random(#augmentPool)]

                    player:addItem(
                    {
                        id       = xi.item.ELITE_BERET,
                        augments = { [roll.augment] = math.random(roll.min, roll.max) },
                    })

                    player:messageSpecial(attohwaID.text.ITEM_OBTAINED, xi.item.ELITE_BERET)

                    -- At most one seal: stop at the first hit.
                    for _, seal in ipairs(headSeals) do
                        if math.random(100) <= sealChance then
                            npcUtil.giveItem(player, seal)
                            break
                        end
                    end

                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
