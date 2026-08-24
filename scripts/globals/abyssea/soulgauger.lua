-----------------------------------
-- Abyssea Soulgauger SGR-1.
--
-- The reconnaissance device four Abyssea quests are built on: The Soul of the Matter
-- and Playing Paparazzi in Konschtat, Help Not Wanted in Altepa, and Imperial
-- Espionage II in Uleguerand. bg-wiki describes it as a sibling of the Soultrapper:
--
--   "Much like using a Soultrapper, you will equip the Soulgauger SGR-1 and Gauger
--    Plates and then look for an NM to get a good quality capture of. Unlike when
--    farming Zeni, you do not need to lower the mob's HP."
--   "You need to have a good distance (~5 yalms) and frontal angle on the mob.
--    Distance and angle appear to be the major factors in appraisal of your captures."
--   "There are four appraisal levels that result in different cruor rewards and text
--    from the NPC."
--   "You do not need to have claim on the monster in order to get a picture that
--    qualifies."
--
-- WHY THE CAPTURE IS RECORDED ON THE PLAYER RATHER THAN IN THE PLATE. A soul plate is
-- a special item type that carries its own payload, which is why znm.lua can call
-- player:addSoulPlate(name, interestData, zeni, ...). A gauger plate is not: item
-- 2480 is a plain GENERAL_TYPE row in item_basic with no data of its own, and there
-- is no addGaugerPlate binding. So the plate item is handed over as an ordinary item
-- and the capture it represents is held in char vars. The visible consequence is that
-- only the most recent capture can be appraised, which is what the quests need since
-- each of them turns in one plate.
--
-- THE APPRAISAL CURVE IS OURS. bg-wiki names the two inputs, distance and frontal
-- angle, and says there are four levels, but publishes no thresholds. The bands below
-- are tuning in the same spirit as martello.lua's regeneration rate.
-----------------------------------
require('scripts/globals/npc_util')
-----------------------------------

xi = xi or {}
xi.abyssea = xi.abyssea or {}
xi.abyssea.soulgauger = xi.abyssea.soulgauger or {}

-- Char vars, shared by all four quests so a plate taken for one is legible to another.
xi.abyssea.soulgauger.gradeVar = 'Soulgauger_Grade'
xi.abyssea.soulgauger.mobVar   = 'Soulgauger_Mob'

-- bg-wiki's "~5 yalms". Closer than the floor is as bad as too far, because the
-- device needs the whole fiend in frame.
local idealRange = 5.0
local nearFloor  = 2.0
local goodBand   = 3.0
local fairBand   = 7.0

xi.abyssea.soulgauger.grade =
{
    BLANK       = 0,
    POOR        = 1,
    FAIR        = 2,
    EXCELLENT   = 3,
}

--- Score one capture out of the four appraisal levels.
---@param player CBaseEntity
---@param mob CBaseEntity
---@return integer grade
local function appraise(player, mob)
    -- "You need to have a ... frontal angle on the mob", so the fiend has to be
    -- looking your way for the plate to show its face at all.
    if not mob:isFacing(player) then
        return xi.abyssea.soulgauger.grade.BLANK
    end

    local distance = mob:checkDistance(player)

    if distance < nearFloor or distance > fairBand then
        return xi.abyssea.soulgauger.grade.POOR
    end

    if math.abs(distance - idealRange) <= goodBand - 1.5 then
        return xi.abyssea.soulgauger.grade.EXCELLENT
    end

    return xi.abyssea.soulgauger.grade.FAIR
end

xi.abyssea.soulgauger.onItemCheck = function(target, item, param, caster)
    if not target:isMob() then
        return xi.msg.basic.ITEM_CANNOT_USE_TARGET
    end

    -- "Mind you, it's not the rank and file we're investigating here. Only the most
    -- powerful foes concern us." Ordinary mobs are not worth a plate.
    if not target:isNM() then
        return xi.msg.basic.ITEM_CANNOT_USE_TARGET
    end

    if caster:getEquipID(xi.slot.AMMO) ~= xi.item.BLANK_GAUGER_PLATE then
        return xi.msg.basic.ITEM_NO_ITEMS_EQUIPPED
    end

    if caster:getFreeSlotsCount() == 0 then
        return xi.msg.basic.FULL_INVENTORY
    end

    return 0
end

xi.abyssea.soulgauger.onItemUse = function(target, player, item)
    local grade = appraise(player, target)

    player:removeAmmo(1)

    -- A blank plate is still a plate; Cleades has a line for it ("Is this your idea
    -- of a joke? Why, this plate's completely blank!"), so it is still handed over.
    if npcUtil.giveItem(player, xi.item.GAUGER_PLATE) then
        player:setCharVar(xi.abyssea.soulgauger.gradeVar, grade)
        player:setCharVar(xi.abyssea.soulgauger.mobVar, target:getID())
    end
end

--- The grade of the plate the player is carrying, or nil if they hold none.
---@param player CBaseEntity
---@return integer|nil
xi.abyssea.soulgauger.heldGrade = function(player)
    if not player:hasItem(xi.item.GAUGER_PLATE) then
        return nil
    end

    return player:getCharVar(xi.abyssea.soulgauger.gradeVar)
end

--- The mob the carried plate depicts.
xi.abyssea.soulgauger.heldMob = function(player)
    return player:getCharVar(xi.abyssea.soulgauger.mobVar)
end

--- Hand the plate in and forget the capture.
xi.abyssea.soulgauger.consumePlate = function(player)
    player:delItem(xi.item.GAUGER_PLATE, 1)
    player:setCharVar(xi.abyssea.soulgauger.gradeVar, 0)
    player:setCharVar(xi.abyssea.soulgauger.mobVar, 0)
end
