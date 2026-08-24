-----------------------------------
-- Frozen Flame Redux
-----------------------------------
-- Log ID: 8, Quest ID: 75
-- Guilboire        : Abyssea - Uleguerand (F-7), entity 17814156
-- Impact Point     : Abyssea - Uleguerand (G-5), entity 17814157
-- Frost Bomb Mk-II : Abyssea - Uleguerand, mobs 17813505 .. 17813507
-- !addquest 8 75
-----------------------------------
-- Retail (bg-wiki "Frozen Flame Redux").
-- |Start=Guilboire (A), Abyssea - Uleguerand  |Fame=aule |FLevel=1  |Repeatable=Yes
-- |Reward=10-600 Cruor by the damage dealt. Chance at Bloody Bolt x10 / Acid Bolt
--         x10 / Snoll Gelato, and at an Empyrean +1 HANDS seal.
--   1. "Talk to Guilboire (A) at (F-7) to begin this quest. He will provide you with
--      two key items, the KI Snoll reflector and KI Experiment cheat sheet."
--   2. "Walk north to (G-5) and find the Impact Point location. The Notorious Monster
--      Frost Bomb Mk-II will spawn to the west."
--   3. "Run up and attack it, which will RAISE its HP. Your goal is to raise its HP
--      to at least 50%. The higher it is, the more Cruor reward you receive."
--   4. "Pull it towards the Impact Point. It will use Hypothermal Combustion
--      regardless of its current TP. This will deal damage to the point."
--   5. "Examine the Impact Point to receive a KI Frosted snoll reflector."
--   6. "Return and speak to Guilboire (A) for your reward."
--   "Zoning is required in order to repeat this quest."
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, fired at the puppet in Abyssea - Uleguerand:
--   401 -> "A sharp pair of eyes you have there, friend. Don't travel too far. I may
--          have need of you before long."                              the gate
--   402 -> "Feast those eyes of yours upon this parchment. These are plans for
--          harnessing the fearsome explosive power of snolls..." through "I await
--          word of your success. Go in safety!"                      THE OFFER
--   403 -> "I await word of your success. Go in safety!"             the reminder
--   404 -> "The experiment was a failure!? You cannot be serious!" / "Fortunately, I
--          have a spare set of instruments. Take this, and do try to be more careful
--          this time."                                          the failure retry
--   405 -> "Ah, there you are, friend! Allow me to examine your <reflector>." then
--          his verdict                                                the turn-in
--   406 -> "Of course, my work is not yet complete."      the post-completion line
--   407 -> "I am pleased to announce that preparations for my latest experiment are
--          complete. I trust you remember the procedure?"        the repeat offer
--
-- THE IMPACT POINT HAS NO EVENT PROGRAM. xidat lists no csids for 17814157, which per
-- the usual pattern means the interaction is a plain key item grant rather than a
-- cutscene, so that is how it is written.
--
-- HOW THE BLAST IS DETECTED, and this is our model rather than retail's. Retail keys
-- off the NM actually using Hypothermal Combustion next to the point; the skill
-- exists here (mob_skills id 1644, scripts/actions/mobskills/hypothermal_combustion
-- .lua) but Frost Bomb Mk-II has no mob script to hook it from, and the framework
-- gives a quest onMobDeath but no onMobSkill. bg-wiki also says the NM fires the skill
-- "regardless of its current TP" once pulled in, so proximity IS the trigger in
-- practice. Examining the point therefore checks that a Frost Bomb Mk-II is spawned
-- and within blast range, and grades on the HP it was raised to, which is exactly
-- what bg-wiki says the cruor scales on.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.FROZEN_FLAME_REDUX)

local impactPoint = 17814157

local frostBombs =
{
    17813505,
    17813506,
    17813507,
}

-- bg-wiki: "Your goal is to raise its HP to at least 50%."
local minimumHpp = 50

-- Ours: how close the bomb has to be to the point to count as having blasted it.
local blastRange = 8

-- bg-wiki gives the band ends only, 10 to 600, scaled by the damage dealt, which
-- tracks the HP the bomb was raised to.
local cruorFloor = 10
local cruorCeil  = 600

local bonusItems =
{
    { xi.item.BLOODY_BOLT, 10 },
    { xi.item.ACID_BOLT,   10 },
    xi.item.CONE_OF_SNOLL_GELATO,
}

local handsSeals =
{
    xi.item.BALE_SEAL_HANDS,
    xi.item.MAVI_SEAL_HANDS,
    xi.item.CALLERS_SEAL_HANDS,
    xi.item.GOETIA_SEAL_HANDS,
}

local bonusChance = 30

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_ULEGUERAND,
}

local function giveInstruments(player)
    npcUtil.giveKeyItem(player, xi.ki.SNOLL_REFLECTOR)
    npcUtil.giveKeyItem(player, xi.ki.EXPERIMENT_CHEAT_SHEET)
end

--- The Frost Bomb Mk-II that is spawned and standing in the blast radius, if any.
local function blastingBomb(npc)
    for _, mobId in ipairs(frostBombs) do
        local mob = GetMobByID(mobId)

        if
            mob ~= nil and
            mob:isSpawned() and
            mob:checkDistance(npc) <= blastRange
        then
            return mob
        end
    end

    return nil
end

local function spawnBomb()
    for _, mobId in ipairs(frostBombs) do
        local mob = GetMobByID(mobId)

        if mob ~= nil and not mob:isSpawned() then
            SpawnMob(mobId)

            return
        end
    end
end

--- Cruor scaled across the published band by the HP the bomb reached.
local function cruorFor(player)
    local hpp = utils.clamp(quest:getVar(player, 'BlastHpp'), 0, 100)

    return math.floor(cruorFloor + (cruorCeil - cruorFloor) * hpp / 100)
end

local impactActions =
{
    onTrigger = function(player, npc)
        if npc:getID() ~= impactPoint then
            return
        end

        -- Already carrying the reading, so there is nothing more to take.
        if player:hasKeyItem(xi.ki.FROSTED_SNOLL_REFLECTOR) then
            return
        end

        if not player:hasKeyItem(xi.ki.SNOLL_REFLECTOR) then
            return
        end

        local bomb = blastingBomb(npc)

        if bomb == nil then
            -- "The Notorious Monster Frost Bomb Mk-II will spawn to the west."
            spawnBomb()

            return
        end

        -- Below half health the blast is too weak to be worth recording, which is the
        -- 50% floor bg-wiki names.
        if bomb:getHPP() < minimumHpp then
            return
        end

        quest:setVar(player, 'BlastHpp', bomb:getHPP())
        player:delKeyItem(xi.ki.SNOLL_REFLECTOR)
        npcUtil.giveKeyItem(player, xi.ki.FROSTED_SNOLL_REFLECTOR)
    end,
}

local function payOut(player)
    xi.abyssea.questReward(player, cruorFor(player), handsSeals)

    if math.random(1, 100) <= bonusChance then
        npcUtil.giveItem(player, bonusItems[math.random(#bonusItems)])
    end

    player:delKeyItem(xi.ki.FROSTED_SNOLL_REFLECTOR)
    player:delKeyItem(xi.ki.EXPERIMENT_CHEAT_SHEET)
    quest:setVar(player, 'BlastHpp', 0)
    xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.FROZEN_FLAME_REDUX)
end

--- He hands over a spare set when the reflector was lost without a reading.
local function lostInstruments(player)
    return not player:hasKeyItem(xi.ki.SNOLL_REFLECTOR) and
        not player:hasKeyItem(xi.ki.FROSTED_SNOLL_REFLECTOR)
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ABYSSEA_ULEGUERAND) >= 1
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Guilboire'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(402)
                end,
            },

            onEventFinish =
            {
                [402] = function(player, csid, option, npc)
                    quest:begin(player)
                    quest:setVar(player, 'BlastHpp', 0)
                    giveInstruments(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Impact_Point'] = impactActions,

            ['Guilboire'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.FROSTED_SNOLL_REFLECTOR) then
                        return quest:progressEvent(405)
                    elseif lostInstruments(player) then
                        return quest:progressEvent(404)
                    end

                    return quest:event(403)
                end,
            },

            onEventFinish =
            {
                [404] = function(player, csid, option, npc)
                    giveInstruments(player)
                end,

                [405] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        payOut(player)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Impact_Point'] = impactActions,

            ['Guilboire'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.FROSTED_SNOLL_REFLECTOR) then
                        return quest:progressEvent(405)
                    elseif quest:getMustZone(player) then
                        return quest:event(406)
                    end

                    return quest:progressEvent(407)
                end,
            },

            onEventFinish =
            {
                [405] = function(player, csid, option, npc)
                    payOut(player)
                end,

                [407] = function(player, csid, option, npc)
                    quest:setVar(player, 'BlastHpp', 0)
                    giveInstruments(player)
                end,
            },
        },
    },
}

return quest
