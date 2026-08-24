-----------------------------------
-- Wanted: Medical Supplies
-----------------------------------
-- Log ID: 8, Quest ID: 56
-- Yasuji : Abyssea - Misareaux (G-7), entity 17662736
-- !addquest 8 56
-----------------------------------
-- Retail (bg-wiki "Wanted: Medical Supplies").
-- |Start=Yasuji (A) (G-7), Abyssea - Misareaux  |Fame=amis |FLevel=2
-- |Repeatable=Yes  |Reward=KI Sapphire abyssite of merit, 800 Cruor,
--                          chance at an Empyrean +1 LEGS seal
--   1. "Talk to Yasuji (A), who is at (G-7) near Conflux #3, and accept the quest."
--   2. "Find a Blue Sturdy Pyxis and open it. There is a chance that you will receive
--      the KI Medical supply chest. It appears to be proportional to the Pyxis level."
--      "Using Forbidden Keys to open the chest will not give you the key item, you
--       must open it manually."
--   3. "Return to Yasuji and receive your reward."
--   "Zoning is required to repeat this quest."
--
-- YASUJI IS A STUB, and this is the holder pattern again. Every block on 17662736 is
-- a sentinel; the real programs live on the unnamed Misareaux holder 17662724, the
-- same holder that carries Soil and Green. Event lookup is zone-global, so firing
-- these ids while the player is talking to Yasuji resolves to the holder's programs.
-- That was confirmed live, not assumed.
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, fired at the puppet in Abyssea - Misareaux:
--   224 -> "Hmmm... This is a difficult situation we are being in..." / "Ororo? I
--          believe I am not knowing you. By what name are you being called?"
--                                                                       THE OFFER
--   225 -> "The medicine supplies we are needing should be inside some of the sturdy
--          pyxises." / "For making benefit the great resistance effort, please be
--          finding and bringing them to me!"                          the reminder
--   226 -> "Ah! You have been finding what I have been requesting!" / "I am thanking
--          you. I am giving you a physical representation of my appreciation."
--                                                                       the turn-in
--   227 -> "We will be doing fine for a while, I am thinking. But the fighting is
--          never-ending..."                                the post-completion line
--   228 -> "Our medicine supply is almost depleting. Will you be helping to obtain
--          more?"                                                  the repeat offer
--
-- THE KEY ITEM IS NOT GRANTED HERE. It is rolled on the shared pyxis open path by
-- xi.abyssea.medicalSupplyRoll, called from xi.pyxis.openChest and gated to blue
-- chests, because that is the only place that knows a chest was opened by hand.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.WANTED_MEDICAL_SUPPLIES)

local cruorReward = 800

local legsSeals =
{
    xi.item.GOETIA_SEAL_LEGS,
    xi.item.LANCERS_SEAL_LEGS,
    xi.item.IGA_SEAL_LEGS,
    xi.item.NAVARCHS_SEAL_LEGS,
}

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_MISAREAUX,
    keyItem  = xi.ki.SAPPHIRE_ABYSSITE_OF_MERIT,
}

local handInSupplies = function(player)
    player:delKeyItem(xi.ki.MEDICAL_SUPPLY_CHEST)
    xi.abyssea.questReward(player, cruorReward, legsSeals)
    xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.WANTED_MEDICAL_SUPPLIES)
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ABYSSEA_MISAREAUX) >= 2
        end,

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['Yasuji'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(224)
                end,
            },

            onEventFinish =
            {
                [224] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['Yasuji'] =
            {
                onTrigger = function(player, npc)
                    if not player:hasKeyItem(xi.ki.MEDICAL_SUPPLY_CHEST) then
                        return quest:event(225)
                    end

                    return quest:progressEvent(226)
                end,
            },

            onEventFinish =
            {
                [226] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        handInSupplies(player)
                    end
                end,
            },
        },
    },

    -- Repeatable. bg-wiki: "Zoning is required to repeat this quest", so the repeat
    -- offer stays behind mustZone and he gives the post-completion line until then.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['Yasuji'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.MEDICAL_SUPPLY_CHEST) then
                        return quest:progressEvent(226)
                    elseif quest:getMustZone(player) then
                        return quest:event(227)
                    end

                    return quest:progressEvent(228)
                end,
            },

            onEventFinish =
            {
                [226] = function(player, csid, option, npc)
                    handInSupplies(player)
                end,
            },
        },
    },
}

return quest
