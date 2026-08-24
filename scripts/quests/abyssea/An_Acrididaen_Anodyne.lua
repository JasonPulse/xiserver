-----------------------------------
-- An Acrididaen Anodyne
-----------------------------------
-- Log ID: 8, Quest ID: 45
-- Yoran-Oran : Abyssea - Attohwa (G-10), entity 17658615
-- Rockhopper : Abyssea - Attohwa (I-10), entity 17658617
-- Gasponia   : Abyssea - Attohwa, entities 17658539 .. 17658568
-- !addquest 8 45
-----------------------------------
-- Retail (bg-wiki "An Acrididaen Anodyne").
-- |Start=Yoran-Oran (A) (G-10), Abyssea - Attohwa  |Fame=aatt |FLevel=3
-- |Previous=Something in the Air  |Repeatable=Yes
-- |Reward=Aug Ex Jupiter's Ring / Aug Ex Fluorite Ring. Chance at an Empyrean +1
--         HEAD seal (Estoq./Bale/Sylvan/Cirque).
--   1. "Speak to Yoran-Oran (A) at (G-10) in Abyssea - Attohwa at the base camp."
--      "Optional: Speak to Jakaka (A) (I-10) for further information on the quest."
--   2. "Go to the small grass area in the south-east part of (I-10) by the bones. In
--      the grass, move around and use the /clap emote until a glowing Rockhopper
--      targetable location appears on the ground. Interact with it to get a KI
--      Rockhopper."
--   3. "Speak to Yoran-Oran (A) to receive KI Phial of counteragent."
--   4. "Examine the Gasponia targetable flowers in the vicinity of (F-8)/(F-9)."
--   5. "Speak to Yoran-Oran (A) to receive your reward."
--
-- CSIDS DECODED, NOT GUESSED. Yoran-Oran is 17658615 -> zone 215, and his block holds
-- two quests. 348-351 are Something in the Air, this quest's |Previous=: 8169 "you
-- must go west-ethy, young ${choice-player-gender}[man/woman], and investigate the
-- source", and 8175 "Are you out of your mind-ethy!? Do you realize how poisonous
-- that is?" is its turn-in. Per-csid attribution for THIS quest:
--   352 -> 8181-8185  THE OFFER, picking up straight from that: "Would you
--          believe-ethy that I just completed my analysis of the
--          ${keyitem-singular: 0[2]} you acquired for me?" ... "The good news-ethy is
--          that I've already formulated a backup plan."
--   353 -> 8189-8191  the rockhopper hunt, "${keyitem-article: 1[2]}... They're said
--          to be found-ethy here in the chasm, but where-ethy?" and "There must be
--          someone in the area-ethy who could enlighten us" -- which is the nudge
--          toward Jakaka that bg-wiki files as optional.
--   355 -> 8199-8203  the exchange. "${keyitem-article: 0[2]}! Oh, thank you! I
--          imagine-ethy it was not easily found!" ... "Behold! The elusive
--          counteragent!" ... "Now, all you need do is return to the gasponia and
--          inject it!"
--   354 -> 8203       that final instruction on its own, the reminder once the phial
--          is in hand.
--   356 -> 8206-8209  THE TURN-IN. "Incredible! A resounding success-ethy! The
--          patients are already showing signs of improvement."
--   357 -> 8208/8209  his post-completion lines.
--   358 -> 8210-8212  the repeat offer, "It's high time to administer another dose of
--          ${keyitem}" / "Could I trouble you to find another
--          ${keyitem-singular: 0[2]}-ethy for me?"
--   396 -> 8211/8212  the same request without the sneeze.
--
-- NEITHER TARGETABLE HAS AN EVENT PROGRAM. csidmsg.load returns nothing for the
-- Rockhopper (17658617) or for any of the thirty Gasponia (17658539-17658568), so
-- both are plain key-item interactions with the standard message, the same shape the
-- event-less Supply Points in this zone use.
--
-- THE /CLAP EMOTE IS NOT A GATE. bg-wiki says to "move around and use the /clap emote
-- until a glowing Rockhopper targetable location appears", i.e. the emote is how the
-- player makes the already-placed entity show itself. There is no server-side record
-- of having emoted at a spot that could be tested here without inventing one, and the
-- entity is what actually hands the key item over.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.AN_ACRIDIDAEN_ANODYNE)

local rockhopperQm = 17658617

-- The thirty Gasponia share one name, so any of them accepts the phial. The range is
-- contiguous in npc_list.
local gasponiaFirst = 17658539
local gasponiaLast  = 17658568

-- bg-wiki lists HEAD seals for this quest: 3114/3117/3120/3127.
local headSeals =
{
    xi.item.ESTOQUEURS_SEAL_HEAD,
    xi.item.BALE_SEAL_HEAD,
    xi.item.SYLVAN_SEAL_HEAD,
    xi.item.CIRQUE_SEAL_HEAD,
}

-- "Aug Ex Jupiter's Ring / Aug Ex Fluorite Ring", one or the other.
local rings = { xi.item.JUPITERS_RING, xi.item.FLUORITE_RING }

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_ATTOHWA,
}

local clearRun = function(player)
    player:delKeyItem(xi.ki.ROCKHOPPER)
    player:delKeyItem(xi.ki.PHIAL_OF_COUNTERAGENT)
    quest:setVar(player, 'Dosed', 0)
end

--- Picking the insect up. Shared by both sections.
local rockhopperActions =
{
    onTrigger = function(player, npc)
        if
            npc:getID() ~= rockhopperQm or
            player:hasKeyItem(xi.ki.ROCKHOPPER) or
            player:hasKeyItem(xi.ki.PHIAL_OF_COUNTERAGENT)
        then
            return
        end

        npcUtil.giveKeyItem(player, xi.ki.ROCKHOPPER)

        return true
    end,
}

--- Injecting a flower. Shared by both sections.
local gasponiaActions =
{
    onTrigger = function(player, npc)
        local entityId = npc:getID()

        if
            entityId < gasponiaFirst or
            entityId > gasponiaLast or
            not player:hasKeyItem(xi.ki.PHIAL_OF_COUNTERAGENT)
        then
            return
        end

        player:delKeyItem(xi.ki.PHIAL_OF_COUNTERAGENT)
        quest:setVar(player, 'Dosed', 1)

        return true
    end,
}

--- His whole conversation depends only on what the player is carrying.
local yoranTrigger = function(player, npc)
    if quest:getVar(player, 'Dosed') == 1 then
        return quest:progressEvent(356, xi.ki.PHIAL_OF_COUNTERAGENT)
    elseif player:hasKeyItem(xi.ki.PHIAL_OF_COUNTERAGENT) then
        return quest:event(354, xi.ki.PHIAL_OF_COUNTERAGENT)
    elseif player:hasKeyItem(xi.ki.ROCKHOPPER) then
        return quest:progressEvent(355, xi.ki.PHIAL_OF_COUNTERAGENT, xi.ki.ROCKHOPPER)
    end

    return quest:event(353, xi.ki.PHIAL_OF_COUNTERAGENT, xi.ki.ROCKHOPPER)
end

local handOverInsect = function(player, csid, option, npc)
    player:delKeyItem(xi.ki.ROCKHOPPER)
    npcUtil.giveKeyItem(player, xi.ki.PHIAL_OF_COUNTERAGENT)
end

local payOut = function(player)
    clearRun(player)
    npcUtil.giveItem(player, rings[math.random(1, #rings)])
    xi.abyssea.questReward(player, 0, headSeals)
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.SOMETHING_IN_THE_AIR) and
                player:getFameLevel(xi.fameArea.ABYSSEA_ATTOHWA) >= 3
        end,

        [xi.zone.ABYSSEA_ATTOHWA] =
        {
            ['Yoran-Oran'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(352, xi.ki.ROCKHOPPER)
                end,
            },

            onEventFinish =
            {
                [352] = function(player, csid, option, npc)
                    quest:begin(player)
                    clearRun(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_ATTOHWA] =
        {
            ['Rockhopper'] = rockhopperActions,
            ['Gasponia']   = gasponiaActions,
            ['Yoran-Oran'] = { onTrigger = yoranTrigger },

            onEventFinish =
            {
                [355] = handOverInsect,

                [356] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        payOut(player)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_ATTOHWA] =
        {
            ['Rockhopper'] = rockhopperActions,
            ['Gasponia']   = gasponiaActions,

            ['Yoran-Oran'] =
            {
                onTrigger = function(player, npc)
                    if
                        quest:getVar(player, 'Dosed') == 1 or
                        player:hasKeyItem(xi.ki.PHIAL_OF_COUNTERAGENT) or
                        player:hasKeyItem(xi.ki.ROCKHOPPER)
                    then
                        return yoranTrigger(player, npc)
                    elseif quest:getVar(player, 'Asked') == 1 then
                        return quest:event(396, xi.ki.ROCKHOPPER)
                    end

                    return quest:progressEvent(358, xi.ki.ROCKHOPPER)
                end,
            },

            onEventFinish =
            {
                [355] = handOverInsect,

                [356] = function(player, csid, option, npc)
                    quest:setVar(player, 'Asked', 0)
                    payOut(player)
                end,

                [358] = function(player, csid, option, npc)
                    clearRun(player)
                    quest:setVar(player, 'Asked', 1)
                end,
            },
        },
    },
}

return quest
