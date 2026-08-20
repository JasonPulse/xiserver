-----------------------------------
-- Voidwatch Operations -- shared engine
--
-- Every Voidwatch op has the same shape: an officer enrols you and hands over a
-- stratum abyssite, you defeat a named set of Voidwatch NMs scattered across a
-- region, then you report back. Only the officer, the abyssite and the NM list
-- change, so the sections are generated from a spec rather than written out nine
-- times.
--
-- THE OFFICER IS A SERVICE MENU, NOT A PER-QUEST NPC. Camille's csid 628 (message
-- 9590 in Wajaom Woodlands) is the whole Voidwatch counter:
--     What will you do?
--       0 Nothing at all.            4 Request <abyssite>.
--       1 Ask many a question.       5 Check voidstone stock.
--       2 Participate in Voidwatch Ops.
--       3 Request debriefing.        6 Request reward issuance.
-- Enrolling is option 2 and reporting back is option 3, so both the accept and the
-- turn-in run through ONE csid per officer. Camille and Owain share csids 628/629/
-- 630; Kieran's counter is 259. Their data[] tables carry the abyssites that prove
-- the pairing -- Camille's holds 2062 (Amber) and Owain's 2060 (Hyacinth), matching
-- what bg-wiki says each chain awards.
--
-- Kills are tracked as a bitmask in the quest var 'VWKills', one bit per target, so
-- the NMs can be defeated in any order -- which is what every walkthrough assumes.
-- bg-wiki is explicit for Border Crossing that the subquests must be STARTED before
-- the NMs die "otherwise the kills will not count", so credit is only taken while
-- the quest is ACCEPTED, which falls out of the section gating for free.
-----------------------------------
require('scripts/globals/npc_util')
-----------------------------------
xi = xi or {}
xi.voidwatch = xi.voidwatch or {}

local killVar = 'VWKills'

xi.voidwatch.allDone = function(player, quest, count)
    return quest:getVar(player, killVar) == bit.lshift(1, count) - 1
end

-- Build the standard sections for one "enrol -> cull -> report" operation.
-- spec fields:
--   giver     { zone, name, menuCsid, postCsid }
--   abyssite  key item handed over on enrolment (optional)
--   targets   ordered list of { zone = xi.zone.X, mob = 'Name' }
--   onFinish  extra work at completion (optional)
xi.voidwatch.opSections = function(quest, spec)
    local count = #spec.targets

    -- Zone-keyed tables for the ACCEPTED phase: every target zone gets an
    -- onMobDeath, and the giver's zone additionally gets the report-back trigger.
    local active = {}

    for i, target in ipairs(spec.targets) do
        local slot = i - 1
        active[target.zone] = active[target.zone] or {}
        active[target.zone][target.mob] =
        {
            onMobDeath = function(mob, player, optParams)
                if player == nil then
                    return
                end

                -- Voidwatch credits the whole alliance that fought the rift, so
                -- isKiller is deliberately not required here.
                local mask = quest:getVar(player, killVar)
                if bit.band(mask, bit.lshift(1, slot)) == 0 then
                    quest:setVar(player, killVar, bit.bor(mask, bit.lshift(1, slot)))
                end
            end,
        }
    end

    active[spec.giver.zone] = active[spec.giver.zone] or {}
    active[spec.giver.zone][spec.giver.name] =
    {
        onTrigger = function(player, npc)
            return quest:progressEvent(spec.giver.menuCsid)
        end,
    }

    active[spec.giver.zone].onEventFinish =
    {
        [spec.giver.menuCsid] = function(player, csid, option, npc)
            -- 9590 option 3: "Request debriefing." Anything else is the officer's
            -- other counter services and must not finish the op.
            if option ~= 3 or not xi.voidwatch.allDone(player, quest, count) then
                return
            end

            if quest:complete(player) then
                quest:setVar(player, killVar, 0)

                if spec.onFinish ~= nil then
                    spec.onFinish(player)
                end
            end
        end,
    }

    local offer = {}
    offer[spec.giver.zone] =
    {
        [spec.giver.name] =
        {
            onTrigger = function(player, npc)
                return quest:progressEvent(spec.giver.menuCsid)
            end,
        },

        onEventFinish =
        {
            [spec.giver.menuCsid] = function(player, csid, option, npc)
                -- 9590 option 2: "Participate in Voidwatch Ops."
                if option ~= 2 then
                    return
                end

                quest:begin(player)
                quest:setVar(player, killVar, 0)

                if spec.abyssite ~= nil then
                    npcUtil.giveKeyItem(player, spec.abyssite)
                end
            end,
        },
    }

    local sections =
    {
        {
            check = function(player, status, vars)
                if spec.previous ~= nil then
                    return status == xi.questStatus.QUEST_AVAILABLE and
                        player:hasCompletedQuest(spec.previous[1], spec.previous[2])
                end

                return status == xi.questStatus.QUEST_AVAILABLE
            end,

            [spec.giver.zone] = offer[spec.giver.zone],
        },

        {
            check = function(player, status, vars)
                return status == xi.questStatus.QUEST_ACCEPTED
            end,
        },
    }

    for zoneId, tbl in pairs(active) do
        sections[2][zoneId] = tbl
    end

    if spec.giver.postCsid ~= nil then
        sections[3] =
        {
            check = function(player, status, vars)
                return status == xi.questStatus.QUEST_COMPLETED
            end,

            [spec.giver.zone] =
            {
                [spec.giver.name] = quest:event(spec.giver.postCsid):replaceDefault(),
            },
        }
    end

    return sections
end
