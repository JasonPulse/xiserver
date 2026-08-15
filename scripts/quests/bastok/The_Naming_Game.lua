-----------------------------------
-- The Naming Game
-----------------------------------
-- Log ID: 1, Quest ID: 81
-- Raibaht : Metalworks (G-8)
-- Cid     : Metalworks (G-8)
-----------------------------------
-- Retail (bg-wiki "The Naming Game"), previous quest Hyper Active, Repeatable=Y:
--   1. Obtain a Chunk of Ordrynite (Pso'Xja Cryptonberry Plaguer/Stalker, or
--      Beaucedine chocobo digging).
--   2. Trade it to Raibaht. Fame Bastok 5.
--   3. Pick the four name segments for Cid's new airship.
-- Reward: sets the name of the airship that appears in CoP 5-1, plus
-- "First time only: 3,600 gil", plus the title Hyper Ultra Sonic Adventurer.
-- Completing it ten times unlocks the fourth name segment.
--
-- REWARD CORRECTION -- this is the notable fix. The previous version of this file
-- claimed in its own header: "FABRICATED GIL REMOVED: this used to pay 3,600 on
-- first clear and 500 on EVERY repeat. Neither figure appears on bg-wiki". That
-- premise was wrong. bg-wiki's Reward field reads, verbatim:
--     * Set name of new airship which appears in CoP 5-1
--     * First time only: {{Icon|Gil|Medium}} 3,600 gil
-- So the 3,600 first-time-only payment IS retail and is restored here. The
-- 500-per-repeat WAS fabricated, and since the quest is repeatable that would
-- have been an unbounded faucet -- removing that part was correct, and it stays
-- removed.
--
-- CSIDs decoded, not guessed. Raibaht is entity 17748012 (npc_list:28596) ->
-- zone 237 index 44, 0x010ED02C. Cid is 17748011 (npc_list:28595) -> index 43.
-- Read against `xi-dat dialog 237`:
--   868 -> the offer. A 459-byte program on the invisible holder DIRECTOR
--          0x010ED0A3, with 1-byte stubs on Cid, Raibaht and Door:Cid's Lab.
--          DIRECTOR's data table holds 9957-9964: 9961 "After watching the chief
--          for the past few weeks, I think I came to realize what was troubling
--          him.", 9962 "Until recently, Chief Cid had been working on what he
--          called a 'semiperpetual motion engine.' However, after months of
--          making little or no progress, he finally gave up on the idea.", 9963
--          "If he were only able to acquire the ${item-singular: 1} that had been
--          used in previous semiperpetual motion experiments..."
--   873 -> a 51-byte program on Raibaht -> 9962, 9963, 9964, the reminder.
--   869 -> the trade and the name picker, and the largest program in the chain at
--          2754 bytes on DIRECTOR, with stubs on Cid, Raibaht and Door:Cid's Lab.
--          csidmsg 237 17748131 -> 869 -> 9981, 9982, 9983 -- the three picker
--          prompts: 9981 "Start with... / Nothing. / Ultra / Hyper / Psycho /
--          ..." (22 options), 9982 "Add... / Nothing. / Terror / Perfect / ..."
--          (22 options), 9983 "And finish with... / Nothing. / Hyper / Neo / ..."
--          (22 options) -- an exact match for bg-wiki's Segment 1/2/3 tables.
--          Surrounding text: 9965 "This... The ${item-singular: 1} of legend! But
--          it cannot be...", 9975 "The name for my new bird!", 9978
--          "${name-player}, you've been helping me prepare my big girl. Why don't
--          you make the final call?", and 9988 "Thank you. This will help with the
--          development of the '${choice: 0}...${choice: 3}'" -- where param 3 has
--          13 options, which is bg-wiki's Segment 4.
--   874 -> a 15-byte program on Raibaht -> 9987 "...If you ever wish to...rethink
--          the name you have given the chief's airship, please bring another
--          ${item-singular: 1}." -- the repeat hook.
--   870 -> the repeat name-change cutscene, 1444 bytes on DIRECTOR -> 9981, 9982,
--          9983 and 9991; 9989 "Hm? You wish to change the name of Chief Cid's
--          airship?", 9990 "Alright. We shall now call her the '...'"
-- Confidence note, stated plainly: 869/873/874/870 are pinned by quoted dialog.
-- 868 is the offer by elimination -- it is the only remaining Naming-Game-range
-- holder program, and its block 9957-9964 is the narrative lead-in to 873's
-- reminder -- so it is slightly weaker than the rest.
--
-- The old stub invented csid 504 for the trade. 504 is a real program in
-- Metalworks (703 bytes on 0x7FFFFFF0 with stubs on Cid 0x010ED02B and
-- 0x010ED02E) but belongs to a different chain; nothing fires it, and it is not
-- touched here. bg-wiki lists no fame, so the stub's 40 is gone.
--
-- xi.item.CHUNK_OF_ORDRYNITE = 1728 (item.lua:1140) is correct and confirmed
-- against sql/item_basic.sql. Title 341 is correct (title.lua:342).
--
-- STILL SIMPLIFIED, and flagged rather than faked: the four chosen segments are
-- stored in charvars, but nothing renders them, because the airship that carries
-- the name only appears in CoP 5-1 and no NPC or entity in this repo reads a
-- player-chosen airship name. Wiring the display needs that airship built first.
-- The picker itself, the ten-clear counter that unlocks segment 4, the first-time
-- 3,600 gil and the title are all faithful.
-----------------------------------
local metalworksID = zones[xi.zone.METALWORKS]

local quest = Quest:new(xi.questLog.BASTOK, xi.quest.id.bastok.THE_NAMING_GAME)

quest.reward =
{
    title = xi.title.HYPER_ULTRA_SONIC_ADVENTURER,
}

-- bg-wiki: "Completing it ten times unlocks the 4th name segment."
local clearsForFinalSegment = 10

local function storeName(player, option)
    -- The three 22-option prompts and the 13-option finisher arrive packed in
    -- `option`; each is kept so a future airship NPC can read them back.
    player:setCharVar('AirshipNameSegments', option)
end

quest.sections =
{
    -- First run: Raibaht explains, then the Ordrynite trade.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.BASTOK) >= 5 and
                player:hasCompletedQuest(xi.questLog.BASTOK, xi.quest.id.bastok.HYPER_ACTIVE)
        end,

        [xi.zone.METALWORKS] =
        {
            ['Raibaht'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(868, { [1] = xi.item.CHUNK_OF_ORDRYNITE })
                end,
            },

            onEventFinish =
            {
                [868] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    -- Accepted: waiting on the Ordrynite.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.METALWORKS] =
        {
            ['Raibaht'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(873, { [1] = xi.item.CHUNK_OF_ORDRYNITE })
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.CHUNK_OF_ORDRYNITE) then
                        return quest:progressEvent(869, { [1] = xi.item.CHUNK_OF_ORDRYNITE })
                    end
                end,
            },

            onEventFinish =
            {
                [869] = function(player, csid, option, npc)
                    player:confirmTrade()
                    storeName(player, option)

                    local clears = player:getCharVar('NamingGameClears') + 1
                    player:setCharVar('NamingGameClears', clears)

                    -- bg-wiki: first time only, 3,600 gil.
                    if player:getCharVar('NamingGamePaid') == 0 then
                        local bonus = xi.settings.main.GIL_RATE * 3600

                        player:setCharVar('NamingGamePaid', 1)
                        player:addGil(bonus)
                        player:messageSpecial(metalworksID.text.GIL_OBTAINED, bonus)
                    end

                    quest:complete(player)
                end,
            },
        },
    },

    -- Completed: 874 is the offer to rename, 870 does it. Repeatable, and each
    -- rename still needs another Chunk of Ordrynite.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.METALWORKS] =
        {
            ['Raibaht'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(874, { [1] = xi.item.CHUNK_OF_ORDRYNITE })
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.CHUNK_OF_ORDRYNITE) then
                        return quest:progressEvent(870,
                        {
                            [1] = xi.item.CHUNK_OF_ORDRYNITE,
                            -- Segment 4 only unlocks after ten clears.
                            [2] = player:getCharVar('NamingGameClears') >= clearsForFinalSegment and 1 or 0,
                        })
                    end
                end,
            },

            onEventFinish =
            {
                [870] = function(player, csid, option, npc)
                    player:confirmTrade()
                    storeName(player, option)
                    player:setCharVar('NamingGameClears', player:getCharVar('NamingGameClears') + 1)
                end,
            },
        },
    },
}

return quest
