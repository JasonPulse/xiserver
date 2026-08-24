-----------------------------------
-- Getting Lucky
-----------------------------------
-- Log ID: 8, Quest ID: 62
-- Kurou-Morou : Abyssea - Grauberg (I-12), entity 17818242
-- Scuff Mark  : Abyssea - Grauberg, entities 17818243 and 17818245
-- !addquest 8 62
-----------------------------------
-- Retail (bg-wiki "Getting Lucky").
-- |Start=Kurou-Morou (A), Abyssea - Grauberg  |Fame=agra |FLevel=1  |Repeatable=Yes
-- |Reward=400 Cruor first time, 200 subsequently. Chance at an Empyrean +1 HANDS
--         seal (Unkai / Caller's / Estoqueur's / Mavi).
--   1. "Speak to Kurou-Morou (A) at Conflux #2 (I-12) to begin this quest."
--   2. "He asks for one purchasable 'Goblin' item and tells you one of three
--      locations."
--   3. "Trade the requested item to the Scuff Mark targetable location at the spot
--      specified to make Ramblix (A) appear."
--   "Zoning is required in order to repeat this quest."
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, fired at the puppet in Abyssea - Grauberg:
--   239 -> "Greetings! You stand before Kurou-Morou the Magnificentaru, from whose
--          astrologically enlightened eyes naught can be..."          THE OFFER
--   240 -> "Your lucky item is <item>!"          the assignment, and the reminder
--   242 -> "Hehehe, no need to say a word, friend. The cosmos has already revealed to
--          me that good fortune has indeed visited you."               the turn-in
--
-- TWO DEVIATIONS FROM BG-WIKI, both forced by our data rather than chosen:
--
-- 1. bg-wiki says "Speak to Cornelia (A) near Conflux #4 to complete the quest."
--    That does not match the decoded dialog. Cornelia's csids in this zone (238, 244,
--    245) are all about her wyvern research, while 242 on Kurou-Morou is plainly this
--    quest's completion line. The quest therefore closes at Kurou-Morou, and the
--    wiki line reads like a copy-paste from a neighbouring quest.
-- 2. bg-wiki names THREE possible locations but npc_list places only TWO Scuff Marks
--    in this zone, 17818243 and 17818245. Only the placed pair is offered. Ramblix
--    has no row in Abyssea - Grauberg at all, so his appearance on a successful
--    delivery is not reproduced; the delivery itself still registers.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.GETTING_LUCKY)

-- The three purchasable "Goblin" items bg-wiki lists. Stored by index in a quest var
-- so the same one is still being asked for after a relog.
local luckyItems =
{
    xi.item.LOAF_OF_GOBLIN_BREAD,
    xi.item.GOBLIN_PIE,
    xi.item.CHUNK_OF_GOBLIN_CHOCOLATE,
}

local scuffMarks =
{
    17818243,
    17818245,
}

local handsSeals =
{
    xi.item.UNKAI_SEAL_HANDS,
    xi.item.CALLERS_SEAL_HANDS,
    xi.item.ESTOQUEURS_SEAL_HANDS,
    xi.item.MAVI_SEAL_HANDS,
}

local cruorFirst  = 400
local cruorRepeat = 200

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_GRAUBERG,
}

--- Roll a fresh item and destination. Both are stored one-based so zero can keep
--- meaning "not assigned yet".
local function assignRun(player)
    quest:setVar(player, 'Item', math.random(#luckyItems))
    quest:setVar(player, 'Mark', math.random(#scuffMarks))
    quest:setVar(player, 'Delivered', 0)
end

local function assignedItem(player)
    return luckyItems[quest:getVar(player, 'Item')] or luckyItems[1]
end

--- The delivery. Only the Scuff Mark he actually named counts, which is the whole
--- point of the quest, so the entity id is checked as well as the item.
local deliverAction =
{
    onTrade = function(player, npc, trade)
        if
            npc:getID() == scuffMarks[quest:getVar(player, 'Mark')] and
            npcUtil.tradeHasExactly(trade, assignedItem(player))
        then
            quest:setVar(player, 'Delivered', 1)

            return true
        end
    end,
}

local function payOut(player, cruor)
    xi.abyssea.questReward(player, cruor, handsSeals)
    quest:setVar(player, 'Delivered', 0)
    xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.GETTING_LUCKY)
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ABYSSEA_GRAUBERG) >= 1
        end,

        [xi.zone.ABYSSEA_GRAUBERG] =
        {
            ['Kurou-Morou'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(239)
                end,
            },

            onEventFinish =
            {
                [239] = function(player, csid, option, npc)
                    quest:begin(player)
                    assignRun(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_GRAUBERG] =
        {
            ['Scuff_Mark'] = deliverAction,

            ['Kurou-Morou'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Delivered') == 0 then
                        -- 240 renders "Your lucky item is <item>!", so the item id is
                        -- passed for it to name.
                        return quest:event(240, assignedItem(player))
                    end

                    return quest:progressEvent(242)
                end,
            },

            onEventFinish =
            {
                [242] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        payOut(player, cruorFirst)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_GRAUBERG] =
        {
            ['Scuff_Mark'] = deliverAction,

            ['Kurou-Morou'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Delivered') == 1 then
                        return quest:progressEvent(242)
                    elseif quest:getMustZone(player) then
                        -- Not yet zoned, so he is still talking about the run just
                        -- finished rather than handing out a fresh one.
                        return quest:event(240, assignedItem(player))
                    end

                    return quest:progressEvent(239)
                end,
            },

            onEventFinish =
            {
                [239] = function(player, csid, option, npc)
                    assignRun(player)
                end,

                [242] = function(player, csid, option, npc)
                    payOut(player, cruorRepeat)
                end,
            },
        },
    },
}

return quest
