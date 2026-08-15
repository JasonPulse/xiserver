-----------------------------------
-- Forest for the Trees
-----------------------------------
-- Log ID: 0, Quest ID: 118
-- Ramua : Northern San d'Oria (E-3), !pos -184 11 256 231
-----------------------------------
-- Retail (bg-wiki "Forest for the Trees"): San d'Oria fame. You must already be
-- signed up with the Woodworking Guild (Cheupirudaux, Northern San d'Oria F-3).
-- Ramua gives the {KI} Timber survey checklist and a Hatchet; log an Arrowwood,
-- Ash, Yew, Willow and Walnut Log in Jugner Forest and bring them back.
-- Reward: Trainee Axe. bg-wiki's Title field is EMPTY for this quest.
--
-- CSIDs decoded, not guessed. Ramua is entity 17723430
-- (sql/npc_list.sql:26594; (17723430-16777216)//4096 = 231 rem 38 -> Northern
-- San d'Oria, matching the !pos above). Resolved with xidat/csidmsg.py and read
-- against `xi-dat dialog 231`:
--   856 -> 17768-17787, the offer. 17769 "You are a member of the Carpenters'
--          Guild, are you not?", 17774 "only my assigned area--Jugner
--          Forest--incomplete", 17787 "here's the ${keyitem-singular: 0[2]} and
--          a freshly sharpened ${item-singular: 1[2]}" => param [0] is the
--          Timber survey checklist, param [1] is the Hatchet.
--   857 -> 17788 "My future as a carpenter is in your hands." = accepted reminder.
--   858 -> 17789-17799, the partial turn-in; separate lines cover the
--          0/1/2/3/4-still-missing cases, params [1]..[5] naming the missing logs.
--   860 -> 17800-17808, the successful turn-in; 17808 hands over
--          ${item-singular: 1[2]} = the Trainee Axe.
--
-- Three bugs fixed from the previous version beyond the CSIDs:
--   1. It fired 635/636. Those are MORUNAUDE's events (entity 17723523, zone 231
--      idx 131), and sandoria/Unexpected_Treasure.lua correctly binds them to
--      her. Ramua's real set is 625, 856-861, 560.
--   2. The bit arithmetic could never complete. logBits held bit *values*
--      (1,2,4,8,16) but they were passed to utils.mask.getBit/setBit as bit
--      *positions* via `bit - 1`, so Yew landed on position 3, Willow on 7 and
--      Walnut on 15. The accumulated mask was 1+2+8+128+32768 = 32907, and the
--      target `allLogsMask = 31` was unreachable. Positions are now 0-4.
--   3. On the final trade it returned progressEvent(636) without first saving
--      newChecklist, so the completion test in onEventFinish read a stale var.
--      The mask is now always persisted before the event fires.
--
-- Flagged for one in-game probe: dialog 17777 "What do you say? ${selection-lines}"
-- and 17785 "Ready? ${selection-lines}" mean 856 contains TWO selection prompts,
-- so the client may require an onEventUpdate mid-event. The option semantics are
-- not derivable from the dump.
-----------------------------------
local quest = Quest:new(xi.questLog.SANDORIA, xi.quest.id.sandoria.FOREST_FOR_THE_TREES)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.SANDORIA,
    item     = xi.item.TRAINEE_AXE,
}

-- Bit POSITION per required log type, stored in the quest var 'Checklist'.
local logBits =
{
    [xi.item.ARROWWOOD_LOG] = 0,
    [xi.item.ASH_LOG]       = 1,
    [xi.item.YEW_LOG]       = 2,
    [xi.item.WILLOW_LOG]    = 3,
    [xi.item.WALNUT_LOG]    = 4,
}

local allLogsMask = 31 -- bits 0-4 set

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.SANDORIA) >= 3
        end,

        [xi.zone.NORTHERN_SAN_DORIA] =
        {
            ['Ramua'] =
            {
                onTrigger = function(player, npc)
                    -- bg-wiki: "You need to have already signed up with the
                    -- Woodworking Guild for this quest to be activated."
                    if player:getSkillRank(xi.skill.WOODWORKING) > 0 then
                        return quest:progressEvent(856, { [0] = xi.ki.TIMBER_SURVEY_CHECKLIST, [1] = xi.item.HATCHET })
                    end
                end,
            },

            onEventFinish =
            {
                [856] = function(player, csid, option, npc)
                    quest:begin(player)
                    npcUtil.giveKeyItem(player, xi.ki.TIMBER_SURVEY_CHECKLIST)
                    npcUtil.giveItem(player, xi.item.HATCHET)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.NORTHERN_SAN_DORIA] =
        {
            ['Ramua'] =
            {
                onTrade = function(player, npc, trade)
                    local checklist = quest:getVar(player, 'Checklist')
                    local updated   = checklist

                    for itemId, bitPos in pairs(logBits) do
                        if
                            not utils.mask.getBit(checklist, bitPos) and
                            npcUtil.tradeHas(trade, itemId)
                        then
                            updated = utils.mask.setBit(updated, bitPos, true)
                        end
                    end

                    if updated == checklist then
                        return
                    end

                    -- Persist before firing either event, so the completion test
                    -- below never reads a stale mask.
                    quest:setVar(player, 'Checklist', updated)
                    player:confirmTrade()

                    if updated == allLogsMask then
                        return quest:progressEvent(860)
                    end

                    return quest:progressEvent(858)
                end,

                onTrigger = function(player, npc)
                    return quest:event(857)
                end,
            },

            onEventFinish =
            {
                [860] = function(player, csid, option, npc)
                    if quest:getVar(player, 'Checklist') == allLogsMask then
                        if quest:complete(player) then
                            player:delKeyItem(xi.ki.TIMBER_SURVEY_CHECKLIST)
                        end
                    end
                end,
            },
        },
    },
}

return quest
