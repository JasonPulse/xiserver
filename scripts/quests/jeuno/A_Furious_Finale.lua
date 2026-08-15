-----------------------------------
-- A Furious Finale
-----------------------------------
-- Log ID: 3, Quest ID: 99
-- Laila : Upper Jeuno (G-7)
-----------------------------------
-- Retail (bg-wiki "A Furious Finale"): the DNC limit break. bg-wiki's Quest Reqs
-- field states only "Dancer level 66+", so no prior-quest gate is enforced here
-- -- an over-gate would make the limit break unreachable, which is worse than an
-- under-gate. (Comeback Queen is DNC AF3 and precedes it in practice, but it is
-- not listed as a requirement.) Laila sends you to earn a
-- Dnc. Testimony from Quadav in Grauberg (S) / North Gustaberg (S); show it to
-- her, then fight her in Qu'Bia Arena, winning at roughly 25% of her HP.
-- Rewards: level cap 75 and the title Dazzling Dance Diva.
--
-- CSIDs decoded, not guessed. Laila is entity 17776829 (sql/npc_list.sql:31052;
-- (17776829-16777216)//4096 = 244 rem 61 -> Upper Jeuno). The quest programs sit
-- on holder 0x010F40A1 (17776801, npc_list 'blank') beside Laila's group;
-- resolved with xidat/csidmsg.py and read against `xi-dat dialog 244`:
--   10160 -> 12118-12121, the offer. 12120 "If ye retrace yer steps, the
--            Divinity o' Dance may appear before ye an' present ye with
--            ${item-article: 0[2]}", 12121 "bring the ${item-singular: 0[2]}
--            back here an' show me." => param [0] is the Dnc. Testimony.
--   10162 -> 12122-12132, showing the testimony and being sent to the arena.
--            12124 "ye've earned the right t'undertake the test t'become Diva o'
--            the Dance Troupe", 12129 "We'll duke it out at Qu'Bia Arena. Ye
--            ready to go?", 12132 "When ye arrive, use yer
--            ${item-singular: 0[2]} t'enter the arena."
--   10161 / 10163 -> short reminder / "ready to go?" re-ask.
--   10164 -> 12134, the post-completion line.
--
-- Three bugs fixed beyond the CSIDs:
--   1. It fired 10123 and 10124. Those are ALFRIEDA's (17776833) and TURLOUGH's
--      (17776832) lines, not Laila's.
--   2. It was an accept+complete stub -- trading the testimony completed the
--      quest outright, skipping the entire Qu'Bia Arena fight.
--   3. The header claimed "Level cap handled server-side via quest-completion
--      check", but nothing raised it. Every other limit break in this repo calls
--      player:setLevelCap(75) explicitly, and so does this now. The title was
--      never granted either.
--
-- Note 12132: retail entry to the arena is by USING the testimony there, not by
-- Laila teleporting you -- so this quest must not setPos. The battlefield at
-- scripts/battlefields/QuBia_Arena/furious_finale.lua takes the testimony as its
-- requiredItems trade, which is the same mechanic the sibling
-- shattering_stars_* limit breaks use.
-----------------------------------
local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.A_FURIOUS_FINALE)

-- bg-wiki: Reward = "Raises level limit to 75", Title = "Dazzling Dance Diva",
-- Fame = Jeuno. The fame value is the pre-existing one in this file, not a
-- number I derived; bg-wiki does not state an amount.
quest.reward =
{
    fame     = 50,
    fameArea = xi.fameArea.JEUNO,
    title    = xi.title.DAZZLING_DANCE_DIVA,
}

quest.sections =
{
    -- Offer: Laila explains the Divinity o' Dance and the testimony.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getMainJob() == xi.job.DNC and
                player:getMainLvl() >= 66
        end,

        [xi.zone.UPPER_JEUNO] =
        {
            ['Laila'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10160, { [0] = xi.item.DANCERS_TESTIMONY })
                end,
            },

            onEventFinish =
            {
                [10160] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    -- Show the testimony; Laila sends you to Qu'Bia Arena. The battlefield is
    -- entered by trading the testimony there, so it is NOT consumed here.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.UPPER_JEUNO] =
        {
            ['Laila'] =
            {
                onTrigger = function(player, npc)
                    if player:hasItem(xi.item.DANCERS_TESTIMONY) then
                        return quest:progressEvent(10162, { [0] = xi.item.DANCERS_TESTIMONY })
                    end

                    return quest:event(10161, { [0] = xi.item.DANCERS_TESTIMONY })
                end,
            },
        },

        -- Win the fight; convert the transient battlefield localVar into quest
        -- progress before the player leaves Qu'Bia Arena, since a local var does
        -- not survive the zone change back to Jeuno. Same handshake as
        -- Moment_of_Truth.lua:162-166.
        [xi.zone.QUBIA_ARENA] =
        {
            onEventFinish =
            {
                [32001] = function(player, csid, option, npc)
                    if player:getLocalVar('battlefieldWin') == xi.battlefield.id.FURIOUS_FINALE then
                        quest:setVar(player, 'Prog', 1)
                    end
                end,
            },
        },
    },

    -- Laila congratulates the new Diva: level cap 75 and the title.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 1
        end,

        [xi.zone.UPPER_JEUNO] =
        {
            ['Laila'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10164)
                end,
            },

            onEventFinish =
            {
                [10164] = function(player, csid, option, npc)
                    -- Guarded on the current cap the way the other limit breaks
                    -- do, so this cannot lower an already-higher cap.
                    if player:getLevelCap() == 70 then
                        player:setLevelCap(75)
                    end

                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
