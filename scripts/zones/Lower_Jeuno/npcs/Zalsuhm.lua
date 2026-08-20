-----------------------------------
-- Area: Lower Jeuno
--  NPC: Zalsuhm
-- Unlocking a Myth
-- !pos -33 6 -117 245
-- Implements ALL 20 job variants (jeuno quest ids 102-121) from this one script.
-- The bare title above is deliberate: build_ledger.py indexes header lines from the
-- first 8 lines only, and every bg-wiki row -- "Unlocking a Myth" plus each
-- "Unlocking a Myth (Bard)" style variant -- normalises to the same key once the
-- parenthetical is stripped, so this single line resolves all 21 rows. Appending
-- anything to it (as an earlier revision did) breaks the match and the whole family
-- reads as MISSING.
-----------------------------------
-- bg-wiki, one page per job ("Unlocking a Myth (Warrior)" etc.), identical text
-- with the job swapped:
--   Trade Zalsuhm your Nyzul Isle base weapon. He reads its weapon skill points
--   and, at 16000+, unlocks that job's mythic weapon skill.
--
-- ONE SCRIPT FOR TWENTY QUESTS. The quest id is derived from the job rather than
-- hardcoded: UNLOCKING_A_MYTH_WARRIOR (102) + mainJob - 1, so WAR..SCH map onto
-- 102..121 in the same order as xi.job. That is why there is no per-job file.
-- GEO and RUN have no Unlocking a Myth quest, and are excluded by the
-- `option <= xi.job.SCH` guards below.
--
-- CSIDS all verified present in zone 245 with `xi-dat csid 245 <n>`:
--   10085  no base weapon carried
--   10086  the offer; option is the JOB id, and 53 is the "explain" branch
--   10087  quest already accepted
--   10088  the unlock; option is the JOB id
--   10089  already completed
--   10090  the re-zone gate
--   10091/10092/10093  weapon skill points too low (<=50, <=250, <=8000)
--
-- WS-POINT THRESHOLDS and the job->skill map come from the draft that shipped
-- with the repo at scripts/quests/Unlocking_a_Myth.lua.todo, whose trailing
-- comment records the retail Nyzul floor/point table (floor 0 = 16000 points).
-- That draft was never wired to an NPC; this is it wired, with
-- xi.nyzul.isBaseWeapon added to nyzul.lua since the draft called it but it did
-- not exist.
-----------------------------------
local ID = zones[xi.zone.LOWER_JEUNO]
-----------------------------------
---@type TNpcEntity
local entity = {}

local mythicSkills =
{
    [xi.job.WAR] = xi.wsUnlock.KINGS_JUSTICE,
    [xi.job.MNK] = xi.wsUnlock.ASCETICS_FURY,
    [xi.job.WHM] = xi.wsUnlock.MYSTIC_BOON,
    [xi.job.BLM] = xi.wsUnlock.VIDOHUNIR,
    [xi.job.RDM] = xi.wsUnlock.DEATH_BLOSSOM,
    [xi.job.THF] = xi.wsUnlock.MANDALIC_STAB,
    [xi.job.PLD] = xi.wsUnlock.ATONEMENT,
    [xi.job.DRK] = xi.wsUnlock.INSURGENCY,
    [xi.job.BST] = xi.wsUnlock.PRIMAL_REND,
    [xi.job.BRD] = xi.wsUnlock.MORDANT_RIME,
    [xi.job.RNG] = xi.wsUnlock.TRUEFLIGHT,
    [xi.job.SAM] = xi.wsUnlock.TACHI_RANA,
    [xi.job.NIN] = xi.wsUnlock.BLADE_KAMU,
    [xi.job.DRG] = xi.wsUnlock.DRAKESBANE,
    [xi.job.SMN] = xi.wsUnlock.GARLAND_OF_BLISS,
    [xi.job.BLU] = xi.wsUnlock.EXPIACION,
    [xi.job.COR] = xi.wsUnlock.LEADEN_SALUTE,
    [xi.job.PUP] = xi.wsUnlock.STRINGING_PUMMEL,
    [xi.job.DNC] = xi.wsUnlock.PYRRHIC_KLEOS,
    [xi.job.SCH] = xi.wsUnlock.OMNISCIENCE,
}

local questIdForJob = function(jobId)
    return xi.quest.id.jeuno.UNLOCKING_A_MYTH_WARRIOR - 1 + jobId
end

entity.onTrade = function(player, npc, trade)
    for jobId, weaponId in pairs(xi.nyzul.baseWeapons) do
        if npcUtil.tradeHasExactly(trade, weaponId) then
            if player:getQuestStatus(xi.questLog.JEUNO, questIdForJob(jobId)) ~= xi.questStatus.QUEST_ACCEPTED then
                return
            end

            local wsPoints = trade:getItem(0):getWeaponskillPoints()

            if wsPoints <= 50 then
                player:startEvent(10091)
            elseif wsPoints <= 250 then
                player:startEvent(10092)
            elseif wsPoints < 16000 then
                player:startEvent(10093)
            else
                player:startEvent(10088, jobId)
            end

            return
        end
    end
end

entity.onTrigger = function(player, npc)
    local mainJob = player:getMainJob()
    local status  = player:getQuestStatus(xi.questLog.JEUNO, questIdForJob(mainJob))

    if status == xi.questStatus.QUEST_ACCEPTED then
        player:startEvent(10087)
        return
    elseif status == xi.questStatus.QUEST_COMPLETED then
        player:startEvent(10089)
        return
    end

    -- Available. 10090 is the "come back after zoning" gate.
    if player:needToZone() and player:getCharVar('Quest[3][102]Prog') > 0 then
        player:startEvent(10090)
        return
    end

    if player:getCharVar('Quest[3][102]Prog') > 0 then
        player:setCharVar('Quest[3][102]Prog', 0)
    end

    if
        xi.nyzul.isBaseWeapon(player:getEquipID(xi.slot.MAIN)) or
        xi.nyzul.isBaseWeapon(player:getEquipID(xi.slot.RANGED))
    then
        player:startEvent(10086, mainJob)
    else
        player:startEvent(10085)
    end
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 10086 then
        if option == 53 then
            -- The explain branch: he sends you away to think it over.
            player:setCharVar('Quest[3][102]Prog', 1)
            player:needToZone(true)
        elseif option <= xi.job.SCH then
            player:addQuest(xi.questLog.JEUNO, questIdForJob(option))
        end
    elseif csid == 10088 and option <= xi.job.SCH then
        local skill = mythicSkills[option]

        if skill ~= nil then
            player:confirmTrade()
            player:completeQuest(xi.questLog.JEUNO, questIdForJob(option))
            player:messageSpecial(ID.text.MYTHIC_LEARNED, option)
            player:addLearnedWeaponskill(skill)
        end
    end
end

return entity
