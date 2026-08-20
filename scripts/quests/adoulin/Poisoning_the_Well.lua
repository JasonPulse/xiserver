-----------------------------------
-- Poisoning the Well
-----------------------------------
-- Log ID: 9, Quest ID: 10
-- Fritha     : Foret de Hennetiel (J-7), entity 17850921
-- River_Mouth: Foret de Hennetiel (J-9), entity 17850923
-- !addquest 9 10
-----------------------------------
-- Retail (bg-wiki "Poisoning the Well").
-- |Start=Fritha, Foret de Hennetiel - (J-7)  |Repeatable=No  |Fame=Adoulin
-- |FLevel=1  |Reward=2000 Experience Points
--   1. Talk to Fritha at (J-7), at the Frontier Station.
--   2. Head to J-9 and click the River Mouth. "This will spawn a Notorious
--      Monster named Cunning Craklaw."
--   3. "After defeating Cunning Craklaw, make sure to click the River Mouth to
--      receive the Vial of toxic Zoldeff water."
--   4. Return to Fritha to complete the quest.
--
-- CSIDS DECODED, NOT GUESSED -- AND THE DUMP'S ZONE LABELS ARE OFF BY ONE HERE.
-- Fritha is 17850921 -> zone 262 idx 553 (0x01106229). `xi-dat events 262` gives
-- her 520, 522, 526 and 2500-2504; the 520/522/526 block (8048/8049, 8061/8062,
-- 8077) belongs to other quests she carries. The dumped dialog file labelled zone
-- N holds zone N-1's text for the Adoulin zones, so Foret's text is in the file
-- labelled 263; the offset is pinned by this repo's own known-correct id
-- (Foret_de_Hennetiel/IDs.lua WAYPOINT_ATTUNED = 7688 resolves in dump 263).
-- Read against 263:
--   2500 -> 7499-7501  THE OFFER. 7500 "I am a researcher, sent here by order of
--          the Scouts' Coalition to survey the water quality in the area. Yet the
--          lurid monstrosities of the forest are too much for me to handle on my
--          own", and 7501 "Any water from the river will do, as long as it's from
--          the mouth." No ${selection-lines}, so speaking to her starts it.
--   2501 -> 7501       the reminder: water from the mouth of the river.
--   2502 -> 7502-7504  THE TURN-IN. "This is perfect! I should be able to continue
--          my research without issue." / 7503 "So the same poisoned water runs
--          through the river after all."
--   2504 -> 7504       her post-completion line.
--   2503 -> 7505/7506  THE RIVER MOUTH. 7505 "Some foul-looking water bubbles
--          forth at the mouth of the river." and 7506 "Something approaches from
--          behind as you bend down to take a sample!" -- the ambush. The
--          River_Mouth entity owns no csid of its own, so these are plain messages
--          rather than an event, the same shape the Shellfish points use.
--
-- THE AMBUSH PAIRING IS MATCHED BY POSITION, NOT GUESSED. River_Mouth 17850923
-- sits at (461.985, -58.006) and mob_spawn_points puts Cunning_Craklaw (17850723)
-- at (460.699, -52.355) -- the same spot, which is what ties 7506's "something
-- approaches from behind" to that NM.
--
-- KEY ITEM: Vial of toxic Zoldeff water is the existing
-- VIAL_OF_TOXIC_ZOLDEFF_WATER (2185).
--
-- THE SECOND CLICK IS RETAIL, NOT AN OVERSIGHT. bg-wiki is explicit that killing
-- the Craklaw is not enough -- you must click the River Mouth again afterwards to
-- actually get the vial, and warns players about exactly that. So the first click
-- spawns and the sample is only taken once the NM is down.
-----------------------------------
local foretID = zones[xi.zone.FORET_DE_HENNETIEL]
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.POISONING_THE_WELL)

local craklawSpawnPoint = 17850723 -- Cunning_Craklaw, mob_spawn_points

quest.reward =
{
    exp      = 2000,
    fameArea = xi.fameArea.ADOULIN,
}

quest.sections =
{
    -- bg-wiki lists no |Previous=, and |FLevel=1 is the base fame level every
    -- character already has.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.FORET_DE_HENNETIEL] =
        {
            ['Fritha'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2500)
                end,
            },

            onEventFinish =
            {
                [2500] = function(player, csid, option, npc)
                    quest:begin(player)
                    quest:setVar(player, 'Craklaw', 0)
                end,
            },
        },
    },

    -- Accepted: pop the Craklaw at the river mouth, kill it, then take the sample.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.FORET_DE_HENNETIEL] =
        {
            ['Cunning_Craklaw'] =
            {
                onMobDeath = function(mob, player, optParams)
                    if player == nil or not optParams.isKiller then
                        return
                    end

                    quest:setVar(player, 'Craklaw', 2)
                end,
            },

            ['River_Mouth'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.VIAL_OF_TOXIC_ZOLDEFF_WATER) then
                        player:messageSpecial(foretID.text.FOUL_WATER_AT_RIVER_MOUTH)
                        return
                    end

                    local stage = quest:getVar(player, 'Craklaw')

                    -- The NM is down: this is the click that actually samples.
                    if stage == 2 then
                        player:messageSpecial(foretID.text.FOUL_WATER_AT_RIVER_MOUTH)
                        npcUtil.giveKeyItem(player, xi.ki.VIAL_OF_TOXIC_ZOLDEFF_WATER)
                        return
                    end

                    player:messageSpecial(foretID.text.FOUL_WATER_AT_RIVER_MOUTH)

                    local nm = GetMobByID(craklawSpawnPoint)
                    if nm ~= nil and not nm:isSpawned() then
                        player:messageSpecial(foretID.text.SOMETHING_APPROACHES)
                        quest:setVar(player, 'Craklaw', 1)
                        nm:spawn()
                        nm:updateClaim(player)
                    end
                end,
            },

            ['Fritha'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.VIAL_OF_TOXIC_ZOLDEFF_WATER) then
                        return quest:progressEvent(2502)
                    end

                    return quest:event(2501)
                end,
            },

            onEventFinish =
            {
                [2502] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.VIAL_OF_TOXIC_ZOLDEFF_WATER)

                    if quest:complete(player) then
                        quest:setVar(player, 'Craklaw', 0)
                    end
                end,
            },
        },
    },

    -- Completed: 7504, she may call on you again.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.FORET_DE_HENNETIEL] =
        {
            ['Fritha'] = quest:event(2504):replaceDefault(),
        },
    },
}

return quest
