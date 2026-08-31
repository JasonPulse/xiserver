-----------------------------------
-- In the Land of the Blind
-----------------------------------
-- Log ID: 9, Quest ID: 140
-- Behsa_Alehgo       : Eastern Adoulin (J-8), entity 17830132
-- Suspicious_Place   : Yorcia Weald (I-8),    entity 17855042
-- Pellucid_Afflusion : Yorcia Weald (G-6),    entity 17855056
-- Jovial_Ahriman     : Yorcia Weald,          mob    17854865
-- !addquest 9 140
-----------------------------------
-- Retail (bg-wiki "In the Land of the Blind").
-- |Start=Behsa Alehgo, Eastern Adoulin (J-8)  |Fame=Adoulin  |FLevel=3
-- |Previous=Eye of the Beholder  |Title=One-Eyed Jack
-- |Reward=Homiliary, 1,000 EXP, 1,000 Bayld
--   1. Speak to Behsa Alehgo in Eastern Adoulin.
--   2. Enter Celennia Memorial Library.
--   3. Check the Suspicious Place on the south side of (I-8) in Yorcia Weald.
--   4. Check it again to spawn Jovial Ahriman, kill it, check a third time.
--   5. Check the Pellucid Afflusion at (G-6) for the reward.
--
-- Was blocked only because its prerequisite was. See The_Secret_to_Success.lua.
--
-- Csids:
--   5209 -> 10328-10335  offer and nudge, Eastern Adoulin holder 17830076
--   38   -> 7303-7331    the library, zone 284 holder 17940492; 7328 names I-8
--   122  -> 8194-8207    the first look; 8196 is the Ahriman talking
--   123  -> 8208-8249    after the kill; 8241 names the Pool of Clarity
--   125  -> 8250-8261    the Pool of Clarity, and the reward
--
-- The Yorcia holder's csids in this range are contiguous and non-overlapping once
-- shared data[] entries are discounted (114, 115, 122, 123, 125), and each lines up
-- with a bg-wiki step.
--
-- One Jovial_Ahriman row exists. It spawns on the second click, not the cutscene.
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.IN_THE_LAND_OF_THE_BLIND)

local behsaAlehgo      = 17830132
local markerI8         = 17855042
local pellucidAfflusion = 17855056
local jovialAhriman    = 17854865

quest.reward =
{
    fameArea = xi.fameArea.ADOULIN,
    item     = xi.item.HOMILIARY,
    bayld    = 1000,
    exp      = 1000,
    title    = xi.title.ONE_EYED_JACK,
}

quest.sections =
{
    -- Section: nobody has seen Erfimia in days.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ADOULIN) >= 3 and
                player:hasCompletedQuest(xi.questLog.ADOULIN, xi.quest.id.adoulin.EYE_OF_THE_BEHOLDER)
        end,

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Behsa_Alehgo'] =
            {
                onTrigger = function(player, npc)
                    if npc:getID() ~= behsaAlehgo then
                        return
                    end

                    return quest:progressEvent(5209)
                end,
            },

            onEventFinish =
            {
                [5209] = function(player, csid, option, npc)
                    quest:begin(player)
                    quest:setVar(player, 'Prog', 0)
                end,
            },
        },
    },

    -- Section: the library, the grove, the ahriman, and the pool.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Behsa_Alehgo'] =
            {
                onTrigger = function(player, npc)
                    if npc:getID() ~= behsaAlehgo then
                        return
                    end

                    return quest:event(5209)
                end,
            },
        },

        [xi.zone.CELENNIA_MEMORIAL_LIBRARY] =
        {
            onZoneIn = function(player, prevZone)
                if quest:getVar(player, 'Prog') ~= 0 then
                    return -1
                end

                return 38
            end,

            onEventFinish =
            {
                [38] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 1)
                end,
            },
        },

        [xi.zone.YORCIA_WEALD] =
        {
            ['Suspicious_Place'] =
            {
                onTrigger = function(player, npc)
                    if npc:getID() ~= markerI8 then
                        return
                    end

                    local prog = quest:getVar(player, 'Prog')

                    if prog == 1 then
                        return quest:progressEvent(122)
                    elseif prog == 3 then
                        return quest:progressEvent(123)
                    elseif prog ~= 2 then
                        return
                    end

                    -- The arming click. bg-wiki puts it after the cutscene on
                    -- purpose so the fight is never a surprise.
                    local mob = GetMobByID(jovialAhriman)

                    if mob ~= nil and not mob:isSpawned() then
                        mob:spawn()
                        mob:updateClaim(player)
                    end

                    return quest:noAction()
                end,
            },

            ['Jovial_Ahriman'] =
            {
                onMobDeath = function(mob, player, optParams)
                    if quest:getVar(player, 'Prog') == 2 then
                        quest:setVar(player, 'Prog', 3)
                    end
                end,
            },

            ['Pellucid_Afflusion'] =
            {
                onTrigger = function(player, npc)
                    if
                        npc:getID() ~= pellucidAfflusion or
                        quest:getVar(player, 'Prog') ~= 4
                    then
                        return
                    end

                    return quest:progressEvent(125)
                end,
            },

            onEventFinish =
            {
                [122] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 2)
                end,

                [123] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 4)
                end,

                [125] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Prog', 0)
                    end
                end,
            },
        },
    },
}

return quest
