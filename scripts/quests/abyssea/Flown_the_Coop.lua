-----------------------------------
-- Flown the Coop
-----------------------------------
-- Log ID: 8, Quest ID: 41
-- Brutus        : Abyssea - Attohwa (H-8), entity 17658603
-- Chocobo_Spoor : Abyssea - Attohwa, entities 17658604 / 17658605 / 17658606
-- Chocobo       : Abyssea - Attohwa, entities 17658607 / 17658608 / 17658609
-- !addquest 8 41
-----------------------------------
-- Retail (bg-wiki "Flown the Coop").
-- |Start=Brutus (A) (H-8), Abyssea - Attohwa  |Fame=aatt |FLevel=2
-- |Reward=First time: KI Jade abyssite of prosperity. Subsequent: 400 Cruor.
--         Chance at an Empyrean +1 HEAD seal (Tantra/Creed/Aoidos'/Mavi).
-- |Repeatable=Yes
--   1. "Speak to Brutus in Abyssea - Attohwa (H-8). He will trade you Gysahl Greens."
--   2. "Trade the Gysahl Greens to one of the Chocobo Spoor targetable locations in
--      the vicinity of (I-8), (I-9), or (J-13)."
--   3. "A Chocobo NPC will appear upon trading Gysahl Greens. Your goal is to sneak
--      up behind the Chocobo NPC and examine it, should it see you, it will get
--      spooked and run away."
--      "When a chocobo appears, it runs around, and when it stops, it checks the
--       surroundings. It will run away if it sees a player. It can see through
--       Invisible."
--   4. "Speak to Brutus after capturing the Chocobo to receive your reward."
--   "Zoning is required in order to repeat this quest."
--
-- CSIDS DECODED, NOT GUESSED. Per-csid attribution from Brutus's byte ranges:
--   332 -> 8103/8104  his idle lines about the birds that survived Jeuno.
--   333 -> 8105-8110  THE OFFER. 8106 "We've got ourselves a stray chocobo on our
--          hands", 8110 is the two-way menu ("Certainly!" / "I think not...").
--   335 -> 8119-8121  THE TURN-IN. "Well, will ya look at this? Back safe and sound!"
--          / "This ain't much in comparison to th' life of a noble bird, but I want
--          ya to have it."
--   336 -> 8121  the same closing line on its own, his post-completion state.
--   337 -> 8113-8118  THE BRIEFING, and it is where the whole mechanic is stated:
--          8114 "If you spot his tracks, just set down ${article}
--          ${item-article: 0[2]} a[nd wait]" -- the greens id is a param -- and 8116
--          "you'll be wantin' to sneak up from behind, all stealthy-like. Get close
--          enough, and...grab 'im while he's none the wiser!"
--
-- "SNEAK UP FROM BEHIND" IS THE QUEST, so it is enforced rather than waved through:
-- the capture only succeeds if the player is actually behind the bird. isBehind is
-- the same check the rest of the codebase uses for positional requirements, and
-- bg-wiki's "It can see through Invisible" is why no stealth exemption is granted.
--
-- THE BIRD'S WANDERING is the NPC's own business, not this quest's: the three
-- Chocobo entities already exist in npc_list (17658607-17658609), one per spoor.
-- What this file owns is the lure, the approach check and the reward.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.FLOWN_THE_COOP)

-- Chocobo_Spoor entity -> the Chocobo it lures out. npc_list pairs them in order,
-- matching bg-wiki's (I-8), (I-9), (J-13).
local spoorToBird =
{
    [17658604] = 17658607,
    [17658605] = 17658608,
    [17658606] = 17658609,
}

-- bg-wiki lists HEAD seals for this quest: 3111/3116/3119/3125.
local headSeals =
{
    xi.item.TANTRA_SEAL_HEAD,
    xi.item.CREED_SEAL_HEAD,
    xi.item.AOIDOS_SEAL_HEAD,
    xi.item.MAVI_SEAL_HEAD,
}

local repeatCruor = 400

-- "Get close enough, and...grab 'im." Melee reach, since the whole point is closing
-- the distance unnoticed.
local grabRange = 6

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_ATTOHWA,
}

local clearRun = function(player)
    quest:setVar(player, 'Caught', 0)
    quest:setVar(player, 'Lured', 0)
end

--- Setting the greens down at a spoor. Shared by both sections.
local spoorActions =
{
    onTrade = function(player, npc, trade)
        local birdId = spoorToBird[npc:getID()]

        if birdId == nil then
            return
        end

        if not npcUtil.tradeHasExactly(trade, xi.item.BUNCH_OF_GYSAHL_GREENS) then
            return
        end

        local bird = GetNPCByID(birdId)

        if bird == nil or bird:isSpawned() then
            return
        end

        bird:setStatus(xi.status.NORMAL)
        quest:setVar(player, 'Lured', 1)

        return true
    end,
}

--- Approaching the bird. Behind it, it is caught; in front, it bolts.
local chocoboActions =
{
    onTrigger = function(player, npc)
        if quest:getVar(player, 'Lured') ~= 1 then
            return
        end

        if player:checkDistance(npc) > grabRange then
            return
        end

        -- "It will run away if it sees a player", and it can see through Invisible.
        if not player:isBehind(npc) then
            npc:setStatus(xi.status.DISAPPEAR)
            clearRun(player)

            return true
        end

        npc:setStatus(xi.status.DISAPPEAR)
        quest:setVar(player, 'Caught', 1)
        quest:setVar(player, 'Lured', 0)

        return true
    end,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ABYSSEA_ATTOHWA) >= 2
        end,

        [xi.zone.ABYSSEA_ATTOHWA] =
        {
            ['Brutus'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(333)
                end,
            },

            onEventFinish =
            {
                [333] = function(player, csid, option, npc)
                    -- 8110's second line, "I think not...", declines.
                    if option ~= 0 then
                        return
                    end

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
            ['Chocobo_Spoor'] = spoorActions,
            ['Chocobo']       = chocoboActions,

            ['Brutus'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Caught') == 1 then
                        return quest:progressEvent(335)
                    end

                    return quest:progressEvent(337, xi.item.BUNCH_OF_GYSAHL_GREENS)
                end,
            },

            onEventFinish =
            {
                [337] = function(player, csid, option, npc)
                    -- "He will trade you Gysahl Greens", once per briefing.
                    if not player:hasItem(xi.item.BUNCH_OF_GYSAHL_GREENS) then
                        npcUtil.giveItem(player, xi.item.BUNCH_OF_GYSAHL_GREENS)
                    end
                end,

                [335] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        clearRun(player)
                        npcUtil.giveKeyItem(player, xi.ki.JADE_ABYSSITE_OF_PROSPERITY)
                    end
                end,
            },
        },
    },

    -- Repeatable. bg-wiki: "Zoning is required in order to repeat this quest."
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_ATTOHWA] =
        {
            ['Chocobo_Spoor'] = spoorActions,
            ['Chocobo']       = chocoboActions,

            ['Brutus'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Caught') == 1 then
                        return quest:progressEvent(335)
                    elseif quest:getMustZone(player) then
                        return quest:event(336)
                    end

                    return quest:progressEvent(337, xi.item.BUNCH_OF_GYSAHL_GREENS)
                end,
            },

            onEventFinish =
            {
                [337] = function(player, csid, option, npc)
                    if not player:hasItem(xi.item.BUNCH_OF_GYSAHL_GREENS) then
                        npcUtil.giveItem(player, xi.item.BUNCH_OF_GYSAHL_GREENS)
                    end
                end,

                [335] = function(player, csid, option, npc)
                    clearRun(player)
                    xi.abyssea.questReward(player, repeatCruor, headSeals)
                    xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.FLOWN_THE_COOP)
                end,
            },
        },
    },
}

return quest
