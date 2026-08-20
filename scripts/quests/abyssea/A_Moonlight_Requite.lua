-----------------------------------
-- A Moonlight Requite
-----------------------------------
-- Log ID: 8, Quest ID: 186
-- Prishe : Abyssea - Empyreal Paradox, entity 17821725
-- !addquest 8 186
-----------------------------------
-- Retail (bg-wiki "A Moonlight Requite").
-- |Start=Prishe, Abyssea - Empyreal Paradox  |Previous=Meanwhile, Back on Abyssea
-- |Reward=Abyssite of the cosmos
--   1. Speak to Prishe in Abyssea - Empyreal Paradox for a cutscene.
--   "Note: This quest cannot be completed it can only be flagged."
--
-- CSIDS DECODED, NOT GUESSED. Prishe is 17821725 (zone 255 idx 3101);
-- `xi-dat events 255` gives her 202-207, and csidscan.py against
-- `xi-dat dialog 255` separates the farewell from her idle chatter:
--   206 -> 8149-8154  THE CUTSCENE. 8149 "Rough days are still ahead for
--          Abyssea, and it pains me that I won't be around to help out", 8151
--          "When you get back, I want you to deliver a message to the cardinal",
--          8154 "ours is a friendship of dimension transcending!"
--   207 -> 8174/8175  her post-cutscene idle, and the line the quest is named
--          for: "Perhaps I'll go for a stroll along the surface of the moon.
--          Moonlighting--heheh, you get it?" / "No? Damn it, I really am losing
--          my edge..."
--   205 -> 8125-8132  belongs to the preceding story beat, not this quest.
--
-- WHY THIS NEVER CALLS quest:complete. bg-wiki states plainly that the quest
-- "cannot be completed it can only be flagged" -- it stays in the log as
-- accepted forever, which is the retail behaviour. So the abyssite is granted
-- at flagging time and the quest is deliberately left ACCEPTED rather than
-- being quietly completed to look tidy.
--
-- KEY ITEM: Abyssite of the cosmos is the existing ABYSSITE_OF_THE_COSMOS (1443).
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.A_MOONLIGHT_REQUITE)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.MEANWHILE_BACK_ON_ABYSSEA)
        end,

        [xi.zone.ABYSSEA_EMPYREAL_PARADOX] =
        {
            ['Prishe'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(206)
                end,
            },

            onEventFinish =
            {
                [206] = function(player, csid, option, npc)
                    quest:begin(player)
                    npcUtil.giveKeyItem(player, xi.ki.ABYSSITE_OF_THE_COSMOS)
                end,
            },
        },
    },

    -- Flagged and stays that way; 207 is all she has left to say.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_EMPYREAL_PARADOX] =
        {
            ['Prishe'] = quest:event(207):replaceDefault(),
        },
    },
}

return quest
