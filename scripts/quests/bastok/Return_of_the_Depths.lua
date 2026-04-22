-----------------------------------
-- Return of the Depths (retail title: "Return to the Depths")
-----------------------------------
-- Log ID: 1, Quest ID: 78
-- Ayame     : Metalworks (K-7)
-- Muckvix   : Lower Jeuno (H-10)
-- Magriffon : Kazham (I-7)
-- Tarnotik  : Oldton Movalpolos
-- Requires CoP expansion; prior A Question of Faith.
-----------------------------------
-- Retail: 5-step NPC chain culminating in Mine Shaft #2716 BCNM (6-man
-- vs Twilotak DRK + Moblin Wisewoman/Clergyman backup).
-- Simplified for 4-player server: the full NPC chain is preserved
-- (Garlic → Muckvix → Magriffon gil trade → Tarnotik), but the BCNM is
-- abstracted: trading Ahriman Tears to Tarnotik directly awards the
-- Bowyer Ring. If/when the Mine Shaft #2716 battlefield is built, swap
-- the reward step to gate on battlefield victory.
-- CSIDs best-guess; verify with !cs in-game.
-----------------------------------
local BOWYER_RING      = 14660
local MISAREAUX_GARLIC = 1661

local quest = Quest:new(xi.questLog.BASTOK, xi.quest.id.bastok.RETURN_OF_THE_DEPTHS)

quest.reward =
{
    fame     = 50,
    fameArea = xi.fameArea.BASTOK,
    title    = xi.title.GOBLIN_IN_DISGUISE,
}

-- Prog
-- 0 = need Misareaux Garlic for Muckvix
-- 1 = go to Magriffon with 10k gil
-- 2 = return to Muckvix
-- 3 = go to Tarnotik with Ahriman Tears
-- 4 = receive Bowyer Ring

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.BASTOK) >= 5
        end,

        [xi.zone.METALWORKS] =
        {
            ['Ayame'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(502)
                end,
            },

            onEventFinish =
            {
                [502] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.LOWER_JEUNO] =
        {
            ['Muckvix'] =
            {
                onTrade = function(player, npc, trade)
                    if
                        quest:getVar(player, 'Prog') == 0 and
                        npcUtil.tradeHasExactly(trade, MISAREAUX_GARLIC)
                    then
                        return quest:progressEvent(300)
                    end
                end,

                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Prog') == 2 then
                        return quest:progressEvent(302)
                    end
                end,
            },

            onEventFinish =
            {
                [300] = function(player, csid, option, npc)
                    player:confirmTrade()
                    player:addGil(2000)
                    player:messageSpecial(zones[xi.zone.LOWER_JEUNO].text.GIL_OBTAINED, 2000)
                    quest:setVar(player, 'Prog', 1)
                end,

                [302] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 3)
                end,
            },
        },

        [xi.zone.KAZHAM] =
        {
            ['Magriffon'] =
            {
                onTrade = function(player, npc, trade)
                    if
                        quest:getVar(player, 'Prog') == 1 and
                        npcUtil.tradeHasExactly(trade, { gil = 10000 })
                    then
                        return quest:progressEvent(400)
                    end
                end,
            },

            onEventFinish =
            {
                [400] = function(player, csid, option, npc)
                    player:confirmTrade()
                    player:addGil(10000) -- refunded per retail
                    quest:setVar(player, 'Prog', 2)
                end,
            },
        },

        [xi.zone.OLDTON_MOVALPOLOS] =
        {
            ['Tarnotik'] =
            {
                onTrade = function(player, npc, trade)
                    if
                        quest:getVar(player, 'Prog') == 3 and
                        npcUtil.tradeHasExactly(trade, xi.item.BOTTLE_OF_AHRIMAN_TEARS)
                    then
                        return quest:progressEvent(200)
                    end
                end,
            },

            onEventFinish =
            {
                [200] = function(player, csid, option, npc)
                    if player:getFreeSlotsCount() > 0 then
                        player:confirmTrade()
                        player:addItem(BOWYER_RING)
                        player:addGil(3000)
                        player:messageSpecial(zones[xi.zone.OLDTON_MOVALPOLOS].text.GIL_OBTAINED, 3000)
                        quest:complete(player)
                    end
                end,
            },
        },
    },
}

return quest
