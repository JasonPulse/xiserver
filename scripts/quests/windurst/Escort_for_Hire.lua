-----------------------------------
-- Escort for Hire (Windurst)
-----------------------------------
-- Log ID: 2, Quest ID: 88
-- Dehn Harzhapan : Port Windurst (G-6)
-- Wanzo-Unzozo   : Garlaige Citadel
-----------------------------------
-- Retail (bg-wiki "Escort for Hire (Windurst)" + the shared notes):
--   1. Speak to Dehn Harzhapan, Port Windurst (G-6). Fame Windurst 6.
--   2. Enter Garlaige Citadel -> Wanzo-Unzozo spawns near the entrance.
--   3. 30 minute limit. Talk to stop/resume him; he pulls aggro and can be cured.
--   4. Escort him to his stop point and speak to him -> {KI} Completion certificate.
--   5. Return to Dehn Harzhapan.
-- Reward: Page from Miratete's Memoirs, plus 10,000 gil on the FIRST completion
-- of ANY Escort for Hire quest. Repeatable under the same one-active /
-- one-per-tally rules as the Bastok and San d'Oria versions.
--
-- FOUR BUGS FIXED HERE, all of which this file shared with the San d'Oria
-- version before that one was repaired:
--
-- 1. WRONG CSID, AND A LIVE CROSS-FIRE. The Garlaige step fired csid 61 on
--    Wanzo-Unzozo. `xi-dat events 200` shows Wanzo, entity 17596835
--    (0x010C81A3, npc_list.sql:23309), owns exactly ONE event: 60. csid 61 has a
--    single owner, 0x010C81A4 = 17596836, which npc_list.sql:23310 names
--    'Ramblix' -- a different NPC standing a few yards away. Because
--    onEventFinish dispatches zone-wide on csid alone, talking to Ramblix while
--    the quest was accepted handed over the Completion certificate and skipped
--    the entire escort. (This is the same NPC name that caused the identical bug
--    in the San d'Oria version, where Ramblix owned csid 52.)
--    csid 60 is a 1-byte 0x00 stub on Wanzo with the real 148-byte program on the
--    zone holder 0x7FFFFFF0 -- the standard holder layout, and the same shape as
--    Olavia's csid 6 in zone 197 and Cannau's csid 51 in zone 195.
--
-- 2. WANZO NEVER RENDERED. npc_list.sql:23309 ships him with status = 2
--    (DISAPPEAR) and nothing in the tree revealed him, so even with the right
--    csid the player arrived to an empty corridor. He is now spawned on zone-in
--    through the shared xi.escort.startEscort, exactly as Olavia and Cannau are.
--
-- 3. THE 10,000 GIL COULD BE COLLECTED TWICE. bg-wiki's shared note is
--    "The reward is 10,000g and a Page From Miratete's Memoirs. Subsequent
--    completions only reward the Miratete's Memoirs." Bastok and San d'Oria both
--    key that on the shared charvar 'EscortForHireCleared'; this file used its
--    own 'EscortForHireWindurstCleared', so a player who had already been paid by
--    one of the other two was paid again here.
--
-- 4. NO CONTRACT OR TALLY GATING. There was no xi.escort.hasActiveContract check
--    and no tallyAllows/stampTally, so this quest violated both "only one active
--    at a time" and "only one may be completed each Conquest Tally" -- unbounded
--    Miratete's Memoirs. It also called addFame(WINDURST, 10) on every completion
--    on top of quest.reward.fame, an amount bg-wiki does not list.
--
-- CSIDs on the Dehn Harzhapan side were already decoded and are unchanged.
-- Dehn is entity 17760441 (npc_list.sql:29842); (17760441-16777216) = 983225,
-- 983225//4096 = 240 rem 185 -> Port Windurst:
--   10014 -> 12790-12792, the offer. 12791 "There's this rich little Tarutaru
--            that needs some help navigating thrrrough the Garlaige Citadel",
--            12792 "Your client's name is Wanzo-Unzozo."
--   10016 -> 12796 "Grrreat job... Here's your reward." = the turn-in.
--   10017 -> 12797 "Sorrry, I don't have any work for you today."
--   10018 -> 12789, his idle line.
--
-- STILL SIMPLIFIED, and flagged rather than faked: Wanzo does not path, and the
-- Banishing Gate mechanics are not modelled. He spawns, can be stopped and
-- resumed, and hands over the certificate at his stop point. The 30 minute limit
-- IS enforced. This matches the Bastok and San d'Oria versions.
-----------------------------------
local windurstID = zones[xi.zone.PORT_WINDURST]

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.ESCORT_FOR_HIRE)

-- Wanzo-Unzozo, npc_list.sql:23309. Ships status 2 (DISAPPEAR).
local wanzo = 17596835

local escortMinutes = 30

quest.sections =
{
    -- Dehn Harzhapan offers the contract.
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE or status == xi.questStatus.QUEST_COMPLETED) and
                player:getFameLevel(xi.fameArea.WINDURST) >= 6 and
                not player:hasKeyItem(xi.ki.COMPLETION_CERTIFICATE) and
                not xi.escort.hasActiveContract(player) and
                xi.escort.tallyAllows(player)
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
                    if option ~= 1 then
                        return
                    end

                    if player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.ESCORT_FOR_HIRE) == xi.questStatus.QUEST_COMPLETED then
                        player:addQuest(xi.questLog.WINDURST, xi.quest.id.windurst.ESCORT_FOR_HIRE)
                    else
                        quest:begin(player)
                    end

                    xi.escort.setActiveContract(player, xi.quest.id.windurst.ESCORT_FOR_HIRE)
                end,
            },
        },
    },

    -- Contract live, certificate not yet earned.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                not player:hasKeyItem(xi.ki.COMPLETION_CERTIFICATE)
        end,

        [xi.zone.PORT_WINDURST] =
        {
            ['Dehn_Harzhapan'] = quest:event(10017),
        },

        [xi.zone.GARLAIGE_CITADEL] =
        {
            onZoneIn = function(player, prevZone)
                if prevZone == xi.zone.SAUROMUGUE_CHAMPAIGN then
                    xi.escort.startEscort(player, escortMinutes, wanzo)
                end

                return -1
            end,

            ['Wanzo-Unzozo'] =
            {
                onTrigger = function(player, npc)
                    if not xi.escort.isEscortLive(player) then
                        return
                    end

                    return quest:progressEvent(60)
                end,
            },

            onEventFinish =
            {
                [60] = function(player, csid, option, npc)
                    if not xi.escort.isEscortLive(player) then
                        return
                    end

                    if xi.escort.atStopPoint(player) then
                        if npcUtil.giveKeyItem(player, xi.ki.COMPLETION_CERTIFICATE) then
                            xi.escort.endEscort(player, wanzo)
                        end
                    else
                        xi.escort.toggleFollow(player)
                    end
                end,
            },
        },
    },

    -- Certificate in hand: back to Dehn Harzhapan for the payout.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                player:hasKeyItem(xi.ki.COMPLETION_CERTIFICATE)
        end,

        [xi.zone.PORT_WINDURST] =
        {
            ['Dehn_Harzhapan'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10016)
                end,
            },

            onEventFinish =
            {
                [10016] = function(player, csid, option, npc)
                    if player:getFreeSlotsCount() == 0 then
                        player:messageSpecial(windurstID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.MIRATETES_MEMOIRS)
                        return
                    end

                    player:delKeyItem(xi.ki.COMPLETION_CERTIFICATE)

                    -- Shared across all three Escort for Hire quests: the 10,000
                    -- gil is a one-time bonus on the first clear of ANY of them.
                    if player:getCharVar('EscortForHireCleared') == 0 then
                        local bonus = xi.settings.main.GIL_RATE * 10000

                        player:setCharVar('EscortForHireCleared', 1)
                        player:addGil(bonus)
                        player:messageSpecial(windurstID.text.GIL_OBTAINED, bonus)
                    end

                    player:addItem(xi.item.MIRATETES_MEMOIRS)
                    player:messageSpecial(windurstID.text.ITEM_OBTAINED, xi.item.MIRATETES_MEMOIRS)
                    player:completeQuest(xi.questLog.WINDURST, xi.quest.id.windurst.ESCORT_FOR_HIRE)

                    xi.escort.clearContract(player)
                    xi.escort.stampTally(player)
                end,
            },
        },
    },

    -- 12789, his idle line once you are not under contract.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.PORT_WINDURST] =
        {
            ['Dehn_Harzhapan'] = quest:event(10018),
        },
    },
}

return quest
