-----------------------------------
-- Drafted by the Duchy
-----------------------------------
-- Log ID: 7, Quest ID: 81
-- Audience Chamber cutscene holder : Ru'Lude Gardens, entity 17772839
-- !addquest 7 81
-----------------------------------
-- Retail (bg-wiki "Drafted by the Duchy").
-- Step two of the Wings of the Goddess Voidwatch storyline (80..98, in id order).
-- |Previous=Guardian of the Void  |Next=Battle on a New Front
-- |Reward=KI Voidwatcher's emblem: Jeuno, KI White stratum abyssite
--   "Travel to the Audience Chamber (H-6) in Ru'Lude Gardens, or the Jeuno Bulwark
--    Gate in Sauromugue Champaign (S), for a cutscene. At the end of the cutscene the
--    Key Items Voidwatcher's emblem: Jeuno and White stratum abyssite will be
--    received, the Quest will be completed, and the next Quest will be automatically
--    flagged."
--
-- CSID ANCHORED BY ITS OWN TEXT, not guessed. The Audience Chamber cutscenes are not
-- on a visible NPC: they live on the unnamed HOLDER entity 17772839 in Ru'Lude
-- Gardens, which carries the whole Mawl'gofaur audience set. Each one is identified
-- by what it actually says:
--   10188 -> msgs 15010-15019. 15018 is decisive: "I hereby authorize you for
--          participation in Voidwatch operations in the JEUNO REGION", which is this
--          step and no other. 15011 checks the emblem at the door, 15020 introduces
--          Mawl'gofaur as "aide to the Archduke and overseer of the Voidwatch
--          operation".
--
-- csid 10200 in the same holder is a further audience variant that no step in this
-- chain has been matched to, so it is deliberately left alone rather than assigned
-- on a hunch.
--
-- The cutscene fires on entering Ru'Lude Gardens, which is what bg-wiki's "Travel to
-- the Audience Chamber for a cutscene" describes. It is gated on this quest being
-- ACCEPTED, so it cannot fire at anyone who is not on this step.
-----------------------------------
require('scripts/globals/voidwatch_wotg')
-----------------------------------

local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.DRAFTED_BY_THE_DUCHY)

local audienceCsid = 10188

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.RULUDE_GARDENS] =
        {
            onZoneIn = function(player, prevZone)
                return audienceCsid
            end,

            onEventFinish =
            {
                [audienceCsid] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        npcUtil.giveKeyItem(player, xi.ki.VOIDWATCHERS_EMBLEM_JEUNO)
                        npcUtil.giveKeyItem(player, xi.ki.WHITE_STRATUM_ABYSSITE)
                    end
                end,
            },
        },
    },
}

return quest
