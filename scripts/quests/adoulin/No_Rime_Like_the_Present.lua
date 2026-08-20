-----------------------------------
-- No Rime Like the Present
-----------------------------------
-- Log ID: 9, Quest ID: 16
-- Hegnor : Morimar Basalt Fields (K-10), entity 17863411
-- qm     : Morimar Basalt Fields (K-7/8), entity 17863412
-- !addquest 9 16
-----------------------------------
-- Retail (bg-wiki "No Rime Like the Present").
-- |Start=Hegnor, Morimar Basalt Fields - (K-10)  |Previous=None  |Repeatable=No
-- |Fame=Adoulin  |FLevel=1  |Quest Reqs=Rime ice fragment
-- |Reward=3000 Experience Points
--   1. Speak with Hegnor (K-10) Frontier Station to initiate this quest.
--   2. Travel to K-7/8 in Morimar Basalt Fields (near Bivouac #1) and wait until
--      ice/snow/blizzard weather appears. "Check with Inthius for weather
--      forecasting."
--   3. "Once ice appears, examine the ??? on one of the trees near there to
--      obtain a Rime ice fragment."
--   4. Return to Hegnor and hand over the Rime ice fragment for your reward.
--
-- CSIDS DECODED, NOT GUESSED -- AND THE DUMP'S ZONE LABELS ARE OFF BY ONE HERE.
-- Hegnor is 17863411 -> zone 265 idx 755 (0x011092F3), the ??? 17863412 -> idx 756
-- (0x011092F4). `xi-dat events 265` gives Hegnor 2500, 2501, 2502, 2504 and the
-- ??? exactly one csid, 2503. The dumped dialog file labelled zone N holds zone
-- N-1's text for the Adoulin zones, so Morimar's text is in the file labelled 266;
-- the offset is pinned by this repo's own known-correct id
-- (Morimar_Basalt_Fields/IDs.lua WAYPOINT_ATTUNED = 7606 resolves in dump 266).
-- Read against 266:
--   2500 -> 7499-7502  THE OFFER. 7500 "The Scouts' Coalition sent me out here for
--          a land survey, but the wind chills me to the bone", 7501 "I need to
--          study rime ice samples, but I can barely move. Can you go get some for
--          me?", and 7502 "Rime ice can only be found when it's snowing outside."
--          No ${selection-lines}, so speaking to him starts it.
--   2501 -> 7502       the reminder: it only forms while it is snowing.
--   2502 -> 7503-7506  THE TURN-IN. "Hoho, some rime ice, I see." through the
--          sulfur discovery to 7506 "I'll have to bring this back to the coalition
--          for further study."
--   2504 -> 7506       his post-completion line.
--   ??? 2503 -> 7507/7508  THE COLLECTION. 7507 "It looks like rime ice could form
--          on this tree." (wrong weather) and 7508 "Something likely to be rime
--          ice lies on the ground." (ice weather -- the fragment). Its data[] is
--          just those two ids, so the event needs no params and the weather branch
--          is the server's to choose.
--
-- KEY ITEM: Rime ice fragment is the existing RIME_ICE_FRAGMENT (2190).
--
-- THE WEATHER GATE is bg-wiki's, and 7502/7507 both state it in-game, so the ???
-- checks weather rather than the quest doing it at accept time. Ice-element
-- weather covers snow and blizzards, which is what bg-wiki's
-- "ice/snow/blizzard" means.
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.NO_RIME_LIKE_THE_PRESENT)

quest.reward =
{
    exp      = 3000,
    fameArea = xi.fameArea.ADOULIN,
}

quest.sections =
{
    -- bg-wiki lists |Previous=None, and |FLevel=1 is the base fame level every
    -- character already has, so there is no gate beyond availability.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.MORIMAR_BASALT_FIELDS] =
        {
            ['Hegnor'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2500)
                end,
            },

            onEventFinish =
            {
                [2500] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    -- Accepted: wait for ice weather at the trees, then carry the fragment back.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.MORIMAR_BASALT_FIELDS] =
        {
            ['qm'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.RIME_ICE_FRAGMENT) then
                        return
                    end

                    return quest:progressEvent(2503)
                end,
            },

            ['Hegnor'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.RIME_ICE_FRAGMENT) then
                        return quest:progressEvent(2502)
                    end

                    return quest:event(2501)
                end,
            },

            onEventFinish =
            {
                [2503] = function(player, csid, option, npc)
                    -- 7507 is the dry-weather look; 7508 is the fragment. Only
                    -- ice-element weather yields one, per bg-wiki and 7502.
                    local weather = player:getWeather()

                    if
                        weather == xi.weather.SNOW or
                        weather == xi.weather.BLIZZARDS
                    then
                        npcUtil.giveKeyItem(player, xi.ki.RIME_ICE_FRAGMENT)
                    end
                end,

                [2502] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.RIME_ICE_FRAGMENT)
                    quest:complete(player)
                end,
            },
        },
    },

    -- Completed: 7506, off to the coalition with his findings.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.MORIMAR_BASALT_FIELDS] =
        {
            ['Hegnor'] = quest:event(2504):replaceDefault(),
        },
    },
}

return quest
