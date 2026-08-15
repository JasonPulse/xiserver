-----------------------------------
-- Synergistic Support
-----------------------------------
-- Log ID: 1, Quest ID: 91
-- Hildolf : Metalworks (F-8)
-----------------------------------
-- Retail (bg-wiki "Synergistic Support"):
--   1. Speak to Hildolf at (F-8) to learn to create fewell. Fame Bastok 1,
--      previous quest Synergistic Pursuits.
--   2. Trade him a Vial of Slime Oil.
--   3. Choose a type from the list -> receive three of that fewell, quest
--      complete.
-- No title, not repeatable. Retail does keep a post-quest repeatable fewell
-- service, which is csid 977 below.
--
-- CSIDs decoded, not guessed. Hildolf is entity 17748169 (npc_list:28753);
-- (17748169-16777216) = 970953, 970953//4096 = 237 rem 201 -> Metalworks,
-- 0x010ED0C9. Read against `xi-dat dialog 237`:
--   978 -> 7361 "Greetings, and welcome to the Bastokan Institute for
--          Synergistic Research! I am Hildolf, chairman and lead researcher."
--          -- the greeting shown before you own a Synergy Crucible.
--   973 -> the offer, 591 bytes. 7363 "Ah, always a pleasure to encounter a
--          fellow synergist! I see you've been keeping your
--          ${keyitem-singular: 0} in fine fettle.", 7367 "Bring to me ${article}
--          ${item-article: 0} and I will gladly synthesize whichever variety of
--          fewell you desire.", 7368 "What say you? / By all means! / Not today."
--   974 -> 7373, the in-progress reminder, repeating the Slime Oil request.
--   975 -> the trade, 1187 bytes. 7374 "Yes, this is certainly ${article}
--          ${item-article: 0}. There can be no mistaking it.", 7375 "As promised,
--          I shall synthesize for you the fewell you desire. What shall it be?",
--          then 7356 "Obtain fewell? / ${item-singular: 0}. / ... /
--          ${item-singular: 7}. / Perhaps another time." -- the eight-element
--          selection, which is what pins this csid -- then 7359 "Accept fewell?
--          / Yes. / No.", 7376 "Now step back and gaze upon Professor Hildolf's
--          Synthesis 101.", 7377 "Hildolf synthesized ${number: 1}
--          ${item-given-plurality: 1, 0}!"
--   976 -> 7379 "Hm? Running low on fewell again, you say?", 7380 "I sympathize,
--          but ...I leave you to your own devices." -- the post-quest refusal.
--   977 -> the post-quest repeatable service, 916 bytes: 7351 "Well, well...if
--          it isn't my prize pupil!", 7354 "If you are in immediate need of
--          fewell, I could provide you with a supply from my stock.", plus the
--          same 7356 picker.
-- (Synergistic Pursuits, the prerequisite, also lives on this entity: 964, and
-- 966 -> 7345 "And there you have it! Your very own ${keyitem-singular: 0}" is
-- the Synergy Crucible hand-over.)
--
-- The old stub invented 702/703. Both are real programs in Metalworks but belong
-- to 0x010ED030 and 0x010ED02E, and nothing fires them; they are not touched.
-- The stub also skipped the 973 offer entirely and the 7359 confirm step, and
-- treated `option` on a nonexistent csid as the element index.
--
-- The eight fewell item ids the stub hardcoded were CORRECT -- 2784-2791, in
-- sql/item_basic.sql:2755-2762 as orb_of_{fire,ice,wind,earth,lightning,water,
-- light,dark}_fewell -- but no enums existed for them. They have now been added
-- to scripts/enum/item.lua and are used by name here.
--
-- bg-wiki lists no fame, so the stub's 30 is gone.
--
-- Note the prerequisite enum is spelled SYNERGUSTIC_PURSUITS in
-- scripts/globals/quests.lua:215 -- an upstream typo, not one of ours. It is used
-- as spelled so that it resolves.
-----------------------------------
local quest = Quest:new(xi.questLog.BASTOK, xi.quest.id.bastok.SYNERGISTIC_SUPPORT)

-- Order matters: this is the order the eight slots appear in the 7356 picker,
-- which follows the item ids.
local fewell =
{
    xi.item.ORB_OF_FIRE_FEWELL,
    xi.item.ORB_OF_ICE_FEWELL,
    xi.item.ORB_OF_WIND_FEWELL,
    xi.item.ORB_OF_EARTH_FEWELL,
    xi.item.ORB_OF_LIGHTNING_FEWELL,
    xi.item.ORB_OF_WATER_FEWELL,
    xi.item.ORB_OF_LIGHT_FEWELL,
    xi.item.ORB_OF_DARK_FEWELL,
}

local fewellCount = 3

local function fewellParams()
    local params = {}

    for slot, item in ipairs(fewell) do
        params[slot - 1] = item
    end

    return params
end

-- 7377 "Hildolf synthesized ${number: 1} ${item-given-plurality: 1, 0}!"
local function synthesize(player, option)
    local item = fewell[option + 1]

    if item == nil then
        return false
    end

    return npcUtil.giveItem(player, { { item, fewellCount } })
end

quest.sections =
{
    -- Offer. Retail gates on owning a Synergy Crucible, which is what
    -- Synergistic Pursuits grants, so 978 covers the not-yet-a-synergist case.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.METALWORKS] =
        {
            ['Hildolf'] =
            {
                onTrigger = function(player, npc)
                    if
                        not player:hasKeyItem(xi.ki.SYNERGY_CRUCIBLE) or
                        not player:hasCompletedQuest(xi.questLog.BASTOK, xi.quest.id.bastok.SYNERGUSTIC_PURSUITS)
                    then
                        return quest:event(978)
                    end

                    return quest:progressEvent(973, { [0] = xi.item.VIAL_OF_SLIME_OIL })
                end,
            },

            onEventFinish =
            {
                -- 7368 "What say you? / By all means! / Not today."
                [973] = function(player, csid, option, npc)
                    if option == 0 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    -- Accepted: waiting on the Slime Oil.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.METALWORKS] =
        {
            ['Hildolf'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(974, { [0] = xi.item.VIAL_OF_SLIME_OIL })
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.VIAL_OF_SLIME_OIL) then
                        return quest:progressEvent(975, fewellParams())
                    end
                end,
            },

            onEventFinish =
            {
                [975] = function(player, csid, option, npc)
                    if not synthesize(player, option) then
                        return
                    end

                    player:confirmTrade()
                    quest:complete(player)
                end,
            },
        },
    },

    -- Post-quest: retail keeps supplying fewell for Slime Oil (977), and refuses
    -- with 976 when you turn up empty-handed.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.METALWORKS] =
        {
            ['Hildolf'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(976, { [0] = xi.item.VIAL_OF_SLIME_OIL })
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.VIAL_OF_SLIME_OIL) then
                        return quest:progressEvent(977, fewellParams())
                    end
                end,
            },

            onEventFinish =
            {
                [977] = function(player, csid, option, npc)
                    if synthesize(player, option) then
                        player:confirmTrade()
                    end
                end,
            },
        },
    },
}

return quest
