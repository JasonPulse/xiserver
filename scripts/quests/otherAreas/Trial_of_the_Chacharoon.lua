-----------------------------------
-- Trial of the Chacharoon
-----------------------------------
-- Log ID: 4, Quest ID: 127
-- Green Thumb Moogle : Mog Garden, entity 17924125
-- Chacharoon         : Mog Garden, entity 17924231
-- Chacharoon         : Mog Garden rearing grounds, entity 17924232
-- !addquest 4 127
-----------------------------------
-- Retail (bg-wiki "Trial of the Chacharoon").
-- |Start=Susuroon, Mog Garden  |Previous=Chacharoon's Cheer
-- |Next=Doctor Chacharoon
-- |Quest Reqs="Sakura and the Fountain" / at least one of Trust: Windurst,
--             Trust: Bastok or Trust: San d'Oria
-- |Reward=Trust Magic: Chacharoon
--   1. "Care for monsters an additional 5 times in order to purchase 'Sakura and
--      the Fountain'."
--   2. "After purchasing the key item, enter your newly expanded Mog Garden area
--      which features the Rearing Grounds."
--   3. "Speak to Chacharoon in the newly open area to complete the quest and gain
--      access to use the Trust Magic: Chacharoon."
--
-- CSIDS, DECODED FROM OUR OWN CLIENT DAT DUMPS
--
--   2062  DIRECTOR 17924176   msgs 8293-8323  the zone-in scene, Chacharoon's
--                                        savings stolen
--   2063  Green Thumb Moogle  msgs 8324-8325  "set sail for your home nation ...
--                                        tap into the tenets of Trust"
--   2064  Green Thumb Moogle  msgs 8326-8327  "Head for the hills and console
--                                        Chacharoon! ... take the tiny trail"
--   2066  Chacharoon 17924231 msgs 8328-8329  "Then go to rearing grounds to make
--                                        tongue-wiggle!"
--   2065  DIRECTOR2 17924188  msgs 8331-8392  the turn-in in the rearing grounds
--
-- All five fired at the puppet and read back:
--   2062 -> "Raise the roof and get ready for rearing! You've now got astounding
--           amounts of acreage" / "We moogles and Chacharoon pioneered a petite
--           plaza in the periphery" and on into the theft
--   2063 -> "Before consoling Chacharoon, I insist you set sail for your home
--           nation." / "Once there, tap into the tenets of Trust."
--   2064 -> "Head for the hills and console Chacharoon!" / "Bring your butt to the
--           boat and take the tiny trail to the top."
--   2066 -> "You have thing-tell to Chacharoon?" / "Then go to rearing grounds to
--           make tongue-wiggle!"
--   2065 -> "Chief, give wide-look to gaaarden! Much space for creatures!"
--
-- 2063 is the nudge while the player has no trust permit yet and 2064 the one once
-- they do, which is the split the two texts themselves draw.
--
-- The rearing grounds are the far end of zone 280 rather than a separate zone, and
-- retail ferries the player there through Chacharoon's "Move to a different
-- location." option; that lives in xi.monsterRearing, not here.
-----------------------------------
require('scripts/globals/monster_rearing')
require('scripts/globals/quests')
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.TRIAL_OF_THE_CHACHAROON)

local function hasTrustPermit(player)
    return player:hasKeyItem(xi.ki.WINDURST_TRUST_PERMIT) or
        player:hasKeyItem(xi.ki.BASTOK_TRUST_PERMIT) or
        player:hasKeyItem(xi.ki.SAN_DORIA_TRUST_PERMIT)
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.CHACHAROONS_CHEER) and
                xi.monsterRearing.rank(player) >= 3
        end,

        [xi.zone.MOG_GARDEN] =
        {
            onZoneIn = function(player, prevZone)
                return 2062
            end,

            onEventFinish =
            {
                [2062] = function(player, csid, option, npc)
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
            ['Green_Thumb_Moogle'] =
            {
                onTrigger = function(player, npc)
                    if not hasTrustPermit(player) then
                        return quest:event(2063)
                    end

                    return quest:event(2064)
                end,
            },

            ['Chacharoon'] =
            {
                onTrigger = function(player, npc)
                    if npc:getID() == xi.monsterRearing.npc.CHACHAROON_GARDEN then
                        return quest:event(2066)
                    end

                    if not hasTrustPermit(player) then
                        return quest:event(2063)
                    end

                    return quest:progressEvent(2065)
                end,
            },

            onEventFinish =
            {
                [2065] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:addSpell(xi.magic.spell.CHACHAROON, { silentLog = true })
                    end
                end,
            },
        },
    },
}

return quest
