-----------------------------------
-- Area: Mog Garden (280)
--  NPC: Chacharoon
-----------------------------------
-- Two entities carry this name: 17924231 in the garden proper and 17924232 in
-- the Rearing Grounds. Their options open on csid 1075 and 1088, both confirmed
-- live rendering message 8601, and "Move to a different location." is what
-- carries the player between the two.
--
-- A third, 17924187, is the cutscene stand-in for the Release the Fleece
-- arrival and stays on status 6.
--
-- Until Cry Not, Caretaker is finished the quest scripts own this NPC, so this
-- fallback only opens the rearing options once the system is unlocked. Handlers
-- from the interaction framework are tried first and this runs only when none
-- of them produced an action.
-----------------------------------
require('scripts/globals/monster_rearing')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    if not xi.monsterRearing.unlocked(player) then
        xi.monsterRearing.say(player, 'Chacharoon busy learning way of scarebeast. Come baaack later!', 'Chacharoon')
        return
    end

    xi.monsterRearing.chacharoonOnTrigger(player, npc)
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.monsterRearing.chacharoonOnEventUpdate(player, csid, option)
end

entity.onEventFinish = function(player, csid, option, npc)
    xi.monsterRearing.chacharoonOnEventFinish(player, csid, option)
end

return entity
