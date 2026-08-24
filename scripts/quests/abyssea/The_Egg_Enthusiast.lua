-----------------------------------
-- The Egg Enthusiast
-----------------------------------
-- Log ID: 8, Quest ID: 61
-- Ranpi-Monpi  : Abyssea - Grauberg (L-6), entity 17818231
-- Earthy_Mound : Abyssea - Grauberg, entities 17818232 / 17818233 / 17818234
-- !addquest 8 61
-----------------------------------
-- Retail (bg-wiki "The Egg Enthusiast").
-- |Start=Ranpi-Monpi (A), Abyssea - Grauberg  |Fame=agra |FLevel=1
-- |Item Reqs=KI Wivre egg  |Repeatable=Yes
-- |Reward=Dependent on which Earthy Mound you go to.
--         First time: 200~400 Cruor. Subsequent: 100~200 Cruor. Chance at an
--         Empyrean +1 BODY seal (Goetia/Estoqueur's/Iga/Unkai/Lancer's).
--   1. "Speak to Ranpi-Monpi (A) at (L-6), northeast of Conflux #8."
--   2. "You must interact with one of three Earthy Mound targetable locations in
--      order to obtain a KI Wivre egg.
--        One can be found near (H-8)/(I-8). Reward: 200 Cruor (400 first time), and
--          a chance at a seal.
--        One is at (J-10), near Conflux #3. Reward: 200 Cruor (400 first time), and
--          a chance at a seal.
--        The last option is at (J-6). Reward: 100 Cruor (200 first time), and will
--          NOT reward a seal."
--   3. "After collecting the KI Wivre egg, you must return to Ranpi-Monpi WITHOUT
--      breaking it. This means you cannot use Confluxes to warp back and cannot be
--      attacked by any monster. Additional ways the egg can break: Taking too long
--      after obtaining the egg, or even losing HP by switching gear on the way back!"
--   "Zoning is required in order to repeat this quest."
--
-- CSIDS DECODED, NOT GUESSED. Per-csid attribution from each entity's byte ranges:
--   Ranpi-Monpi 224 -> 7939-7943  THE OFFER. 7940 is the two-way menu ("Mais oui!" /
--          "Non..."), 7941 the refusal "Zen I have no use for vous", 7942 "Dieu
--          merci! I have awaited zee coming of une such as vous!"
--   Ranpi-Monpi 225 -> 7947-7950  the reminder, and it is where every breakage rule
--          bg-wiki lists is actually stated: 7947 "zee eggs are extremement fragile",
--          7948 "zhey are even known to crack wizeen zee hands of personnes een poor
--          healz", 7949 "don't even zink of taking zem zroo zee veridical confluxes",
--          7950 "I require for vous to procure a wivre egg."
--   Ranpi-Monpi 229 -> 7952-7956  THE TURN-IN, carrying BOTH outcomes: 7952 "vous
--          have brought moi zee egg I requested!", 7953 "Sacre bleu! Why, zis egg eez
--          cracked terriblement!", 7955/7956 the intact-egg warmth lines. The client
--          picks the branch, so this fires with the egg id as its param.
--   Ranpi-Monpi 230 -> 7960  his post-completion line.
--   Earthy_Mound 226 (17818232), 227 (17818233), 228 (17818234) -> 7951 "This appears
--          to be a nesting ground for wivre." One csid per mound, which is what fixes
--          the mound-to-egg pairing below rather than any choice made here.
--
-- THREE DISTINCT KEY ITEMS, not one: the enum carries WIVRE_EGG1/2/3 (1713-1715), and
-- one csid per mound, so which mound was used is recoverable at turn-in from the egg
-- the player is holding. That is what makes bg-wiki's per-mound Cruor table
-- implementable without tracking anything extra.
--
-- BREAKAGE. The rules bg-wiki lists are "attacked by any monster", "losing HP",
-- "taking too long" and "using a Conflux". HP loss is the one signal available here
-- without inventing hooks, and it subsumes being attacked, so the egg is checked
-- against the HP the player had when they picked it up, plus the time limit.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.THE_EGG_ENTHUSIAST)

-- Earthy_Mound entity -> { csid, its egg, first-time Cruor, repeat Cruor, seal? }.
local mounds =
{
    [17818232] = { 226, xi.ki.WIVRE_EGG1, 400, 200, true  },
    [17818233] = { 227, xi.ki.WIVRE_EGG2, 400, 200, true  },
    [17818234] = { 228, xi.ki.WIVRE_EGG3, 200, 100, false },
}

local eggs =
{
    xi.ki.WIVRE_EGG1,
    xi.ki.WIVRE_EGG2,
    xi.ki.WIVRE_EGG3,
}

-- bg-wiki lists BODY seals for this quest: 3133/3134/3142/3141/3143.
local bodySeals =
{
    xi.item.GOETIA_SEAL_BODY,
    xi.item.ESTOQUEURS_SEAL_BODY,
    xi.item.IGA_SEAL_BODY,
    xi.item.UNKAI_SEAL_BODY,
    xi.item.LANCERS_SEAL_BODY,
}

-- "Taking too long after obtaining the egg" breaks it. bg-wiki gives no figure, and
-- the run is a short walk from any of the three mounds, so this is the generous end.
local carryLimit = 300

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_GRAUBERG,
}

--- The mound entry matching whichever egg the player is carrying, or nil.
local carriedMound = function(player)
    for _, entry in pairs(mounds) do
        if player:hasKeyItem(entry[2]) then
            return entry
        end
    end

    return nil
end

local clearEggs = function(player)
    for _, ki in ipairs(eggs) do
        player:delKeyItem(ki)
    end

    quest:setVar(player, 'EggHp', 0)
    quest:setVar(player, 'EggTime', 0)
end

--- "cannot be attacked by any monster" and "even losing HP" are the same signal, and
--- "taking too long" is the other. Either breaks the egg.
local eggIsBroken = function(player)
    local carriedHp = quest:getVar(player, 'EggHp')
    local takenAt   = quest:getVar(player, 'EggTime')

    if carriedHp == 0 or takenAt == 0 then
        return true
    end

    if player:getHP() < carriedHp then
        return true
    end

    return GetSystemTime() - takenAt > carryLimit
end

--- The mounds behave the same on the first run and on repeats.
local moundActions =
{
    onTrigger = function(player, npc)
        local entry = mounds[npc:getID()]

        if entry == nil or carriedMound(player) ~= nil then
            return
        end

        npcUtil.giveKeyItem(player, entry[2])
        quest:setVar(player, 'EggHp', player:getHP())
        quest:setVar(player, 'EggTime', GetSystemTime())

        return quest:event(entry[1])
    end,
}

--- bg-wiki's per-mound table, with the cracked-egg branch paying nothing.
local payOut = function(player, firstTime)
    local entry = carriedMound(player)

    if entry == nil then
        return
    end

    local broken = eggIsBroken(player)
    local cruor  = firstTime and entry[3] or entry[4]
    local seals  = nil

    if entry[5] and not broken then
        seals = bodySeals
    end

    clearEggs(player)

    -- 7953 "zis egg eez cracked terriblement!" is the no-reward branch.
    if broken then
        return
    end

    xi.abyssea.questReward(player, cruor, seals)
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.ABYSSEA_GRAUBERG] =
        {
            ['Ranpi-Monpi'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(224)
                end,
            },

            onEventFinish =
            {
                [224] = function(player, csid, option, npc)
                    -- 7941 is "Zen I have no use for vous", the decline.
                    if option ~= 0 then
                        return
                    end

                    quest:begin(player)
                    clearEggs(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_GRAUBERG] =
        {
            ['Earthy_Mound'] = moundActions,

            ['Ranpi-Monpi'] =
            {
                onTrigger = function(player, npc)
                    local entry = carriedMound(player)

                    if entry ~= nil then
                        return quest:progressEvent(229, entry[2])
                    end

                    return quest:event(225)
                end,
            },

            onEventFinish =
            {
                [229] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        payOut(player, true)
                    end
                end,
            },
        },
    },

    -- Repeatable. bg-wiki: "Zoning is required in order to repeat this quest."
    -- "If you break the egg, you must zone to re-try the quest."
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_GRAUBERG] =
        {
            ['Earthy_Mound'] = moundActions,

            ['Ranpi-Monpi'] =
            {
                onTrigger = function(player, npc)
                    local entry = carriedMound(player)

                    if entry ~= nil then
                        return quest:progressEvent(229, entry[2])
                    elseif quest:getMustZone(player) then
                        return quest:event(230)
                    end

                    return quest:event(225)
                end,
            },

            onEventFinish =
            {
                [229] = function(player, csid, option, npc)
                    payOut(player, false)
                    xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.THE_EGG_ENTHUSIAST)
                end,
            },
        },
    },
}

return quest
