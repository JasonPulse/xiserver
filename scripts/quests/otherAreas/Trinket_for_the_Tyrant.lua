-----------------------------------
-- Trinket for the Tyrant
-----------------------------------
-- Log ID: 4, Quest ID: 120
-- Green Thumb Moogle : Mog Garden, entity 17924125
-- !addquest 4 120
-----------------------------------
-- Retail (bg-wiki "Trinket for the Tyrant").
-- |Start=Green Thumb Moogle, Mog Garden  |Fame=Other
-- |Previous=Courtesy Crustacean  |Next=Hypnotic Hospitality  |Title=Novice Nurseryman
-- |Item Reqs=KI Glass pendulum  |Reward=Flask of Grow-M-Good
--   "You must enter the Mog Garden on 10 separate Earth days before you can commence
--    this quest. Having 10 Shining Stars is not enough, even if you get extra Shining Stars from a Campaign."
--   1. "Talk to your Green Thumb Moogle to start the quest."
--   2. "Check your Flotsam to obtain a Glass pendulum."
--   3. "Talk to your Green Thumb Moogle to complete the quest and receive a Flask
--      of Grow-M-Good."
--
-- The 10-day gate is xi.mog_garden.visitDays, which counts Earth days of entry on
-- the GPS crystal exactly as retail's stars do. It is NOT VanadielUniqueDay and NOT
-- a Shining Star count, because bg-wiki rules both of those out explicitly.
--
-- CSIDS VERIFIED ON THE LIVE CLIENT. Each was fired at the puppet and the text it
-- rendered was read back off the chat stream:
--   2025 -> "<Grrrg> <grrrg>...The pain...it pierces the provenance of my puffy
--           paunch, kupo." / "his consort's the most terrifically terrifying
--           tyrant of all time, kupo! Even the moogle's name is
--           tyrannical--Kupivolo!"                                    the offer
--   2026 -> "My tummy's taken a turn for the treacherous, so I must ask for
--           assistance, kupo." / "Discover a desirable doohickey that'll trump
--           the tyrannical tendencies of my companion's cohort." the reminder
--   2027 -> "Why, this is...! I've finally found the fix for this firestorm!"
--                                                                   the turn-in
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.TRINKET_FOR_THE_TYRANT)

local visitDaysRequired = 10

quest.reward =
{
    item  = xi.item.FLASK_OF_GROW_M_GOOD,
    title = xi.title.NOVICE_NURSERYMAN,
}

-- Hands over the key item the moogle asked for.
--
-- Returns nothing on purpose so the call falls through to the node's own script and
-- the node still yields its ordinary drift. The interaction framework only
-- prioritises the handler system when a handler produced an action, so a nil return
-- is what lets both happen on one examine.
local findAction =
{
    onTrigger = function(player, npc)
        if not player:hasKeyItem(xi.ki.GLASS_PENDULUM) then
            npcUtil.giveKeyItem(player, xi.ki.GLASS_PENDULUM)
        end
    end,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.COURTESY_CRUSTACEAN) == xi.questStatus.QUEST_COMPLETED and
                xi.mog_garden.visitDays(player) >= visitDaysRequired
        end,

        [xi.zone.MOG_GARDEN] =
        {
            ['Green_Thumb_Moogle'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2025)
                end,
            },

            onEventFinish =
            {
                [2025] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.MOG_GARDEN] =
        {
            ['Flotsam'] = findAction,

            ['Green_Thumb_Moogle'] =
            {
                onTrigger = function(player, npc)
                    if not player:hasKeyItem(xi.ki.GLASS_PENDULUM) then
                        return quest:event(2026)
                    end

                    return quest:progressEvent(2027)
                end,
            },

            onEventFinish =
            {
                [2027] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.GLASS_PENDULUM)
                    end
                end,
            },
        },
    },
}

return quest
