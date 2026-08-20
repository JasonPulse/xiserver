-----------------------------------
-- Rose on the Heath
-----------------------------------
-- Log ID: 8, Quest ID: 12
-- Ayame  : Abyssea - Konschtat (I-13), entity 16839219
-- Argus  : Abyssea - Konschtat (D-7),  entity 16839225
-- Helga  : Abyssea - Konschtat (G-5),  entity 16839226
-- Rashid : Abyssea - Konschtat (F-10), entity 16839221
-- !addquest 8 12
-----------------------------------
-- Retail (bg-wiki "Rose on the Heath").
-- |Start=Ayame (A) (I-13), Abyssea - Konschtat
-- |Previous=Of Malnourished Martellos  |Reward=400 Cruor
--   1. Speak to Ayame (A) at (I-13). You receive Captain Rashid's, Captain
--      Argus's and Captain Helga's linkpearls, plus the Seal of the resistance.
--   2. Speak to Argus (A) at (D-7), Conflux #03 then north/east.
--   3. Speak to Helga (A) at (G-5), Conflux #05 then north through the Wivres.
--   4. Speak to Rashid (A) at (F-10), Conflux #02 then northwest.
--   5. Return to Ayame (A) to complete the quest.
--
-- CSIDS DECODED, NOT GUESSED, with csidscan.py against `xi-dat dialog 15`:
--   Ayame 231 -> 7876-7881  THE OFFER. 7877 "The linkshell that was our sole
--          line of communication to our field regiments suffered irreparable
--          damage", 7878 "You must seek out our lost squadrons and deliver
--          these linkpearls", 7879 "There are three regiments, all told", and
--          7881 hands over the seal and gives the quest its name: "Should
--          anyone ask you for the password, it is 'rose on the heath.'"
--   Ayame 233 -> 7922-7927  THE COMPLETION. "Thank the heavens you're safe!" /
--          7924 "this will have to suffice" -- the reward line.
--   Argus  238 -> 7884/7889/7897-7901  his handover.
--   Helga  241 -> 7884/7889/7909-7915  hers.
--   Rashid 235 -> 7883-7894            his.
-- All three captains share the two framing messages that make the handover
-- unmistakable: 7884 "A stray beam of light catches ${name-player}'s
-- ${keyitem-singular: 0[2]}, causing it to gleam for a moment" -- the seal --
-- and 7889 "You hand over ${keyitem-singular: 0[2]}" -- the linkpearl. 7885
-- confirms the password: "That seal... Hm? 'Rose on the heath', you say?"
--
-- PROGRESS is a three-bit mask in the quest var 'Captains', so the three may be
-- visited in any order. bg-wiki lists them Argus/Helga/Rashid but nothing in the
-- dialog enforces a sequence.
--
-- KEY ITEMS are all existing: CAPTAIN_RASHIDS_LINKPEARL (1575),
-- CAPTAIN_ARGUSS_LINKPEARL (1576), CAPTAIN_HELGAS_LINKPEARL (1577) and
-- SEAL_OF_THE_RESISTANCE (1578). Each captain takes only his or her own pearl.
--
-- CHAIN NOTE: Rashid's 235 closes on 7894 pointing at Julio ("an alchemist
-- who's taken refuge in our camp... Talk to him"), which is how retail hands
-- off to Full_of_Himself_Alchemist.lua. This quest is also the |Previous= for
-- Shady_Business_Redux.lua, so completing it opens both.
-----------------------------------
local konschtatID = zones[xi.zone.ABYSSEA_KONSCHTAT]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.ROSE_ON_THE_HEATH)

local cruorReward = 400

-- captain -> { bit, handover csid, linkpearl }
local captains =
{
    ['Argus']  = { bit = 0, csid = 238, pearl = xi.ki.CAPTAIN_ARGUSS_LINKPEARL  },
    ['Helga']  = { bit = 1, csid = 241, pearl = xi.ki.CAPTAIN_HELGAS_LINKPEARL  },
    ['Rashid'] = { bit = 2, csid = 235, pearl = xi.ki.CAPTAIN_RASHIDS_LINKPEARL },
}

local allDelivered = 0x07

local captainTrigger = function(player, npc)
    local entry = captains[npc:getName()]
    if entry == nil then
        return
    end

    if bit.band(quest:getVar(player, 'Captains'), bit.lshift(1, entry.bit)) ~= 0 then
        return
    end

    return quest:progressEvent(entry.csid, { [0] = entry.pearl })
end

local captainFinish = function(player, csid, option, npc)
    for _, entry in pairs(captains) do
        if entry.csid == csid then
            local mask = quest:getVar(player, 'Captains')
            quest:setVar(player, 'Captains', bit.bor(mask, bit.lshift(1, entry.bit)))
            player:delKeyItem(entry.pearl)
            return
        end
    end
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.OF_MALNOURISHED_MARTELLOS)
        end,

        [xi.zone.ABYSSEA_KONSCHTAT] =
        {
            ['Ayame'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(231, { [0] = xi.ki.SEAL_OF_THE_RESISTANCE })
                end,
            },

            onEventFinish =
            {
                [231] = function(player, csid, option, npc)
                    quest:begin(player)
                    quest:setVar(player, 'Captains', 0)
                    npcUtil.giveKeyItem(player,
                    {
                        xi.ki.SEAL_OF_THE_RESISTANCE,
                        xi.ki.CAPTAIN_RASHIDS_LINKPEARL,
                        xi.ki.CAPTAIN_ARGUSS_LINKPEARL,
                        xi.ki.CAPTAIN_HELGAS_LINKPEARL,
                    })
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_KONSCHTAT] =
        {
            ['Argus']  = { onTrigger = captainTrigger },
            ['Helga']  = { onTrigger = captainTrigger },
            ['Rashid'] = { onTrigger = captainTrigger },

            ['Ayame'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Captains') == allDelivered then
                        return quest:progressEvent(233)
                    end

                    return quest:event(232)
                end,
            },

            onEventFinish =
            {
                [238] = captainFinish,
                [241] = captainFinish,
                [235] = captainFinish,

                [233] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Captains', 0)
                        player:delKeyItem(xi.ki.SEAL_OF_THE_RESISTANCE)
                        player:addCurrency('cruor', cruorReward)
                        player:messageSpecial(konschtatID.text.CRUOR_OBTAINED, cruorReward, player:getCurrency('cruor'))
                    end
                end,
            },
        },
    },
}

return quest
