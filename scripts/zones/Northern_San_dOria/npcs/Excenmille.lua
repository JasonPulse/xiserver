-----------------------------------
-- Area: Northern San d'Oria
--  NPC: Excenmille
-- Type: Trust NPC, Ballista Pursuivant
-- !pos -229.344 6.999 22.976 231
-----------------------------------
local ID = zones[xi.zone.NORTHERN_SAN_DORIA]
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local trustSandoria = player:getQuestStatus(xi.questLog.SANDORIA, xi.quest.id.sandoria.TRUST_SANDORIA)
    local excenmilleTrustChatFlag = player:getLocalVar('ExcenmilleTrustChatFlag')
    local rank3 = player:getRank(player:getNation()) >= 3 and 1 or 0

    if
        trustSandoria == xi.questStatus.QUEST_COMPLETED and
        not player:hasSpell(xi.magic.spell.CURILLA) and
        excenmilleTrustChatFlag == 0
    then
        player:startEvent(896, 0, 0, 0, 0, 0, 0, 0, rank3)
        player:setLocalVar('ExcenmilleTrustChatFlag', 1)
    else
        player:startEvent(29)
    end
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
