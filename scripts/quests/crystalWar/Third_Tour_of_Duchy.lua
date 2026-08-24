-----------------------------------
-- Third Tour of Duchy
-----------------------------------
-- Log ID: 7, Quest ID: 92
-- Audience Chamber cutscene holder : Ru'Lude Gardens, entity 17772839
-- !addquest 7 92
-----------------------------------
-- Retail (bg-wiki "Third Tour of Duchy").
-- Step thirteen of the Wings of the Goddess Voidwatch storyline (80..98, in id order).
-- |Previous=A Farewell to Felines  |Next=Glimmer of Hope
-- |Reward=(none listed)
--   "Proceed to the Audience Chamber in Ru'Lude Gardens or the Bulwark Gate in
--    Sauromugue Champaign (S) for a cutscene which ends this quest and begins the
--    following quest."
--
-- CSID ANCHORED BY ITS OWN TEXT, not guessed. The Audience Chamber cutscenes are not
-- on a visible NPC: they live on the unnamed HOLDER entity 17772839 in Ru'Lude
-- Gardens, which carries the whole Mawl'gofaur audience set. Each one is identified
-- by what it actually says:
--   10208 -> msgs 15145-15155. 15145 "It would seem the Voidwatch effort in the THREE
--          NATIONS was a success", i.e. it looks back on A New Menace, and 15150-15154
--          then introduce the alabaster substance that the remainder of the chain is
--          about. That places it at the third summons.
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

local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.THIRD_TOUR_OF_DUCHY)

local audienceCsid = 10208

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
                        -- bg-wiki lists no reward for this step; it exists to
                        -- advance the chain.
                    end
                end,
            },
        },
    },
}

return quest
