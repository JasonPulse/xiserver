-----------------------------------
-- The Rider Cometh
-----------------------------------
-- Log ID: 6, Quest ID: 76
-- Naja Salaheem   : Aht Urhgan Whitegate (I-10)
-- Walahra Temple  : Aht Urhgan Whitegate, cuboid trigger area 4 (J/K-8)
-- Yoyoroon        : Nashmau (G-6), upper level stalls -- NOT Yuyuroon
-- Entry Gate      : Hazhalm Testing Grounds (_260)
-----------------------------------
-- Retail (bg-wiki "The Rider Cometh"). Prereq: Aht Urhgan Mission 48,
-- Eternal Mercenary. Unlocks Unwavering Resolve.
--
-- All CSIDs below were decoded offline with xidat/csidmsg.py and confirmed by
-- reading the messages each one emits against `xi-dat dialog`. None were
-- guessed. The previous stub fired 300 on Nashmeira, which Nashmeira does not
-- own -- see DECODED_CSIDS.md Appendix B.
--
--   Whitegate (zone 50), proxy entity 0x01032269:
--     959 -> msgs 14500-14527, the full Naja thread. 14503 "That foreboding
--            visage known as the Dark Rider is now known to be none other than
--            the nefarious god Odin himself...he regularly haunts the Hazhalm
--            Testing Grounds", 14507 "you must send him back to the hell from
--            which he came!", and the post-victory lines 14512-14515. The
--            client branches internally on quest progress.
--   Whitegate (zone 50), proxy entity 0x010321AD:
--     882 -> msgs 14918-15098. 15091 "with a simple alchemical modification,
--            the talisman could function as a powerful key, granting any
--            bearer access to the deepest chambers of Hazhalm" => Talisman key.
--   Nashmau (zone 53), proxy entity 0x01035062:
--     318 -> 11818-11840, first Yoyoroon conversation. 11839 asks for a treat
--            from the teahouse, 11840 "Be safe in your travels" => Message
--            from Yoyoroon.
--     327 -> 11847-11868, the talisman + food trade and appraisal. 11868 is
--            the menu "Give a treat to Yoyoroon? / <item1> / <item2> / Both",
--            matching bg-wiki's "or even both". 11860-11862 = success.
--     320 -> 11869-11873, "One [keyitem], restored as closely as possible to
--            its original glory" => Talisman of the rebel gods.
--
-- bg-wiki lists inspecting the Imperial Whitegate as a fallback if the temple
-- cutscene does not fire. That binding is deliberately NOT implemented: the
-- Imperial Whitegate is shared with Trust_Nashmeira, BLU_AF3_Transformations,
-- The_Beast_Within, Divine_Interference, Waking_the_Colossus, ToAU 17/26/46 and
-- RoV 2_07/2_09/2_13, and quest:progressEvent (priority 1000) would outrank
-- mission:event (100) and hijack the NPC. Trigger area 4 is the retail primary
-- path and is safe.
--
-- Ship checks performed: Aht_Urhgan_Whitegate/Zone.lua onEventFinish acts only
-- on 44/200/203/526/797 and Nashmau/Zone.lua on none of these, so no csid
-- collides with a zone warp. Naja_Salaheem, Yoyoroon and _260 were each checked
-- for competing handlers.
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.THE_RIDER_COMETH)

quest.reward =
{
    title = xi.title.HEIR_OF_THE_BLIGHTED_GLOOM,
    item  = { xi.item.IMPERIAL_GOLD_PIECE },
}

local rewardItems =
{
    [0] = xi.item.AESIR_MANTLE,
    [1] = xi.item.AESIR_EAR_PENDANT,
    [2] = xi.item.AESIR_TORQUE,
}

local appraisalFoods =
{
    xi.item.BOWL_OF_SUTLAC,
    xi.item.IRMIK_HELVASI,
}

-- Mirrors Waking the Colossus: the client greys out rewards already held, and
-- bit 4 marks the pact as already learned.
local function getRewardMask(player)
    local rewardMask = 0

    for bitNum, itemId in pairs(rewardItems) do
        if player:hasItem(itemId) then
            rewardMask = utils.mask.setBit(rewardMask, bitNum, true)
        end
    end

    if player:hasSpell(xi.magic.spell.ODIN) then
        rewardMask = utils.mask.setBit(rewardMask, 4, true)
    end

    return rewardMask
end

local function giveQuestReward(player, eventOption)
    local wasRewarded = true

    -- Lower bound matters: if the player cancels the reward menu the option is 0,
    -- which would index rewardItems[-1] = nil. npcUtil.giveItem(player, nil) does
    -- not error -- it builds an empty item list and returns true -- so without
    -- this guard the quest would complete and consume the Talisman key while
    -- handing over nothing. (Waking_the_Colossus has the same unguarded shape.)
    if eventOption < 1 or eventOption > 5 then
        return false
    end

    if eventOption <= 3 then
        wasRewarded = npcUtil.giveItem(player, rewardItems[eventOption - 1])
    elseif eventOption == 4 then
        npcUtil.giveCurrency(player, 'gil', 10000)
    elseif eventOption == 5 then
        player:addSpell(xi.magic.spell.ODIN)
    end

    return wasRewarded
end

local function tradedTalismanAndFood(trade)
    if not trade:hasItemQty(xi.item.TIMEWORN_TALISMAN, 1) then
        return false
    end

    for _, food in ipairs(appraisalFoods) do
        if trade:hasItemQty(food, 1) then
            return true
        end
    end

    return false
end

quest.sections =
{
    -- Offer: Naja briefs the player on the Dark Rider.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedMission(xi.mission.log_id.TOAU, xi.mission.id.toau.ETERNAL_MERCENARY)
        end,

        [xi.zone.AHT_URHGAN_WHITEGATE] =
        {
            ['Naja_Salaheem'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(959)
                end,
            },

            onEventFinish =
            {
                [959] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    -- Yoyoroon in Nashmau explains the talisman and asks for a treat.
    --
    -- Progress is tracked with an explicit Prog var rather than by testing which
    -- key items the player currently holds. That matters because the battlefield
    -- declares requiredKeyItems = { TALISMAN_KEY }, and battlefield.lua:408
    -- documents those as "removed upon entry unless 'keep = true'". Once entry
    -- consumes the key the player holds none of this quest's key items, so a
    -- has/hasn't-key-item ladder would fall back into this section and hand out a
    -- second Message from Yoyoroon.
    --   Prog 0 = accepted, needs the first Yoyoroon talk
    --   Prog 1 = has Message from Yoyoroon, owes the talisman + food trade
    --   Prog 2 = appraisal done, holds Talisman of the rebel gods
    --   Prog 3 = holds Talisman key, may enter Hazhalm
    --   Prog 4 = Odin defeated, owed the reward
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 0
        end,

        [xi.zone.NASHMAU] =
        {
            ['Yoyoroon'] =
            {
                onTrigger = function(player, npc)
                    -- Retail refuses to progress while the player is Blue Mage.
                    if player:getMainJob() == xi.job.BLU then
                        return
                    end

                    return quest:progressEvent(318)
                end,
            },

            onEventFinish =
            {
                [318] = function(player, csid, option, npc)
                    if npcUtil.giveKeyItem(player, xi.ki.MESSAGE_FROM_YOYOROON) then
                        quest:setVar(player, 'Prog', 1)
                    end
                end,
            },
        },
    },

    -- Trade Timeworn Talisman plus Sutlac and/or Irmik Helvasi. The appraisal
    -- can fail, consuming the talisman and the food.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 1
        end,

        [xi.zone.NASHMAU] =
        {
            ['Yoyoroon'] =
            {
                onTrade = function(player, npc, trade)
                    if tradedTalismanAndFood(trade) then
                        -- Record this now: confirmTrade() in the finish handler
                        -- empties the container, so it cannot be inspected there.
                        local bothFoods =
                            trade:hasItemQty(xi.item.BOWL_OF_SUTLAC, 1) and
                            trade:hasItemQty(xi.item.IRMIK_HELVASI, 1)

                        quest:setVar(player, 'BothFoods', bothFoods and 1 or 0)

                        return quest:progressEvent(327)
                    end
                end,

                onTrigger = function(player, npc)
                    if
                        quest:getVar(player, 'Appraised') == 1 and
                        not quest:getMustZone(player)
                    then
                        return quest:progressEvent(320)
                    end
                end,
            },

            onEventFinish =
            {
                [327] = function(player, csid, option, npc)
                    player:confirmTrade()

                    -- bg-wiki: the appraisal can fail, and trading both foods
                    -- alongside the talisman gives the highest chance of
                    -- success. A failure consumes everything traded.
                    --
                    -- The exact retail percentages are not documented, so these
                    -- are house numbers, not decoded values -- flagged rather
                    -- than presented as retail-accurate. Both-foods is
                    -- deliberately not 100%, because bg-wiki says "highest
                    -- chance", not "guaranteed".
                    local successRate = quest:getVar(player, 'BothFoods') == 1 and 85 or 50

                    quest:setVar(player, 'BothFoods', 0)

                    if math.random(100) <= successRate then
                        quest:setVar(player, 'Appraised', 1)

                        -- bg-wiki: "you will have to zone and talk to Yoyoroon
                        -- again to receive the Talisman of the rebel gods."
                        quest:setMustZone(player)
                    end
                end,

                [320] = function(player, csid, option, npc)
                    if npcUtil.giveKeyItem(player, xi.ki.TALISMAN_OF_THE_REBEL_GODS) then
                        player:delKeyItem(xi.ki.MESSAGE_FROM_YOYOROON)
                        quest:setVar(player, 'Appraised', 0)
                        quest:setVar(player, 'Prog', 2)
                    end
                end,
            },
        },
    },

    -- Walahra Temple converts the restored talisman into the Talisman key.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 2
        end,

        [xi.zone.AHT_URHGAN_WHITEGATE] =
        {
            onTriggerAreaEnter =
            {
                [4] = function(player, triggerArea)
                    return quest:progressEvent(882)
                end,
            },

            onEventFinish =
            {
                [882] = function(player, csid, option, npc)
                    if npcUtil.giveKeyItem(player, xi.ki.TALISMAN_KEY) then
                        player:delKeyItem(xi.ki.TALISMAN_OF_THE_REBEL_GODS)
                        quest:setVar(player, 'Prog', 3)
                    end
                end,
            },
        },
    },

    -- Odin defeated in Hazhalm; Naja debriefs and hands out the reward.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog >= 3
        end,

        [xi.zone.HAZHALM_TESTING_GROUNDS] =
        {
            onEventFinish =
            {
                -- 32001 is the battlefield win event. BattlefieldQuest's
                -- onBattlefieldWin sets the 'battlefieldWin' LOCAL var
                -- (battlefield.lua:1513), and a local var does not survive the
                -- zone change from Hazhalm back to Whitegate -- so it has to be
                -- converted to a persistent quest var here, in the battlefield's
                -- own zone, before the player leaves. This is exactly what
                -- Moment_of_Truth.lua:162-166 does (localVar -> Prog = 5 inside
                -- the Jade Sepulcher section). Reading the local var at Naja
                -- instead would make the reward permanently unreachable.
                [32001] = function(player, csid, option, npc)
                    if player:getLocalVar('battlefieldWin') == xi.battlefield.id.RIDER_COMETH then
                        quest:setVar(player, 'Prog', 4)
                    end
                end,
            },
        },

        [xi.zone.AHT_URHGAN_WHITEGATE] =
        {
            ['Naja_Salaheem'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Prog') == 4 then
                        return quest:progressEvent(959, { [0] = xi.besieged.getMercenaryRank(player), [7] = getRewardMask(player) })
                    end
                end,
            },

            onEventFinish =
            {
                [959] = function(player, csid, option, npc)
                    if giveQuestReward(player, option) then
                        -- No delKeyItem here: battlefield entry already consumed
                        -- the Talisman key (battlefield.lua:408). quest:complete
                        -- clears the quest vars, resetting Prog.
                        quest:complete(player)
                    end
                end,
            },
        },
    },
}

return quest
