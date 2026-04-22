-----------------------------------
-- Fit for a Prince
-----------------------------------
-- Log ID: 0, Quest ID: 106
-- Halver : Chateau d'Oraguille (I-9), !pos 2 0.1 0.1 233
-----------------------------------
-- Retail requires a second player in your party whose Mithra appearance
-- matches a randomized description from Halver, then both party members
-- turn in to Halver for two rings (Castor's/Pollux's).
--
-- On this 4-player private server a retail-accurate match is rarely
-- achievable, so the flow is simplified: a single player accepts from
-- Halver, returns, and receives BOTH rings. CSIDs are best-guess from
-- the client event dump; verify with !cs in-game.
-----------------------------------
local CASTORS_RING = 14628
local POLLUXS_RING = 14629

local quest = Quest:new(xi.questLog.SANDORIA, xi.quest.id.sandoria.FIT_FOR_A_PRINCE)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.SANDORIA,
    title    = xi.title.ROYAL_WEDDING_PLANNER,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.SANDORIA) >= 3
        end,

        [xi.zone.CHATEAU_DORAGUILLE] =
        {
            ['Halver'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(578)
                end,
            },

            onEventFinish =
            {
                [578] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.CHATEAU_DORAGUILLE] =
        {
            ['Halver'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(579)
                end,
            },

            onEventFinish =
            {
                [579] = function(player, csid, option, npc)
                    if
                        player:getFreeSlotsCount() >= 2 and
                        quest:complete(player)
                    then
                        player:addItem(CASTORS_RING)
                        player:addItem(POLLUXS_RING)
                        player:setTitle(xi.title.CONSORT_CANDIDATE) -- retail gives one title per partner; grant both on solo server
                    end
                end,
            },
        },
    },
}

return quest
