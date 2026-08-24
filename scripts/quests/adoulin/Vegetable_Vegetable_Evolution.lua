-----------------------------------
-- Vegetable Vegetable Evolution
-----------------------------------
-- Log ID: 9, Quest ID: 109
-- Amchuchus_Laboratory : Western Adoulin (J-10), entity 17826028
-- qm (Yorcia Weald I-8): Yorcia Weald, entity 17855075
-- _6tc                 : Lower Jeuno, the Tenshodo door, entity 17780832
-- !addquest 9 109
-----------------------------------
-- Retail (bg-wiki "Vegetable Vegetable Evolution").
-- |Start=Door: Amuchuchu's Laboratory, Western Adoulin
-- |Fame=Adoulin |FLevel=4 |Previous=Vegetable Vegetable Revolution
-- |Title=Vegetable Evolutionary |Reward=2000 Bayld, 12 Rarab Tail
--   1. Click the laboratory door in the back of the Inventors' Coalition.
--   2. Check the ??? in Yorcia Weald at (I-8) near the Bryophitic Boulder Ergon
--      Locus for a cutscene, and the Midras's explosive sample and Report on
--      Midras's explosive key items.
--   3. Enter the Tenshodo in Lower Jeuno for a cutscene.
--   4. Return to the laboratory door for the reward.
--
-- bg-wiki also lists two account-wide gates the header does not: the player must
-- be at least Rank 5 in a home nation, and must hold Magicite (the Rank 4 mission
-- reward) or Midras refuses to send them, saying they do not know the Tenshodo.
-- Both are checked here rather than left to the client, because the client branch
-- that plays without Magicite hands over nothing and would strand the quest.
--
-- CSIDS DECODED FROM THE CLIENT EVENT PROGRAMS. Each was confirmed against the
-- dialog its byte range references:
--   Western Adoulin 5062 on 17826028 -> 10775-10791, Amchuchu asking you to look
--       in on Junior in Yorcia Weald, plus the 10788 re-ask. One csid covers the
--       offer and the reminder; the program branches internally.
--   Western Adoulin 5063 on 17826028 -> 10792-10799, "So? What did Aldo have to
--       say?" through the reward.
--   Yorcia Weald 105 on 17855075 -> 8350-8381, the Midras scene including the
--       8351 "Midras / Junior" prompt and the Tenshodo errand.
--   Lower Jeuno 10125 on 17780832 -> 10426-10450, being led in to Aldo, handing
--       over both key items, and being told to report back to Adoulin.
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.VEGETABLE_VEGETABLE_EVOLUTION)

local yorciaQm = 17855075

local function hasMagicite(player)
    return player:hasKeyItem(xi.ki.MAGICITE_OPTISTONE) or
        player:hasKeyItem(xi.ki.MAGICITE_AURASTONE) or
        player:hasKeyItem(xi.ki.MAGICITE_ORASTONE)
end

quest.reward =
{
    fameArea = xi.fameArea.ADOULIN,
    item     = { { xi.item.RARAB_TAIL, 12 } },
    bayld    = 2000,
    title    = xi.title.VEGETABLE_EVOLUTIONARY,
}

quest.sections =
{
    -- Section: offer
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.ADOULIN, xi.quest.id.adoulin.VEGETABLE_VEGETABLE_REVOLUTION) and
                player:getFameLevel(xi.fameArea.ADOULIN) >= 4 and
                player:getRank(player:getNation()) >= 5
        end,

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Amchuchus_Laboratory'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(5062)
                end,
            },

            onEventFinish =
            {
                [5062] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    -- Section: check on Midras, then carry his package to the Tenshodo
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Amchuchus_Laboratory'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Prog') == 2 then
                        return quest:progressEvent(5063)
                    end

                    return quest:event(5062)
                end,
            },

            onEventFinish =
            {
                [5063] = function(player, csid, option, npc)
                    quest:complete(player)
                end,
            },
        },

        [xi.zone.YORCIA_WEALD] =
        {
            ['qm'] =
            {
                onTrigger = function(player, npc)
                    if npc:getID() ~= yorciaQm or quest:getVar(player, 'Prog') ~= 0 then
                        return
                    end

                    if not hasMagicite(player) then
                        player:printToPlayer('Midras looks you over and shakes his head. Someone who has never earned the trust of their own nation would never get through the Tenshodo\'s door.', xi.msg.channel.NS_SAY)

                        return
                    end

                    return quest:progressEvent(105, 1)
                end,
            },

            onEventFinish =
            {
                [105] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 1)
                    npcUtil.giveKeyItem(player, { xi.ki.MIDRASS_EXPLOSIVE_SAMPLE, xi.ki.REPORT_ON_MIDRASS_EXPLOSIVE })
                end,
            },
        },

        [xi.zone.LOWER_JEUNO] =
        {
            ['_6tc'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Prog') == 1 then
                        return quest:progressEvent(10125)
                    end
                end,
            },

            onEventFinish =
            {
                [10125] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 2)
                    player:delKeyItem(xi.ki.MIDRASS_EXPLOSIVE_SAMPLE)
                    player:delKeyItem(xi.ki.REPORT_ON_MIDRASS_EXPLOSIVE)
                end,
            },
        },
    },
}

return quest
