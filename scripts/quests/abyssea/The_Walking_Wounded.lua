-----------------------------------
-- The Walking Wounded
-----------------------------------
-- Log ID: 8, Quest ID: 14
-- Rashid : Abyssea - Konschtat (F-10), entity 16839221
-- !addquest 8 14
-----------------------------------
-- Retail (bg-wiki "The Walking Wounded").
-- |Start=Rashid (A) (F-10), Abyssea - Konschtat  |Repeatable=Yes
-- |Previous=Full-of-Himself Alchemist
--   1. Speak to Rashid (A) at (F-10), northwest of Veridical Conflux #02.
--   2. He asks you to trade a Soothing Potion to each of the five nearby
--      Resistance Fighter NPCs.
--   3. After trading each Resistance Fighter, return to Rashid (A) to complete.
--   "Zoning is not required to repeat this quest."
--
-- CSIDS DECODED, NOT GUESSED. Rashid is 16839221 -> zone 15 idx 565
-- (0x0100F235); `xi-dat events 15` gives him 206, 234, 235, 236, 261, 262, 263,
-- 264. He carries more than one quest, and csidscan.py against `xi-dat dialog 15`
-- splits them cleanly: 234/235/236 are the Julio-the-alchemist intro chain
-- (7883-7895, the Full-of-Himself Alchemist prerequisite), while THIS quest is
-- the 261-264 block:
--   261 -> 7940-7949  THE OFFER. 7941 "I've got wounded men here, and all our
--          woundpatchers are out afield!", 7942 is the accept prompt: "Offer
--          your aid? ${selection-lines} Of course! / I'm a busy
--          ${choice-player-gender}[man/woman]." -- "Of course!" is the FIRST
--          line, so OPTION 0 ACCEPTS, and 7949 is the decline. 7944 "Five of my
--          men are locked in battle... in the vicinity of this camp" and 7945
--          "deliver ${article} ${item-article: 0[2]} to each of them" -- the
--          potion is param 0. 7946 points at Julio as the supply source.
--   262 -> 7944-7948  the reminder, the same request without the preamble.
--   263 -> 7955/7956  THE TURN-IN. "Excellent! Our regiment is back fighting at
--          full strength, and we have you to thank for it."
--
-- THE FIVE FIGHTERS. Messages 7950-7954 are five distinct replies -- one per
-- man, from "Boy, did that ever hit the spot!" to "I wasn't really hurt. I just
-- told Captain Rashid that I was because I'm addicted to the taste of these
-- things." None of them carries a ${prompt}, and `xi-dat events 15` shows the
-- Resistance_Fighter entities own no csids at all, so these are plain messages
-- rather than cutscenes. That is why the trades are tracked server-side here.
--
-- WHY POSITION SLOTS RATHER THAN ENTITY IDS. Zone 15 holds fifteen
-- Resistance_Fighter entities. Ten of them sit on the five camp positions around
-- Rashid in two overlapping sets -- 16839241-45 (entityFlags 50) and
-- 16839250/52/54/56/58 (entityFlags 40) -- at pairwise identical coordinates,
-- and which set is spawned during the quest cannot be settled from the data
-- alone. Keying the bitmask on the POSITION each entity occupies rather than on
-- its id makes that ambiguity irrelevant: either set completes the quest, and a
-- given spot can only ever be credited once. The remaining five fighters sit at
-- (-560, 243) and around (-130, 507) -- different camps, not "nearby", excluded.
--
-- PROGRESS is a five-bit mask in the quest var 'Potions', one bit per position,
-- so the five deliveries can be made in any order and none can be double-counted.
--
-- ITEM: Soothing Potion is id 5716 (`item_basic`), which had no enum name and
-- was added as SOOTHING_POTION after checking the id was unused.
--
-- CHAIN NOTE: the |Previous= quest, Full-of-Himself Alchemist (abyssea 13), is
-- itself not implemented yet, and it is also the in-game source of Soothing
-- Potions via Julio. The gate below is correct per bg-wiki; that quest still
-- needs building before this one is reachable in a fresh playthrough.
-----------------------------------
local konschtatID = zones[xi.zone.ABYSSEA_KONSCHTAT]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.THE_WALKING_WOUNDED)

-- entity id -> position slot (0-4). Both overlapping sets map onto the same
-- five slots; see the header.
local fighterSlot =
{
    [16839241] = 0, [16839250] = 0, -- (-296.816, -197.603)
    [16839242] = 1, [16839252] = 1, -- (-282.936, -167.467)
    [16839243] = 2, [16839254] = 2, -- (-273.152, -182.459)
    [16839244] = 3, [16839256] = 3, -- (-262.581, -208.360)
    [16839245] = 4, [16839258] = 4, -- (-287.350, -220.531)
}

local fighterThanks =
{
    [0] = konschtatID.text.FIGHTER_THANKS_1,
    [1] = konschtatID.text.FIGHTER_THANKS_2,
    [2] = konschtatID.text.FIGHTER_THANKS_3,
    [3] = konschtatID.text.FIGHTER_THANKS_4,
    [4] = konschtatID.text.FIGHTER_THANKS_5,
}

local allDelivered = 0x1F -- five bits

quest.sections =
{
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE or
                    status == xi.questStatus.QUEST_COMPLETED) and
                player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.FULL_OF_HIMSELF_ALCHEMIST)
        end,

        [xi.zone.ABYSSEA_KONSCHTAT] =
        {
            ['Rashid'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(261, { [0] = xi.item.SOOTHING_POTION })
                end,
            },

            onEventFinish =
            {
                [261] = function(player, csid, option, npc)
                    -- 7942: 0 "Of course!", 1 "I'm a busy man/woman."
                    if option ~= 0 then
                        return
                    end

                    if player:getQuestStatus(xi.questLog.ABYSSEA, xi.quest.id.abyssea.THE_WALKING_WOUNDED) == xi.questStatus.QUEST_COMPLETED then
                        player:addQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.THE_WALKING_WOUNDED)
                    else
                        quest:begin(player)
                    end

                    -- Fresh mask each time, so a repeat run starts from zero.
                    quest:setVar(player, 'Potions', 0)
                end,
            },
        },
    },

    -- Accepted: deliver a potion to each of the five, in any order.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_KONSCHTAT] =
        {
            ['Resistance_Fighter'] =
            {
                onTrade = function(player, npc, trade)
                    local slot = fighterSlot[npc:getID()]
                    if slot == nil then
                        return
                    end

                    local mask = quest:getVar(player, 'Potions')
                    if bit.band(mask, bit.lshift(1, slot)) ~= 0 then
                        return -- this one has already been treated
                    end

                    if not npcUtil.tradeHasExactly(trade, xi.item.SOOTHING_POTION) then
                        return
                    end

                    player:confirmTrade()
                    quest:setVar(player, 'Potions', bit.bor(mask, bit.lshift(1, slot)))
                    player:messageSpecial(fighterThanks[slot])
                end,
            },

            ['Rashid'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Potions') == allDelivered then
                        return quest:progressEvent(263)
                    end

                    return quest:event(262, { [0] = xi.item.SOOTHING_POTION })
                end,
            },

            onEventFinish =
            {
                [263] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Potions', 0)
                    end
                end,
            },
        },
    },
}

return quest
