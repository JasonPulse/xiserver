-----------------------------------
-- Fear of the Dark II
-----------------------------------
-- Log ID: 6, Quest ID: 14
-- Suldiran : Al Zahbi (J-10) Upper Level, entity 16974322
-- !addquest 6 14
-----------------------------------
-- Retail (bg-wiki "Fear of the Dark II").
-- |Start=Suldiran, Al Zahbi (J-10) Upper Level  |Repeatable=Yes  |Previous= none
-- |Item Reqs=2 Imp Wing  |Reward=200 Gil
--   1. Speak to Suldiran at (J-10) on the upper level.
--   2. Bring him 2 Imp Wings.
--   3. Trade them to complete the quest.
--
-- CSIDS DECODED, NOT GUESSED. Suldiran is 16974322; (16974322-16777216) =
-- 197106, 197106//4096 = 48 rem 498 -> Al Zahbi, 0x010301F2. `xi-dat events 48`
-- gives him 14, 15, 16, 17, 18, 208. Resolved with csidscan.py against
-- `xi-dat dialog 48`:
--   14 -> 7950-7957  THE OFFER. 7950 "There's something foul in the air of late
--         ... It is the 'true darkness.'", 7953 carries the request ("Such a
--         charm would need to be made of ${number: 1} ${item-given-plurality:
--         1[2], 0[2]}..."), and 7955 is the accept prompt: "Will you gather the
--         materials? ${selection-lines} As well as some for myself! / I don't
--         think so..." -- the affirmative is the FIRST line, so OPTION 0
--         ACCEPTS. 7957 is the decline ("You do not share my fear...").
--         The count is param 1 and the item is param 0.
--   15 -> 7958       the reminder: "My charm requires ${number: 1} ${item...}
--         Make haste!"
--   17 -> 7960/7961  THE TURN-IN.
--   208 -> 7674      an unrelated Al Zahbi line, not part of this quest.
--
-- ITEM: Imp Wing is the existing IMP_WING (2163).
-- Note this is the Aht Urhgan quest (log 6, id 14). Fear of the Dark III is a
-- separate Abyssea quest with its own file and is unrelated to this chain.
-----------------------------------

local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.FEAR_OF_THE_DARK_II)

local wingCount = 2

quest.reward =
{
    gil = 200,
}

quest.sections =
{
    -- bg-wiki lists no |Previous= and no |Quest Reqs=. COMPLETED is accepted
    -- because |Repeatable=Yes.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE or
                status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.AL_ZAHBI] =
        {
            ['Suldiran'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(14, { [0] = xi.item.IMP_WING, [1] = wingCount })
                end,
            },

            onEventFinish =
            {
                [14] = function(player, csid, option, npc)
                    -- 7955: 0 "As well as some for myself!", 1 "I don't think so..."
                    if option ~= 0 then
                        return
                    end

                    if player:getQuestStatus(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.FEAR_OF_THE_DARK_II) == xi.questStatus.QUEST_COMPLETED then
                        player:addQuest(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.FEAR_OF_THE_DARK_II)
                    else
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    -- Accepted: bring him the two wings.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.AL_ZAHBI] =
        {
            ['Suldiran'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, { { xi.item.IMP_WING, wingCount } }) then
                        return quest:progressEvent(17)
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(15, { [0] = xi.item.IMP_WING, [1] = wingCount })
                end,
            },

            onEventFinish =
            {
                [17] = function(player, csid, option, npc)
                    player:confirmTrade()
                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
