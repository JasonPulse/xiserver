-----------------------------------
-- Courtesy Crustacean
-----------------------------------
-- Log ID: 4, Quest ID: 119
-- Green Thumb Moogle : Mog Garden, entity 17924125
-- !addquest 4 119
-----------------------------------
-- Retail (bg-wiki "Courtesy Crustacean").
-- |Start=Green Thumb Moogle, Mog Garden  |Fame=Other
-- |Previous=Flotsam Finding  |Next=Trinket for the Tyrant  |Title=Sardineophyte
-- |Item Reqs=KI Kaleidoscopic clam  |Reward=Flask of Grow-M-Good
--   "You must enter the Mog Garden on 5 separate Earth days before you can commence
--    this quest. Having 5 Shining Stars is not enough, even if you get extra Shining Stars from a Campaign."
--   1. "Talk to your Green Thumb Moogle to flag this quest. The Green Thumb Moogle
--      asks for a rare and beautiful shell that might wash up on your beach."
--   2. "Go to your Coastal Fishing Net and raise the net. You will receive a
--      Kaleidoscopic clam."
--   3. "Go back and speak with your Green Thumb Moogle."
--
-- The 5-day gate is xi.mog_garden.visitDays, which counts Earth days of entry on
-- the GPS crystal exactly as retail's stars do. It is NOT VanadielUniqueDay and NOT
-- a Shining Star count, because bg-wiki rules both of those out explicitly.
--
-- CSIDS VERIFIED ON THE LIVE CLIENT. Each was fired at the puppet and the text it
-- rendered was read back off the chat stream:
--   2022 -> "How have you adjusted to governing these garden grounds, kupo?" /
--           "By the bye, did I neglect to notify you that an ancient associate of
--           mine--Monsieur Kupont--shall arrive anon?"                the offer
--   2023 -> "I'd love to secure a striking specimen of a shell for him" / "If you
--           could wade through what washes up on shore and find a fitting figure
--           of one, I would be...dare I say it...shell-shocked."   the reminder
--   2024 -> "This relic is...not just resplendent and rare, but ravishing too,
--           kupo!"                                                  the turn-in
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.COURTESY_CRUSTACEAN)

local visitDaysRequired = 5

quest.reward =
{
    item  = xi.item.FLASK_OF_GROW_M_GOOD,
    title = xi.title.SARDINEOPHYTE,
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
        if not player:hasKeyItem(xi.ki.KALEIDOSCOPIC_CLAM) then
            npcUtil.giveKeyItem(player, xi.ki.KALEIDOSCOPIC_CLAM)
        end
    end,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.FLOTSAM_FINDING) == xi.questStatus.QUEST_COMPLETED and
                xi.mog_garden.visitDays(player) >= visitDaysRequired
        end,

        [xi.zone.MOG_GARDEN] =
        {
            ['Green_Thumb_Moogle'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2022)
                end,
            },

            onEventFinish =
            {
                [2022] = function(player, csid, option, npc)
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
            ['Coastal_Fishing_Net'] = findAction,

            ['Green_Thumb_Moogle'] =
            {
                onTrigger = function(player, npc)
                    if not player:hasKeyItem(xi.ki.KALEIDOSCOPIC_CLAM) then
                        return quest:event(2023)
                    end

                    return quest:progressEvent(2024)
                end,
            },

            onEventFinish =
            {
                [2024] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.KALEIDOSCOPIC_CLAM)
                    end
                end,
            },
        },
    },
}

return quest
