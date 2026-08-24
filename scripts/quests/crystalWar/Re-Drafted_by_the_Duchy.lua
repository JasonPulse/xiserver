-----------------------------------
-- Re-Drafted by the Duchy
-----------------------------------
-- Log ID: 7, Quest ID: 86
-- Audience Chamber cutscene holder : Ru'Lude Gardens, entity 17772839
-- !addquest 7 86
-----------------------------------
-- Retail (bg-wiki "Re-Drafted by the Duchy").
-- Step seven of the Wings of the Goddess Voidwatch storyline (80..98, in id order).
-- |Previous=The Truth Is Out There  |Next=A New Menace
-- |Reward=KI White stratum abyssite IV, KI Tricolor Voidwatcher's emblem
--   "Proceed to the Audience Chamber in Ru'Lude Gardens for a cutscene. At the end of
--    the cutscene, the key items White stratum abyssite IV and Tricolor Voidwatcher's
--    emblem will be received."
--
-- CSID ANCHORED BY ITS OWN TEXT, not guessed. The Audience Chamber cutscenes are not
-- on a visible NPC: they live on the unnamed HOLDER entity 17772839 in Ru'Lude
-- Gardens, which carries the whole Mawl'gofaur audience set. Each one is identified
-- by what it actually says:
--   10199 -> msgs 15110-15122. 15110 "We regret having to summon you AGAIN so soon
--          after your last tour of duty", 15111 "new rifts in the greater THREE
--          NATIONS area" (which is what the next step, A New Menace, sends you to),
--          and 15114 "Here is your BADGE OF AUTHORIZATION" -- that badge is the
--          Tricolor Voidwatcher's emblem this step rewards.
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

local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.REDRAFTED_BY_THE_DUCHY)

local audienceCsid = 10199

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
                        npcUtil.giveKeyItem(player, xi.ki.WHITE_STRATUM_ABYSSITE_IV)
                        npcUtil.giveKeyItem(player, xi.ki.TRICOLOR_VOIDWATCHERS_EMBLEM)
                    end
                end,
            },
        },
    },
}

return quest
