-----------------------------------
-- Proof of the Lion
-----------------------------------
-- Log ID: 8, Quest ID: 85
-- Excenmille : Abyssea - Altepa (G-11), entity 17670762
-- !addquest 8 85
-----------------------------------
-- Retail (bg-wiki "Proof of the Lion").
-- |Start=Excenmille (A), Abyssea - Altepa  |Repeatable=Yes  |Fame=aalt  |FLevel=1
-- |Item Reqs=Waugyl's claw
-- |Reward=600 Cruor for first-time completion, 300 thereafter
--   1. Talk to Excenmille (A) at (G-11) to begin this quest, east of Conflux #5.
--   2. Obtain Puppet's Blood from Desert Puks just to the north.
--   3. Use the blood to pop Waugyl at (F-9).
--   4. "Defeat Waugyl, then everyone with the quest active will receive the
--      Waugyl's claw."
--   5. Return and speak to Excenmille (A) to collect your reward.
--   "Zoning is required to repeat this quest."
--
-- CSIDS DECODED, NOT GUESSED. Excenmille is 17670762 -> zone 218 idx 618
-- (0x010DA26A). `xi-dat events 218` gives him 302-308 and 352; csidscan.py against
-- `xi-dat dialog 218` splits them, and 352 (8315-8325) belongs to another quest he
-- carries. This quest has a full first-run and a separate repeat-run script:
--   302 -> 8191-8198  THE FIRST OFFER. 8194 is the accept prompt: "Ready to do
--          battle? ${selection-lines} I am. / More or less...?" -- the affirmative
--          is the FIRST line, so OPTION 0 ACCEPTS, and 8195 is the decline
--          ("Best run back behind the ward with the tots and greybeards"). 8197
--          "A hideous beast called the waugyl prowls the northern reaches" and
--          8198 "You are to slay him and bring back proof of your deed."
--   303 -> 8197/8198  the reminder, the task without the challenge.
--   304 -> 8199-8203  THE FIRST TURN-IN. 8202 "Excenmille M Aurchiat raises a toast
--          to your honor and courage", 8203 "I would present you with this as well."
--   305 -> 8204/8205  his post-completion lines about protecting the weak.
--   306 -> 8206-8214  THE REPEAT OFFER. 8210 "the fearsome waugyl is terrorizing the
--          northern reaches once more" and 8212 "Slay the beast? ${selection-lines}
--          I will. / Another day." -- again the affirmative is FIRST, so option 0
--          accepts, with 8213 as the decline.
--   307 -> 8214/8215  the repeat reminder.
--   308 -> 8216/8217  THE REPEAT TURN-IN. 8217 "Return here if you wish to test your
--          sword arm again."
--
-- WHY TWO OFFER/TURN-IN PAIRS RATHER THAN ONE PLUS A FLAG: the repeat script is not
-- a shortened version of the first, it is a different conversation -- he learns your
-- name in 8199-8202 and greets you by it from 8206 onward. So first-run and repeat
-- fire different csids rather than reusing 302/304 with a param.
--
-- ITEM: Puppet's Blood is the container-word trap -- item_basic holds it as
-- `vial_of_puppets_blood` and the existing enum is VIAL_OF_PUPPETS_BLOOD (3239).
-- KEY ITEM: Waugyl's claw is the existing WAUGYLS_CLAW (1764).
--
-- THE POP IS THE ITEM'S JOB, NOT THIS QUEST'S. bg-wiki has you trade the blood at
-- Waugyl's own pop point, which is mob 17670576's spawn -- shared with anyone
-- hunting him outside the quest. This script therefore only credits the claw on his
-- death, and leaves spawning to the pop item, so a Waugyl killed by someone else
-- still counts for anyone holding the quest, which is what bg-wiki's "everyone with
-- the quest active will receive the Waugyl's claw" describes.
-----------------------------------
local altepaID = zones[xi.zone.ABYSSEA_ALTEPA]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.PROOF_OF_THE_LION)

local firstCruor  = 600
local repeatCruor = 300

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_ALTEPA,
}

quest.sections =
{
    -- COMPLETED is accepted because |Repeatable=Yes, and bg-wiki requires a zone in
    -- between. 306 is the repeat offer.
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE or
                    status == xi.questStatus.QUEST_COMPLETED) and
                not quest:getMustZone(player)
        end,

        [xi.zone.ABYSSEA_ALTEPA] =
        {
            ['Excenmille'] =
            {
                onTrigger = function(player, npc)
                    if player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.PROOF_OF_THE_LION) then
                        return quest:progressEvent(306)
                    end

                    return quest:progressEvent(302)
                end,
            },

            onEventFinish =
            {
                [302] = function(player, csid, option, npc)
                    -- 8194: 0 "I am.", 1 "More or less...?"
                    if option ~= 0 then
                        return
                    end

                    quest:begin(player)
                end,

                [306] = function(player, csid, option, npc)
                    -- 8212: 0 "I will.", 1 "Another day."
                    if option ~= 0 then
                        return
                    end

                    player:addQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.PROOF_OF_THE_LION)
                end,
            },
        },
    },

    -- Accepted: Waugyl dies, the claw comes back here.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_ALTEPA] =
        {
            ['Waugyl'] =
            {
                onMobDeath = function(mob, player, optParams)
                    if player == nil then
                        return
                    end

                    -- bg-wiki: everyone with the quest active is credited, not just
                    -- the killer, so isKiller is deliberately not tested here.
                    if not player:hasKeyItem(xi.ki.WAUGYLS_CLAW) then
                        npcUtil.giveKeyItem(player, xi.ki.WAUGYLS_CLAW)
                    end
                end,
            },

            ['Excenmille'] =
            {
                onTrigger = function(player, npc)
                    if not player:hasKeyItem(xi.ki.WAUGYLS_CLAW) then
                        if player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.PROOF_OF_THE_LION) then
                            return quest:event(307)
                        end

                        return quest:event(303)
                    end

                    if player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.PROOF_OF_THE_LION) then
                        return quest:progressEvent(308)
                    end

                    return quest:progressEvent(304)
                end,
            },

            onEventFinish =
            {
                [304] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.WAUGYLS_CLAW)

                    if quest:complete(player) then
                        player:addCurrency('cruor', firstCruor)
                        player:messageSpecial(altepaID.text.CRUOR_OBTAINED, firstCruor, player:getCurrency('cruor'))
                        xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.PROOF_OF_THE_LION)
                    end
                end,

                [308] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.WAUGYLS_CLAW)

                    if quest:complete(player) then
                        player:addCurrency('cruor', repeatCruor)
                        player:messageSpecial(altepaID.text.CRUOR_OBTAINED, repeatCruor, player:getCurrency('cruor'))
                        xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.PROOF_OF_THE_LION)
                    end
                end,
            },
        },
    },

    -- Completed: 8204/8205, on the duty of protecting the weak.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_ALTEPA] =
        {
            ['Excenmille'] = quest:event(305):replaceDefault(),
        },
    },
}

return quest
