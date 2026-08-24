-----------------------------------
-- Sisters in Crime
-----------------------------------
-- Log ID: 8, Quest ID: 27
-- Bopa_Greso  : Abyssea - Tahrongi (I-10), entity 16962115
-- Cha_Lebagta : Abyssea - Tahrongi (I-10), entity 16962116
-- Signpost    : Abyssea - Tahrongi, entities 16962121 .. 16962124
-- !addquest 8 27
-----------------------------------
-- Retail (bg-wiki "Sisters in Crime").
-- |Start=Cha Lebagta (A) and Bopa Greso (A) (I-10), Abyssea - Tahrongi
-- |Fame=atah |FLevel=4 |Repeatable=Yes
-- |Reward=First time: Water Spider's Web x2. Subsequent: 400 Cruor.
--   1. "Speak with Bopa Greso (A) at (I-10), southeast of Conflux #02."
--   2. "Go around to the four Signboard targetable locations and put up the KI
--      Hastily scrawled posters provided to you. They're along the path at:
--      (G-7), (H-6), (H-9), (I-8)."
--   3. "Return to Bopa Greso (A) to complete the quest."
--   "Zoning is required to repeat this quest."
--
-- CSIDS DECODED, NOT GUESSED. Per-csid attribution from each entity's byte ranges:
--   Bopa_Greso 366 -> 7997/7998  her idle grumbling about the mercenary captain.
--   Bopa_Greso 367 -> 8000-8002  THE OFFER. 8001 is the two-way menu ("You're
--          rrright." / "Dead wrrrong."), 8002 the brush-off for declining.
--   Bopa_Greso 368 -> 8011  the reminder, and it is where the count comes from:
--          "you'll find FOUR signposts scattered through the canyon. Slap one of
--          these on each of 'em, and rrreport to us when the job is done."
--   Bopa_Greso 369 -> 8017/8018  THE TURN-IN. "You did good, kid. It's only a matter
--          of time before we're rrreunited with the boss now."
--   Bopa_Greso 370 -> 8017  the same line on its own, her post-completion state.
--   Bopa_Greso 371 -> 8008/8011/8019/8020  the repeat offer, "You there! It's about
--          time you showed up!"
--   Cha_Lebagta carries 367/369/371 as ONE-BYTE stubs, i.e. the pair share the
--   conversation and either sister can be spoken to; her own 372-375 are her
--   side-chatter and are not part of this flow.
--
-- THE SIGNPOSTS HAVE NO EVENT PROGRAMS. csidmsg.load returns nothing for
-- 16962121-16962124, so putting a poster up is a plain key-item consumption with the
-- standard message rather than a cutscene, the same shape the event-less Supply
-- Points in Attohwa use. npc_list names them Signpost; bg-wiki calls them Signboard.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.SISTERS_IN_CRIME)

-- Signpost entity -> bit. npc_list order, matching bg-wiki's (G-7), (H-6), (H-9),
-- (I-8).
local signposts =
{
    [16962121] = 0,
    [16962122] = 1,
    [16962123] = 2,
    [16962124] = 3,
}

local allPosted   = 0x0F -- four bits
local posterCount = 4

local repeatCruor = 400

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_TAHRONGI,
}

local clearRun = function(player)
    quest:setVar(player, 'Posts', 0)
    player:delKeyItem(xi.ki.HASTILY_SCRAWLED_POSTER)
end

--- Posting a bill. Shared by the first run and the repeat.
local signpostActions =
{
    onTrigger = function(player, npc)
        local bit1 = signposts[npc:getID()]

        if bit1 == nil or not player:hasKeyItem(xi.ki.HASTILY_SCRAWLED_POSTER) then
            return
        end

        local mask = quest:getVar(player, 'Posts')

        if bit.band(mask, bit.lshift(1, bit1)) ~= 0 then
            return
        end

        mask = bit.bor(mask, bit.lshift(1, bit1))
        quest:setVar(player, 'Posts', mask)

        -- The posters are one key item covering the whole batch, so it is only
        -- surrendered once the last signpost is done.
        if mask == allPosted then
            player:delKeyItem(xi.ki.HASTILY_SCRAWLED_POSTER)
        end

        return true
    end,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ABYSSEA_TAHRONGI) >= 4
        end,

        [xi.zone.ABYSSEA_TAHRONGI] =
        {
            ['Bopa_Greso'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(367, posterCount)
                end,
            },

            onEventFinish =
            {
                [367] = function(player, csid, option, npc)
                    -- 8002 is "Dead wrrrong", the decline.
                    if option ~= 0 then
                        return
                    end

                    quest:begin(player)
                    clearRun(player)
                    npcUtil.giveKeyItem(player, xi.ki.HASTILY_SCRAWLED_POSTER)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_TAHRONGI] =
        {
            ['Signpost'] = signpostActions,

            ['Bopa_Greso'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Posts') == allPosted then
                        return quest:progressEvent(369)
                    end

                    return quest:event(368, posterCount)
                end,
            },

            onEventFinish =
            {
                [369] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        clearRun(player)
                        npcUtil.giveItem(player, { { xi.item.WATER_SPIDERS_WEB, 2 } })
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

        [xi.zone.ABYSSEA_TAHRONGI] =
        {
            ['Signpost'] = signpostActions,

            ['Bopa_Greso'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Posts') == allPosted then
                        return quest:progressEvent(369)
                    elseif player:hasKeyItem(xi.ki.HASTILY_SCRAWLED_POSTER) then
                        return quest:event(368, posterCount)
                    elseif quest:getMustZone(player) then
                        return quest:event(370)
                    end

                    return quest:progressEvent(371, posterCount)
                end,
            },

            onEventFinish =
            {
                [369] = function(player, csid, option, npc)
                    clearRun(player)
                    xi.abyssea.questReward(player, repeatCruor, nil)
                    xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.SISTERS_IN_CRIME)
                end,

                [371] = function(player, csid, option, npc)
                    if option ~= 0 then
                        return
                    end

                    clearRun(player)
                    npcUtil.giveKeyItem(player, xi.ki.HASTILY_SCRAWLED_POSTER)
                end,
            },
        },
    },
}

return quest
