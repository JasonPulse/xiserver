-----------------------------------
-- Soulgauger SGR-1 (18679)
-----------------------------------
---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    return xi.abyssea.soulgauger.onItemCheck(target, item, param, caster)
end

itemObject.onItemUse = function(target, user, item, action)
    xi.abyssea.soulgauger.onItemUse(target, user, item)
end

return itemObject
