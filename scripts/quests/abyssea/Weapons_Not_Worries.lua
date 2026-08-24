-----------------------------------
-- Weapons, Not Worries
-----------------------------------
-- Log ID: 8, Quest ID: 21
-- Peshi_Yohnts : Abyssea - Tahrongi (F-9), entity 16962100
-- !addquest 8 21
-----------------------------------
-- Retail (bg-wiki "Weapons, Not Worries").
-- |Start=Peshi Yohnts (A) (F-9), Abyssea - Tahrongi  |Fame=atah |FLevel=1
-- |Item Reqs=Pickaxe, Hardened Bone  |Reward=100 Cruor  |Repeatable=Yes
--   1. Speak to Peshi Yohnts at (F-9) in the Western Encampment.
--   2. "She'll give you a Pickaxe and asks you to excavate a Hardened Bone from
--      Excavation Points, or purchased on the Auction House."
--      "She'll only give you one so any extras from failure or repeating the quest
--       will require your to bring own."
--   3. "Trade Peshi Yohnts a Hardened Bone to complete the quest."
--   "Zoning is required to repeat this quest."
--
-- CSIDS DECODED, NOT GUESSED. Peshi_Yohnts is 16962100 -> zone 45. Per-csid
-- attribution from her entry table's byte ranges:
--   313 -> 7885/7886  THE OFFER. 7885 "<Sigh>... Nothing I do ever-- Oh, a visitor.
--          Perrrhaps you could help me", 7886 is the two-way menu ("Sounds like she
--          needs it." / "Not getting involved.").
--   314 -> 7891       the declining line, "I'd offer my supporrrt, but I'd probably
--          just get in the way."
--   315 -> 7892/7893 plus msg 201, the activity-points marker. THE TURN-IN:
--          "Once again, a stranger perrrforms with ease a task I couldn't manage."
--   316 -> 7893       her post-completion grumble.
--   317 -> 7894       the repeat offer, "It's the ${choice-player-gender}[man/lady]
--          who's so much better than me at everything. Do you think you could find
--          m[ore]..."
--   388 -> 7884       her idle line, "No, that won't do... <Sigh>..."
--
-- THE EXCAVATION POINTS are ordinary HELM nodes, not quest entities: 16962161 has a
-- 79-byte program and the other five have none at all, so mining is the existing
-- excavation system's job and nothing here touches it. bg-wiki agrees the bone can
-- simply be bought on the Auction House instead.
--
-- bg-wiki also notes "You'll need to speak to Kupipi at (H-12) beforehand if you've
-- never done so before." That is the zone's shared introduction rather than anything
-- this quest records, and it is not modelled here.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.WEAPONS_NOT_WORRIES)

local cruorReward = 100

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_TAHRONGI,
}

--- Trading the bone in. Shared by the first run and the repeat.
local turnIn = function(player, npc, trade)
    if npcUtil.tradeHasExactly(trade, xi.item.HARDENED_BONE) then
        return quest:progressEvent(315, xi.item.HARDENED_BONE)
    end
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.ABYSSEA_TAHRONGI] =
        {
            ['Peshi_Yohnts'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(313)
                end,
            },

            onEventFinish =
            {
                [313] = function(player, csid, option, npc)
                    -- 7886's second line declines; only the first accepts.
                    if option ~= 0 then
                        return
                    end

                    quest:begin(player)
                    npcUtil.giveItem(player, xi.item.PICKAXE)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_TAHRONGI] =
        {
            ['Peshi_Yohnts'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(388)
                end,

                onTrade = turnIn,
            },

            onEventFinish =
            {
                [315] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        xi.abyssea.questReward(player, cruorReward, nil)
                    end
                end,
            },
        },
    },

    -- Repeatable. bg-wiki: "Zoning is required to repeat this quest." It also notes
    -- "as soon as you engage her to repeat the quest a second time, it automatically
    -- is flagged in the quest log", so 317 re-accepts with no menu.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_TAHRONGI] =
        {
            ['Peshi_Yohnts'] =
            {
                onTrigger = function(player, npc)
                    if quest:getMustZone(player) then
                        return quest:event(316)
                    end

                    return quest:progressEvent(317)
                end,

                onTrade = turnIn,
            },

            onEventFinish =
            {
                [315] = function(player, csid, option, npc)
                    xi.abyssea.questReward(player, cruorReward, nil)
                    xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.WEAPONS_NOT_WORRIES)
                end,
            },
        },
    },
}

return quest
