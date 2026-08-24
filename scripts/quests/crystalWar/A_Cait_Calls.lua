-----------------------------------
-- A Cait Calls
-----------------------------------
-- Log ID: 7, Quest ID: 84
-- Veridical_Conflux : Pashhow Marshlands [S] (J-9), entity 17146658
-- !addquest 7 84
-----------------------------------
-- Retail (bg-wiki "A Cait Calls").
-- Step five of the Wings of the Goddess Voidwatch storyline (80..98, in id order).
-- |Previous=VW Op. 126: Qufim Incursion  |Next=The Truth Is Out There
-- |Reward=(none listed)
--   "Travel to Pashhow Marshlands (S) and click on the Veridical Conflux located near
--    the Pashhow Gate Crystal in (J-9) to start a cutscene. The cutscene both ends
--    this Quest and begins the following quest."
--
-- CSIDS DECODED, NOT GUESSED. The Pashhow Marshlands [S] Veridical Conflux is entity
-- 17146658 in zone 90 and owns four blocks: 7 and 9 are one-byte stubs, 11 is 87
-- bytes and 13 is 744. Both 11 and 13 render msg 9070 "The lights of the veridical
-- conflux flutter and shimmer, as if to beckon you within..." and 9071 "Warp to the
-- Walk of Echoes? Proceed. Not yet.", so 13 is the substantial program and 11 the
-- short prompt. This step uses 13.
--
-- The conflux is shared with the ordinary Walk of Echoes warp, so the handler is
-- gated on this quest being ACCEPTED and returns nothing otherwise, leaving the warp
-- untouched for everyone else.
-----------------------------------
require('scripts/globals/voidwatch_wotg')
-----------------------------------

local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.A_CAIT_CALLS)

local pashhowConflux = 17146658
local confluxCsid    = 13

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.PASHHOW_MARSHLANDS_S] =
        {
            ['Veridical_Conflux'] =
            {
                onTrigger = function(player, npc)
                    if npc:getID() ~= pashhowConflux then
                        return
                    end

                    return quest:progressEvent(confluxCsid)
                end,
            },

            onEventFinish =
            {
                [confluxCsid] = function(player, csid, option, npc)
                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
