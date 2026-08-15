-----------------------------------
-- Survival of the Wisest
-----------------------------------
-- Log ID: 4, Quest ID: 33
-- Xarcabard [S] : zone-in trigger (SCH 66+, all SCH AF complete)
-- Indescript_Markings : Pashhow Marshlands [S] (via audit memory) or
-- Xarcabard [S]. Simplified here: Xarcabard [S] zone-in auto-accepts.
-----------------------------------
-- SCH Genkai 5 (lv75 cap). Retail: farm Scholar's Testimony from Orcs
-- [S] zones, trade to Indescript Markings, fight Gunther + Crimson
-- Grimoire BCNM. Simplified for 4-player server: trade testimony to
-- Indescript_Markings, complete. BCNM abstracted — revisit if wanted.
-----------------------------------
local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.SURVIVAL_OF_THE_WISEST)

-- bg-wiki "Survival of the Wisest": Reward = "Raises level limit to 75",
-- Title = "Grimoire Bearer". Neither was being granted, so completing this
-- limit break did nothing at all for the player. bg-wiki lists no fame for it.
quest.reward =
{
    title = xi.title.GRIMOIRE_BEARER,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getMainJob() == xi.job.SCH and
                player:getMainLvl() >= 66 and
                -- Fixed: both the log and the table were wrong here. Apocalypse
                -- Nigh is a JEUNO quest -- APOCALYPSE_NIGH = 89 sits in the
                -- xi.questLog.JEUNO block of scripts/globals/quests.lua (block
                -- header line 321, entry line 412). There is no
                -- APOCALYPSE_NIGH in the windurst table at all, so
                -- xi.quest.id.windurst.APOCALYPSE_NIGH resolved to nil and was
                -- passed as the uint16 questID argument of hasCompletedQuest,
                -- which is a sol2 binding type error -- it broke the SCH genkai
                -- gate in Xarcabard [S] rather than merely failing the check.
                -- (windurst id 89 is A_DISCERNING_EYE, an unrelated quest.)
                -- Every other reference in the repo already uses the jeuno form:
                -- Trust_Prishe.lua:40, Trust_Ulmia.lua:17,
                -- Shadows_of_the_Departed.lua:112-113, Apocalypse_Nigh.lua:10.
                player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.APOCALYPSE_NIGH)
        end,

        [xi.zone.XARCABARD_S] =
        {
            onZoneIn = function(player, prevZone)
                if quest:getVar(player, 'Accepted') == 0 then
                    quest:begin(player)
                    quest:setVar(player, 'Accepted', 1)
                end

                return -1
            end,
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.PASHHOW_MARSHLANDS_S] =
        {
            ['Indescript_Markings'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.SCHOLARS_TESTIMONY) then
                        return quest:progressEvent(200)
                    end
                end,
            },

            onEventFinish =
            {
                [200] = function(player, csid, option, npc)
                    player:confirmTrade()

                    -- The whole point of a genkai quest. Guarded on the current
                    -- cap the same way Achieving_True_Power and the other limit
                    -- breaks do, so a re-run cannot lower an already-higher cap.
                    if player:getLevelCap() == 70 then
                        player:setLevelCap(75)
                    end

                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
