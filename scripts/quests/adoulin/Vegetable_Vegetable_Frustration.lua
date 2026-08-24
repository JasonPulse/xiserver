-----------------------------------
-- Vegetable Vegetable Frustration
-----------------------------------
-- Log ID: 9, Quest ID: 111
-- Amchuchus_Laboratory : Western Adoulin (J-10), entity 17826028
-- Contemplation_Site   : Western Adoulin (I-5), entity 17826032
-- Raibaht              : Metalworks (G-8), entity 17748012
-- Peculiar_Fissure     : Palborough Mines map 3 (G-8), entity 17363387
-- Incensed_Pineapple   : Palborough Mines, mob 17363319
-- !addquest 9 111
-----------------------------------
-- Retail (bg-wiki "Vegetable Vegetable Frustration").
-- |Start=Amchuchu, Inventors' Coalition, Western Adoulin |Fame=Adoulin
-- |Previous=Vegetable Vegetable Crisis, The Usual |Item Reqs=Sabiki Rig
-- |Title=Vegetable Hero |Reward=Midras's Helm +1, 2000 Bayld
--   1. Check Amchuchu's Laboratory for a cutscene.
--   2. Speak with Raibaht in the Metalworks.
--   3. Examine the Peculiar Fissure in Palborough Mines map 3 (G-8). Bang on the
--      rock three times, then think.
--   4. Return to Raibaht.
--   5. Examine the Contemplation Site at (I-5) and trade it a Sabiki Rig for the
--      Packet of Midras's explosives.
--   6. Examine the Peculiar Fissure for a short cutscene, then again to spawn
--      Incensed Pineapple. Beat it before it self-destructs.
--   7. Examine the fissure for the Tarnished ring and Rusty locket.
--   8. Return to Raibaht, then to the Contemplation Site for the reward.
--   9. Optional: check the laboratory for Midras's Helm +1.
--
-- THE ONE-GAME-DAY WAIT AFTER VEGETABLE VEGETABLE CRISIS IS NOT ENFORCED. Nothing
-- in the log or in char vars records when Crisis completed, so a wait check would
-- read an unset var and lock the quest shut forever. The Crisis, The Usual and
-- Cid's Secret completions are all real gates and are checked.
--
-- CSIDS DECODED FROM THE CLIENT EVENT PROGRAMS, each confirmed against the dialog
-- its byte range references. Three of the five entities the quest touches are
-- silent triggers whose programs sit on an unnamed holder in the same zone, which
-- is legal because the csid space is zone-global:
--   Western Adoulin 5211 (holder 17826033) -> 10968-10978, Amchuchu on Junior's
--       slump and the errand to Bastok.
--   Western Adoulin 5212 (holder 17826033) -> 10980-11000, Midras at the docks,
--       the Sabiki Rig request, and the blast powder hand-over.
--   Western Adoulin 5213 (holder 17826033) -> 11001-11003, the repeat request
--       after the bomb self-destructs.
--   Western Adoulin 5214 (holder 17826033) -> 11006-11056, Almid's letter, the
--       11017 "which father" prompt, and the reward.
--   Western Adoulin 5215 (holder 17826033) -> 11058-11064, Midras handing over
--       the helm at the coalition.
--   Metalworks 990 (holder 17748195) -> 7419-7431, Raibaht on the childhood fight
--       and the location of the accident.
--   Metalworks 991 (holder 17748195) -> 7432-7438, Raibaht sending you to Midras
--       for the right mixture.
--   Metalworks 992 (holder 17748195) -> 7440-7456, the ring and locket handover.
--   Palborough Mines 126 (holder 17363386) -> 7498-7504, the reach/bang/think
--       prompt and, on the return visit, the "that wall isn't safe" warning. One
--       event covers both; the ritual loop runs inside the client's event VM.
--   Palborough Mines 127 (holder 17363386) -> 7505-7506, the failed split.
--   Palborough Mines 128 (holder 17363386) -> 7509-7524, Sirius and Almid.
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.VEGETABLE_VEGETABLE_FRUSTRATION)

local peculiarFissure  = 17363387
local incensedPineapple = 17363319

-- Progress ladder, stored in the quest var 'Prog'.
local progAccepted   = 0
local progRaibaht    = 1
local progFissure    = 2
local progAdvice     = 3
local progExplosives = 4
local progWarned     = 5
local progSpawned    = 6
local progBeaten     = 7
local progTokens     = 8
local progReported   = 9

quest.reward =
{
    fameArea = xi.fameArea.ADOULIN,
    bayld    = 2000,
    title    = xi.title.VEGETABLE_HERO,
}

quest.sections =
{
    -- Section: offer
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.ADOULIN, xi.quest.id.adoulin.VEGETABLE_VEGETABLE_CRISIS) and
                player:hasCompletedQuest(xi.questLog.BASTOK, xi.quest.id.bastok.THE_USUAL) and
                player:hasCompletedQuest(xi.questLog.BASTOK, xi.quest.id.bastok.CIDS_SECRET)
        end,

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Amchuchus_Laboratory'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(5211)
                end,
            },

            onEventFinish =
            {
                [5211] = function(player, csid, option, npc)
                    quest:begin(player)
                    quest:setVar(player, 'Prog', progAccepted)
                end,
            },
        },
    },

    -- Section: the mine, the powder, and the bomb
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.METALWORKS] =
        {
            ['Raibaht'] =
            {
                onTrigger = function(player, npc)
                    local prog = quest:getVar(player, 'Prog')

                    if prog == progAccepted then
                        return quest:progressEvent(990)
                    elseif prog == progFissure then
                        return quest:progressEvent(991)
                    elseif prog == progTokens then
                        return quest:progressEvent(992)
                    end
                end,
            },

            onEventFinish =
            {
                [990] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', progRaibaht)
                end,

                [991] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', progAdvice)
                end,

                [992] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.TARNISHED_RING)
                    player:delKeyItem(xi.ki.RUSTY_LOCKET)
                    quest:setVar(player, 'Prog', progReported)
                end,
            },
        },

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Contemplation_Site'] =
            {
                onTrigger = function(player, npc)
                    local prog = quest:getVar(player, 'Prog')

                    if prog == progAdvice then
                        return quest:progressEvent(5212)
                    elseif prog == progWarned and not player:hasKeyItem(xi.ki.PACKET_OF_MIDRASS_EXPLOSIVES) then
                        return quest:progressEvent(5213)
                    elseif prog == progReported then
                        return quest:progressEvent(5214)
                    end
                end,

                onTrade = function(player, npc, trade)
                    local prog = quest:getVar(player, 'Prog')

                    if
                        npcUtil.tradeHas(trade, xi.item.SABIKI_RIG) and
                        (prog == progAdvice or prog == progWarned) and
                        not player:hasKeyItem(xi.ki.PACKET_OF_MIDRASS_EXPLOSIVES)
                    then
                        quest:setVar(player, 'Traded', 1)

                        return quest:progressEvent(5212)
                    end
                end,
            },

            ['Amchuchus_Laboratory'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Prog') < progRaibaht then
                        return quest:event(5211)
                    end
                end,
            },

            onEventFinish =
            {
                [5212] = function(player, csid, option, npc)
                    -- One csid covers both halves of this scene: Midras asking for
                    -- the rig, and Midras handing the powder over once he has it.
                    -- The trade handler flags which half just played.
                    if quest:getVar(player, 'Traded') == 1 then
                        player:confirmTrade()
                        quest:setVar(player, 'Traded', 0)
                        quest:setVar(player, 'Prog', progExplosives)
                        npcUtil.giveKeyItem(player, xi.ki.PACKET_OF_MIDRASS_EXPLOSIVES)
                    end
                end,

                [5214] = function(player, csid, option, npc)
                    quest:complete(player)
                end,
            },
        },

        [xi.zone.PALBOROUGH_MINES] =
        {
            ['Peculiar_Fissure'] =
            {
                onTrigger = function(player, npc)
                    if npc:getID() ~= peculiarFissure then
                        return
                    end

                    local prog = quest:getVar(player, 'Prog')

                    if prog == progRaibaht then
                        return quest:progressEvent(126)
                    elseif prog == progExplosives then
                        return quest:progressEvent(126)
                    elseif prog == progWarned and player:hasKeyItem(xi.ki.PACKET_OF_MIDRASS_EXPLOSIVES) then
                        local bomb = GetMobByID(incensedPineapple)

                        if bomb ~= nil and not bomb:isSpawned() then
                            quest:setVar(player, 'Prog', progSpawned)
                            bomb:setLocalVar('questPlayer', player:getID())
                            bomb:spawn()
                            bomb:updateClaim(player)
                        end

                        return true
                    elseif prog == progBeaten then
                        return quest:progressEvent(128)
                    end
                end,
            },

            ['Incensed_Pineapple'] =
            {
                onMobDeath = function(mob, player, optParams)
                    if quest:getVar(player, 'Prog') == progSpawned then
                        quest:setVar(player, 'Prog', progBeaten)
                    end
                end,
            },

            onEventFinish =
            {
                [126] = function(player, csid, option, npc)
                    local prog = quest:getVar(player, 'Prog')

                    if prog == progRaibaht then
                        quest:setVar(player, 'Prog', progFissure)
                    elseif prog == progExplosives then
                        quest:setVar(player, 'Prog', progWarned)
                    end
                end,

                [127] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.PACKET_OF_MIDRASS_EXPLOSIVES)
                    quest:setVar(player, 'Prog', progWarned)
                end,

                [128] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.PACKET_OF_MIDRASS_EXPLOSIVES)
                    npcUtil.giveKeyItem(player, { xi.ki.TARNISHED_RING, xi.ki.RUSTY_LOCKET })
                    quest:setVar(player, 'Prog', progTokens)
                end,
            },
        },
    },

    -- Section: the optional visit that pays out the helm
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED and
                quest:getVar(player, 'Helm') == 0
        end,

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Amchuchus_Laboratory'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(5215)
                end,
            },

            onEventFinish =
            {
                [5215] = function(player, csid, option, npc)
                    if npcUtil.giveItem(player, xi.item.MIDRASS_HELM_P1) then
                        quest:setVar(player, 'Helm', 1)
                    end
                end,
            },
        },
    },
}

return quest
