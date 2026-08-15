-----------------------------------
-- For Whom the Bell Tolls
-- GEO AF Quest 3
-- !addquest 9 36
-- Sylvie            : !pos 78.094 32.000 135.725 256
-- Deranged_Ameretat : !pos 318.539 -0.542 395.143 265
-----------------------------------
local morimarID = zones[xi.zone.MORIMAR_BASALT_FIELDS]
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.FOR_WHOM_THE_BELL_TOLLS)

quest.reward =
{
    fameArea = xi.fameArea.ADOULIN,
    bayld    = 5000,
    item     = { { xi.item.FILIAE_BELL, 1 }, { xi.item.DOWSERS_WAND, 1 } },
    fame     = 30,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.ADOULIN, xi.quest.id.adoulin.ELEMENTARY_MY_DEAR_SYLVIE) == xi.questStatus.QUEST_COMPLETED and
                player:getMainLvl() >= 90 and
                player:getMainJob() == xi.job.GEO
        end,

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Sylvie'] =
            {
                onTrigger = function(player, npc)
                    player:printToPlayer('Sylvie: The Silver Luopan I have been studying... something is wrong with it.', xi.msg.channel.NS_SAY)
                    player:printToPlayer('Sylvie: Go to the Ergon Locus in Morimar Basalt Fields and investigate.', xi.msg.channel.NS_SAY)
                    npcUtil.giveKeyItem(player, xi.ki.SILVER_LUOPAN)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 0
        end,

        [xi.zone.MORIMAR_BASALT_FIELDS] =
        {
            -- QM CORRECTED: this was bound to 'Primordial_Convergence', which is
            -- the PREVIOUS quest's QM (Elementary, My Dear Sylvie). Coordinates
            -- settle it -- Burgeoning Flames spawns at (484.657, -17.086, 270.256)
            -- and (429.885, -16.964, 323.899), matching the two Primordial
            -- Convergence rows (npc_list.sql:34863/34864) pairwise; Deranged
            -- Ameretat spawns at (318.539, -0.542, 395.143), matching Ergon_Locus
            -- 17863432 (z 389.647), while the Convergences are 100+ units away.
            -- The printToPlayer line below already said "Ergon Locus".
            ['Ergon_Locus'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.SILVER_LUOPAN) then
                        if npcUtil.popFromQM(player, npc, morimarID.mob.DERANGED_AMERETAT, { claim = true, look = true }) then
                            player:printToPlayer('The Ergon Locus reacts violently to the Silver Luopan!', xi.msg.channel.NS_SAY)
                            player:delKeyItem(xi.ki.SILVER_LUOPAN)
                        else
                            player:printToPlayer('The area is too dangerous right now. Try again later.', xi.msg.channel.NS_SAY)
                        end
                    end
                end,
            },

            ['Deranged_Ameretat'] =
            {
                onMobDeath = function(mob, player, optParams)
                    if quest:getVar(player, 'Prog') == 0 then
                        quest:setVar(player, 'Prog', 1)
                        player:printToPlayer('The creature falls... The Ergon Locus returns to normal.', xi.msg.channel.NS_SAY)
                    end
                end,
            },
        },

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Sylvie'] =
            {
                onTrigger = function(player, npc)
                    player:printToPlayer('Sylvie: Please investigate the Ergon Locus in Morimar Basalt Fields.', xi.msg.channel.NS_SAY)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 1
        end,

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Sylvie'] =
            {
                onTrigger = function(player, npc)
                    player:printToPlayer('Sylvie: You purified the Ergon Locus! The bell now resonates clearly.', xi.msg.channel.NS_SAY)
                    player:printToPlayer('Sylvie: Take these tools. You have earned them.', xi.msg.channel.NS_SAY)
                    if quest:complete(player) then
                        player:printToPlayer('Sylvie: Wescolina in Western Adoulin can now craft Geomancy armor for you.', xi.msg.channel.NS_SAY)
                    end
                end,
            },
        },
    },
}

return quest
