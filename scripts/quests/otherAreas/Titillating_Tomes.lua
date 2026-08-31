-----------------------------------
-- Titillating Tomes
-----------------------------------
-- Log ID: 4, Quest ID: 122
-- Green Thumb Moogle : Mog Garden, entity 17924125
-- Cutscene holder    : Mog Garden, entity 17924176
-- !addquest 4 122
-----------------------------------
-- Retail (bg-wiki "Titillating Tomes").
-- |Start=Green Thumb Moogle, Mog Garden  |Fame=Other
-- |Previous=Hypnotic Hospitality  |Next=Glittering Gals
-- |Title=Wibbly Wobbly Woozy Warrior  |Reward=Straw Hat
-- |Item Reqs=Drill Calamary, Calico Comet, Philosopher's Stone
--   1. "Once you have achieved Rank 7 in all geological locations (that is, you have
--      bought the MHMU treatises for all sections of your Mog Garden except monster
--      rearing), zone into your Mog Garden and talk to your Green Thumb Moogle."
--   2. "He will ask for the following items: Drill Calamary can be obtained from the
--      Coastal Fishing Net, Calico Comet from the Pond Dredger, Philosopher's Stone
--      from the Mineral Vein."
--   3. "Trade all the items at once to the Moogle in order to complete the quest."
--
-- THE GATE IS THE ONE THE RANK SYSTEM WAS BUILT FOR. bg-wiki spells out that monster
-- rearing is excluded, which is why xi.mog_garden.geologicalLocations lists five
-- families and not six, and why xi.mog_garden.allLocationsMaxRank reads only those
-- five. Nothing here re-derives it.
--
-- CSIDS. These were decoded offline with xidat/csidmsg.py over zone 280 and then
-- read back against output/dialog-table-280.xml. THE HANDOFF DOC'S ATTRIBUTION WAS
-- WRONG and is not used: it lists 2041 offer / 2042 reminder / 2043 turn-in, and the
-- decode contradicts the last two outright.
--
--   2042  THE TURN-IN, and this one is proven. It emits 8068 "You're due a dab of
--         deference, thanks to the effort you've exerted in easing this endemic,
--         kupo." and 8069 "I also wrapped up writing to the reeling relatives of our
--         suffering scholars!" Both belong to this quest and to no other: the
--         "endemic" and the "suffering scholars" are the MHMU's wibbly wobbly
--         woozies. It sits on the Moogle himself.
--
--   2041  THE OFFER, and this one is INFERRED rather than proven. Read the reasoning
--         before changing it. The offer scene is messages 8055 to 8065, anchored by
--         8060, which names all three items through params: "≺item≻ filched from the
--         fishing net, ≺item≻ plucked from the pond, and ≺item≻ veiled within veins".
--         A sweep of csidmsg.py across ALL 166 entities in zone 280 attributes 8060
--         to no csid at all, because the sweep is positional and under-reports inside
--         large programs. What ties 2041 to that scene is a co-reference: 2041 is a
--         4990-byte program on holder 17924176 and it emits 8018, which describes
--         "Kupogaard, the most prolific of professors to publish prose on the
--         hardships of husbandry", while 8059 inside the offer scene says "The rife
--         resources remarked upon in the compilations you--<ahem> Kupogaard created".
--         Same character, same conversation. 2041 is also the only large program in
--         the numeric run and sits exactly where bg-wiki puts the offer.
--         ONE `!cs 2041` ON A PUPPET CONFIRMS OR REFUTES THIS. Until then it is
--         flagged here rather than presented as decoded.
--
--   NO REMINDER IS WIRED. The reminder is 8066/8067 ("The MHMU needs ... If we don't
--   get them, the wibbly wobbly woozies will continue to whittle away at our
--   wisemen's wits, kupo!") and the same sweep attributes it to no csid either.
--   Rather than reuse the offer or invent an id, mid-quest talk is left to fall
--   through to the Moogle's own script. The quest is completable without it; a
--   fabricated csid would render nothing and look like content.
--
-- ITEMS, every one resolved by id, because three of the four are the container-word
-- trap that a name-only lookup misses:
--   Drill Calamary        xi.item.DRILL_CALAMARY      17006
--   Calico Comet          xi.item.CALICO_COMET         5715
--   Philosopher's Stone   xi.item.PHILOSOPHERS_STONE    942
--   Straw Hat             STRAW_HAT_M 27733 / STRAW_HAT_F 27734, a gendered pair
--
-- The hat is handed over by hand rather than through quest.reward because it is two
-- item ids; xi.mog_garden.genderedReward picks the half matching the character.
-----------------------------------
require('scripts/globals/mog_garden')
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.TITILLATING_TOMES)

quest.reward =
{
    title = xi.title.WIBBLY_WOBBLY_WOOZY_WARRIOR,
}

-- "Trade all the items at once", so this is an exact three-item hand-over. The order
-- is 8060's own: fishing net, pond, vein.
local scholarsCure =
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
                -- 8060 renders the three items from params, so they are passed
                -- rather than left for the event to find.
                onTrigger = function(player, npc)
                    return quest:progressEvent(2041, scholarsCure[1], scholarsCure[2], scholarsCure[3])
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
                    if npcUtil.tradeHasExactly(trade, scholarsCure) then
                        return quest:progressEvent(2042)
                    end
                end,
            },

            onEventFinish =
            {
                [2042] = function(player, csid, option, npc)
                    local hat = xi.mog_garden.genderedReward(player, xi.item.STRAW_HAT_M, xi.item.STRAW_HAT_F)

                    if not npcUtil.giveItem(player, hat) then
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
