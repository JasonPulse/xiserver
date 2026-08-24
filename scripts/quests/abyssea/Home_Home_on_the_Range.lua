-----------------------------------
-- Home, Home on the Range
-----------------------------------
-- Log ID: 8, Quest ID: 69
-- Moogle       : Abyssea - Uleguerand (F-7), entity 17814099
-- Lumber_Chest : Abyssea - Uleguerand, entity 17814100
-- Fabric_Chest : Abyssea - Uleguerand, entity 17814101
-- !addquest 8 69
-----------------------------------
-- Retail (bg-wiki "Home, Home on the Range").
-- |Start=Moogle (A), Abyssea - Uleguerand  |Fame=aule |FLevel=2
-- |Item Reqs=KI Piece of sodden oak lumber, KI Sodden linen cloth,
--            KI Dhorme khimaira's mane
-- |Reward=1,500 Cruor  |Repeatable= (blank, so once only)
--   1. "Talk to the Moogle (A) at (F-7) Conflux #7. He will ask you to find him
--      materials."
--   2. "Retrieve a KI Piece of sodden oak lumber from the Lumber Chest at Conflux #1
--      near the maw."
--   3. "Return to the Moogle (A), who takes the log then asks for a KI Sodden linen
--      cloth. You can find one in the Fabric Chest at Conflux #6."
--   4. "After you turn that into him, the final item he needs is a KI Dhorme
--      khimaira's mane. You must defeat Dhorme Khimaira to obtain this. It will drop
--      to everyone who has this quest active."
--   5. Return to the Moogle for your reward.
--
-- CSIDS DECODED, NOT GUESSED. Per-csid attribution from each entity's byte ranges,
-- and the stage is readable straight off which key item each block's data[] names:
--   276 -> 7921 "a moogle without a Mog House is like a Mithra without a tail" --
--          THE OFFER. Its data[] names 1718 (Piece of sodden oak lumber), so this is
--          the block that asks for the lumber.
--   277 -> 7928 "I believe there should be some ${keyitem-plural: 0[2]} in storage
--          at one of the encampments" -- the lumber reminder. data[] 1718.
--   280 -> 7930 "Splendid!" + 7931 "I seem to have forgotten another most important
--          material" -- lumber handed over, cloth requested. data[] 1719 (Sodden
--          linen cloth).
--   281 -> 7933/7934 -- the cloth reminder. data[] 1719.
--   284 -> 7930 + 7935 "all I'll be needing is ${keyitem-article: 0[2]}" -- cloth
--          handed over, mane requested. data[] 1720 (Dhorme khimaira's mane).
--   285 -> 7936/7937/7938 "I fear you won't be finding a supply around camp this
--          time" -- the mane reminder. data[] 1720.
--   286 -> 7939 "is this truly a ${keyitem-singular: 0[2]} you've brought to me?"
--          plus msg 201, the activity-points marker -- THE TURN-IN.
--   287 -> 7941 "I now have everything I need to manufacture a magnificent new Mog
--          House" -- his post-completion line.
--   366 -> 7921 -- his idle line, the same opening without the request.
--   Lumber_Chest 278/279 -> 7929 "It is stocked to the brim with
--          ${keyitem-plural: 0[2]}." data[] 1718.
--   Fabric_Chest 282/283 -> 7929 with data[] 1719.
--
-- THE MANE comes from Dhorme Khimaira and "will drop to everyone who has this quest
-- active", so it is granted from the mob's death rather than a chest.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.HOME_HOME_ON_THE_RANGE)

-- Progress is the stage number, so the three fetch legs read in order.
local stageLumber = 0
local stageCloth  = 1
local stageMane   = 2
local stageDone   = 3

local cruorReward = 1500

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_ULEGUERAND,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ABYSSEA_ULEGUERAND) >= 2
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Moogle'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(276)
                end,
            },

            onEventFinish =
            {
                [276] = function(player, csid, option, npc)
                    quest:begin(player)
                    quest:setVar(player, 'Prog', stageLumber)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Lumber_Chest'] =
            {
                onTrigger = function(player, npc)
                    if
                        quest:getVar(player, 'Prog') ~= stageLumber or
                        player:hasKeyItem(xi.ki.PIECE_OF_SODDEN_OAK_LUMBER)
                    then
                        return quest:event(279, xi.ki.PIECE_OF_SODDEN_OAK_LUMBER)
                    end

                    npcUtil.giveKeyItem(player, xi.ki.PIECE_OF_SODDEN_OAK_LUMBER)

                    return quest:event(278, xi.ki.PIECE_OF_SODDEN_OAK_LUMBER)
                end,
            },

            ['Fabric_Chest'] =
            {
                onTrigger = function(player, npc)
                    if
                        quest:getVar(player, 'Prog') ~= stageCloth or
                        player:hasKeyItem(xi.ki.SODDEN_LINEN_CLOTH)
                    then
                        return quest:event(283, xi.ki.SODDEN_LINEN_CLOTH)
                    end

                    npcUtil.giveKeyItem(player, xi.ki.SODDEN_LINEN_CLOTH)

                    return quest:event(282, xi.ki.SODDEN_LINEN_CLOTH)
                end,
            },

            ['Moogle'] =
            {
                onTrigger = function(player, npc)
                    local prog = quest:getVar(player, 'Prog')

                    if prog == stageLumber then
                        if player:hasKeyItem(xi.ki.PIECE_OF_SODDEN_OAK_LUMBER) then
                            return quest:progressEvent(280)
                        end

                        return quest:event(277)
                    elseif prog == stageCloth then
                        if player:hasKeyItem(xi.ki.SODDEN_LINEN_CLOTH) then
                            return quest:progressEvent(284)
                        end

                        return quest:event(281)
                    elseif prog == stageMane then
                        if player:hasKeyItem(xi.ki.DHORME_KHIMAIRAS_MANE) then
                            return quest:progressEvent(286)
                        end

                        return quest:event(285)
                    end

                    return quest:event(366)
                end,
            },

            onEventFinish =
            {
                [280] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.PIECE_OF_SODDEN_OAK_LUMBER)
                    quest:setVar(player, 'Prog', stageCloth)
                end,

                [284] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.SODDEN_LINEN_CLOTH)
                    quest:setVar(player, 'Prog', stageMane)
                end,

                [286] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.DHORME_KHIMAIRAS_MANE)
                        quest:setVar(player, 'Prog', stageDone)
                        xi.abyssea.questReward(player, cruorReward, nil)
                    end
                end,
            },

            -- "It will drop to everyone who has this quest active", so the mane is
            -- granted on death rather than being a claim-gated drop.
            ['Dhorme_Khimaira'] =
            {
                onMobDeath = function(mob, player, optParams)
                    if
                        quest:getVar(player, 'Prog') == stageMane and
                        not player:hasKeyItem(xi.ki.DHORME_KHIMAIRAS_MANE)
                    then
                        npcUtil.giveKeyItem(player, xi.ki.DHORME_KHIMAIRAS_MANE)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Moogle'] = quest:event(287):replaceDefault(),
        },
    },
}

return quest
