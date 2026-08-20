-----------------------------------
-- For Love of a Daughter
-----------------------------------
-- Log ID: 8, Quest ID: 26
-- Baha_Mannohl   : Abyssea - Tahrongi (H-4), entity 16962110
-- Tahrongi_Cacti : Abyssea - Tahrongi (F-6), entity 16962120
-- !addquest 8 26
-----------------------------------
-- Retail (bg-wiki "For Love of a Daughter").
-- |Start=Baha Mannohl (A) (H-4), Abyssea - Tahrongi  |Repeatable=Yes
-- |Item Reqs=Cup of Tahrongi cactus water
-- |Reward=First five completions: 300 Cruor each. Sixth attempt: Viridian
--         abyssite of lenity, and the quest can no longer be taken.
--   1. Speak to Baha Mannohl (A) at (H-4) by Veridical Conflux #05.
--   2. Walk into the Caoineag and find the targetable Tahrongi Cacti at (F-6).
--      It must be clicked between 20:00 and 4:00 game time for a Cup of
--      Tahrongi cactus water.
--   3. Return to Baha Mannohl (A) to complete the quest.
--
-- CSIDS DECODED, NOT GUESSED, via csidmsg.load() on Baha_Mannohl's block --
-- entries {356:1, 357:14, 358:87, 359:147, 360:178, 361:191, 362:256, 363:269,
-- 364:300, 365:313}, data[] = [7983, 7984, 7985, 7986, 50, 7987, 7988, 7989,
-- 201, 0, 7990, 7991, 7992, 7993, 5, 7994]:
--   356 -> 7983       his pre-quest despair: "Whatever shall I do...?"
--   357 -> 7984-7988  THE OFFER. 7985 "It's my daughter... She's come down with
--          a terrrible sickness", and 7987 is the actual task: "They say there's
--          a cactus that yields water only after sundown. Water that can cure
--          the rarest of ill[nesses]" -- which is where the night-time window
--          below comes from.
--   358 -> 7987/7988  the reminder, the cactus line without the preamble.
--   359 -> 7989       THE TURN-IN. "Oh, frrriend, you have no idea how much
--          this means to me! I can only hope this helps her..."
--   361 -> 7990-7992  THE REPEAT OFFER. 7991 "The fever subsided for a time, but
--          is back now worse than ever", 7992 "you must brrring us more cactus
--          water!" -- which is why this is repeatable rather than one-shot.
--
-- THE CACTUS IS SCRIPTLESS. `xi-dat events 45` lists no csids at all for
-- Tahrongi_Cacti (16962120) -- csidmsg.load() cannot even find a block for it --
-- so clicking it is a plain server-side grant, the same shape as the Gasponia in
-- Something_in_the_Air.lua and the Fragmented Nutshell in Savory_Salvation.lua.
--
-- THE NIGHT WINDOW is 20:00-4:00, which wraps midnight. Written as `>= 20 or
-- < 4` deliberately: the `>= 20 and < 4` form is never true and is a bug this
-- repo has already shipped four times (see QUEST_BACKLOG.md, live-bug class 5).
--
-- THE SIXTH ATTEMPT is a hard stop, not another repeat: bg-wiki says the sixth
-- awards the Viridian abyssite of lenity "and you will not be al[lowed]" to take
-- it again. Completion count is tracked in the quest var 'Runs'.
--
-- KEY ITEMS: CUP_OF_TAHRONGI_CACTUS_WATER (1595) and
-- VIRIDIAN_ABYSSITE_OF_LENITY (1414), both already defined.
-----------------------------------
local tahrongiID = zones[xi.zone.ABYSSEA_TAHRONGI]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.FOR_LOVE_OF_A_DAUGHTER)

local cruorReward  = 300
local paidRuns     = 5 -- completions that pay cruor; the sixth ends the quest

quest.sections =
{
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE or
                    status == xi.questStatus.QUEST_COMPLETED) and
                vars.Runs <= paidRuns
        end,

        [xi.zone.ABYSSEA_TAHRONGI] =
        {
            ['Baha_Mannohl'] =
            {
                onTrigger = function(player, npc)
                    if player:getQuestStatus(xi.questLog.ABYSSEA, xi.quest.id.abyssea.FOR_LOVE_OF_A_DAUGHTER) == xi.questStatus.QUEST_COMPLETED then
                        return quest:progressEvent(361, { [0] = xi.ki.CUP_OF_TAHRONGI_CACTUS_WATER })
                    end

                    return quest:progressEvent(357, { [0] = xi.ki.CUP_OF_TAHRONGI_CACTUS_WATER })
                end,
            },

            onEventFinish =
            {
                [357] = function(player, csid, option, npc)
                    quest:begin(player)
                end,

                [361] = function(player, csid, option, npc)
                    player:addQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.FOR_LOVE_OF_A_DAUGHTER)
                end,
            },
        },
    },

    -- Accepted: the cactus only yields between 20:00 and 4:00.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_TAHRONGI] =
        {
            ['Tahrongi_Cacti'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.CUP_OF_TAHRONGI_CACTUS_WATER) then
                        return
                    end

                    -- bg-wiki: "between 20:00 and 4:00 game time". Wrapping
                    -- window, so `or` -- never `and`.
                    if VanadielHour() >= 20 or VanadielHour() < 4 then
                        npcUtil.giveKeyItem(player, xi.ki.CUP_OF_TAHRONGI_CACTUS_WATER)
                    end
                end,
            },

            ['Baha_Mannohl'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.CUP_OF_TAHRONGI_CACTUS_WATER) then
                        return quest:progressEvent(359, { [0] = xi.ki.CUP_OF_TAHRONGI_CACTUS_WATER })
                    end

                    return quest:event(358, { [0] = xi.ki.CUP_OF_TAHRONGI_CACTUS_WATER })
                end,
            },

            onEventFinish =
            {
                [359] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.CUP_OF_TAHRONGI_CACTUS_WATER)

                    if not quest:complete(player) then
                        return
                    end

                    local runs = quest:getVar(player, 'Runs') + 1
                    quest:setVar(player, 'Runs', runs)

                    if runs > paidRuns then
                        -- Sixth turn-in: the abyssite instead of cruor, and the
                        -- section check above stops offering it from here on.
                        npcUtil.giveKeyItem(player, xi.ki.VIRIDIAN_ABYSSITE_OF_LENITY)
                    else
                        player:addCurrency('cruor', cruorReward)
                        player:messageSpecial(tahrongiID.text.CRUOR_OBTAINED, cruorReward, player:getCurrency('cruor'))
                    end
                end,
            },
        },
    },
}

return quest
