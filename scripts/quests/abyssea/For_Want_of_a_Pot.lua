-----------------------------------
-- For Want of a Pot
-----------------------------------
-- Log ID: 8, Quest ID: 47
-- Naruru      : Abyssea - Attohwa (G-10), entity 17658619
-- Cargo_Crate : Abyssea - Attohwa (H-8),  entity 17658621
-- Ranpi-Monpi : Windurst Waters,          entity 17752138
-- !addquest 8 47
-----------------------------------
-- Retail (bg-wiki "For Want of a Pot").
-- |Start=Naruru (A) (G-10), Abyssea - Attohwa  |Fame=aatt  |FLevel=3
-- |Item Reqs=Sieglinde Putty  |Reward=Orblight  |Next=Family Ties
--   1. Speak to Naruru (A) at (G-10) to begin.
--   2. Interact with the Cargo Crate at (H-8) for KI Damaged stewpot.
--   3. Return to Naruru, then speak to Ranpi-Monpi in Windurst Waters.
--   4. Trade the Sieglinde Putty to him for KI Naruru's stewpot.
--   5. Return to Naruru.
--
-- Chain head for Family_Ties.lua, which gates on this being complete.
--
-- Csids from xidat/csidmsg.py against the zone dialog dumps. Naruru owns 366-374
-- and 395; 373/374/395 are Family Ties and are untouched here.
--   366 -> 8236-8240  her monologue before the quest is available
--   367 -> 8241-8244  offer; 8244 seeds Family Ties
--   368 -> 8245       she recognises the pot
--   369 -> 8246/8247  the hole, and what sends you to Windurst
--   370 -> 8248       turn-in
--   371 -> 8249       post-completion
--   1020 -> 12399-12403, Ranpi-Monpi. Covers both halves of the repair, the same
--           shape Vegetable_Vegetable_Frustration.lua's 5212 has. The trade flags
--           which half just played.
--
-- The Cargo Crate owns no event blocks, so the pickup is a plain key item grant.
-- Items: xi.item.BOTTLE_OF_SIEGLINDE_PUTTY 1886, xi.item.ORBLIGHT 438 (added).
-- Key items DAMAGED_STEWPOT and NARURUS_STEWPOT already existed and appear in no
-- entity's data[], so both are granted server-side.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.FOR_WANT_OF_A_POT)

local cargoCrate = 17658621

quest.reward =
{
    item     = xi.item.ORBLIGHT,
    fameArea = xi.fameArea.ABYSSEA_ATTOHWA,
}

quest.sections =
{
    -- bg-wiki lists no |Previous=; |FLevel=3 against |Fame=aatt is the only gate.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ABYSSEA_ATTOHWA) >= 3
        end,

        [xi.zone.ABYSSEA_ATTOHWA] =
        {
            ['Naruru'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(367)
                end,
            },

            onEventFinish =
            {
                [367] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    -- Fetch the damaged pot from the wreckage, then show it to Naruru.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 0
        end,

        [xi.zone.ABYSSEA_ATTOHWA] =
        {
            ['Cargo_Crate'] =
            {
                onTrigger = function(player, npc)
                    if
                        npc:getID() ~= cargoCrate or
                        player:hasKeyItem(xi.ki.DAMAGED_STEWPOT)
                    then
                        return
                    end

                    npcUtil.giveKeyItem(player, xi.ki.DAMAGED_STEWPOT)

                    return quest:noAction()
                end,
            },

            ['Naruru'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.DAMAGED_STEWPOT) then
                        return quest:progressEvent(368)
                    end

                    return quest:event(366)
                end,
            },

            onEventFinish =
            {
                -- 8245 recognition, then 8246/8247 send you to the guild.
                [368] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 1)
                end,
            },
        },
    },

    -- The guild repair, and back to Naruru with a whole pot.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 1
        end,

        [xi.zone.ABYSSEA_ATTOHWA] =
        {
            ['Naruru'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.NARURUS_STEWPOT) then
                        return quest:progressEvent(370)
                    end

                    return quest:event(369)
                end,
            },

            onEventFinish =
            {
                [370] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.NARURUS_STEWPOT)

                    if quest:complete(player) then
                        quest:setVar(player, 'Prog', 0)
                    end
                end,
            },
        },

        [xi.zone.WINDURST_WATERS] =
        {
            ['Ranpi-Monpi'] =
            {
                onTrade = function(player, npc, trade)
                    if
                        player:hasKeyItem(xi.ki.DAMAGED_STEWPOT) and
                        npcUtil.tradeHasExactly(trade, xi.item.BOTTLE_OF_SIEGLINDE_PUTTY)
                    then
                        quest:setVar(player, 'Repairing', 1)

                        return quest:progressEvent(1020, xi.item.BOTTLE_OF_SIEGLINDE_PUTTY)
                    end
                end,

                onTrigger = function(player, npc)
                    if not player:hasKeyItem(xi.ki.DAMAGED_STEWPOT) then
                        return
                    end

                    return quest:progressEvent(1020, xi.item.BOTTLE_OF_SIEGLINDE_PUTTY)
                end,
            },

            onEventFinish =
            {
                -- 1020 carries both halves: 12401 asks for the putty, 12402/12403
                -- hand the mended pot back. Only the traded run swaps the key item.
                [1020] = function(player, csid, option, npc)
                    if quest:getVar(player, 'Repairing') ~= 1 then
                        return
                    end

                    player:confirmTrade()
                    quest:setVar(player, 'Repairing', 0)
                    player:delKeyItem(xi.ki.DAMAGED_STEWPOT)
                    npcUtil.giveKeyItem(player, xi.ki.NARURUS_STEWPOT)
                end,
            },
        },
    },

    -- Completed: 8249, she can finally cook for the camp.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_ATTOHWA] =
        {
            ['Naruru'] = quest:event(371):replaceDefault(),
        },
    },
}

return quest
