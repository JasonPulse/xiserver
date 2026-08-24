-----------------------------------
-- Granddaddy Dearest
-----------------------------------
-- Log ID: 9, Quest ID: 26
-- Alienor   : Western Adoulin (E-8), entity 17825972
-- Anastase  : Ru'Lude Gardens (G-9), entity 17772843
-- !addquest 9 26
-----------------------------------
-- Retail (bg-wiki "Granddaddy Dearest").
-- |Start=Alienor, Western Adoulin (E-8)  |Fame=Adoulin |FLevel=3  |Repeatable=Yes
-- |Previous=Researchers from the West
--   1. "Speak to Alienor in Western Adoulin (E-8) to start the quest and receive KI
--      Tray of Adoulinian delicacies."
--   2. "Go to Ru'Lude Gardens (G-9) and speak to Anastase to receive KI Small bag of
--      Adoulinian delicacies."
--   3. "Anastase will ask you to check up on one of his subordinates, chosen at
--      random: Jillia in Selbina, Zurko-Bazurko in Mhaura, Quwi Orihbhe in Rabao, or
--      Wistful Bison in Norg."
--   4. "Return to Anastase and speak with him again."
--   5. "Return to Alienor."
--
-- The four subordinates are the same four that Researchers from the West sends you to,
-- which is why that quest is its prerequisite. Their entities are Jillia 17793138 in
-- Selbina, Zurko-Bazurko 17797258 in Mhaura, Quwi Orihbhe 17789017 in Rabao and
-- Wistful Bison 17809535 in Norg.
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, fired at the puppet in Western Adoulin:
--   5010 -> "Good day to you, adventurer! Have you registered with the Pioneers'
--           Coalition yet?"                                     Alienor's greeting
--   5009 -> "Hey, how goes the whole pioneering thing? You making sure to use those
--           waypoints?"                                            her other idle
-- Neither is quest-specific, so the delivery legs below are driven as plain
-- interactions with printToPlayer rather than firing a cutscene that was not proven
-- to belong to this quest.
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.GRANDDADDY_DEAREST)

-- Ordered so the roll can be stored as an index.
local subordinates =
{
    { zone = xi.zone.SELBINA, npc = 'Jillia'         },
    { zone = xi.zone.MHAURA,  npc = 'Zurko-Bazurko'  },
    { zone = xi.zone.RABAO,   npc = 'Quwi_Orihbhe'   },
    { zone = xi.zone.NORG,    npc = 'Wistful_Bison'  },
}

quest.reward =
{
    fameArea = xi.fameArea.ADOULIN,
}

--- Handing the small bag to whichever subordinate Anastase named.
local function deliveryZones()
    local zones = {}

    for index, entry in ipairs(subordinates) do
        zones[entry.zone] =
        {
            [entry.npc] =
            {
                onTrigger = function(player, npc)
                    if
                        quest:getVar(player, 'Target') ~= index or
                        not player:hasKeyItem(xi.ki.SMALL_BAG_OF_ADOULINIAN_DELICACIES)
                    then
                        return
                    end

                    player:delKeyItem(xi.ki.SMALL_BAG_OF_ADOULINIAN_DELICACIES)
                    quest:setVar(player, 'Delivered', 1)
                    player:printToPlayer('You hand over the small bag of Adoulinian delicacies, and it is received with obvious delight.', xi.msg.channel.NS_SAY)

                    return true
                end,
            },
        }
    end

    return zones
end

local accepted =
{
    check = function(player, status, vars)
        return status == xi.questStatus.QUEST_ACCEPTED or status == xi.questStatus.QUEST_COMPLETED
    end,

    [xi.zone.RULUDE_GARDENS] =
    {
        ['Anastase'] =
        {
            onTrigger = function(player, npc)
                -- Leg two: swap the tray for the small bag and name a subordinate.
                if player:hasKeyItem(xi.ki.TRAY_OF_ADOULINIAN_DELICACIES) then
                    player:delKeyItem(xi.ki.TRAY_OF_ADOULINIAN_DELICACIES)
                    npcUtil.giveKeyItem(player, xi.ki.SMALL_BAG_OF_ADOULINIAN_DELICACIES)
                    quest:setVar(player, 'Target', math.random(#subordinates))
                    player:printToPlayer('Anastase accepts the tray and presses a small bag into your hands, naming one of his researchers in the Middle Lands.', xi.msg.channel.NS_SAY)

                    return true
                end

                -- Leg four: report the delivery.
                if quest:getVar(player, 'Delivered') == 1 and quest:getVar(player, 'Reported') == 0 then
                    quest:setVar(player, 'Reported', 1)
                    player:printToPlayer('Anastase listens to your account of the visit, plainly relieved.', xi.msg.channel.NS_SAY)

                    return true
                end
            end,
        },
    },
}

for zoneId, handlers in pairs(deliveryZones()) do
    accepted[zoneId] = handlers
end

accepted[xi.zone.WESTERN_ADOULIN] =
{
    ['Alienor'] =
    {
        onTrigger = function(player, npc)
            if quest:getVar(player, 'Reported') ~= 1 then
                return
            end

            npcUtil.completeQuest(player, xi.questLog.ADOULIN, xi.quest.id.adoulin.GRANDDADDY_DEAREST, quest.reward)
            quest:setVar(player, 'Target', 0)
            quest:setVar(player, 'Delivered', 0)
            quest:setVar(player, 'Reported', 0)

            return true
        end,
    },
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE or status == xi.questStatus.QUEST_COMPLETED) and
                player:getQuestStatus(xi.questLog.JEUNO, xi.quest.id.jeuno.RESEARCHERS_FROM_THE_WEST) == xi.questStatus.QUEST_COMPLETED and
                player:getFameLevel(xi.fameArea.ADOULIN) >= 3 and
                not player:hasKeyItem(xi.ki.TRAY_OF_ADOULINIAN_DELICACIES) and
                not player:hasKeyItem(xi.ki.SMALL_BAG_OF_ADOULINIAN_DELICACIES)
        end,

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Alienor'] =
            {
                onTrigger = function(player, npc)
                    quest:begin(player)
                    quest:setVar(player, 'Delivered', 0)
                    quest:setVar(player, 'Reported', 0)
                    npcUtil.giveKeyItem(player, xi.ki.TRAY_OF_ADOULINIAN_DELICACIES)

                    return true
                end,
            },
        },
    },

    accepted,
}

return quest
