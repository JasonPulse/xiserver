-----------------------------------
-- Boreal Blossoms
-----------------------------------
-- Log ID: 8, Quest ID: 72
-- Oruga      : Abyssea - Uleguerand (K-9), entity 17814109
-- Frostbloom : Abyssea - Uleguerand, entities 17814110 / 17814111 / 17814112
-- !addquest 8 72
-----------------------------------
-- Retail (bg-wiki "Boreal Blossoms").
-- |Start=Oruga (A), Abyssea - Uleguerand  |Repeatable=Yes  |Fame=aule  |FLevel=1
-- |Reward=First time completion: 400 Cruor
--   1. Talk to Oruga (A) to start. "She is at (K-9) south (through the tunnel) at
--      Conflux #5 near the fire."
--   2. She asks you to procure three Frostblooms.
--   3. "There are three areas that they can be obtained, and at each one there are
--      three spawn points nearby." Frostbloom #1 at G-8 eastern edge, #2 at G-8
--      left edge, #3 at G-6 upper left corner.
--   4. Return to Oruga (A) after collecting three to complete the quest.
--   "Zoning is required in order to repeat this quest."
--
-- CSIDS DECODED, NOT GUESSED. Oruga is 17814109 -> zone 253 idx 605 (0x010FD25D)
-- and the three Frostblooms sit on the next three indices. `xi-dat events 253`
-- gives Oruga 304, 305, 306, 310, 311, 312 and all three Frostblooms the SAME csid,
-- 308. Resolved with csidscan.py against `xi-dat dialog 253`:
--   304 -> 7980       her idle line ("Of all the times to run out o' salve...").
--   305 -> 7980-7993  THE OFFER. 7982 "I be searchin' for a flower that blooms
--          forth from the deepest, chillest snow. This be the key ingredient in the
--          salve we survivors use to ease frostbite", 7984 is the accept prompt:
--          "Aye? ${selection-lines} Aye. / Sorry, I don't speak pirate." -- the
--          affirmative is the FIRST line, so OPTION 0 ACCEPTS, and 7986 is the
--          decline. 7990 carries the request: "I be lookin' for a suitable quantity
--          o' ${keyitem-plural: 0[2]}. Three or there'bouts should suffice."
--   306 -> 7989/7990  the reminder, the request without the reminiscing.
--   310 -> 7996-7998  THE TURN-IN. "They be ${keyitem-plural: 0[2]}. And three o'
--          them, no less." / 7998 "Take this, and may fair winds blow at yer back."
--   311 -> 7999       her post-completion line about blossoms in the chill.
--   312 -> 7985/7986 + 7989/7990 + 8000  the repeat offer, behind 8000
--          "${name-player}. I be needin' yer aid again. Ye savvy?"
--   Frostbloom 308 -> 7994 "A bright red flower blooms brilliantly atop the pure
--          white snow." and 7995 "No ${keyitem-singular: 0[2]} remains here."
--
-- THREE BLOOMS MEANS THREE DISTINCT KEY ITEMS, NOT A COUNTER. key_item.lua has
-- FROSTBLOOM1 (1758), FROSTBLOOM2 (1759) and FROSTBLOOM3 (1760) as separate ids, and
-- bg-wiki describes three separate AREAS rather than three picks from one patch --
-- which is why progress is three key items rather than a tally, and why picking the
-- same area twice cannot advance the quest. The three entities share csid 308
-- precisely because the KI is a param rather than baked into the event.
--
-- The bloom is param 0 on 308 so that 7994/7995 name the right one at each area.
-----------------------------------
local uleguerandID = zones[xi.zone.ABYSSEA_ULEGUERAND]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.BOREAL_BLOSSOMS)

local cruorReward = 400

-- Frostbloom entity -> the key item that area yields.
local bloomKeyItem =
{
    [17814110] = xi.ki.FROSTBLOOM1,
    [17814111] = xi.ki.FROSTBLOOM2,
    [17814112] = xi.ki.FROSTBLOOM3,
}

local allBlooms = { xi.ki.FROSTBLOOM1, xi.ki.FROSTBLOOM2, xi.ki.FROSTBLOOM3 }

local hasAllBlooms = function(player)
    for _, ki in ipairs(allBlooms) do
        if not player:hasKeyItem(ki) then
            return false
        end
    end

    return true
end

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_ULEGUERAND,
}

quest.sections =
{
    -- COMPLETED is accepted because |Repeatable=Yes, and bg-wiki requires a zone in
    -- between. 312 is her re-offer.
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE or
                    status == xi.questStatus.QUEST_COMPLETED) and
                not quest:getMustZone(player)
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Oruga'] =
            {
                onTrigger = function(player, npc)
                    if player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.BOREAL_BLOSSOMS) then
                        return quest:progressEvent(312, { [0] = xi.ki.FROSTBLOOM1 })
                    end

                    return quest:progressEvent(305, { [0] = xi.ki.FROSTBLOOM1 })
                end,
            },

            onEventFinish =
            {
                [305] = function(player, csid, option, npc)
                    -- 7984: 0 "Aye.", 1 "Sorry, I don't speak pirate."
                    if option ~= 0 then
                        return
                    end

                    quest:begin(player)
                end,

                [312] = function(player, csid, option, npc)
                    if option ~= 0 then
                        return
                    end

                    player:addQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.BOREAL_BLOSSOMS)
                end,
            },
        },
    },

    -- Accepted: one bloom from each of the three areas, then back to Oruga.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Frostbloom'] =
            {
                onTrigger = function(player, npc)
                    local ki = bloomKeyItem[npc:getID()]
                    if ki == nil then
                        return
                    end

                    return quest:progressEvent(308, { [0] = ki })
                end,
            },

            ['Oruga'] =
            {
                onTrigger = function(player, npc)
                    if hasAllBlooms(player) then
                        return quest:progressEvent(310, { [0] = xi.ki.FROSTBLOOM1 })
                    end

                    return quest:event(306, { [0] = xi.ki.FROSTBLOOM1 })
                end,
            },

            onEventFinish =
            {
                [308] = function(player, csid, option, npc)
                    local ki = bloomKeyItem[npc:getID()]

                    -- 7995 "No ... remains here." is the already-picked branch, so
                    -- nothing is granted a second time.
                    if ki ~= nil and not player:hasKeyItem(ki) then
                        npcUtil.giveKeyItem(player, ki)
                    end
                end,

                [310] = function(player, csid, option, npc)
                    for _, ki in ipairs(allBlooms) do
                        player:delKeyItem(ki)
                    end

                    if quest:complete(player) then
                        player:addCurrency('cruor', cruorReward)
                        player:messageSpecial(uleguerandID.text.CRUOR_OBTAINED, cruorReward, player:getCurrency('cruor'))
                        xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.BOREAL_BLOSSOMS)
                    end
                end,
            },
        },
    },

    -- Completed: 7999, the blossoms as a message to never give up.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Oruga'] = quest:event(311):replaceDefault(),
        },
    },
}

return quest
