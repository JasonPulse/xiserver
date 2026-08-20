-----------------------------------
-- Beastman headgear quests -- shared implementation
--
-- Three quests run this exact flow, so they call
-- xi.beastmanHeadgear.sections() with their own ids instead of duplicating it:
--   A Generous General?        (otherAreas 109)
--   An Affable Adamantking?    (otherAreas 107)
--   An Understanding Overlord? (otherAreas 106)
--
-- Retail (bg-wiki, all three Walkthroughs are the same text with the nouns
-- swapped):
--   1. Enter the beastman stronghold for a cutscene that starts the quest.
--      "If you choose not to accept this quest, you will not be given the chance
--       to start it again until the next Conquest Tally."
--   2. Speak to the craftsman for a cutscene.
--   3. Trade the craftsman two leather/shell materials and 10,000 gil.
--   4. Wait until the next game day, then talk to him again; he hands over a
--      cutting and instructions. "Zoning is no longer required."
--   5. Synthesize the headgear from that cutting.
--   6. Trade the headgear back for the reward and title.
--   All three are Repeatable, once per Conquest Tally.
--
-- WHAT WAS THERE BEFORE. All three shipped as "accept + immediate complete"
-- one-section stubs bound to Faulpie, each firing a fabricated csid -- 720, 710
-- and 700. `xi-dat csid 230 720` reports no such event; 700's only owners in zone
-- 230 are Trail_Markings / Iru-Kuiru / a blank holder, none of them Faulpie. Two
-- of the three did not even start at Faulpie: bg-wiki's |Start= is the beastman
-- leader in the stronghold, and An Affable Adamantking's craftsman is Peshi
-- Yohnts in Windurst Woods, not Faulpie at all.
--
-- CSIDS DECODED, NOT GUESSED. Each craftsman owns a contiguous block of SIX
-- events, and the block's identity is pinned by the item ids embedded in its own
-- bytecode rather than by position:
--
--   Faulpie, Southern San d'Oria, entity 17719379 (npc_list.sql:25958);
--   (17719379-16777216) = 942163, 942163//4096 = 230 rem 83 -> 0x010E6053.
--     760-765  refs item 1865 orc_helm_cutting + 851 square_of_ram_leather
--              -> An Understanding Overlord? (bg-wiki: Buffalo Hide, Ram Leather)
--     770-775  refs item 1868 goblin_coif_cutting + 850 square_of_sheep_leather
--              -> A Generous General?        (bg-wiki: Buffalo Hide, Sheep Leather)
--
--   Peshi Yohnts, Windurst Woods, entity 17764402 (npc_list.sql:30003);
--   (17764402-16777216) = 987186, 987186//4096 = 241 rem 50 -> 0x010F1032.
--     710-715  refs item 1866 set_of_quadav_barbut_parts + 1637 bugard leather
--              + 885 turtle_shell
--              -> An Affable Adamantking?    (bg-wiki: Bugard Leather, Turtle Shell)
--
-- Roles within each block, read against `xi-dat dialog`:
--   +0  the offer / guild conversation. Faulpie 6915 "What brings you by my
--       humble guild today...? Perhaps you wish to place a special order?"
--   +1  the reminder while you fetch the materials (same two item refs as +0)
--   +2  the materials hand-over. Faulpie 6926 "Wonderful. Now that I have
--       everything I require, I can begin working on the final product......
--       What? You didn't think I was going to be able to whip this together in a
--       matter of minutes, did you?" -- i.e. this is what starts the game-day wait
--   +3  the still-working reminder (single line)
--   +4  hands over the cutting -- this is the event whose bytecode carries the
--       cutting's item id, which is what identifies the whole block
--   +5  the turn-in and reward (the largest program of the six, ~30 messages)
--
-- SOFT SPOT, called out rather than hidden: +0 versus +1. Both reference the same
-- two materials, so which is the first-contact conversation and which is the
-- "come back with the materials" reminder is inferred from +0 carrying the generic
-- guild greeting and being the longer program. Getting them the wrong way round
-- swaps two pieces of flavour text; it cannot mispay, because every state change
-- hangs off +2/+4/+5, which are unambiguous.
--
-- The stronghold zone-in cutscenes, on the zone-wide 0x7FFFFFF0 holder, pinned by
-- searching each zone for its own beastman leader's name:
--   Oldton Movalpolos (11)  csid 60, msgs 8037-8044 -- 8038 "prepare to hear the
--     ro-oar of Gu'Zho Thunderblade!!!", and 8048 is the accept prompt:
--     "Your grade in Movalpolos geography? ${selection-lines} A+. / F-."
--     "A+." is the FIRST selection line, so OPTION 0 ACCEPTS. 8049 is the decline
--     ("I'll just wait he-ere a little longer"), 8050 the accept continuation
--     ("Well, then I have a pro-oposition for you").
--   Qulun Dome (148)        csid 60, msgs 7378-7389 -- 7384 "Trooper first class
--     Raptorlegs Gedwa[d]"
--   Monastic Cavern (150)   csid  5, msgs 7339-7349 -- 7342 "I am Loo Kohor,
--     servant of Tzee Xicu the Manifest"
-- Option 0 is taken as the accept for all three on the strength of the Oldton
-- prompt, which is the only one of the three whose selection lines resolve.
--
-- The synthesis step needs nothing from us -- sql/synth_recipes.sql already has
-- all three, and each consumes exactly the cutting this quest grants and produces
-- exactly the headgear it asks for in return:
--   39961 'Orc Helm'      consumes 1865 -> produces 15200
--   43523 'Goblin Coif'   consumes 1868 -> produces 15203
--   53528 'Quadav Barbut' consumes 1866 -> produces 15201
--
-- FAME: bg-wiki lists |Fame= for none of the three, so no fame is granted. The old
-- stubs each paid `fame = 30, fameArea = SANDORIA`, which is wrong outright for
-- the Windurst one.
-----------------------------------

xi = xi or {}
xi.beastmanHeadgear = xi.beastmanHeadgear or {}

-- config fields:
--   questId          the otherAreas quest id
--   startZone        the beastman stronghold zone
--   startCsid        its zone-in cutscene
--   startPrevZone    the only zone you may arrive from for that cutscene to
--                    fire. bg-wiki names one specific entrance per quest, and
--                    without this the cutscene fires on EVERY entry to the
--                    stronghold, hijacking anyone passing through on other
--                    content and burning their Conquest Tally.
--   craftsmanZone    where the craftsman stands
--   craftsmanName    npc_list name of the craftsman
--   baseCsid         first of the craftsman's block of six
--   materials        the two items traded alongside the gil
--   cutting          the item he hands back
--   headgear         what you synthesize and trade in
--   reward           the item you receive
--   title            the title you receive
--   tallyVar         charvar gating the once-per-tally repeat
xi.beastmanHeadgear.sections = function(quest, config)
    local craftsmanID = zones[config.craftsmanZone]

    local offerCsid    = config.baseCsid
    local remindCsid   = config.baseCsid + 1
    local materialCsid = config.baseCsid + 2
    local waitCsid     = config.baseCsid + 3
    local cuttingCsid  = config.baseCsid + 4
    local turnInCsid   = config.baseCsid + 5

    return
    {
        -- The stronghold cutscene. Repeatable, so COMPLETED is eligible too, but
        -- only once per Conquest Tally -- bg-wiki: "Yes, Once per Conquest Tally".
        {
            check = function(player, status, vars)
                return (status == xi.questStatus.QUEST_AVAILABLE or
                        status == xi.questStatus.QUEST_COMPLETED) and
                    player:getCharVar(config.tallyVar) == 0
            end,

            [config.startZone] =
            {
                onZoneIn = function(player, prevZone)
                    -- Only from the entrance bg-wiki names. Firing on any entry
                    -- put this cutscene in front of every player walking into
                    -- the stronghold for unrelated content.
                    if prevZone ~= config.startPrevZone then
                        return
                    end

                    return config.startCsid
                end,

                onEventFinish =
                {
                    [config.startCsid] = function(player, csid, option, npc)
                        -- Option 0 is the accepting line; see the header note.
                        -- Declining still burns the tally, which is what bg-wiki
                        -- describes: "you will not be given the chance to start it
                        -- again until the next Conquest Tally."
                        player:setCharVar(config.tallyVar, 1, NextConquestTally())

                        if option ~= 0 then
                            return
                        end

                        if player:getQuestStatus(xi.questLog.OTHER_AREAS, config.questId) == xi.questStatus.QUEST_COMPLETED then
                            player:addQuest(xi.questLog.OTHER_AREAS, config.questId)
                        else
                            quest:begin(player)
                        end
                    end,
                },
            },
        },

        -- Accepted, materials not yet handed over.
        {
            check = function(player, status, vars)
                return status == xi.questStatus.QUEST_ACCEPTED and
                    vars.Prog == 0
            end,

            [config.craftsmanZone] =
            {
                [config.craftsmanName] =
                {
                    onTrade = function(player, npc, trade)
                        -- bg-wiki: "Trade <craftsman> a <hide>, <leather>, and
                        -- 10,000 gil." npc_util documents gil as a nested pair.
                        local order =
                        {
                            config.materials[1],
                            config.materials[2],
                            { 'gil', 10000 },
                        }

                        if npcUtil.tradeHasExactly(trade, order) then
                            return quest:progressEvent(materialCsid)
                        end
                    end,

                    onTrigger = function(player, npc)
                        if quest:getVar(player, 'Talked') == 0 then
                            return quest:progressEvent(offerCsid)
                        end

                        return quest:event(remindCsid)
                    end,
                },

                onEventFinish =
                {
                    [offerCsid] = function(player, csid, option, npc)
                        quest:setVar(player, 'Talked', 1)
                    end,

                    [materialCsid] = function(player, csid, option, npc)
                        player:confirmTrade()
                        quest:setVar(player, 'Prog', 1)

                        -- "Wait until the next game day to talk to him again."
                        quest:setVar(player, 'Wait', VanadielUniqueDay() + 1)
                    end,
                },
            },
        },

        -- Materials in, waiting on the cutting.
        {
            check = function(player, status, vars)
                return status == xi.questStatus.QUEST_ACCEPTED and
                    vars.Prog == 1
            end,

            [config.craftsmanZone] =
            {
                [config.craftsmanName] =
                {
                    onTrigger = function(player, npc)
                        if quest:getVar(player, 'Wait') > VanadielUniqueDay() then
                            return quest:event(waitCsid)
                        end

                        return quest:progressEvent(cuttingCsid)
                    end,
                },

                onEventFinish =
                {
                    [cuttingCsid] = function(player, csid, option, npc)
                        if npcUtil.giveItem(player, config.cutting) then
                            quest:setVar(player, 'Prog', 2)
                        end
                    end,
                },
            },
        },

        -- Cutting given: synthesize the headgear and trade it back.
        {
            check = function(player, status, vars)
                return status == xi.questStatus.QUEST_ACCEPTED and
                    vars.Prog == 2
            end,

            [config.craftsmanZone] =
            {
                [config.craftsmanName] =
                {
                    onTrade = function(player, npc, trade)
                        if npcUtil.tradeHasExactly(trade, config.headgear) then
                            return quest:progressEvent(turnInCsid)
                        end
                    end,

                    onTrigger = function(player, npc)
                        return quest:event(waitCsid)
                    end,
                },

                onEventFinish =
                {
                    [turnInCsid] = function(player, csid, option, npc)
                        if player:getFreeSlotsCount() == 0 then
                            player:messageSpecial(craftsmanID.text.ITEM_CANNOT_BE_OBTAINED, config.reward)
                            return
                        end

                        player:confirmTrade()

                        if quest:complete(player) then
                            quest:setVar(player, 'Prog', 0)
                            quest:setVar(player, 'Talked', 0)
                            quest:setVar(player, 'Wait', 0)
                        end
                    end,
                },
            },
        },
    }
end
