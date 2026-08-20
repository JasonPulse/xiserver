-----------------------------------
-- I Dream of Flowers
-----------------------------------
-- Log ID: 8, Quest ID: 49
-- Goraow       : Abyssea - Misareaux (G-5), entity 17662729
-- Grassy_Mound : Abyssea - Misareaux (K-12), entity 17662730
-- !addquest 8 49
-----------------------------------
-- Retail (bg-wiki "I Dream of Flowers").
-- |Start=Goraow (A), Abyssea - Misareaux  |Item Reqs=Lilac  |Reward=800 Cruor
--   1. Speak to Goraow (A) at (G-5), northeast of Conflux #5.
--   2. Trade Goraow a Lilac.
--   3. Examine the Grassy Mound at (K-12), near Conflux #8.
--   4. Trade the Lilac to the Grassy Mound.
--   5. Speak to Goraow (A) to complete the quest.
--
-- CSIDS DECODED, NOT GUESSED, AND THE HOLDER MATTERED HERE. Goraow is 17662729
-- (zone 216 idx 777) and the Grassy Mound 17662730 (idx 778), but every one of
-- their programs is a 1-byte stub -- the real bytecode all lives on holder
-- 17662724 (0x010D8304). csidmsg.py and csidscan.py both return nothing when
-- pointed at the visible NPCs; scanning the HOLDER is what resolves them:
--   Goraow 168 -> 8193-8198  the approach. 8197 "Tending the graves of fallen
--          comrades is about all I'm good for", 8198 "If only I could get my
--          hands on some flowers..." -- which is the request.
--   Goraow 178 -> 8197/8198  the same wish, shortened: the active reminder.
--   Goraow 173 -> 8199-8201  SHOWING HIM THE LILAC. 8199 "Why, if it isn't
--          ${article} ${item-article: 1[2]}! To think that there're still some
--          to be had!", 8200 "could I ask you to offer it at the burial ground?",
--          8201 "Head south by east of here and you'll find it." The flower is
--          param 1.
--   Goraow 174 -> 8200/8201  the reminder once he has asked: go and offer it.
--   Mound  169 -> 8202       "This grassy mound appears to serve as a makeshift
--          grave." -- examining it with nothing to offer.
--   Mound  172 -> 8202-8204  THE OFFERING. 8203 "Offer the ${item-singular:
--          1[2]}? ${selection-lines} Yes. / No." -- Yes is the FIRST line, so
--          OPTION 0 OFFERS. 8204 "${name-player} places the ${item} upon the
--          grave."
--   Mound  175 -> 8205       the mound once a flower is already on it.
--   Goraow 179 -> 8206-8208  THE COMPLETION. "You have my gratitude. It would've
--          been nice to offer the flower myself, but it wasn't mine to give."
--   Goraow 180 -> 8209/8210  his post-completion lines.
--
-- WHY GORAOW DOES NOT CONSUME THE LILAC. bg-wiki has you trade it to him AND
-- then trade it to the mound, and 8200 makes the reason explicit -- he asks you
-- to offer it on his behalf, he never takes it ("it wasn't mine to give", 8206).
-- So csid 173 deliberately omits confirmTrade, which returns the flower to the
-- player; only the mound consumes it.
--
-- ITEM: Lilac is the existing LILAC (956).
-- CRUOR: bg-wiki |Reward=800 Cruor, paid by Goraow on completion.
-----------------------------------
local misareauxID = zones[xi.zone.ABYSSEA_MISAREAUX]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.I_DREAM_OF_FLOWERS)

local cruorReward = 800

quest.sections =
{
    -- bg-wiki lists no |Previous= and no |Quest Reqs=.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['Goraow'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(168, { [1] = xi.item.LILAC })
                end,
            },

            onEventFinish =
            {
                [168] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    -- Accepted, flower not yet shown to him.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 0
        end,

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['Goraow'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.LILAC) then
                        return quest:progressEvent(173, { [1] = xi.item.LILAC })
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(178, { [1] = xi.item.LILAC })
                end,
            },

            ['Grassy_Mound'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(169)
                end,
            },

            onEventFinish =
            {
                [173] = function(player, csid, option, npc)
                    -- No confirmTrade: he asks you to lay it on the grave
                    -- yourself, so the flower goes back to the player.
                    quest:setVar(player, 'Prog', 1)
                end,
            },
        },
    },

    -- He has asked: lay the flower on the grave, then report back.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 1
        end,

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['Grassy_Mound'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.LILAC) then
                        return quest:progressEvent(172, { [1] = xi.item.LILAC })
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(169)
                end,
            },

            ['Goraow'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(174, { [1] = xi.item.LILAC })
                end,
            },

            onEventFinish =
            {
                [172] = function(player, csid, option, npc)
                    -- 8203: 0 "Yes.", 1 "No."
                    if option ~= 0 then
                        return
                    end

                    player:confirmTrade()
                    quest:setVar(player, 'Prog', 2)
                end,
            },
        },
    },

    -- Flower laid: back to Goraow.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 2
        end,

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['Goraow'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(179, { [1] = xi.item.LILAC })
                end,
            },

            ['Grassy_Mound'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(175, { [1] = xi.item.LILAC })
                end,
            },

            onEventFinish =
            {
                [179] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Prog', 0)

                        -- Destiny Odyssey's first walkthrough line is "Zone
                        -- after completing the previous quest", and this is
                        -- that previous quest.
                        xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.DESTINY_ODYSSEY)

                        player:addCurrency('cruor', cruorReward)
                        player:messageSpecial(misareauxID.text.CRUOR_OBTAINED, cruorReward, player:getCurrency('cruor'))
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['Goraow']       = quest:event(180):replaceDefault(),
            ['Grassy_Mound'] = quest:event(175, { [1] = xi.item.LILAC }):replaceDefault(),
        },
    },
}

return quest
