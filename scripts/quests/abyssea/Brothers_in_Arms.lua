-----------------------------------
-- Brothers in Arms
-----------------------------------
-- Log ID: 8, Quest ID: 73
-- Zazarg : Abyssea - Uleguerand (G-7), entity 17814113
-- !addquest 8 73
-----------------------------------
-- Retail (bg-wiki "Brothers in Arms").
-- |Start=Zazarg (A), Abyssea - Uleguerand  |Fame=aule  |FLevel=5
-- |Item Reqs=Imperial pearl  |Reward=2,000 Cruor
--   1. Talk to Zazarg (A) at (G-7) Conflux #7.
--   2. You are tasked to defeat Blanga. "He is force popped near Conflux #8."
--   3. "Upon defeating him with this quest active, everyone in the party will
--      receive an Imperial pearl key item."
--   4. Return to Zazarg (A) for your reward.
--
-- CSIDS DECODED, NOT GUESSED. Zazarg is 17814113 -> zone 253 idx 609
-- (0x010FD261). `xi-dat events 253` gives him 313-317 and 357; csidscan.py against
-- `xi-dat dialog 253` splits them, and 357 (8132-8141) belongs to another quest he
-- carries:
--   313 -> 8001/8002  BEFORE HE WILL TALK. "Yours is a face I haven't seen before.
--          What brings you to these parts, stranger?" -- and 8005 in the offer makes
--          the reason explicit: "Like there's anyone in this barren hinterland that
--          hasn't heard your name by now." This is bg-wiki's |FLevel=5 talking.
--   314 -> 8003-8012  THE OFFER. 8006 "Perhaps you've heard of the fiend that they
--          call the Blanga", 8007 "not before it had made off with our linkpearl.
--          Needless to say, the ability to communicate with our comrades is vital",
--          and 8008 is the accept prompt: "Retrieve the pearl? ${selection-lines}
--          Consider it done. / Do it yourself!" -- the affirmative is the FIRST
--          line, so OPTION 0 ACCEPTS, and 8012 is the decline.
--   315 -> 8010/8011/8013  the reminder: "Surely you haven't forgotten the name of
--          your quarry, have ya? The Blanga!"
--   316 -> 8014-8023  THE TURN-IN, and it is the source of the quest's title: 8015
--          "Let's see here... No, this won't do at all", 8016 "Look for yourself...
--          it's broken!", then 8018 "I'm just glad to have it back as a memento of
--          my brothers in arms."
--   317 -> 8022/8023  his post-completion lines.
--
-- THE PEARL IS BROKEN AND THAT IS THE POINT. 8016 has Zazarg reject the pearl as
-- useless and reward you anyway (8017 "don't look so glum... It's no fault of your
-- own"), so there is no success/failure branch to model here -- the single turn-in
-- csid covers it.
--
-- KEY ITEM: Imperial pearl is the existing IMPERIAL_PEARL (1721).
--
-- THE POP IS NOT THIS QUEST'S JOB. bg-wiki says Blanga is force-popped near Conflux
-- #8 by his own pop item, shared with anyone hunting him outside the quest, so this
-- script only credits the pearl on his death. bg-wiki is explicit that "everyone in
-- the party" is credited rather than just the killer, which is why isKiller is not
-- tested below.
-----------------------------------
local uleguerandID = zones[xi.zone.ABYSSEA_ULEGUERAND]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.BROTHERS_IN_ARMS)

local cruorReward = 2000

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_ULEGUERAND,
}

quest.sections =
{
    -- Under the fame bar: 8001/8002, he does not know who you are yet.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ABYSSEA_ULEGUERAND) < 5
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Zazarg'] = quest:event(313):replaceDefault(),
        },
    },

    -- bg-wiki lists no |Previous=; the only gate is |FLevel=5.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Zazarg'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(314)
                end,
            },

            onEventFinish =
            {
                [314] = function(player, csid, option, npc)
                    -- 8008: 0 "Consider it done.", 1 "Do it yourself!"
                    if option ~= 0 then
                        return
                    end

                    quest:begin(player)
                end,
            },
        },
    },

    -- Accepted: Blanga dies, the pearl comes back here.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Blanga'] =
            {
                onMobDeath = function(mob, player, optParams)
                    if player == nil then
                        return
                    end

                    -- bg-wiki: everyone in the party with the quest active is
                    -- credited, so isKiller is deliberately not tested.
                    if not player:hasKeyItem(xi.ki.IMPERIAL_PEARL) then
                        npcUtil.giveKeyItem(player, xi.ki.IMPERIAL_PEARL)
                    end
                end,
            },

            ['Zazarg'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.IMPERIAL_PEARL) then
                        return quest:progressEvent(316)
                    end

                    return quest:event(315)
                end,
            },

            onEventFinish =
            {
                [316] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.IMPERIAL_PEARL)

                    if quest:complete(player) then
                        player:addCurrency('cruor', cruorReward)
                        player:messageSpecial(uleguerandID.text.CRUOR_OBTAINED, cruorReward, player:getCurrency('cruor'))
                    end
                end,
            },
        },
    },

    -- Completed: 8022/8023, back into the thick of things.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Zazarg'] = quest:event(317):replaceDefault(),
        },
    },
}

return quest
