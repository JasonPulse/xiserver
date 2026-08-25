-----------------------------------
-- Titillating Tomes
-----------------------------------
-- Log ID: 4, Quest ID: 122
-- Green Thumb Moogle : Mog Garden, entity 17924125
-- !addquest 4 122
-----------------------------------
-- Retail (bg-wiki and FFXIclopedia "Titillating Tomes").
-- |Start=Green Thumb Moogle, Mog Garden  |Fame=Other  |Repeatable=No
-- |Previous=Hypnotic Hospitality  |Next=Glittering Gals
-- |Title=Wibbly Wobbly Woozy Warrior
-- |Reward=Straw Hat (corresponding to your character's sex)
-- |Item Reqs=Drill Calamary, Calico Comet, Philosopher's Stone
--   "Once you have achieved Rank 7 in all geological locations (that is, you have
--    bought the MHMU treatises for all sections of your Mog Garden except monster
--    rearing), zone into your Mog Garden and talk to your Green Thumb Moogle."
--   1. "Talk to your Green Thumb Moogle for a cutscene with The Great Kupellion. You
--      will be tasked with getting a drill calamary, philosopher's stone, and calico
--      comet."
--   2. "Trade all the items at once to the Moogle in order to complete the quest."
--
-- THE GATE. bg-wiki lists the requirement as the five MHMU treatises, one per
-- geological location, which is exactly rank 7 in all five. That is what
-- xi.mog_garden.allLocationsMaxRank checks, so this quest reads the rank system rather
-- than the key items directly and stays correct if the book ids ever move.
--
-- WHERE THE THREE ITEMS COME FROM, and why they are reachable. All three drop from a
-- rank 7 gathering point with no bait, serum or assistant, which bg-wiki is explicit
-- about, and all three are in the rank 7 pools in scripts/globals/mog_garden/yields.lua:
--   Drill Calamary      coastal fishing net, rank 7 special list (slots 4 and 8)
--   Calico Comet        pond dredger, rank 7 special list (slots 4 and 8)
--   Philosopher's Stone mineral vein, rank 7 biominerals, tier 4 only
-- The vein restriction is real and worth knowing before this reads as broken: a rank 7
-- garden still yields nothing above rank 2 from Mineral Vein #1, so the stone only
-- comes out of Mineral Vein #4.
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, with one exception noted below:
--   2042 -> the reminder, which names all three items
--   2043 -> the trade turn-in
--   2041 -> the opening cutscene, and the one csid here that would not render
--           standalone. It is a multi-actor scene (The Great Kupellion, entity
--           17924191, comes to the garden) and those actors are not spawned for a bare
--           !cs, so nothing renders. It is taken from POSITION: 2042 and 2043 are both
--           verified and consecutive, and 2041 sits immediately before them exactly
--           where bg-wiki puts the opening cutscene. This is the same situation as
--           Hypnotic Hospitality's 2032, handled the same way.
--
-- FFXIclopedia records both cutscenes as held on the Goblin Footprint entity
-- (17924208), which is hidden on zone load. They play from the Green Thumb Moogle
-- here, which is where bg-wiki's walkthrough puts the conversation.
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.TITILLATING_TOMES)

quest.reward =
{
    title = xi.title.WIBBLY_WOBBLY_WOOZY_WARRIOR,
}

local kupellionsRequest =
{
    xi.item.DRILL_CALAMARY,
    xi.item.CALICO_COMET,
    xi.item.PHILOSOPHERS_STONE,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.HYPNOTIC_HOSPITALITY) == xi.questStatus.QUEST_COMPLETED and
                xi.mog_garden.allLocationsMaxRank(player)
        end,

        [xi.zone.MOG_GARDEN] =
        {
            ['Green_Thumb_Moogle'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2041)
                end,
            },

            onEventFinish =
            {
                [2041] = function(player, csid, option, npc)
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
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, kupellionsRequest) then
                        return quest:progressEvent(2043)
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(2042)
                end,
            },

            onEventFinish =
            {
                [2043] = function(player, csid, option, npc)
                    -- Straw Hat comes in a male and a female cut, the female id one
                    -- above the male, so the gender subtracts straight off it.
                    local strawHat = xi.item.STRAW_HAT_F - player:getGender()

                    -- Hand the hat over before taking the three items, so a full
                    -- inventory costs the player nothing. giveItem tells them why.
                    if not npcUtil.giveItem(player, strawHat) then
                        return
                    end

                    player:confirmTrade()
                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
