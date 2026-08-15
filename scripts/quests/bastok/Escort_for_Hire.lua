-----------------------------------
-- Escort for Hire (Bastok)
-----------------------------------
-- Log ID: 1, Quest ID: 70
-- Trilok : Port Bastok (D-6)
-- Olavia : The Crawlers' Nest
-----------------------------------
-- Retail (bg-wiki "Escort for Hire (Bastok)" + the shared Escort for Hire notes):
--   1. Speak to Trilok, Port Bastok (D-6). Fame Bastok 6.
--   2. Zone into Crawlers' Nest from Rolanberry Fields -> cutscene, Olavia spawns.
--   3. Talk to her to stop/resume. 30 minute (Earth time) limit. She dies easily.
--   4. At her stop point speak to her -> {KI} Completion certificate.
--   5. Return to Trilok.
-- Reward: Page from Miratete's Memoirs, plus 10,000 gil on the FIRST completion
-- of any Escort for Hire quest. Repeatable, but only one Escort for Hire may be
-- active at a time and only one may be completed per Conquest Tally.
--
-- CSIDs decoded, not guessed. Trilok is entity 17743889 (sql/npc_list.sql:28191);
-- (17743889-16777216) = 966673, 966673//4096 = 236 rem 17 -> Port Bastok,
-- 0x010EC011. Resolved with xidat/csidmsg.py against `xi-dat dialog 236`:
--   291 -> 8855 "Hey, I know you. You're that adventurer that everybody's been
--          talking about. I've got a proposition for you", 8856 "There's this
--          lady, Olavia, who wants somebody to guide her through the Crawlers'
--          Nest.", 8857 "She said she'll be waiting at the entrance of the nest"
--   292 -> 8859 the active reminder, and 8861 "Back out of the deal? / Right
--          now. / Not just yet." -- which is why the cancel path below exists
--   293 -> 8863 "Oh, ${name-player}! I heard you met up with Olavia and helped
--          her out. Here's your reward."
--   294 -> 8864 "Hmmm... I'm sorry, but there just isn't any good work these
--          days." -- post-completion idle
--   44  -> 7483, his generic idle
-- Olavia is entity 17584479 (npc_list:23085); (17584479-16777216) = 807263,
-- 807263//4096 = 197 rem 351 -> Crawlers' Nest, 0x010C515F. `xi-dat csid 197 6`
-- reports two owners: a 138-byte program on the zone-global actor 0x7FFFFFF0 and
-- a 1-byte stub on Olavia herself -- the standard layout where the real program
-- lives on a zone-wide holder. That program references entity 5F510C01 (Olavia)
-- and the vars s039 / fdi1 / fdo2. Zone 197's dialog carries the whole escort:
--   7291 "So, you're the guy/lady they sent to escort me through this place...
--        Come on. Follow me.${wait-animation: 4}"
--   7288 "Is anything wrong?" (stop)   7289 "Come on, let's go. Follow me." (resume)
--   7290 "You've been a great help. You can pick up your payment from Trilok."
--   7293 "You have ${number: 0} minutes (Earth time) to complete this quest."
--   7294 "You have lost sight of Olavia..."   7292 "We've run out of time..."
-- csid 5 is a 19-byte program on 0x7FFFFFF0 reading only "qstc" -- a pure state
-- check with no dialog, i.e. the spawn gate.
--
-- CRITICAL BUG REMOVED: the stub used csid 45 for Trilok. csid 45 is fired by
-- scripts/zones/Port_Bastok/npcs/Bodaway.lua:32 as
-- `player:startEvent(45, seconds, 0, ...)` -- Bodaway is a time-of-day NPC. Since
-- onEventFinish dispatches zone-wide on csid alone, talking to Bodaway with fame
-- 6 silently started (or restarted) this quest. The stub's Olavia csid 52 does
-- not exist in zone 197 at all.
--
-- Also removed: an unconditional `addFame(BASTOK, 10)` on every repeat stacked on
-- top of quest.reward.fame = 30. bg-wiki lists no fame for this quest, and with
-- no Conquest Tally gate that was unbounded fame plus unbounded Miratete's
-- Memoirs from a Trilok click loop. Fame is no longer granted at all, and the
-- tally gate below is now enforced.
--
-- The 10,000 gil first-clear bonus is shared across all three nations' Escort
-- for Hire quests, so it is keyed on the shared charvar 'EscortForHireCleared'
-- (the stub used a Bastok-only var, letting the bonus be collected once per
-- nation). scripts/quests/sandoria/Escort_for_Hire.lua uses the same var.
--
-- STILL SIMPLIFIED: Olavia does not path. She spawns, can be stopped and
-- resumed, and hands over the certificate at her stop point, but the three fixed
-- routes and the "lost sight of her" failure need waypoint data this repo does
-- not carry. The 30 minute limit IS enforced. Flagged rather than faked.
-----------------------------------
local bastokID = zones[xi.zone.PORT_BASTOK]

local quest = Quest:new(xi.questLog.BASTOK, xi.quest.id.bastok.ESCORT_FOR_HIRE)

-- Olavia, sql/npc_list.sql:23085. Ships with status 2 (DISAPPEAR) so she does
-- not render until spawned -- without this the quest dead-ended on arrival.
local olavia = 17584479

local escortMinutes = 30

quest.sections =
{
    -- Trilok offers the contract. Repeatable, so COMPLETED is eligible too, but
    -- only once per Conquest Tally and only if no other Escort for Hire is live.
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE or status == xi.questStatus.QUEST_COMPLETED) and
                player:getFameLevel(xi.fameArea.BASTOK) >= 6 and
                not player:hasKeyItem(xi.ki.COMPLETION_CERTIFICATE) and
                not xi.escort.hasActiveContract(player) and
                xi.escort.tallyAllows(player)
        end,

        [xi.zone.PORT_BASTOK] =
        {
            ['Trilok'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(291)
                end,
            },

            onEventFinish =
            {
                [291] = function(player, csid, option, npc)
                    if option ~= 0 then
                        return
                    end

                    if player:getQuestStatus(xi.questLog.BASTOK, xi.quest.id.bastok.ESCORT_FOR_HIRE) == xi.questStatus.QUEST_COMPLETED then
                        player:addQuest(xi.questLog.BASTOK, xi.quest.id.bastok.ESCORT_FOR_HIRE)
                    else
                        quest:begin(player)
                    end

                    xi.escort.setActiveContract(player, xi.quest.id.bastok.ESCORT_FOR_HIRE)
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

        [xi.zone.PORT_BASTOK] =
        {
            -- 8861 "Back out of the deal? / Right now. / Not just yet."
            ['Trilok'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(292)
                end,
            },

            onEventFinish =
            {
                [292] = function(player, csid, option, npc)
                    if option == 0 then
                        xi.escort.cancelContract(player, xi.questLog.BASTOK, xi.quest.id.bastok.ESCORT_FOR_HIRE)
                    end
                end,
            },
        },

        [xi.zone.CRAWLERS_NEST] =
        {
            onZoneIn = function(player, prevZone)
                if prevZone == xi.zone.ROLANBERRY_FIELDS then
                    xi.escort.startEscort(player, escortMinutes, olavia)
                end

                return -1
            end,

            ['Olavia'] =
            {
                onTrigger = function(player, npc)
                    if not xi.escort.isEscortLive(player) then
                        return
                    end

                    return quest:progressEvent(6)
                end,
            },

            onEventFinish =
            {
                [6] = function(player, csid, option, npc)
                    if not xi.escort.isEscortLive(player) then
                        return
                    end

                    -- 7290 "You've been a great help. You can pick up your
                    -- payment from Trilok." -- the certificate is only handed
                    -- over once she has reached her stop point.
                    if xi.escort.atStopPoint(player) then
                        if npcUtil.giveKeyItem(player, xi.ki.COMPLETION_CERTIFICATE) then
                            xi.escort.endEscort(player, olavia)
                        end
                    else
                        xi.escort.toggleFollow(player)
                    end
                end,
            },
        },
    },

    -- Certificate in hand: back to Trilok for the payout.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                player:hasKeyItem(xi.ki.COMPLETION_CERTIFICATE)
        end,

        [xi.zone.PORT_BASTOK] =
        {
            ['Trilok'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(293)
                end,
            },

            onEventFinish =
            {
                [293] = function(player, csid, option, npc)
                    if player:getFreeSlotsCount() == 0 then
                        player:messageSpecial(bastokID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.MIRATETES_MEMOIRS)
                        return
                    end

                    player:delKeyItem(xi.ki.COMPLETION_CERTIFICATE)

                    if player:getCharVar('EscortForHireCleared') == 0 then
                        local bonus = xi.settings.main.GIL_RATE * 10000

                        player:setCharVar('EscortForHireCleared', 1)
                        player:addGil(bonus)
                        player:messageSpecial(bastokID.text.GIL_OBTAINED, bonus)
                    end

                    player:addItem(xi.item.MIRATETES_MEMOIRS)
                    player:messageSpecial(bastokID.text.ITEM_OBTAINED, xi.item.MIRATETES_MEMOIRS)
                    player:completeQuest(xi.questLog.BASTOK, xi.quest.id.bastok.ESCORT_FOR_HIRE)

                    xi.escort.clearContract(player)
                    xi.escort.stampTally(player)
                end,
            },
        },
    },

    -- 8864, post-completion idle.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.PORT_BASTOK] =
        {
            ['Trilok'] = quest:event(294),
        },
    },
}

return quest
