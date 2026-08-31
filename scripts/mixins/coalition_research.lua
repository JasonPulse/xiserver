-----------------------------------
-- Coalition Assignments: Behavioral Research.
--
-- Client message 7414: "Head to <zone> to find and observe a monster located
-- there. The assignment will be considered completed if you become the victim
-- of a special attack from <creature>."
--
-- There is no global hook for "a mob landed a TP move on a player". The core
-- dispatches onMobWeaponSkill to the mob's own script by name, which would mean
-- a file per mob name across ten zones, so this rides the WEAPONSKILL_USE
-- listener instead: battleentity.cpp fires it on the mob with the target it
-- found, and a zone mixin puts it on every mob in the zone from one file.
--
-- Applied by the zone mixins under scripts/mixins/zones for the ten zones a
-- Research assignment names. The listener no-ops for everyone who is not
-- running one, so it is safe on a hot path.
-----------------------------------
require('scripts/globals/coalition_assignments')
require('scripts/globals/mixins')
-----------------------------------

g_mixins = g_mixins or {}

g_mixins.coalitionResearch = function(mob)
    mob:addListener('WEAPONSKILL_USE', 'COALITION_RESEARCH', function(user, target)
        if
            target == nil or
            not target:isPC()
        then
            return
        end

        xi.coalitionAssignments.onWeaponskillTaken(target, user:getFamily())
    end)
end

return g_mixins.coalitionResearch
