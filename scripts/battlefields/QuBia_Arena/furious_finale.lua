-----------------------------------
-- Area: Qu'Bia Arena
-- Name: A Furious Finale - Laila Fight (DNC)
-----------------------------------
-- Retail (bg-wiki "A Furious Finale"): the DNC limit break. Kill Quadav in
-- Grauberg (S) / North Gustaberg (S) for a Dnc. Testimony, then fight Laila in
-- Qu'Bia Arena; she yields at roughly 25% HP.
--
-- Modelled directly on the sibling limit-break battlefields in this directory
-- (shattering_stars_brd / _drk / _pld), which are the same shape: solo, subjob
-- disabled, 10-minute limit, entered by TRADING the job testimony at the Burning
-- Circle. That trade-to-enter mechanic is what the decoded quest dialog
-- describes -- Upper Jeuno dialog 12132 says "When ye arrive, use yer
-- ${item-singular: 0[2]} t'enter the arena", i.e. Laila does not teleport you.
--
-- Everything referenced here already existed in the DB; only this script and the
-- LAILA entry in QuBia_Arena/IDs.lua were missing:
--   xi.battlefield.id.FURIOUS_FINALE = 530   (scripts/globals/battlefield.lua:255)
--   bcnm_records (530, 206, 'furious_finale', 'nobody', 0, 600)
--     -- 600 seconds corroborates the 10-minute limit used below.
--   Laila mobs 17621281 / 17621282 / 17621283 in zone 206, one per arena,
--     matching how MAAT+n is laid out for the Maat fights.
--
-- FLAGGED: `index` is the client's battlefield-menu slot and is not derivable
-- from the dump. 0-16 and 20-21 are taken by the other Qu'Bia contents, so 17 is
-- the first free slot. A wrong index shows the wrong menu label but cannot
-- corrupt state -- confirm it on a puppet before trusting the menu text.
-----------------------------------
local qubiaID = zones[xi.zone.QUBIA_ARENA]
-----------------------------------

local content = Battlefield:new({
    zoneId        = xi.zone.QUBIA_ARENA,
    battlefieldId = xi.battlefield.id.FURIOUS_FINALE,
    maxPlayers    = 1,
    levelCap      = 99,
    allowSubjob   = false,
    timeLimit     = utils.minutes(10),
    index         = 17,
    entryNpc      = 'BC_Entrance',
    exitNpc       = 'Burning_Circle',
    requiredItems = { xi.item.DANCERS_TESTIMONY, wearMessage = qubiaID.text.TESTIMONY_WEARS, wornMessage = qubiaID.text.TESTIMONY_IS_TORN },
})

function content:entryRequirement(player, npc, isRegistrant, trade)
    local jobRequirement   = player:getMainJob() == xi.job.DNC
    local levelRequirement = player:getMainLvl() >= 66
    local questStatus      = player:getQuestStatus(xi.questLog.JEUNO, xi.quest.id.jeuno.A_FURIOUS_FINALE)

    return jobRequirement and levelRequirement and questStatus == xi.questStatus.QUEST_ACCEPTED
end

content.groups =
{
    {
        mobIds =
        {
            { qubiaID.mob.LAILA     },
            { qubiaID.mob.LAILA + 1 },
            { qubiaID.mob.LAILA + 2 },
        },

        allDeath = function(battlefield, mob)
            battlefield:setStatus(xi.battlefield.status.WON)
        end,
    },
}

return content:register()
