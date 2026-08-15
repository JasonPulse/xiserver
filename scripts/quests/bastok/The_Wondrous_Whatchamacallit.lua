-----------------------------------
-- The Wondrous Whatchamacallit
-----------------------------------
-- Log ID: 1, Quest ID: 90
-- Selliste : Bastok Mines (K-7)
-----------------------------------
-- Retail (bg-wiki "The Wondrous Whatchamacallit"), previous quest Synergistic
-- Pursuits, and Quest Reqs "Synergy skill 5+":
--   1. Speak to Selliste at (K-7). Fame Bastok 1.
--   2. Gather six stones from ??? spots: Flamestone (Cloister of Flames),
--      Froststone (Frost), Galestone (Gales), Tremorstone (Tremors),
--      Stormstone (Storms), Tidestone (Tides).
--   3. Synergize them into an Ampoule of astral matter in a Synergy Furnace.
--   4. Trade the astral matter to Selliste -> Portafurnace.
-- No title, not repeatable.
--
-- CSIDs decoded, not guessed. Selliste is entity 17735861 (npc_list:27529);
-- (17735861-16777216) = 958645, 958645//4096 = 234 rem 181 -> Bastok Mines,
-- 0x010EA0B5. Read against `xi-dat dialog 234`:
--   595 -> 10418 "No, that won't work either. Confound it! If only there were a
--          skilled synergist around here to help me out..." -- the pre-req idle,
--          shown when you are not yet a synergist.
--   591 -> the offer, two prompts plus the recipe. 10420 "Wait a minute...you
--          there! Yes, you! That faint yet distinctive scent of fewell and
--          ash...", 10423 "Help Selliste? / Not interested. / My pleasure!",
--          10430 "if only I could get my hands on some of the astral
--          whatchamacallit", 10434 "All you need to do is use your synergy skills
--          to whip up ${article} ${item-article: 0}", 10435 the second
--          "Help Selliste?" prompt, then 10437 "It's just ${item-article: 0},
--          ${item-article: 1}, ${item-article: 2}, ${item-article: 3},
--          ${item-article: 4}..." and 10438 "...And finally, ${item-article: 0}."
--          -- five slots plus one, i.e. the six stones, which is what pins this
--          csid. 10439 "I suspect you can find the ingredients somewhere strong
--          in elemental energy. Maybe a place with some of those big crystal
--          doohickeys lying around?"
--   592 -> 10441 "I knew you'd be back! ...Ready to do the world a favor and help
--          me complete my most marvelous invention?", 10442 "Don't tell me you've
--          already forgotten the recipe for astral matter." -- the reminder.
--   593 -> the trade. 10443 "Why, yes! Yes, I'd recognize it anywhere! One
--          hundred percent pure, unadulterated astral
--          whatchama-thingama-doodad-jiggity-callit!!!", 10445 "I dub it the
--          'portafurnace'! And as a reward for making this day possible, I
--          present you with one of your very own!", 10447 "Anywhere, that is,
--          except for busy cities and towns. And dungeons."
--   594 -> 10449, 10450 "Well, if it isn't my favorite adventurer! Synergizing up
--          a storm with the help of my miraculous portafurnace?" -- post-quest.
--   596 -> 10451 "What? Don't tell me you lost the ${item-singular: 0} I made for
--          you.", 10452 "Here's a brand-spankin' new one." -- the REPLACEMENT if
--          you lose the Portafurnace, which retail has and the stub lacked.
--          (10453 "come back a little later" is the same program's cooldown line.)
--
-- THE OLD STUB'S CSIDS DO NOT EXIST: `xi-dat csid 234 800` returns nothing, and
-- the same for 801. The stub handed the Portafurnace over on a second Selliste
-- click with no Astral Matter trade, no six-stone hunt and no Synergy skill check.
--
-- TWO MISSING ENUMS, now added to scripts/enum/item.lua with ids taken from
-- sql/item_basic.sql rather than guessed:
--   xi.item.PORTAFURNACE = 13078 (item_basic.sql:10513 'portafurnace')
--   xi.item.AMPOULE_OF_ASTRAL_MATTER = 2799 (item_basic.sql:2770,
--     'ampoule_of_astral_matter', sort name 'astral_matter')
-- The stub hardcoded 13078 as a bare local, which was the right number but
-- unnamed, and it never referenced the astral matter at all.
--
-- The Synergy skill gate uses getCharSkillLevel, NOT getSkillLevel: synergy is
-- craft skill index 57 (scripts/enum/skill.lua:67), and craft skills are packed
-- by src/map/utils/charutils.cpp as (RealSkills.skill/10)*0x20 + rank, so
-- getSkillLevel returns the packed value and would open the gate far too early.
--
-- bg-wiki lists no fame, so the stub's 30 is gone.
--
-- STILL SIMPLIFIED, and flagged rather than faked: the six ??? stone spots in the
-- Cloisters and the synergy recipe that turns them into astral matter are not
-- wired here. Those are two separate systems -- ??? placements in six zones, and
-- a synergy recipe row -- and neither belongs in this file. What is faithful: the
-- correct NPC and csids, the Synergy skill 5 and Synergistic Pursuits gates, the
-- astral matter trade, the Portafurnace reward and the lost-item replacement.
-----------------------------------
local quest = Quest:new(xi.questLog.BASTOK, xi.quest.id.bastok.THE_WONDROUS_WHATCHAMACALLIT)

quest.reward =
{
    item = xi.item.PORTAFURNACE,
}

local synergyGate = 5

-- The six stones, in the order the 10437/10438 slots present them.
local stones =
{
    xi.item.FLAMESTONE,
    xi.item.FROSTSTONE,
    xi.item.GALESTONE,
    xi.item.TREMORSTONE,
    xi.item.STORMSTONE,
    xi.item.TIDESTONE,
}

local function recipeParams()
    local params = { [0] = xi.item.AMPOULE_OF_ASTRAL_MATTER }

    for slot, stone in ipairs(stones) do
        params[slot] = stone
    end

    return params
end

local function isSynergist(player)
    return player:hasKeyItem(xi.ki.SYNERGY_CRUCIBLE) and
        player:hasCompletedQuest(xi.questLog.BASTOK, xi.quest.id.bastok.SYNERGUSTIC_PURSUITS) and
        player:getCharSkillLevel(xi.skill.SYNERGY) >= synergyGate
end

quest.sections =
{
    -- Offer, or 595 if not yet a synergist.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.BASTOK) >= 1
        end,

        [xi.zone.BASTOK_MINES] =
        {
            ['Selliste'] =
            {
                onTrigger = function(player, npc)
                    if not isSynergist(player) then
                        return quest:event(595)
                    end

                    return quest:progressEvent(591, recipeParams())
                end,
            },

            onEventFinish =
            {
                -- 10435 "Help Selliste? / Not interested. / My pleasure!" --
                -- note the order: accepting is the SECOND option here.
                [591] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    -- Accepted: waiting on the astral matter.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.BASTOK_MINES] =
        {
            ['Selliste'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(592, recipeParams())
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.AMPOULE_OF_ASTRAL_MATTER) then
                        return quest:progressEvent(593, { [0] = xi.item.PORTAFURNACE })
                    end
                end,
            },

            onEventFinish =
            {
                [593] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:confirmTrade()
                    end
                end,
            },
        },
    },

    -- Post-quest: 594 normally, 596 to replace a lost Portafurnace.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.BASTOK_MINES] =
        {
            ['Selliste'] =
            {
                onTrigger = function(player, npc)
                    if not player:hasItem(xi.item.PORTAFURNACE) then
                        return quest:progressEvent(596, { [0] = xi.item.PORTAFURNACE })
                    end

                    return quest:event(594, { [0] = xi.item.PORTAFURNACE })
                end,
            },

            onEventFinish =
            {
                [596] = function(player, csid, option, npc)
                    if not player:hasItem(xi.item.PORTAFURNACE) then
                        npcUtil.giveItem(player, xi.item.PORTAFURNACE)
                    end
                end,
            },
        },
    },
}

return quest
