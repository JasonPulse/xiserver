-----------------------------------
-- Zone: Abyssea - Vunkerl
--  NPC: Bastion Prefect
-----------------------------------
require('scripts/globals/bastion')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.bastion.onTrigger(player, npc)
end

return entity
