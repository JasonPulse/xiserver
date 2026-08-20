-----------------------------------
-- A Geothermal Expedition
-----------------------------------
-- Log ID: 9, Quest ID: 18
-- Fallion    : Morimar Basalt Fields (I-10), entity 17863413
-- Hot_Spring : Morimar Basalt Fields (H-7/G-8/H-8), entities 17863414-17863416
-- !addquest 9 18
-----------------------------------
-- Retail (bg-wiki "A Geothermal Expedition").
-- |Start=Fallion, Morimar Basalt Fields - (I-10)  |Fame=Adoulin
-- |Reward=3000 Experience Points
--   1. Speak with Fallion (I-10) to initiate the quest (Bivouac #3).
--   2. "Visit and test the three Hot Springs, under different conditions, to
--      obtain 5 reports." Locations: H-7, G-8 and H-8.
--   3. "There is no weather requirement for the reports. They seem to be based
--      purely on time. The ability to collect a report opens up exactly at the
--      start of a certain hour in the game in various windows."
--   4. Return to Fallion and submit your reports to receive your reward.
--
-- CSIDS DECODED, NOT GUESSED -- AND THE DUMP'S ZONE LABELS ARE OFF BY ONE HERE.
-- Fallion is 17863413 -> zone 265 idx 757 (0x011092F5). `xi-dat events 265` gives
-- him 2520, 2521, 2522, 2523, 2524; the three Hot_Spring entities sit on the next
-- indices and own no csids at all. The dumped dialog file labelled zone N holds
-- zone N-1's text for the Adoulin zones, so Morimar's text is in the file labelled
-- 266; the offset is pinned by this repo's own known-correct id
-- (Morimar_Basalt_Fields/IDs.lua WAYPOINT_ATTUNED = 7606 resolves in dump 266).
-- Read against 266:
--   2520 -> 7511-7515  THE OFFER. 7512 "I'm looking for some help in analyzing the
--          water of the major 'hot spots' here in the Morimar Basalt Fields",
--          7513 "there are only five main types of springs, but the truth is the
--          smell, water quality, and what have you change depending on the
--          [conditions]", and 7514 "perform a simple examination of each of these
--          five types and come back to me". No ${selection-lines}, so speaking to
--          him starts it.
--   2521 -> 7513/7515  the reminder: five types, and mind the kit.
--   2522 -> 7516-7519  THE TURN-IN. "You're back! The pages of your report didn't
--          get all soggy from the steam, I trust?" through to 7519.
--   2523 -> 7520/7521  THE SPRING ITSELF. 7520 "A${choice: 1}[/ boiling] hot spring
--          bubbles at the surface." and 7521 "You use the testing kit in the water.
--          ${choice: 2}[Nothing happens/The color slowly changes/The color
--          changes/The color changes quickly/The color changes almost instantly].
--          This hot spring has ${choice: 2}[a normal/a perfect/a strong/a very
--          strong/an overpoweringly strong] smell to it." -- five outcomes on one
--          param, which is exactly bg-wiki's "five main types".
--   2524 -> 7519       his post-completion line.
--
-- FIVE REPORTS FROM THREE SPRINGS is why this tracks a five-bit mask keyed on the
-- READING rather than on which spring was visited: 7521's ${choice: 2} has five
-- branches while there are only three springs, so the same spring yields different
-- readings at different times. That is what bg-wiki means by "under different
-- conditions".
--
-- ON THE TIME WINDOWS: bg-wiki says the reading is time-based and that the windows
-- open "at the start of a certain hour", but it does not publish which hour maps to
-- which of the five readings -- no source does. The reading is therefore derived
-- from the game hour in five even bands, so all five are collectable within a
-- Vana'diel day by revisiting, which is the behaviour bg-wiki describes. The band
-- boundaries are ours; the five-reading structure and the time dependence are
-- retail.
--
-- The Hot_Spring entities own no csid, so their two lines are plain messages
-- rather than an event -- the same shape the Shellfish gathering points use.
-----------------------------------
local morimarID = zones[xi.zone.MORIMAR_BASALT_FIELDS]
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.A_GEOTHERMAL_EXPEDITION)

local allReports = 0x1F -- five readings, one bit each

quest.reward =
{
    exp      = 3000,
    fameArea = xi.fameArea.ADOULIN,
}

quest.sections =
{
    -- bg-wiki lists no |Previous= and no |Quest Reqs=.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.MORIMAR_BASALT_FIELDS] =
        {
            ['Fallion'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2520)
                end,
            },

            onEventFinish =
            {
                [2520] = function(player, csid, option, npc)
                    quest:begin(player)
                    quest:setVar(player, 'Reports', 0)
                end,
            },
        },
    },

    -- Accepted: test the springs until all five readings are on record.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.MORIMAR_BASALT_FIELDS] =
        {
            ['Hot_Spring'] =
            {
                onTrigger = function(player, npc)
                    -- Five even bands across the Vana'diel day; see the header on
                    -- why the boundaries are ours and the structure is retail.
                    local reading = math.floor(VanadielHour() / 24 * 5)
                    local mask    = quest:getVar(player, 'Reports')

                    player:messageSpecial(morimarID.text.HOT_SPRING_BUBBLES, 0, 0)

                    if bit.band(mask, bit.lshift(1, reading)) ~= 0 then
                        return
                    end

                    quest:setVar(player, 'Reports', bit.bor(mask, bit.lshift(1, reading)))
                    player:messageSpecial(morimarID.text.USE_TESTING_KIT, 0, 0, reading)
                end,
            },

            ['Fallion'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Reports') == allReports then
                        return quest:progressEvent(2522)
                    end

                    return quest:event(2521)
                end,
            },

            onEventFinish =
            {
                [2522] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Reports', 0)
                    end
                end,
            },
        },
    },

    -- Completed: 7519, still hoping pioneers make the area safe.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.MORIMAR_BASALT_FIELDS] =
        {
            ['Fallion'] = quest:event(2524):replaceDefault(),
        },
    },
}

return quest
