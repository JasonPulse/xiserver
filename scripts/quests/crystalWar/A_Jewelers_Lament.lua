-----------------------------------
-- A Jeweler's Lament
-----------------------------------
-- Log ID: 7, Quest ID: 48
-- Wahid : Bastok Markets [S] (J-9)
-----------------------------------
-- Retail (bg-wiki "A Jeweler's Lament"):
--   1. Speak to Wahid, Bastok Markets [S] (J-9).
--   2. Trade him a Sunstone, an Aquamarine and a Jadeite.
--   3. Zone out and back, speak to Wahid again.
--   4. Exit to North Gustaberg [S] for a cutscene (the soldier Bernhard).
--   5. Examine the ??? at North Gustaberg [S] (J-4) for a cutscene.
--   6. Examine it again -> {KI} Unadorned ring.
--   7. Return to Wahid, then zone out and back and speak again -> Trainee Burin.
-- No title, no previous/next.
--
-- CSIDs decoded, not guessed. Wahid is entity 17134154 (sql/npc_list.sql:9613);
-- (17134154-16777216) = 356938, 356938//4096 = 87 rem 586 -> Bastok Markets [S].
-- Resolved with xidat/csidmsg.py and read against `xi-dat dialog 87`. He owns a
-- clean contiguous block 335-344:
--   335 -> 7625-7631, the start. 7625 "Well met! I am Wahid, a gem dealer of
--          some repute", 7627 "I'm suffering from a shortage of product--
--          ${item-plural: 0[2]}, ${item-plural: 1[2]}, and ${item-plural: 2[2]}",
--          7631 "see if you can locate the three stones I seek." The three
--          item-plural slots map exactly to the three gems.
--   336 -> 7632, the quest-active reminder ("You haven't come across any...").
--   337 -> 7633-7660, the three-gem trade. 7633 "Oho! I knew I could count on
--          you!", 7635 "What say you to 50,000 gil for the lot of them?"
--   339 / 341 / 343 -> the North Gustaberg [S] steps and the reward.
--
-- Crystal War zones are NOT dialog-offset (unlike the Adoulin dumps). Control:
-- `xi-dat dialog 87 7625` returns Wahid's own introduction, as quoted above.
--
-- The previous stub fired csid 1100, which `xi-dat csid 87 1100` reports as
-- "not found in zone 87" -- it was one of a fabricated arithmetic sequence keyed
-- to the quest id (1000, 1010, 1040 ... 1580) and could never render.
--
-- STILL SIMPLIFIED: steps 4-6 (the Bernhard cutscene and the North Gustaberg [S]
-- ??? that grants the Unadorned ring) are not wired, because csids 339/341/343
-- are identified only by position in Wahid's block, not yet by dialog match. The
-- gem trade and the reward are faithful; the ring detour is not yet enforced.
-----------------------------------
local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.A_JEWELERS_LAMENT)

quest.reward =
{
    item = xi.item.TRAINEE_BURIN,
}

local requiredGems =
{
    xi.item.SUNSTONE,
    xi.item.AQUAMARINE,
    xi.item.JADEITE,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.BASTOK_MARKETS_S] =
        {
            ['Wahid'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(335, { [0] = requiredGems[1], [1] = requiredGems[2], [2] = requiredGems[3] })
                end,
            },

            onEventFinish =
            {
                [335] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.BASTOK_MARKETS_S] =
        {
            ['Wahid'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(336, { [0] = requiredGems[1], [1] = requiredGems[2], [2] = requiredGems[3] })
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, requiredGems) then
                        return quest:progressEvent(337)
                    end
                end,
            },

            onEventFinish =
            {
                [337] = function(player, csid, option, npc)
                    player:confirmTrade()

                    if quest:complete(player) then
                        npcUtil.giveKeyItem(player, xi.ki.UNADORNED_RING)
                    end
                end,
            },
        },
    },
}

return quest
