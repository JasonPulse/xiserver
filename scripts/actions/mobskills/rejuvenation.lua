-----------------------------------
-- Rejuvenation
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    local master = mob:getMaster()

    if master ~= nil then
        -- Trust (Selh'teus): instantly restores HP, MP, and TP to the entire party.
        for _, member in pairs(master:getPartyWithTrusts()) do
            member:addHP(member:getMaxHP() - member:getHP())
            member:addMP(member:getMaxMP() - member:getMP())
            member:addTP(3000 - member:getTP())
        end
    else
        -- Enemy/boss version: single target.
        target:addHP(target:getMaxHP() - target:getHP())
        target:addMP(target:getMaxMP() - target:getMP())
        target:addTP(3000 - target:getTP())
    end

    skill:setMsg(xi.msg.basic.SELF_HEAL)
    return 0
end

return mobskillObject
