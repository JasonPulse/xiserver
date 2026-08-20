-----------------------------------
-- Bringing Down the Mountain
-----------------------------------
-- Log ID: 8, Quest ID: 24
-- Diegai    : Abyssea - Tahrongi (H-7)/(I-7), entity 16962105
-- Baladanzo : Abyssea - Tahrongi (J-8), entity 16962113
-- !addquest 8 24
-----------------------------------
-- Retail (bg-wiki "Bringing Down the Mountain").
-- |Start=Diegai (A), Abyssea - Tahrongi  |Item Reqs=Gunpowder Swathe x10
-- |Reward=500 Cruor per trade, 5,000 Cruor total
--   1. Speak with Diegai (A) at the border of (H-7)/(I-7) near Conflux #07.
--   2. Travel to (J-8) and speak with Baladanzo (A).
--   3. Defeat Bog Body Qutrub around (J-5) until they drop 10 Gunpowder Swathes.
--   4. Return to Baladanzo at (J-8) and trade him all 10 -- or trade them a few
--      at a time, which is why the reward is quoted per trade.
--
-- CSIDS DECODED, NOT GUESSED, across both NPCs, with csidscan.py against
-- `xi-dat dialog 45`:
--   Diegai 330 -> 7924-7931  THE OFFER. 7927/7928 tell the story of the rubble,
--          and 7931 is the request: "You must check on Baladanzo for me."
--   Diegai 329 -> 7924       his idle sniffling before the quest.
--   Diegai 331 -> 7931       the reminder, the request on its own.
--   Diegai 332 -> 7937/7938  his line AFTER you have found Baladanzo, and the
--          hint that drives step 3: "I heard that those rotting bog bodies have
--          the ability to cut through s[tone]".
--   Baladanzo 335 -> 7933-7936  FIRST MEETING. 7934 "Diegai sent you, you say?",
--          7936 "Our future lies on the other side of this wall, in Mhaula!"
--   Baladanzo 336 -> 7935/7936  the same, shortened, on later visits.
--   Baladanzo 338 -> 7939/7940/7943/7944  THE FIRST TRADE. 7939 "Hm?
--          ${lettercase: 1}${article} ${item-article: 0[2]}?", 7940 "This will
--          help, but alone it will not serve to bring this mountain down",
--          7944 "In the meantime, take this" -- the per-trade cruor.
--   Baladanzo 339 -> 7941/7942  A LATER TRADE. 7941 "This makes ${number: 1}
--          ${item-given-plurality: 1[2], 0[2]} you have brought me", 7942 "With
--          ${number: 2} more, this stone beast will crumble before us." So the
--          running total is param 1 and the remainder is param 2.
--   Baladanzo 340 -> 7945-7947  THE FINAL TRADE, the tenth: "This is it, friend.
--          The day we have long waited for."
--   Baladanzo 337 -> 7943       the reminder, stating how many are still needed.
--
-- PROGRESS is a running count in the quest var 'Swathes' rather than a single
-- ten-item hand-in, because bg-wiki's reward line is "500 Cruor PER TRADE, 5,000
-- Cruor total" and 7941/7942 exist precisely to report a partial tally. Any
-- number of swathes may be traded at once.
--
-- ITEM: Gunpowder Swathe is id 2212 (`item_basic`), which had no enum name and
-- was added as GUNPOWDER_SWATHE after checking the id was unused.
-----------------------------------
local tahrongiID = zones[xi.zone.ABYSSEA_TAHRONGI]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.BRINGING_DOWN_THE_MOUNTAIN)

local swathesNeeded  = 10
local cruorPerSwathe = 500

-- Banks the swathes just traded and pays the per-trade cruor (7944 "In the
-- meantime, take this"). Shared by all three trade events.
local creditSwathes = function(player, questRef)
    local traded = player:getLocalVar('[BDTM]traded')
    if traded < 1 then
        return
    end

    player:confirmTrade()
    questRef:setVar(player, 'Swathes', math.min(questRef:getVar(player, 'Swathes') + traded, swathesNeeded))
    player:setLocalVar('[BDTM]traded', 0)

    local cruor = traded * cruorPerSwathe
    player:addCurrency('cruor', cruor)
    player:messageSpecial(tahrongiID.text.CRUOR_OBTAINED, cruor, player:getCurrency('cruor'))
end

quest.sections =
{
    -- bg-wiki lists no |Previous= and no |Quest Reqs=.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.ABYSSEA_TAHRONGI] =
        {
            ['Diegai'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(330)
                end,
            },

            ['Baladanzo'] = quest:event(334),

            onEventFinish =
            {
                [330] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    -- Accepted: find Baladanzo, then feed him swathes until the tenth.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_TAHRONGI] =
        {
            ['Baladanzo'] =
            {
                onTrade = function(player, npc, trade)
                    local brought = trade:getItemQty(xi.item.GUNPOWDER_SWATHE)
                    if brought < 1 or trade:getItemCount() ~= brought then
                        return
                    end

                    local have  = quest:getVar(player, 'Swathes')
                    local total = math.min(have + brought, swathesNeeded)

                    -- The event handler cannot see the trade, so carry the
                    -- amount across in a local var.
                    player:setLocalVar('[BDTM]traded', brought)

                    if total >= swathesNeeded then
                        return quest:progressEvent(340,
                            { [0] = xi.item.GUNPOWDER_SWATHE, [1] = total, [2] = 0 })
                    elseif have == 0 then
                        return quest:progressEvent(338,
                            { [0] = xi.item.GUNPOWDER_SWATHE, [1] = total, [2] = swathesNeeded - total })
                    end

                    return quest:progressEvent(339,
                        { [0] = xi.item.GUNPOWDER_SWATHE, [1] = total, [2] = swathesNeeded - total })
                end,

                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Met') == 0 then
                        return quest:progressEvent(335)
                    end

                    local remaining = swathesNeeded - quest:getVar(player, 'Swathes')

                    return quest:event(337,
                        { [0] = xi.item.GUNPOWDER_SWATHE, [2] = remaining })
                end,
            },

            ['Diegai'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Met') == 1 then
                        return quest:event(332)
                    end

                    return quest:event(331)
                end,
            },

            onEventFinish =
            {
                [335] = function(player, csid, option, npc)
                    quest:setVar(player, 'Met', 1)
                end,

                [338] = function(player, csid, option, npc)
                    creditSwathes(player, quest)
                end,

                [339] = function(player, csid, option, npc)
                    creditSwathes(player, quest)
                end,

                [340] = function(player, csid, option, npc)
                    creditSwathes(player, quest)

                    if quest:complete(player) then
                        quest:setVar(player, 'Swathes', 0)
                        quest:setVar(player, 'Met', 0)
                    end
                end,
            },
        },
    },
}

return quest
