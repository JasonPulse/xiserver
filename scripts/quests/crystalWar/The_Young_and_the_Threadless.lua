-----------------------------------
-- The Young and the Threadless
-----------------------------------
-- Log ID: 7, Quest ID: 56
-- Ponono : Windurst Waters [S] (K-11, north map)
-----------------------------------
-- Retail (bg-wiki "The Young and the Threadless"):
--   1. Speak to Ponono, Windurst Waters [S] (K-11) -> {KI} Ponono's charm.
--   2. Zone out and back, speak again -> the three delicate thread key items.
--   3. Steep each thread in a pool of mystic water:
--        Knightwell, West Ronfaure (H-11)
--        Fay Spring, Grauberg [S] (F-6)
--        Lake Tepokalipuka, East Sarutabaruta (F-9)
--   4. Return to Ponono -> Trainee Scissors.
-- No title, no previous/next.
--
-- CSIDs decoded, not guessed. Ponono is entity 17162690
-- (sql/npc_list.sql:10695); (17162690-16777216) = 385474, 385474//4096 = 94
-- rem 450 -> Windurst Waters [S]. Resolved with xidat/csidmsg.py and read
-- against `xi-dat dialog 94`. Ponono owns exactly 191-198:
--   191 -> 7706-7714, the start granting the charm. 7707 "Here's a token for
--          your troubles... it's a Ponono original, after all!", 7709 "Do you see
--          the three threads so exquisitaruly entwined?"
--   192 -> 7715-7732, the zone-and-return cutscene that hands out the three
--          threads. 7715 "How nice to see you sportaruing the
--          ${keyitem-singular: 0[2]} I gave you!", 7717 "The thread must be
--          steepy-weeped in three pools of mystic water, you see..."
--   194 / 195 / 196 -> the three per-pool variants. They share the 7733/7736
--          frame with one unique middle message each, which is exactly a 3-way
--          branch -- one per water location.
--   197 -> 7737-7748, the final cutscene and reward.
--   198 -> 7706, the reminder.
--
-- Crystal War zones are NOT dialog-offset. Control: `xi-dat search 94
-- "Rhinostery"` -> [10941] "This is the Rhinostery, home to a myriad of research
-- and study...", i.e. zone 94's own table reads correctly.
--
-- The previous stub fired csid 1160, which `xi-dat csid 94 1160` reports as
-- "not found in zone 94" -- part of a fabricated arithmetic sequence keyed to the
-- quest id, so the NPC did nothing when triggered.
-----------------------------------
local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.THE_YOUNG_AND_THE_THREADLESS)

quest.reward =
{
    item = xi.item.TRAINEE_SCISSORS,
}

-- One bit per pool, stored in the quest var 'Steeped'. Each pool consumes its
-- matching thread key item.
-- POOL CSIDS CORRECTED. 194/195/196 were a fabricated run of consecutive ids;
-- `xi-dat csid <zone> <n>` reports each of them as "not found" in its own zone,
-- so all three steeping steps did nothing and the quest dead-ended after the
-- thread hand-out. They are in fact Ponono's own "you haven't enchanted them all
-- yet" reminders back in Windurst Waters [S] (msgs 7733-7736), which is what the
-- old header note mistook for "the three per-pool variants".
-- The real ids are one 64-byte program per pool entity, each confirmed by its
-- dialog naming both the pool and the colour it dyes the thread:
--   Knightwell        zone 100 West Ronfaure      0x010642BB (17187515) csid 141
--     -> 8058 "dipped the ${keyitem} in the crisp, cool waters of the Knightwell"
--        8059 "now shimmers a brilliant shade of red!"
--   Fay Spring        zone  89 Grauberg [S]       0x010592BC (17142460) csid  23
--     -> 7801 "...the tranquil waters of the Fay Spring"  7802 "...blue!"
--   Lake Tepokalipuka zone 116 East Sarutabaruta  0x010742CF (17253071) csid  72
--     -> 7467 "...the curious waters of Lake Tepokalipuka"  7468 "...green!"
local pools =
{
    [xi.zone.WEST_RONFAURE]     = { npc = 'Knightwell',         bit = 0, ki = xi.ki.DELICATE_WOOL_THREAD,   csid = 141 },
    [xi.zone.GRAUBERG_S]        = { npc = 'Fay_Spring',         bit = 1, ki = xi.ki.DELICATE_LINEN_THREAD,  csid =  23 },
    [xi.zone.EAST_SARUTABARUTA] = { npc = 'Lake_Tepokalipuka',  bit = 2, ki = xi.ki.DELICATE_COTTON_THREAD, csid =  72 },
}

local allSteeped = 7 -- bits 0-2

local function poolSection()
    local section =
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Threads == 1 and
                vars.Steeped ~= allSteeped
        end,
    }

    for zoneId, data in pairs(pools) do
        section[zoneId] =
        {
            [data.npc] =
            {
                onTrigger = function(player, npc)
                    if
                        not utils.mask.getBit(quest:getVar(player, 'Steeped'), data.bit) and
                        player:hasKeyItem(data.ki)
                    then
                        return quest:progressEvent(data.csid)
                    end
                end,
            },

            onEventFinish =
            {
                [data.csid] = function(player, csid, option, npc)
                    quest:setVar(player, 'Steeped', utils.mask.setBit(quest:getVar(player, 'Steeped'), data.bit, true))
                    player:delKeyItem(data.ki)
                end,
            },
        }
    end

    return section
end

quest.sections =
{
    -- Offer: Ponono hands over his charm.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.WINDURST_WATERS_S] =
        {
            ['Ponono'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(191, { [0] = xi.ki.PONONOS_CHARM })
                end,
            },

            onEventFinish =
            {
                [191] = function(player, csid, option, npc)
                    quest:begin(player)

                    if npcUtil.giveKeyItem(player, xi.ki.PONONOS_CHARM) then
                        -- bg-wiki: you must zone before he will hand out the threads.
                        quest:setMustZone(player)
                    end
                end,
            },
        },
    },

    -- After zoning, Ponono hands over the three threads.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Threads ~= 1
        end,

        [xi.zone.WINDURST_WATERS_S] =
        {
            ['Ponono'] =
            {
                onTrigger = function(player, npc)
                    if quest:getMustZone(player) then
                        return quest:event(198, { [0] = xi.ki.PONONOS_CHARM })
                    end

                    return quest:progressEvent(192, { [0] = xi.ki.PONONOS_CHARM })
                end,
            },

            onEventFinish =
            {
                [192] = function(player, csid, option, npc)
                    if npcUtil.giveKeyItem(player, { xi.ki.DELICATE_WOOL_THREAD, xi.ki.DELICATE_LINEN_THREAD, xi.ki.DELICATE_COTTON_THREAD }) then
                        quest:setVar(player, 'Threads', 1)
                    end
                end,
            },
        },
    },

    poolSection(),

    -- All three steeped: return to Ponono for the Trainee Scissors.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Steeped == allSteeped
        end,

        [xi.zone.WINDURST_WATERS_S] =
        {
            ['Ponono'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(197)
                end,
            },

            onEventFinish =
            {
                [197] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.PONONOS_CHARM)
                    end
                end,
            },
        },
    },
}

return quest
