-----------------------------------
-- Tangling with Tongue-twisters
-----------------------------------
-- Log ID: 8, Quest ID: 29
-- Kupipi : Abyssea - Tahrongi (H-12), entity 16962090
-- !addquest 8 29
-----------------------------------
-- Retail (bg-wiki "Tangling with Tongue-twisters").
-- |Start=Kupipi (A) (H-12), Abyssea - Tahrongi  |Fame=atah |FLevel=5
-- |Previous=Cleansing the Canyon  |Repeatable=Yes
-- |Item Reqs=KI Bloodied arrow (first time only), KI Crimson bloodstone (subsequent)
-- |Reward=First time: Evolith with random augments. Subsequent: 500 Cruor.
--   1. Speak to Kupipi at (H-12).
--   2. "She will ask for you to defeat one of the 5 mentioned monsters: Cuelebre,
--      Adze, Minhocao, Chukwa, or Mictlantecuhtli."
--   3. "If you defeat one with the quest active, you will receive a KI Bloodied arrow
--      upon the first time completing the quest. If you are completing this quest a
--      second time or more, you will instead receive a KI Crimson bloodstone."
--   4. Return to Kupipi to complete the quest.
--
-- CSIDS DECODED, NOT GUESSED. Kupipi is 16962090 -> zone 45, and her block holds two
-- quests: 300/301/318-321 are Cleansing the Canyon (this quest's |Previous=, and
-- 7899 "clean this area up of all hostile-wostiles" is its brief), while 382-386 are
-- this one. Per-csid attribution from her entry table's byte ranges:
--   382 -> 8053-8056  THE OFFER. 8053 "if it isn't ${name-player}, the caulk that
--          keeps the survivors of Windurst together", 8055 is the menu and every one
--          of its three lines ACCEPTS ("Truly! / Totally! / Indubitably!"), which is
--          why no option is tested below. 8056 is the nudge for dithering.
--   383 -> 8059-8062/8072  the reminder, and it is where the target list lives: 8059
--          "Cuelebre, Adze, Minhocao, Chukwa, and...Mictli...Metlec...
--          Mictlantecuhtli!", 8061 "let's say that just ONE of them will suffice.
--          Bring back proof o[f it]".
--   384 -> 8063-8066  THE TURN-IN. 8063 "that's an arrow from the quiver of Semih
--          Lafihna. Wherever did you find it?" -- the Bloodied arrow -- followed by
--          her realising who is missing.
--   385 -> 8071  her post-completion line.
--   386 -> 8059-8062/8072  the repeat offer, the same target list re-read.
--
-- THE PROOF ITEM CHANGES ON REPEATS, which is the only thing separating the two runs:
-- bg-wiki gives Bloodied arrow for the first completion and Crimson bloodstone
-- thereafter, and 8063's reaction is specifically to the arrow. So the kill grants
-- whichever the player is owed.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.TANGLING_WITH_TONGUE_TWISTERS)

-- bg-wiki's five, all in Abyssea - Tahrongi.
local targets =
{
    'Cuelebre',
    'Adze',
    'Minhocao',
    'Chukwa',
    'Mictlantecuhtli',
}

local repeatCruor = 500

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_TAHRONGI,
}

--- Whichever proof the player is owed for this run.
local proofItem = function(player)
    if player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.TANGLING_WITH_TONGUE_TWISTERS) then
        return xi.ki.CRIMSON_BLOODSTONE
    end

    return xi.ki.BLOODIED_ARROW
end

local hasProof = function(player)
    return player:hasKeyItem(xi.ki.BLOODIED_ARROW) or
        player:hasKeyItem(xi.ki.CRIMSON_BLOODSTONE)
end

local clearProof = function(player)
    player:delKeyItem(xi.ki.BLOODIED_ARROW)
    player:delKeyItem(xi.ki.CRIMSON_BLOODSTONE)
end

--- One handler per named NM, built from the list so the five stay in step.
local killHandlers = function()
    local handlers = {}

    for _, name in ipairs(targets) do
        handlers[name] =
        {
            onMobDeath = function(mob, player, optParams)
                if not hasProof(player) then
                    npcUtil.giveKeyItem(player, proofItem(player))
                end
            end,
        }
    end

    return handlers
end

local acceptedZone = killHandlers()

acceptedZone['Kupipi'] =
{
    onTrigger = function(player, npc)
        if hasProof(player) then
            return quest:progressEvent(384)
        end

        return quest:event(383)
    end,
}

acceptedZone.onEventFinish =
{
    [384] = function(player, csid, option, npc)
        -- The repeat path has already completed once, so complete() only fires the
        -- first time; both paths clear the proof and pay out.
        local firstTime = not player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.TANGLING_WITH_TONGUE_TWISTERS)

        clearProof(player)

        if firstTime then
            if quest:complete(player) then
                npcUtil.giveItem(player, xi.item.EVOLITH)
            end

            return
        end

        xi.abyssea.questReward(player, repeatCruor, nil)
    end,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.CLEANSING_THE_CANYON) and
                player:getFameLevel(xi.fameArea.ABYSSEA_TAHRONGI) >= 5
        end,

        [xi.zone.ABYSSEA_TAHRONGI] =
        {
            ['Kupipi'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(382)
                end,
            },

            onEventFinish =
            {
                [382] = function(player, csid, option, npc)
                    -- 8055's three lines are all affirmative, so there is nothing to
                    -- test here.
                    quest:begin(player)
                    clearProof(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_TAHRONGI] = acceptedZone,
    },

    -- Repeatable: she re-reads the same target list from 386.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_TAHRONGI] =
        {
            ['Kupipi'] =
            {
                onTrigger = function(player, npc)
                    if hasProof(player) then
                        return quest:progressEvent(384)
                    end

                    return quest:progressEvent(386)
                end,
            },

            onEventFinish =
            {
                [384] = function(player, csid, option, npc)
                    clearProof(player)
                    xi.abyssea.questReward(player, repeatCruor, nil)
                end,

                [386] = function(player, csid, option, npc)
                    clearProof(player)
                end,
            },
        },
    },
}

return quest
