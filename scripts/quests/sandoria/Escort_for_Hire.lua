-----------------------------------
-- Escort for Hire (San d'Oria)
-----------------------------------
-- Log ID: 0, Quest ID: 103
-- Rondipur : Northern San d'Oria (F-6)
-- Cannau   : The Eldieme Necropolis
-----------------------------------
-- Retail (bg-wiki "Escort for Hire (San d'Oria)" + the shared notes):
--   1. Speak to Rondipur, Northern San d'Oria (F-6). Fame San d'Oria 6.
--   2. Enter Eldieme Necropolis from Batallia Downs (I-10) -> cutscene, Cannau
--      spawns.
--   3. 30 minute limit. She runs west to the door at (H-8), which needs a
--      {KI} Magicked astrolabe or a second person on the switch. Talk to
--      stop/resume her; she pulls aggro from everything and blood-aggros undead
--      at low HP, and she can be cured.
--   4. Past (H-8) she goes to (F-8) by the north or south path and stops.
--   5. Speak to her promptly -> {KI} Completion certificate. If she despawns
--      first there is no credit.
--   6. Return to Rondipur.
-- Reward: Page from Miratete's Memoirs, plus 10,000 gil on the FIRST completion
-- of any Escort for Hire quest. Repeatable under the same one-active /
-- one-per-tally rules as the Bastok version.
--
-- CSIDs decoded, not guessed. Rondipur is entity 17723626 (npc_list:26791);
-- (17723626-16777216) = 946410, 946410//4096 = 231 rem 234 -> Northern
-- San d'Oria, 0x010E70EA. Resolved against `xi-dat dialog 231`:
--   721 -> 13116 "${choice-player-gender}[Sir/Lady] ${name-player}! Much I have
--          heard of your noble efforts on the battlefield... your assistance is
--          requested for a special mission.", 13117 "escorting the noble young
--          missus Lady Cannau", 13118 "travel to the Eldieme Necropolis",
--          13119 "You shall be compensated generously upon the completion"
--   722 -> 13120 "You shall find Miss Cannau in the Eldieme Necropolis.",
--          13122 "Cancel your contract? / Yes. / No." -- the cancel path
--   723 -> 13124 "Ah, I heard from my men that you have been successful in
--          escorting the missus."
--   724 -> 13125 "<Sigh> I have the feeling this may not be the last time the
--          missus goes galavanting about the necropolis." -- post-completion
--   725 -> 13126, his generic idle
-- Cannau is entity 17576406 (npc_list:22905); (17576406-16777216) = 799190,
-- 799190//4096 = 195 rem 470 -> Eldieme Necropolis, 0x010C31D6.
-- `xi-dat csid 195 51` reports the zone-global actor 0x7FFFFFF0 holding a
-- 148-byte program plus a 1-byte stub on Cannau -- the same layout as Olavia's
-- csid 6 in zone 197. That program references entity D6310C01 (Cannau)
-- repeatedly, reads s040 / fdi1 / fdo2, and carries an 0x51 key-item opcode,
-- which is the Completion certificate hand-off.
--
-- CSID CAVEAT, stated plainly: Cannau's own dialog block is not resolvable with
-- csidmsg because her text references are computed rather than literal, and
-- `xi-dat search 195 "certificate"` finds nothing relevant. So 51 is proven by
-- ownership, the entity reference in its bytecode, the key-item opcode and by
-- being structurally identical to the Bastok version -- but not by a quoted
-- line. That is weaker than the Rondipur ids above and is called out here rather
-- than presented as equally solid.
--
-- CRITICAL BUG REMOVED: the stub used csid 52 for Cannau. `xi-dat csid 195 52`
-- has exactly one owner, 0x010C31D8 = 17576408, which npc_list:22907 names
-- 'Ramblix'. Because onEventFinish dispatches zone-wide on csid alone, talking to
-- Ramblix while the quest was accepted handed over the Completion certificate and
-- skipped the entire escort. The stub also used 722 (the cancel/reminder event)
-- as the accept and 724 (the post-completion idle) as the in-progress reminder.
--
-- Also removed: an unconditional `addFame(SANDORIA, 10)` on every repeat on top
-- of quest.reward.fame = 30 with no tally gate -- unbounded fame and unbounded
-- Miratete's Memoirs. bg-wiki lists no fame, so none is granted. And the old
-- grantReward() set 'EscortForHireCleared' itself before the branch that tested
-- it, so the first-completion condition was self-satisfying; the shared charvar
-- is now read once, in one place.
--
-- STILL SIMPLIFIED: Cannau does not path, and the (H-8) door switch is not
-- modelled. She spawns, can be stopped and resumed, and hands over the
-- certificate at her stop point. The 30 minute limit IS enforced. Flagged rather
-- than faked.
-----------------------------------
local sandyID = zones[xi.zone.NORTHERN_SAN_DORIA]

local quest = Quest:new(xi.questLog.SANDORIA, xi.quest.id.sandoria.ESCORT_FOR_HIRE)

-- Cannau, sql/npc_list.sql:22905. Ships with status 2 (DISAPPEAR) so she does
-- not render until spawned -- without this the quest dead-ended on arrival.
local cannau = 17576406

local escortMinutes = 30

quest.sections =
{
    -- Rondipur offers the contract.
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE or status == xi.questStatus.QUEST_COMPLETED) and
                player:getFameLevel(xi.fameArea.SANDORIA) >= 6 and
                not player:hasKeyItem(xi.ki.COMPLETION_CERTIFICATE) and
                not xi.escort.hasActiveContract(player) and
                xi.escort.tallyAllows(player)
        end,

        [xi.zone.NORTHERN_SAN_DORIA] =
        {
            ['Rondipur'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(721)
                end,
            },

            onEventFinish =
            {
                [721] = function(player, csid, option, npc)
                    if option ~= 0 then
                        return
                    end

                    if player:getQuestStatus(xi.questLog.SANDORIA, xi.quest.id.sandoria.ESCORT_FOR_HIRE) == xi.questStatus.QUEST_COMPLETED then
                        player:addQuest(xi.questLog.SANDORIA, xi.quest.id.sandoria.ESCORT_FOR_HIRE)
                    else
                        quest:begin(player)
                    end

                    xi.escort.setActiveContract(player, xi.quest.id.sandoria.ESCORT_FOR_HIRE)
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

        [xi.zone.NORTHERN_SAN_DORIA] =
        {
            -- 13122 "Cancel your contract? / Yes. / No."
            ['Rondipur'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(722)
                end,
            },

            onEventFinish =
            {
                [722] = function(player, csid, option, npc)
                    if option == 0 then
                        xi.escort.cancelContract(player, xi.questLog.SANDORIA, xi.quest.id.sandoria.ESCORT_FOR_HIRE)
                    end
                end,
            },
        },

        [xi.zone.THE_ELDIEME_NECROPOLIS] =
        {
            onZoneIn = function(player, prevZone)
                if prevZone == xi.zone.BATALLIA_DOWNS then
                    xi.escort.startEscort(player, escortMinutes, cannau)
                end

                return -1
            end,

            ['Cannau'] =
            {
                onTrigger = function(player, npc)
                    if not xi.escort.isEscortLive(player) then
                        return
                    end

                    return quest:progressEvent(51)
                end,
            },

            onEventFinish =
            {
                [51] = function(player, csid, option, npc)
                    if not xi.escort.isEscortLive(player) then
                        return
                    end

                    if xi.escort.atStopPoint(player) then
                        if npcUtil.giveKeyItem(player, xi.ki.COMPLETION_CERTIFICATE) then
                            xi.escort.endEscort(player, cannau)
                        end
                    else
                        xi.escort.toggleFollow(player)
                    end
                end,
            },
        },
    },

    -- Certificate in hand: back to Rondipur for the payout.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                player:hasKeyItem(xi.ki.COMPLETION_CERTIFICATE)
        end,

        [xi.zone.NORTHERN_SAN_DORIA] =
        {
            ['Rondipur'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(723)
                end,
            },

            onEventFinish =
            {
                [723] = function(player, csid, option, npc)
                    if player:getFreeSlotsCount() == 0 then
                        player:messageSpecial(sandyID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.MIRATETES_MEMOIRS)
                        return
                    end

                    player:delKeyItem(xi.ki.COMPLETION_CERTIFICATE)

                    if player:getCharVar('EscortForHireCleared') == 0 then
                        local bonus = xi.settings.main.GIL_RATE * 10000

                        player:setCharVar('EscortForHireCleared', 1)
                        player:addGil(bonus)
                        player:messageSpecial(sandyID.text.GIL_OBTAINED, bonus)
                    end

                    player:addItem(xi.item.MIRATETES_MEMOIRS)
                    player:messageSpecial(sandyID.text.ITEM_OBTAINED, xi.item.MIRATETES_MEMOIRS)
                    player:completeQuest(xi.questLog.SANDORIA, xi.quest.id.sandoria.ESCORT_FOR_HIRE)

                    xi.escort.clearContract(player)
                    xi.escort.stampTally(player)
                end,
            },
        },
    },

    -- 13125, post-completion idle.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.NORTHERN_SAN_DORIA] =
        {
            ['Rondipur'] = quest:event(724),
        },
    },
}

return quest
