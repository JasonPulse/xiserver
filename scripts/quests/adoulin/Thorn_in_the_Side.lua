-----------------------------------
-- Thorn in the Side
-----------------------------------
-- Log ID: 9, Quest ID: 121
-- Zaffeld              : Eastern Adoulin (J-8), entity 17830131
-- Occultist_Footprints : Yorcia Weald (J-6),    entity 17855033
-- !addquest 9 121
-----------------------------------
-- Retail (bg-wiki "Thorn in the Side").
-- |Start=Zaffeld, Eastern Adoulin (J-8)  |Fame=Adoulin  |FLevel=3
-- |Quest Reqs=Snapweed Tendril x2, Snapweed Secretion  |Reward=1,000 Bayld
-- |Previous=  |Next=Velkkovert Operations
--   1. Speak to Zaffeld (J-8) in Eastern Adoulin.
--   2. Click the Occultist Footprints at the I-6/J-6 border in Yorcia Weald.
--   3. Trade 1 Snapweed Secretion and 2 Snapweed Tendrils to them.
--
-- Chain head for Velkkovert Operations, which gates on this being complete.
--
-- Zone 257's yml dialog is shifted; read dialog-table-257.xml instead. Ids below
-- are from the XML, and the same sweep reproduced Velkkovert's live-probed
-- 5047/5048/5049, which is what makes the neighbouring ids trustworthy.
--
-- Eastern Adoulin, holder 17830076 except 33 which is on Zaffeld:
--   31 -> 10092-10109  offer; accept prompt 10107, declined branch 10109
--   32 -> 10110-10114  re-ask
--   33 -> 10117-10119  nudge and post-completion, one csid for both states
-- Yorcia Weald, on the footprints:
--   102 -> 7897-7932  the coven's demand, Nashu's plan
--   103 -> 7933-7935  mid-quest; grants nothing, the items are all the player's
--   104 -> 7936-7951  turn-in. Retail ends this quest in failure, hence 10119.
--
-- Nashu is status 6 in every npc_list row, so the re-ask comes off Zaffeld.
-- Accept is option 1: Adoulin selection dialogs are 1-based, matching the
-- live-probed 5047 in Velkkovert_Operations.lua.
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.THORN_IN_THE_SIDE)

local occultistFootprints = 17855033

-- The coven wants both kinds off the snapweeds in the weald. 7905 asks for the
-- tendrils by count, so the pair is ordered the way the demand is spoken.
local covenDemand =
{
    { xi.item.SNAPWEED_TENDRIL, 2 },
    xi.item.BOTTLE_OF_SNAPWEED_SECRETION,
}

quest.reward =
{
    fameArea = xi.fameArea.ADOULIN,
    bayld    = 1000,
}

quest.sections =
{
    -- Section: Zaffeld reads the trap reports and Nashu invites himself along.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ADOULIN) >= 3
        end,

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Zaffeld'] =
            {
                -- 32 is the "changed your mind?" scene, so a player who turned
                -- Nashu down once gets that rather than the full introduction.
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Declined') == 1 then
                        return quest:progressEvent(32)
                    end

                    return quest:progressEvent(31)
                end,
            },

            onEventFinish =
            {
                [31] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                    else
                        quest:setVar(player, 'Declined', 1)
                    end
                end,

                [32] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:setVar(player, 'Declined', 0)
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    -- Section: the weald, the demand, and a capture that goes wrong.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.YORCIA_WEALD] =
        {
            ['Occultist_Footprints'] =
            {
                onTrade = function(player, npc, trade)
                    if
                        npc:getID() == occultistFootprints and
                        quest:getVar(player, 'Coven') == 1 and
                        npcUtil.tradeHasExactly(trade, covenDemand)
                    then
                        return quest:progressEvent(104)
                    end
                end,

                onTrigger = function(player, npc)
                    if npc:getID() ~= occultistFootprints then
                        return
                    end

                    if quest:getVar(player, 'Coven') == 0 then
                        return quest:progressEvent(102)
                    end

                    return quest:event(103)
                end,
            },

            onEventFinish =
            {
                [102] = function(player, csid, option, npc)
                    quest:setVar(player, 'Coven', 1)
                end,

                [104] = function(player, csid, option, npc)
                    player:confirmTrade()

                    if quest:complete(player) then
                        quest:setVar(player, 'Coven', 0)
                    end
                end,
            },
        },

        -- 10117, the nudge back towards the weald.
        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Zaffeld'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(33)
                end,
            },
        },
    },

    -- Section: 10119, Zaffeld on how it ended in failure and how the traps stopped.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Zaffeld'] = quest:event(33):replaceDefault(),
        },
    },
}

return quest
