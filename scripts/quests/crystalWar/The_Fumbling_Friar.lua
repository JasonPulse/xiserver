-----------------------------------
-- The Fumbling Friar
-- !addquest 7 22
-- Fondactiont : !pos -95 0 196 164
-- qm2         : !pos 80 -1 457 89
-----------------------------------

local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.THE_FUMBLING_FRIAR)

quest.reward =
{
    item = xi.item.SCROLL_OF_RECALL_PASHH,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasKeyItem(xi.ki.BRONZE_RIBBON_OF_SERVICE) and -- TODO: Change to BRASS_RIBBON_OF_SERVICE when Campaign has been added.
                player:getMainLvl() >= 30
        end,

        [xi.zone.GARLAIGE_CITADEL_S] =
        {
            ['Fondactiont'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(26)
                end,
            },

            onEventFinish =
            {
                [26] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.GARLAIGE_CITADEL_S] =
        {
            ['Fondactiont'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.ORNATE_PACKAGE) then
                        return quest:progressEvent(28)
                    else
                        return quest:event(27)
                    end
                end,
            },

            onEventFinish =
            {
                [28] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.ORNATE_PACKAGE)
                    end
                end,
            },
        },

        [xi.zone.GRAUBERG_S] =
        {
            ['qm2'] =
            {
                onTrigger = function(player, npc)
                    -- Container:keyItem only CONSTRUCTS a KeyItemAction; the grant
                    -- happens in KeyItemAction:perform, which runs only if the
                    -- action is returned. This built it, threw it away, and
                    -- returned NoAction instead, so the Ornate Package was never
                    -- given and the quest could not be finished. NoAction also
                    -- carries Action.Priority.Progress (1000), which outranks the
                    -- legacy qm2.lua fallback, so nothing else could grant it
                    -- either. bg-wiki: "click it to obtain the {KI} Ornate package".
                    if not player:hasKeyItem(xi.ki.ORNATE_PACKAGE) then
                        return quest:keyItem(xi.ki.ORNATE_PACKAGE)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.GARLAIGE_CITADEL_S] =
        {
            ['Fondactiont'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(29):replaceDefault()
                end,
            },
        },
    },
}

return quest
