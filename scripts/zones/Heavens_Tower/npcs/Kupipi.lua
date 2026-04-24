-----------------------------------
-- Area: Heaven's Tower
--  NPC: Kupipi
-- Involved in Mission 2-3
-- Involved in Quest: Riding on the Clouds
-- !pos 2 0.1 30 242
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local trustWindurst = player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.TRUST_WINDURST)
    local kupipiTrustChatFlag = player:getLocalVar('KupipiTrustChatFlag')

    if
        trustWindurst == xi.questStatus.QUEST_COMPLETED and
        not player:hasSpell(xi.magic.spell.NANAA_MIHGO) and
        kupipiTrustChatFlag == 0
    then
        player:startEvent(438)
        player:setLocalVar('KupipiTrustChatFlag', 1)
    elseif player:getNation() == xi.nation.WINDURST then
        if player:getRank(player:getNation()) == 10 then
            player:startEvent(408) -- After achieving Windurst Rank 10, Kupipi has more to say
        else
            player:startEvent(251)
        end
    else
        player:startEvent(251)
    end
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
