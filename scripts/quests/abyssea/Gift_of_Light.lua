-----------------------------------
-- Gift of Light
-----------------------------------
-- Log ID: 8, Quest ID: 1
-- Amaura       : Abyssea - La Theine (E-3), entity 17318646
-- Jagged_Cliff : Abyssea - La Theine (J-6), entity 17318648
-- !addquest 8 1
-----------------------------------
-- Retail (bg-wiki "Gift of Light").
-- |Start=Amaura (A) (E-3), Abyssea - La Theine  |Fame=alth |FLevel=1
-- |Item Reqs=KI Sunbeam fragment  |Reward=Hi-Reraiser, 120 Cruor  |Repeatable=Yes
--   1. Speak to Amaura at (E-3) near Conflux #01. "She asks for a KI Sunbeam
--      fragment."
--   2. "Examine the Jagged Cliff targetable location at the southeast corner of
--      (J-6) for a mini game."
--      "You can only complete this mini game during the day, 6:00~18:00 Vana'diel
--       time."
--      "In this mini-game, you need to retrieve a KI Sunbeam fragment at the bottom
--       of the chasm by bungee jumping. This requires pressing the NOW prompt at the
--       correct time. You have three tries."
--      "Even if you do not obtain the fragment, you can return to Amaura to complete
--       the quest, but you will only receive 60 Cruor."
--   3. Return to Amaura. "If you already have a Hi-Reraiser, you must dispose of it
--      to complete the quest."
--   "Zoning is required to repeat this quest."
--
-- CSIDS DECODED, NOT GUESSED. Per-csid attribution from each entity's byte ranges:
--   Amaura 153 -> 7876-7889  THE OFFER. 7879 "I've fair run out of the
--          ${keyitem-plural: 0[2]} I use to brew my medicine", 7880 is the two-way
--          menu ("Always willing to serve!" / "I've better things to do, lady."),
--          7882 "ye'll be wantin' to go to the edge of the ravine east of here, when
--          the moon's not showin'", 7884 names Raminel. data[] holds 1579 (Sunbeam
--          fragment), so the block supplies the key item id itself.
--   Amaura 154 -> 7882-7884  the reminder, the directions without the preamble.
--   Amaura 155 -> 7885-7887  THE TURN-IN, and it carries BOTH outcomes: 7885 "ye've
--          returned...and with what I asked for", 7886 the reward line, and 7887
--          "So ye've returned...and WITHOUT what I asked for." The client can see
--          whether the player holds the fragment, so this fires bare and the two
--          Cruor tiers are decided here.
--   Amaura 156 -> 7888       her post-completion line.
--   Jagged_Cliff 152 -> 7890-7905  THE WHOLE MINIGAME in one 791-byte program.
--          7890 introduces Raminel, 7894 is the ready menu ("Ready to the extreme!"
--          / "I hear my kettle whistling..."), 7897-7900 "One! Two! Three!
--          Descend!", 7901 "Grab the ${keyitem-singular: 0[2]}... (Tries left:
--          ${number: 1}) ${selection-lines} Now!", 7902 "Beautifully done!", 7904
--          "Oh, that was so awfully close! Would you care for another attempt?",
--          7905 the decline. The three tries and the timing check all run inside the
--          event, so Lua fires it and reads the outcome off the option.
--
-- NEEDS CONFIRMATION: the exact option value 152 returns on a successful grab. The
-- program keeps its own try counter and timing in work vars, which are not decoded
-- here, so the only readable signal is "the accepting option is not the decline".
-- Treating any non-zero option as success is therefore the reading used below. If it
-- proves inverted in game, the fix is one comparison, and either way the quest stays
-- completable because bg-wiki has both outcomes ending at Amaura.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.GIFT_OF_LIGHT)

local cruorWithFragment = 120
local cruorEmptyHanded  = 60

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_LATHEINE,
}

--- bg-wiki: "You can only complete this mini game during the day, 6:00~18:00."
local isDaytime = function()
    local hour = VanadielHour()

    return hour >= 6 and hour < 18
end

local cliffActions =
{
    onTrigger = function(player, npc)
        if player:hasKeyItem(xi.ki.SUNBEAM_FRAGMENT) or not isDaytime() then
            return
        end

        return quest:progressEvent(152, xi.ki.SUNBEAM_FRAGMENT)
    end,
}

local cliffFinish = function(player, csid, option, npc)
    -- See the NEEDS CONFIRMATION note in the header.
    if option ~= 0 then
        npcUtil.giveKeyItem(player, xi.ki.SUNBEAM_FRAGMENT)
    end
end

--- Both tiers hand out the Hi-Reraiser; only the Cruor differs.
local payOut = function(player)
    local cruor = cruorEmptyHanded

    if player:hasKeyItem(xi.ki.SUNBEAM_FRAGMENT) then
        cruor = cruorWithFragment
        player:delKeyItem(xi.ki.SUNBEAM_FRAGMENT)
    end

    npcUtil.giveItem(player, xi.item.HI_RERAISER)
    xi.abyssea.questReward(player, cruor, nil)
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Amaura'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(153)
                end,
            },

            onEventFinish =
            {
                [153] = function(player, csid, option, npc)
                    -- 7881 is the refusal, "Young'uns these days have lost all
                    -- respect for their elders."
                    if option ~= 0 then
                        return
                    end

                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Jagged_Cliff'] = cliffActions,

            ['Amaura'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(155)
                end,
            },

            onEventFinish =
            {
                [152] = cliffFinish,

                [155] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        payOut(player)
                    end
                end,
            },
        },
    },

    -- Repeatable. bg-wiki: "Zoning is required to repeat this quest."
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Jagged_Cliff'] = cliffActions,

            ['Amaura'] =
            {
                onTrigger = function(player, npc)
                    if quest:getMustZone(player) then
                        return quest:event(156)
                    end

                    return quest:progressEvent(153)
                end,
            },

            onEventFinish =
            {
                [152] = cliffFinish,

                [153] = function(player, csid, option, npc)
                    if option ~= 0 then
                        return
                    end

                    -- Re-running: she asks again, and the turn-in below pays out.
                    quest:setVar(player, 'Prog', 1)
                end,

                [155] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 0)
                    payOut(player)
                    xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.GIFT_OF_LIGHT)
                end,
            },
        },
    },
}

return quest
