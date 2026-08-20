-----------------------------------
-- Explosive Endeavors
-----------------------------------
-- Log ID: 8, Quest ID: 5
-- Fontoumant   : Abyssea - La Theine (H-7), entity 17318627
-- Dark_Fissure : Abyssea - La Theine, entities 17318628 / 17318630 / 17318632
-- !addquest 8 5
-----------------------------------
-- Retail (bg-wiki "Explosive Endeavors").
-- |Start=Fontoumant (A), Abyssea - La Theine  |Repeatable=Yes  |Fame=alth
-- |FLevel=3  |Reward=240 Cruor
--   1. Speak to Fontoumant (A) at (H-7), Veridical Conflux #04, to begin.
--   2. "You will be given Anti-Abyssean grenade #01, #02, #03."
--   3. "Examine the Dark Fissure targetable locations in the canyons at (F-6),
--      (F-7), and (H-6). Select the option 'Attack the darkness!'."
--   4. Return to Fontoumant (A) at (H-7) to complete the quest.
--   "Zoning is required to repeat this quest."
--
-- CSIDS DECODED, NOT GUESSED. Fontoumant is 17318627 -> zone 132 idx 739
-- (0x010842E3). `xi-dat events 132` gives him 178-182, and the three Dark Fissures
-- one csid each: 17318628 -> 183, 17318630 -> 184, 17318632 -> 185. Resolved with
-- csidscan.py against `xi-dat dialog 132`:
--   178 -> 7964       BEFORE HE WILL TALK. "An outsider, are we? I've no time to
--          waste on one who's yet to earn my trust." -- this is bg-wiki's |FLevel=3.
--   181 -> 7965-7979  THE OFFER. 7969 "The fiends surge out from fissures--wounds on
--          the earth's surface--that have opened up in ravines after tremors", 7970
--          is the accept prompt: "Assist with the research? ${selection-lines} I'm
--          at your disposal! / I've prior, less dangerous engagements." -- the
--          affirmative is the FIRST line, so OPTION 0 ACCEPTS, and 7971 is the
--          decline. 7973 "I have created anti-Abyssean grenades, and I would have
--          you test them out at three newly opened fissures" and 7974 "you are to
--          take the grenades and cast one into each fissure."
--   179 -> 7973/7975/7976  the reminder, including 7976 "Forgotten the fissure
--          locations, have you? The first is a stone's throw away from this
--          encampment, and the second and third are located in the ravine west."
--   180 -> 7977       THE TURN-IN. "Take this as recompense for your troubles."
--   182 -> 7978       THE COOLDOWN. "I've yet to finish readying another set of
--          grenades. Return here in a while, if you would." -- which is what
--          bg-wiki's "zoning is required to repeat" gates in practice.
--   Fissures 183/184/185 -> the throw, one csid per fissure.
--
-- THREE GRENADES, ONE PER FISSURE, AS THREE DISTINCT KEY ITEMS. key_item.lua has
-- ANTI_ABYSSEAN_GRENADE_01 (1569), _02 (1570) and _03 (1571) as separate ids and
-- each fissure owns its own csid, so the pairing is fissure-to-grenade rather than a
-- count of three throws -- which is also why the same fissure cannot be bombed
-- twice to finish early.
--
-- The 7979 line ("I've just finished readying a new set of grenades. Might I prevail
-- upon you to assist me again?") is the repeat preamble and sits inside 181, so the
-- offer csid serves both first and repeat runs here rather than there being a
-- separate repeat event.
--
-- bg-wiki notes you may randomly get experience "by defeating a monster" when a bomb
-- is tossed, and says outright it "has no bearing on completing the quest", so it is
-- not modelled.
-----------------------------------
local laTheineID = zones[xi.zone.ABYSSEA_LA_THEINE]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.EXPLOSIVE_ENDEAVORS)

local cruorReward = 240

-- Dark Fissure entity -> { its csid, the grenade it consumes }
local fissures =
{
    [17318628] = { 183, xi.ki.ANTI_ABYSSEAN_GRENADE_01 },
    [17318630] = { 184, xi.ki.ANTI_ABYSSEAN_GRENADE_02 },
    [17318632] = { 185, xi.ki.ANTI_ABYSSEAN_GRENADE_03 },
}

local grenades =
{
    xi.ki.ANTI_ABYSSEAN_GRENADE_01,
    xi.ki.ANTI_ABYSSEAN_GRENADE_02,
    xi.ki.ANTI_ABYSSEAN_GRENADE_03,
}

local allThrown = function(player)
    for _, ki in ipairs(grenades) do
        if player:hasKeyItem(ki) then
            return false
        end
    end

    return true
end

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_LATHEINE,
}

quest.sections =
{
    -- Under the fame bar: 7964, he will not trust you yet.
    {
        check = function(player, status, vars)
            return status ~= xi.questStatus.QUEST_ACCEPTED and
                player:getFameLevel(xi.fameArea.ABYSSEA_LATHEINE) < 3
        end,

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Fontoumant'] = quest:event(178):replaceDefault(),
        },
    },

    -- Eligible. COMPLETED is accepted because |Repeatable=Yes, and bg-wiki requires
    -- a zone in between; 182 is his not-ready-yet line.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE or
                status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Fontoumant'] =
            {
                onTrigger = function(player, npc)
                    if quest:getMustZone(player) then
                        return quest:event(182)
                    end

                    return quest:progressEvent(181)
                end,
            },

            onEventFinish =
            {
                [181] = function(player, csid, option, npc)
                    -- 7970: 0 "I'm at your disposal!", 1 "I've prior, less dangerous
                    -- engagements."
                    if option ~= 0 then
                        return
                    end

                    if player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.EXPLOSIVE_ENDEAVORS) then
                        player:addQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.EXPLOSIVE_ENDEAVORS)
                    else
                        quest:begin(player)
                    end

                    -- 7973: he hands over all three at once.
                    for _, ki in ipairs(grenades) do
                        npcUtil.giveKeyItem(player, ki)
                    end
                end,
            },
        },
    },

    -- Accepted: one grenade into each fissure, then report back.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Dark_Fissure'] =
            {
                onTrigger = function(player, npc)
                    local entry = fissures[npc:getID()]
                    if entry == nil then
                        return
                    end

                    -- This fissure's grenade is already spent.
                    if not player:hasKeyItem(entry[2]) then
                        return
                    end

                    return quest:progressEvent(entry[1])
                end,
            },

            ['Fontoumant'] =
            {
                onTrigger = function(player, npc)
                    if allThrown(player) then
                        return quest:progressEvent(180)
                    end

                    return quest:event(179)
                end,
            },

            onEventFinish =
            {
                [183] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.ANTI_ABYSSEAN_GRENADE_01)
                end,

                [184] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.ANTI_ABYSSEAN_GRENADE_02)
                end,

                [185] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.ANTI_ABYSSEAN_GRENADE_03)
                end,

                [180] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:addCurrency('cruor', cruorReward)
                        player:messageSpecial(laTheineID.text.CRUOR_OBTAINED, cruorReward, player:getCurrency('cruor'))
                        xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.EXPLOSIVE_ENDEAVORS)
                    end
                end,
            },
        },
    },
}

return quest
