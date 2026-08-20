-----------------------------------
-- Cleansing the Canyon
-----------------------------------
-- Log ID: 8, Quest ID: 22
-- Kupipi : Abyssea - Tahrongi (H-12), entity 16962090
-- !addquest 8 22
-----------------------------------
-- Retail (bg-wiki "Cleansing the Canyon").
-- |Start=Kupipi (A) (H-12), Abyssea - Tahrongi  |Repeatable=Yes
-- |Previous=Refuel and Replenish (Tahrongi)  |Item Reqs=Sanguinet x3
-- |Reward=First time completion: Elixir.  Subsequent completions: 100 Cruor
--   1. Speak with Kupipi (A) at (H-12) to begin the quest.
--   2. She will request 3 Sanguinets. "These drop from Abyssea-unique monster
--      families (such as Clionid, Murex, Amoeban, etc.) in every Abyssea zone."
--   3. Trade her the Sanguinets to complete the quest.
--
-- CSIDS DECODED, NOT GUESSED. Kupipi is 16962090 -> zone 45 idx 554
-- (0x0102D22A). `xi-dat events 45` gives her 300, 301, 318-321 and 382-386 --
-- she carries more than one quest. csidscan.py against `xi-dat dialog 45` splits
-- them: 382-386 are the five-NM hunt (8053-8072, "It's a listaru of the most
-- fearsome fiends terrorizing our five camps... Cuelebre, Adze, Minhocao,
-- Chukwa, and...Mictlantecuhtli"), while THIS quest is the 318-321 block:
--   318 -> 7895-7902  THE OFFER. 7896 "one of our supply convoys was
--          ambushed-wambushed on its way to the western camp!", 7899 "I want
--          you--yes, you--to clean this area up of all hostile-wostiles", and
--          7900 carries the request: "I'll need you to bring back ${number: 1}
--          ${item-given-plurality: 1[2], 0[2]} as proof of your exploitarus."
--          The item is param 0 and the count is param 1. There is NO
--          ${selection-lines} anywhere in the block, so there is no accept
--          option to test -- speaking to her starts it. 7902 "...Pretty
--          ple～ase?" is her closing plea, not a decline branch.
--   319 -> 7899/7900  the reminder, the request without the preamble.
--   320 -> 7903/7904  THE TURN-IN. "I knew it! I just kne～w it! You're every
--          ilm the champion that Kupipi figured-wigured you for!"
--   321 -> 7904       her post-completion line ("You can do even bettaru!").
--
-- ITEM: Sanguinet is the existing SANGUINET (2888).
-- REWARD: the Elixir is first-completion only; repeats pay 100 Cruor, which is
-- why the reward is applied by hand rather than through quest.reward.
--
-- PREREQUISITE NOTE: bg-wiki's |Previous= is Refuel and Replenish (Tahrongi),
-- which is one of the nine martello replenishment quests and is not implemented
-- -- those run on a client-side-masked twelve-option Martello menu whose param
-- convention is not recoverable from the dumped DAT. The gate below is correct
-- per bg-wiki; that quest still needs building before this one is reachable in a
-- fresh playthrough.
-----------------------------------
local tahrongiID = zones[xi.zone.ABYSSEA_TAHRONGI]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.CLEANSING_THE_CANYON)

local sanguinetCount = 3
local cruorReward    = 100

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_TAHRONGI,
}

quest.sections =
{
    -- COMPLETED is accepted because |Repeatable=Yes.
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE or
                    status == xi.questStatus.QUEST_COMPLETED) and
                player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.REFUEL_AND_REPLENISH_TAHRONGI)
        end,

        [xi.zone.ABYSSEA_TAHRONGI] =
        {
            ['Kupipi'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(318, { [0] = xi.item.SANGUINET, [1] = sanguinetCount })
                end,
            },

            onEventFinish =
            {
                [318] = function(player, csid, option, npc)
                    if player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.CLEANSING_THE_CANYON) then
                        player:addQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.CLEANSING_THE_CANYON)
                    else
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    -- Accepted: bring her the three Sanguinets.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_TAHRONGI] =
        {
            ['Kupipi'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, { { xi.item.SANGUINET, sanguinetCount } }) then
                        return quest:progressEvent(320)
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(319, { [0] = xi.item.SANGUINET, [1] = sanguinetCount })
                end,
            },

            onEventFinish =
            {
                [320] = function(player, csid, option, npc)
                    local first = not player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.CLEANSING_THE_CANYON)

                    player:confirmTrade()

                    if quest:complete(player) then
                        if first then
                            npcUtil.giveItem(player, xi.item.ELIXIR)
                        else
                            player:addCurrency('cruor', cruorReward)
                            player:messageSpecial(tahrongiID.text.CRUOR_OBTAINED, cruorReward, player:getCurrency('cruor'))
                        end
                    end
                end,
            },
        },
    },

    -- Completed: 7904, "You can do even bettaru!"
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_TAHRONGI] =
        {
            ['Kupipi'] = quest:event(321):replaceDefault(),
        },
    },
}

return quest
