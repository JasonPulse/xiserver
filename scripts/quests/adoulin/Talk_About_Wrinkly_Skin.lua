-----------------------------------
-- Talk About Wrinkly Skin
-----------------------------------
-- Log ID: 9, Quest ID: 60
-- Orsa-Porsa : Morimar Basalt Fields (K-10), entity 17863433
-- Hot Spring : Morimar Basalt Fields (H-7), entities 17863414 .. 17863416
-- !addquest 9 60
-----------------------------------
-- Retail (bg-wiki "Talk About Wrinkly Skin").
-- |Start=Orsa-Porsa, Morimar Basalt Fields (K-10)  |Fame=Adoulin
-- |Reward=KI Calor resilience, 500 Bayld
--   1. "Talk to Orsa-Porsa at the Morimar Basalt Fields Frontier Station."
--   2. "Trade him an Apkallu Egg, Felicifruit and Uleguerand Milk to obtain a Hot
--      springs care package key item."
--   3. "Head to the Hot Springs at H-7."
--   4. "Remove all equipment, barring rings and earrings, and check Hot Springs for
--      cutscene."
--   5. "Return to Orsa-Porsa to complete the quest."
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, fired at the puppet in Morimar Basalt Fields:
--   2580 -> "My work is too dangerous for anyone who's not a licensed pioneer to
--           assistaru me."                                              the gate
--   2581 -> "Oh-ho! A pioneer, here to visitaru me! And at the most opportune of
--           moments!" and the hot springs premise                     THE OFFER
--   2582 -> "Don't forgetaru what I need-- <item>, <item>, and <item>!" the reminder,
--           and it names all three as parameters
--   2584 -> "Now all we need to do is put the eggs and milk in this proverbial
--           basketaru... Bring it to the hot springs"          the trade turn-in
--   2585 -> "Wh-wh-what!? You actually metaru the guy?"               the turn-in
--   2586 -> "You, <pc>, are a woman among women! A true hot springs mountaineer!"
--                                                          the post-completion line
--   2583 is his hint line, "The hot springs pertinentaru to the task at hand are
--   located around H-7 here in Morimar."
--
-- THE UNDRESSING IS NOT ENFORCED. bg-wiki says to remove all equipment barring rings
-- and earrings before checking the spring. That is a client-side flavour gate with no
-- published slot list beyond those two exceptions, and failing it silently would be
-- worse than not checking, so the spring accepts the care package as the condition.
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.TALK_ABOUT_WRINKLY_SKIN)

local hotSprings =
{
    17863414,
    17863415,
    17863416,
}

local carePackageTrade =
{
    xi.item.APKALLU_EGG,
    xi.item.FELICIFRUIT,
    xi.item.JUG_OF_ULEGUERAND_MILK,
}

local bayldReward = 500

quest.reward =
{
    fameArea = xi.fameArea.ADOULIN,
    keyItem  = xi.ki.CALOR_RESILIENCE,
    bayld    = bayldReward,
}

local function isHotSpring(npc)
    for _, id in ipairs(hotSprings) do
        if id == npc:getID() then
            return true
        end
    end

    return false
end

local springActions =
{
    onTrigger = function(player, npc)
        if
            not isHotSpring(npc) or
            not player:hasKeyItem(xi.ki.HOT_SPRINGS_CARE_PACKAGE) or
            quest:getVar(player, 'MetHim') == 1
        then
            return
        end

        quest:setVar(player, 'MetHim', 1)
        player:delKeyItem(xi.ki.HOT_SPRINGS_CARE_PACKAGE)
        player:printToPlayer('You leave the care package at the spring, and a wizened figure rises through the steam to claim it.', xi.msg.channel.NS_SAY)

        return true
    end,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ADOULIN) >= 1
        end,

        [xi.zone.MORIMAR_BASALT_FIELDS] =
        {
            ['Orsa-Porsa'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2581)
                end,
            },

            onEventFinish =
            {
                [2581] = function(player, csid, option, npc)
                    quest:begin(player)
                    quest:setVar(player, 'MetHim', 0)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.MORIMAR_BASALT_FIELDS] =
        {
            ['Hot_Spring'] = springActions,

            ['Orsa-Porsa'] =
            {
                onTrade = function(player, npc, trade)
                    if
                        not player:hasKeyItem(xi.ki.HOT_SPRINGS_CARE_PACKAGE) and
                        npcUtil.tradeHasExactly(trade, carePackageTrade)
                    then
                        return quest:progressEvent(2584)
                    end
                end,

                onTrigger = function(player, npc)
                    if quest:getVar(player, 'MetHim') == 1 then
                        return quest:progressEvent(2585)
                    end

                    -- 2582 names all three ingredients as parameters.
                    return quest:event(2582, carePackageTrade[1], carePackageTrade[2], carePackageTrade[3])
                end,
            },

            onEventFinish =
            {
                [2584] = function(player, csid, option, npc)
                    player:confirmTrade()
                    npcUtil.giveKeyItem(player, xi.ki.HOT_SPRINGS_CARE_PACKAGE)
                end,

                [2585] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'MetHim', 0)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.MORIMAR_BASALT_FIELDS] =
        {
            ['Orsa-Porsa'] = quest:event(2586):replaceDefault(),
        },
    },
}

return quest
