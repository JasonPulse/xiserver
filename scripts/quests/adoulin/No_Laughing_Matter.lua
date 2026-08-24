-----------------------------------
-- No Laughing Matter
-----------------------------------
-- Log ID: 9, Quest ID: 102
-- Peladi_Shalmohr : Western Adoulin (G-11), entity 17826008
-- Mischief_Marker : Western Adoulin (J-11), entity 17826009
-- !addquest 9 102
-----------------------------------
-- Retail (bg-wiki "No Laughing Matter").
-- |Start=Peladi Shalmohr, Western Adoulin (G-10/11) |Fame=Adoulin |FLevel=1
-- |Repeatable=No |Next=All the Way to the Bank
-- |Title=Apprentice Tarutaru Sauce Manager |Reward=900 Experience Points
--   1. Speak to Peladi Shalmohr inside the Mummers' Coalition.
--   2. Check the Mischief Marker at (J-11) for a cutscene with Tuffle-Buffle and
--      Musto-Rusto.
--   3. Trade the appetizer ingredients to the Mischief Marker:
--      Fire Crystal, Popoto, Stick of Selbina Butter.
--   4. Trade the main course ingredients:
--      Fire Crystal, Slice of Dhalmel Meat, Flask of Olive Oil, Pinch of Black Pepper.
--   5. Trade the dessert ingredients:
--      Fire Crystal, Stick of Selbina Butter, Faerie Apple, Pot of Maple Sugar,
--      Stick of Cinnamon.
--   6. Peladi Shalmohr appears in the last cutscene and signs you on.
--
-- TUFFLE-BUFFLE'S SYNTH FAILURES ARE NOT SIMULATED. bg-wiki warns that he may
-- break the ingredients and asks you to buy spares, but neither bg-wiki nor
-- FFXIclopedia publishes a rate, and picking one would be inventing retail
-- behaviour rather than reproducing it. Every trade here succeeds.
--
-- CSIDS PROBED LIVE ON THE PUPPET IN WESTERN ADOULIN, one !cs per id, each read
-- back off the chat log:
--   5043 -> Peladi: "I can't believe it! That flop of a duo causes prrroblem
--           after problem" through the 10142 accept prompt          THE OFFER
--   5044 -> "you were borrrn to be a manager! ... Rrready to make a splash"
--                                                                  her re-ask
--   5045 -> Tuffle-Buffle: "I could really go for some sweetaru trail cookies"
--           through the appetizer request              THE FIRST MARKER SCENE
--   5046 -> "Geez, how long could it possibly take to find some <food>???"
--           then the synth                     APPETIZER TRADE, asks for main
--   5047 -> the same opening with the main-course food     MAIN COURSE TRADE
--   5048 -> the same opening with the dessert food    DESSERT TRADE + Peladi
--   5049 / 5050 / 5051 -> Musto-Rusto: "Forgotten already? ... Necessary skills:
--           Cooking  Necessary crystal: Fire crystal"  the recipe, per stage
--   5052 -> Peladi: "keep Tarutaru Sauce out of trouble, or your days as an
--           apprentice manager are numbered"        her mid-quest reminder
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.NO_LAUGHING_MATTER)

local courses =
{
    {
        items    = { xi.item.FIRE_CRYSTAL, xi.item.POPOTO, xi.item.STICK_OF_SELBINA_BUTTER },
        trade    = 5046,
        reminder = 5049,
    },
    {
        items    = { xi.item.FIRE_CRYSTAL, xi.item.SLICE_OF_DHALMEL_MEAT, xi.item.FLASK_OF_OLIVE_OIL, xi.item.PINCH_OF_BLACK_PEPPER },
        trade    = 5047,
        reminder = 5050,
    },
    {
        items    = { xi.item.FIRE_CRYSTAL, xi.item.STICK_OF_SELBINA_BUTTER, xi.item.FAERIE_APPLE, xi.item.POT_OF_MAPLE_SUGAR, xi.item.STICK_OF_CINNAMON },
        trade    = 5048,
        reminder = 5051,
    },
}

quest.reward =
{
    fameArea = xi.fameArea.ADOULIN,
    exp      = 900,
    title    = xi.title.APPRENTICE_TARUTARU_SAUCE_MANAGER,
}

quest.sections =
{
    -- Section: offer
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ADOULIN) >= 1
        end,

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Peladi_Shalmohr'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(5043)
                end,
            },

            onEventFinish =
            {
                [5043] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                        quest:setVar(player, 'Course', 0)
                    end
                end,
            },
        },
    },

    -- Section: three courses, traded one at a time to the Mischief Marker
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Peladi_Shalmohr'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Course') == 0 then
                        return quest:event(5044)
                    end

                    return quest:event(5052)
                end,
            },

            ['Mischief_Marker'] =
            {
                onTrigger = function(player, npc)
                    local course = quest:getVar(player, 'Course')

                    if course == 0 then
                        return quest:progressEvent(5045)
                    end

                    local stage = courses[course]

                    if stage ~= nil then
                        return quest:event(stage.reminder)
                    end
                end,

                onTrade = function(player, npc, trade)
                    local stage = courses[quest:getVar(player, 'Course')]

                    if stage ~= nil and npcUtil.tradeHasExactly(trade, stage.items) then
                        return quest:progressEvent(stage.trade)
                    end
                end,
            },

            onEventFinish =
            {
                [5045] = function(player, csid, option, npc)
                    quest:setVar(player, 'Course', 1)
                end,

                [5046] = function(player, csid, option, npc)
                    player:confirmTrade()
                    quest:setVar(player, 'Course', 2)
                end,

                [5047] = function(player, csid, option, npc)
                    player:confirmTrade()
                    quest:setVar(player, 'Course', 3)
                end,

                [5048] = function(player, csid, option, npc)
                    player:confirmTrade()
                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
