-----------------------------------
-- Let There Be Light
-----------------------------------
-- Log ID: 8, Quest ID: 67
-- Zauko       : Abyssea - Uleguerand (K-9), entity 17814088
-- Coal_Casket : Abyssea - Uleguerand, entities 17814089 / 17814090 / 17814091
-- !addquest 8 67
-----------------------------------
-- Retail (bg-wiki "Let There Be Light").
-- |Start=Zauko (A) (K-9), Abyssea - Uleguerand  |Fame=aule |FLevel=1
-- |Reward=First time: 400 Cruor. Subsequent: 200 Cruor. Chance at an Empyrean +1
--         BODY seal (Savant's/Caller's/Tantra/Iga/Lancer's).  |Repeatable=Yes
--   1. Talk to Zauko at (K-9) near Conflux #5.
--   2. "Then interact with the Coal Casket behind him for a KI Torch coal."
--   3. "Walk to the second encampment near Conflux #6 and place the coal into the
--      Coal Casket next to the flames."
--   4. "Afterwards, walk to the third encampment near Conflux #7 and place the coal
--      into the Coal Casket."
--   5. Return to Zauko for your reward.
--   "The Torch coal is destroyed when you use a conflux, so you must walk to each
--    encampment."  "Zoning is required to repeat this quest."
--
-- CSIDS DECODED, NOT GUESSED. Per-csid attribution from each entity's byte ranges:
--   Zauko 250 -> 7870-7873  THE OFFER. 7870 "The ${keyitem-singular: 0[2]} may be
--          found in the casket beside me", 7871 is the declining line, 7872 the
--          "Thou shalt avail thyself not of the confluxe" warning, 7873 "Deposit a
--          portion of ${keyitem-singular: 0[2]} within each".
--   Zauko 251 -> 7872/7873  the reminder, the instructions without the preamble.
--   Zauko 263 -> the turn-in; it carries msg 201 (the activity-points marker every
--          rewarding event in these zones ends on).
--   Zauko 264 -> 7888       his post-completion line.
--   Zauko 265 -> the repeat offer.
--   Coal_Casket 17814089 (the source, beside Zauko):
--     252 -> 7876  "The casket contains an ample supply of ${keyitem-singular}."
--     254 -> 7876/7877  adds "You cannot carry any more ${keyitem-singular}."
--   Coal_Casket 17814090 and 17814091 (the two encampments):
--     255 -> 7875  "You open the casket and deposit a pack of ${keyitem} within."
--     256 -> 7876/7878  adds "There seems to be no need for replenishment at this
--            time."
--   17814091 carries 252/255/256 as ONE-BYTE stubs, i.e. the same programs as
--   17814090; the client resolves them zone-wide, so both deposit caskets fire 255.
--
-- CONFLUX DESTRUCTION IS NOT MODELLED. bg-wiki says using a conflux destroys the
-- coal, and it says so as a warning to the player, not as a failure state that has
-- to be enforced for the quest to be completable: the recovery is to walk back and
-- take another coal, which this already allows at any time.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.LET_THERE_BE_LIGHT)

-- The casket beside Zauko hands coal out; the other two receive it.
local sourceCasket = 17814089

local depositCaskets =
{
    [17814090] = 0,
    [17814091] = 1,
}

local bothDeposited = 0x03

-- bg-wiki lists BODY seals for this quest: 3149/3144/3131/3142/3143.
local bodySeals =
{
    xi.item.SAVANTS_SEAL_BODY,
    xi.item.CALLERS_SEAL_BODY,
    xi.item.TANTRA_SEAL_BODY,
    xi.item.IGA_SEAL_BODY,
    xi.item.LANCERS_SEAL_BODY,
}

local firstCruor  = 400
local repeatCruor = 200

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_ULEGUERAND,
}

local clearRun = function(player)
    quest:setVar(player, 'Caskets', 0)
    player:delKeyItem(xi.ki.TORCH_COAL)
end

--- The caskets behave the same on the first run and on repeats.
local casketActions =
{
    onTrigger = function(player, npc)
        local entityId = npc:getID()

        if entityId == sourceCasket then
            if player:hasKeyItem(xi.ki.TORCH_COAL) then
                return quest:event(254, xi.ki.TORCH_COAL)
            end

            npcUtil.giveKeyItem(player, xi.ki.TORCH_COAL)

            return quest:event(252, xi.ki.TORCH_COAL)
        end

        local bit1 = depositCaskets[entityId]

        if bit1 == nil then
            return
        end

        local mask = quest:getVar(player, 'Caskets')

        -- Already stoked, or nothing in hand to stoke it with.
        if
            bit.band(mask, bit.lshift(1, bit1)) ~= 0 or
            not player:hasKeyItem(xi.ki.TORCH_COAL)
        then
            return quest:event(256, xi.ki.TORCH_COAL)
        end

        quest:setVar(player, 'Caskets', bit.bor(mask, bit.lshift(1, bit1)))
        player:delKeyItem(xi.ki.TORCH_COAL)

        return quest:event(255, xi.ki.TORCH_COAL)
    end,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Zauko'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(250)
                end,
            },

            onEventFinish =
            {
                [250] = function(player, csid, option, npc)
                    -- 7871 is the refusal, "Blasphemy!", so only the accepting
                    -- option begins anything.
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

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Coal_Casket'] = casketActions,

            ['Zauko'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Caskets') == bothDeposited then
                        return quest:progressEvent(263)
                    end

                    return quest:event(251)
                end,
            },

            onEventFinish =
            {
                [263] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        clearRun(player)
                        xi.abyssea.questReward(player, firstCruor, bodySeals)
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

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Coal_Casket'] = casketActions,

            ['Zauko'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Caskets') == bothDeposited then
                        return quest:progressEvent(263)
                    elseif quest:getMustZone(player) then
                        return quest:event(264)
                    end

                    return quest:progressEvent(265)
                end,
            },

            onEventFinish =
            {
                [263] = function(player, csid, option, npc)
                    clearRun(player)
                    xi.abyssea.questReward(player, repeatCruor, bodySeals)
                    xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.LET_THERE_BE_LIGHT)
                end,

                [265] = function(player, csid, option, npc)
                    clearRun(player)
                end,
            },
        },
    },
}

return quest
