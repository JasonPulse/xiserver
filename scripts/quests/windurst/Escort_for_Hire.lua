-----------------------------------
-- Escort for Hire (Windurst)
-----------------------------------
-- Log ID: 2, Quest ID: 88
-- Dehn Harzhapan : Port Windurst (G-6), default event 10018
-- Wanzo-Unzozo   : Garlaige Citadel, default event 60
-----------------------------------
-- Retail: timed escort through Garlaige Citadel with Banishing Gate
-- mechanics. Currently simplified: accept from Dehn -> zone into Garlaige
-- Citadel -> speak to Wanzo-Unzozo for the Completion certificate -> return to
-- Dehn. First clear 10k gil + Miratete's Memoirs, repeats Memoirs only. The
-- escort itself is still missing.
--
-- CSIDs are no longer guesses. Decoded with xidat/csidmsg.py against
-- Dehn Harzhapan, entity 17760441 (npc_list.sql:29842;
-- (17760441-16777216)//4096 = 240 rem 185 -> Port Windurst):
--   10014 -> dialog 12790-12792, the offer. 12791 "There's this rich little
--            Tarutaru that needs some help navigating thrrrough the Garlaige
--            Citadel", 12792 "Your client's name is Wanzo-Unzozo. He should be
--            waiting just inside the citadel's entrrrance." Names both the
--            client and the zone, so this is unambiguously this quest.
--   10016 -> dialog 12796 "Grrreat job, <name>. I knew I could count on you to
--            get the job done. Here's your reward." = the turn-in.
--   10017 -> 12797 "Sorrry, I don't have any work for you today."
--   10018 -> 12789 idle line (matches this file's original header note).
--
-- The previous ids were both wrong: 10019 is Pygmalion's only event and is
-- A Discerning Eye's airship dropped-item cutscene (dialog 12801-12816), and
-- 10020 belongs to a different entity (0x010F00BC) showing dialog 11723-11729.
-----------------------------------
local miratetesMemoirs = xi.item.MIRATETES_MEMOIRS

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.ESCORT_FOR_HIRE)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.WINDURST,
}

local function canAccept(player)
    return player:getFameLevel(xi.fameArea.WINDURST) >= 6
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE or status == xi.questStatus.QUEST_COMPLETED) and
                canAccept(player) and
                not player:hasKeyItem(xi.ki.COMPLETION_CERTIFICATE)
        end,

        [xi.zone.PORT_WINDURST] =
        {
            ['Dehn_Harzhapan'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10014)
                end,
            },

            onEventFinish =
            {
                [10014] = function(player, csid, option, npc)
                    if option == 1 then
                        if player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.ESCORT_FOR_HIRE) == xi.questStatus.QUEST_COMPLETED then
                            player:addQuest(xi.questLog.WINDURST, xi.quest.id.windurst.ESCORT_FOR_HIRE)
                        else
                            quest:begin(player)
                        end
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.GARLAIGE_CITADEL] =
        {
            ['Wanzo-Unzozo'] =
            {
                onTrigger = function(player, npc)
                    if not player:hasKeyItem(xi.ki.COMPLETION_CERTIFICATE) then
                        return quest:progressEvent(61)
                    end
                end,
            },

            onEventFinish =
            {
                [61] = function(player, csid, option, npc)
                    npcUtil.giveKeyItem(player, xi.ki.COMPLETION_CERTIFICATE)
                end,
            },
        },

        [xi.zone.PORT_WINDURST] =
        {
            ['Dehn_Harzhapan'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.COMPLETION_CERTIFICATE) then
                        return quest:progressEvent(10016)
                    end
                end,
            },

            onEventFinish =
            {
                [10016] = function(player, csid, option, npc)
                    if player:getFreeSlotsCount() > 0 then
                        player:delKeyItem(xi.ki.COMPLETION_CERTIFICATE)
                        if player:getCharVar('EscortForHireWindurstCleared') == 0 then
                            player:setCharVar('EscortForHireWindurstCleared', 1)
                            player:addGil(10000)
                            player:messageSpecial(zones[xi.zone.PORT_WINDURST].text.GIL_OBTAINED, 10000)
                        end

                        player:addItem(miratetesMemoirs)
                        player:messageSpecial(zones[xi.zone.PORT_WINDURST].text.ITEM_OBTAINED, miratetesMemoirs)
                        player:completeQuest(xi.questLog.WINDURST, xi.quest.id.windurst.ESCORT_FOR_HIRE)
                        player:addFame(xi.fameArea.WINDURST, 10)
                    end
                end,
            },
        },
    },
}

return quest
