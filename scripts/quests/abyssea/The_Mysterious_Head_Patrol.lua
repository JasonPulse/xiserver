-----------------------------------
-- The Mysterious Head Patrol
-----------------------------------
-- Log ID: 8, Quest ID: 64
-- Eight_of_Hearts : Abyssea - Grauberg (H-13), entity 17818227
-- Eight_of_Clubs  : Abyssea - Grauberg (H-8),  entity 17818229
-- !addquest 8 64
-----------------------------------
-- Retail (bg-wiki "The Mysterious Head Patrol").
-- |Start=Eight of Hearts (A) (H-13), Abyssea - Grauberg
-- |Item Reqs=Silver pocket watch  |Reward=400 Cruor
--   1. Speak to Eight of Hearts (A) at (H-13), southwest of Conflux #2.
--   2. He requests a Silver pocket watch. Obtain it from Eight of Clubs (A) at
--      (H-8), a short walk from Conflux #5.
--   3. Return to Eight of Hearts (A) to complete this quest.
--
-- CSIDS DECODED, NOT GUESSED, via csidmsg.load() on both blocks and find_msg
-- against `xi-dat dialog 254`:
--   Eight_of_Hearts (entries {202:1, 203:94, 204:132, 205:499, 217:541, 218:542},
--   data[] holding 1711 at index 8):
--     202 -> 7965-7968  THE OFFER, and the quest's whole premise: 7966 "But
--            THeRe iS sOMeoNE wHo SomETimes Pa-TRoLs My HEad", 7967 "A NameLEss
--            pERsoN SmaLL iN stAtuRE aND clothed in YeLLoW", 7968 "PoSSeSSing
--            ${keyitem-article: 0[2]}... thiS pERsoN's IdeNTity I caNNoT sEEm To
--            deCiPHer." The watch is param 0. There is no ${selection-lines}
--            anywhere in the block, so there is no accept option to test.
--     203 -> 7969/7970  the reminder, the same description condensed.
--     204 -> 7979-7990  THE RESOLUTION. 7979 "tHAt ${keyitem-singular: 0[2]} iS
--            famiLiAR to ME!", 7981 "A cArDian LikE Me, yOU Say?", 7983 "I
--            shouLD LikE to mEEt tHis indi-VIDual."
--     205 -> 7991       his post-completion line.
--   Eight_of_Clubs (entries {209:1, 210:30, 211:77, 212:106, 213:161, 214:190,
--   215:449, 222:478, 223:554}):
--     210 -> 7974-7977  handing over the watch.
--     211 -> 7978       his line once it has been handed over.
--     209 -> 7973       his idle line before this quest.
--   His 214/215 belong to Master Missing, Master Missed and his 222/223 to
--   The_Perils_of_Kororo.lua -- three quests share this Cardian, which is why the
--   entry-offset table matters more than the message ranges here.
--
-- ITEM: bg-wiki's "Silver pocket watch" is a KEY item -- xi.ki.
-- SILVER_POCKET_WATCH (1711), and it is exactly the id sitting at data[8] of
-- Eight of Hearts' block, which is what confirms param 0 is the watch. Note the
-- adjacent ELEGANT_GEMSTONE (1712) belongs to Master Missing, Master Missed.
--
-- WHY THERE IS NO onTrade: the watch is a key item, so it cannot be traded. It
-- is granted by Eight of Clubs and the turn-in fires on possession.
--
-- CHAIN: this is the head of the Grauberg Cardian chain -- this quest, then
-- Master Missing, Master Missed (65), then The_Perils_of_Kororo.lua (66).
-----------------------------------
local graubergID = zones[xi.zone.ABYSSEA_GRAUBERG]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.THE_MYSTERIOUS_HEAD_PATROL)

local cruorReward = 400

quest.sections =
{
    -- bg-wiki lists no |Previous= and no |Quest Reqs= for this one.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.ABYSSEA_GRAUBERG] =
        {
            ['Eight_of_Hearts'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(202, { [0] = xi.ki.SILVER_POCKET_WATCH })
                end,
            },

            ['Eight_of_Clubs'] = quest:event(209),

            onEventFinish =
            {
                [202] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    -- Accepted: get the watch from Eight of Clubs.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_GRAUBERG] =
        {
            ['Eight_of_Clubs'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.SILVER_POCKET_WATCH) then
                        return quest:event(211, { [0] = xi.ki.SILVER_POCKET_WATCH })
                    end

                    return quest:progressEvent(210, { [0] = xi.ki.SILVER_POCKET_WATCH })
                end,
            },

            ['Eight_of_Hearts'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.SILVER_POCKET_WATCH) then
                        return quest:progressEvent(204, { [0] = xi.ki.SILVER_POCKET_WATCH })
                    end

                    return quest:event(203, { [0] = xi.ki.SILVER_POCKET_WATCH })
                end,
            },

            onEventFinish =
            {
                [210] = function(player, csid, option, npc)
                    npcUtil.giveKeyItem(player, xi.ki.SILVER_POCKET_WATCH)
                end,

                [204] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.SILVER_POCKET_WATCH)
                        player:addCurrency('cruor', cruorReward)
                        player:messageSpecial(graubergID.text.CRUOR_OBTAINED, cruorReward, player:getCurrency('cruor'))
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_GRAUBERG] =
        {
            ['Eight_of_Hearts'] = quest:event(205):replaceDefault(),
        },
    },
}

return quest
