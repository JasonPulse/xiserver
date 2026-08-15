-----------------------------------
-- A Proper Burial
-----------------------------------
-- Log ID: 1, Quest ID: 87
-- Offa     : Bastok Markets (F-10)      -- the present-day Offa
-- Offa (S) : Bastok Markets [S]         -- the boy
-----------------------------------
-- Retail (bg-wiki "A Proper Burial"), Wings of the Goddess:
--   1. Speak to Offa in the present to begin.
--   2. Go to Bastok Markets [S] and speak to young Offa. Two options branch the
--      quest: "Bury it somewhere in the city" (longer) or "Conceal the burial
--      spot with a rock" (recommended).
--   3. Shuttle present <-> past speaking to Offa each time. At one stage trade
--      a Set of Fish Bones to Offa (S).
--   4. A final present-Offa talk ends the shuttle and hands over the Rolanberry.
--   5. Trade the Rolanberry to young Offa (S).
--   6. Return to present Offa -> complete, and the Withered Berry.
-- No title, not repeatable.
--
-- CSIDs decoded, not guessed, and independently corroborated in-repo.
-- Present Offa is entity 17739818 (npc_list:27754); (17739818-16777216) =
-- 962602, 962602//4096 = 235 rem 42 -> Bastok Markets, 0x010EB02A.
-- `xi-dat csid 235 475` reports a 544-byte program on the zone-global actor
-- 0x7FFFFFF0 plus 1-byte stubs on Offa AND on 0x010EB04F = '_6j9' 'Door:House'
-- (npc_list:27791, at -290.049/-17.349/-143.573, which is the same spot Offa (S)
-- occupies in zone 87). The six present-day cutscenes and their matching idle
-- lines, read against `xi-dat dialog 235`:
--   475 / 476 -> 12395 "Haaahhh, another squandered day.", 12397 "Do you know
--                what a Bastokan Time Capsule is?", 12400 "the box had been
--                ravaged and its contents plundered"
--   477 / 478 -> 12404 "A while back I went to dig up our letters but realized
--                I had totally forgotten where they were buried."
--   479 / 480 -> 12407 "If only we had put ${item-article: 0} in the capsule as
--                well." -- the Fish Bones hint
--   481 / 482 -> 12411 "A false-bottom box... That would have worked."
--   483 / 484 -> 12414-12421, the letter reading; 12421 "I'm sorry, but I have
--                only this to offer you in gratitude." -- the Rolanberry
--   485 / 486 -> 12426 "Who needs dreams when you have ${item-article: 0} as
--                scrumptious as this!" -- the Withered Berry
-- The odd ids are the cutscenes (on the zone-global holder), the even ones are
-- Offa's own short idle chats. That even/odd split is confirmed by
-- scripts/zones/Bastok_Markets/npcs/Lamepaue.lua:173-183, upstream's Past Event
-- Watcher, which labels 475/477/479/481/483/485 as "A Proper Burial (pt.1)"
-- through "(pt.6)" -- i.e. exactly the six odd ids derived from the DATs.
--
-- Offa (S) is entity 17134034 (npc_list:9493); (17134034-16777216) = 356818,
-- 356818//4096 = 87 rem 466 -> Bastok Markets [S], 0x010571D2. Read against
-- `xi-dat dialog 87`:
--   128 / 129,130 -> 11265 "What advice will you give Offa? ${selection-lines}
--                    Bury it somewhere in the city. / Conceal the burial spot
--                    with a rock." -- the branch; 11266 confirms the choice,
--                    11267/11268 are the two outcomes, and the chats 11269
--                    ("I'll just have my father bury it here in the city") and
--                    11270 ("cover up the burial spot with a rock!") are one per
--                    branch
--   131 / 132     -> 11274 "I sure do feel a lot better, knowing our capsule's
--                    resting place is hidden under a rock."
--   133 / 134     -> 11275 "Hm? You want to bury this in the time capsule too?",
--                    11276 "they'll be so busy with these bones that they won't
--                    even notice the letters!" -- the Fish Bones trade
--   135 / 136     -> 11280 "A what? A false bottom? In the box?"
--   137 / 138     -> 11283 "Eh? You want to bury this in the capsule, too?",
--                    11285 "I'll make sure your ${item-singular: 0} gets buried
--                    along with the letters." -- the Rolanberry trade
--   110           -> 11271, his pre-quest idle
--
-- CRITICAL COLLISION NEUTRALISED: Lamepaue (the Past Event Watcher) fires
-- 475/477/479/481/483/485 to replay these cutscenes. Since onEventFinish is
-- dispatched zone-wide keyed only on csid, a bare handler on those ids would let
-- a player advance -- or finish -- this quest by replaying its own cutscenes at
-- Lamepaue. Every handler below is therefore gated on the triggering npc
-- actually being Offa, by entity id.
--
-- The old stub used csids 125-133. In zone 235 those belong to unrelated
-- entities, and in zone 87 they collide with Engelhart: 126 and 127 are fired by
-- scripts/zones/Bastok_Markets_[S]/npcs/Engelhart.lua:31,33 (Engelhart is
-- 0x010571D1 = 17134033, npc_list:9492 -- the entity immediately before Offa).
-- The correct ids 128-138 do not collide with him.
--
-- Also fixed: the stub granted a Rolanberry TWICE, in onEventFinish[129] and
-- again in onEventFinish[128]. Retail grants exactly one, and you hand it back.
-- And bg-wiki lists no fame, so the stub's 40 is gone.
--
-- xi.item.WITHERED_ROLANBERRY (5675) is bg-wiki's "Withered Berry":
-- sql/item_basic.sql:5454 gives it the sort name 'withered_berry'. Not invented.
--
-- STILL SIMPLIFIED: the two-option branch at csid 128 is recorded in the 'Advice'
-- var and both outcomes are shown, but both then follow the same csid chain,
-- because only one chain exists in the dumps. bg-wiki says one route is "longer"
-- -- if that means extra shuttle stages, those stages have no distinct csids that
-- could be found, so the difference is not modelled. Flagged rather than faked.
-----------------------------------
local offaPresent = 17739818
local offaPast    = 17134034

local quest = Quest:new(xi.questLog.BASTOK, xi.quest.id.bastok.A_PROPER_BURIAL)

quest.reward =
{
    item = xi.item.WITHERED_ROLANBERRY,
}

-- Prog runs 0..10, alternating present -> past. The interleave follows the
-- dialog: present 479 wishes for the Fish Bones, then past 133 trades them;
-- present 483 hands over the Rolanberry, then past 137 buries it.
--   0  accepted, go to the past            -> past 128 (the branch)
--   1  back to the present                 -> present 477
--   2  to the past                         -> past 131
--   3  back to the present                 -> present 479 (Fish Bones hint)
--   4  to the past, trade Fish Bones       -> past 133
--   5  back to the present                 -> present 481
--   6  to the past                         -> past 135
--   7  back to the present, get Rolanberry -> present 483
--   8  to the past, trade Rolanberry       -> past 137
--   9  back to the present                 -> present 485, complete
local presentStage =
{
    [1] = 477,
    [3] = 479,
    [5] = 481,
    [7] = 483,
    [9] = 485,
}

local pastStage =
{
    [0] = 128,
    [2] = 131,
    [6] = 135,
}

-- The even ids are Offa's idle chats, one per stage, and they are listed rather
-- than derived: at Prog 4 and 8 the past Offa is waiting on a TRADE, so any
-- arithmetic fallback would land on the trade cutscenes 133/137 and fire them
-- with nothing traded.
local presentIdle =
{
    [0] = 476,
    [2] = 478,
    [4] = 480,
    [6] = 482,
    [8] = 484,
}

local pastIdle =
{
    [3] = 132,
    [5] = 134,
    [7] = 136,
    [9] = 138,
}

-- Only advance when Offa himself started the event, so replaying a cutscene at
-- Lamepaue cannot move the quest along.
local function isOffa(npc, expectedId)
    return npc ~= nil and npc:getID() == expectedId
end

local function advance(expectedId, from, to)
    return function(player, csid, option, npc)
        if isOffa(npc, expectedId) and quest:getVar(player, 'Prog') == from then
            quest:setVar(player, 'Prog', to)
        end
    end
end

quest.sections =
{
    -- Offer.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.BASTOK_MARKETS] =
        {
            ['Offa'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(475)
                end,
            },

            onEventFinish =
            {
                [475] = function(player, csid, option, npc)
                    if isOffa(npc, offaPresent) then
                        quest:begin(player)
                    end
                end,
            },
        },

        [xi.zone.BASTOK_MARKETS_S] =
        {
            ['Offa'] = quest:event(110),
        },
    },

    -- The shuttle.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.BASTOK_MARKETS] =
        {
            ['Offa'] =
            {
                onTrigger = function(player, npc)
                    local prog = quest:getVar(player, 'Prog')

                    if presentStage[prog] then
                        return quest:progressEvent(presentStage[prog])
                    elseif presentIdle[prog] then
                        return quest:event(presentIdle[prog])
                    end
                end,
            },

            onEventFinish =
            {
                [477] = advance(offaPresent, 1, 2),
                [479] = advance(offaPresent, 3, 4),
                [481] = advance(offaPresent, 5, 6),

                -- 12421 "I'm sorry, but I have only this to offer you in
                -- gratitude." -- the single Rolanberry, granted once, here.
                [483] = function(player, csid, option, npc)
                    if not isOffa(npc, offaPresent) or quest:getVar(player, 'Prog') ~= 7 then
                        return
                    end

                    if npcUtil.giveItem(player, xi.item.ROLANBERRY) then
                        quest:setVar(player, 'Prog', 8)
                    end
                end,

                [485] = function(player, csid, option, npc)
                    if isOffa(npc, offaPresent) and quest:getVar(player, 'Prog') == 9 then
                        quest:complete(player)
                    end
                end,
            },
        },

        [xi.zone.BASTOK_MARKETS_S] =
        {
            ['Offa'] =
            {
                onTrigger = function(player, npc)
                    local prog = quest:getVar(player, 'Prog')

                    if pastStage[prog] then
                        return quest:progressEvent(pastStage[prog])
                    elseif prog == 1 then
                        -- 129 and 130 are the two branch outcomes, one per
                        -- answer given to 11265.
                        return quest:event(129 + quest:getVar(player, 'Advice'))
                    elseif pastIdle[prog] then
                        return quest:event(pastIdle[prog])
                    end
                end,

                onTrade = function(player, npc, trade)
                    local prog = quest:getVar(player, 'Prog')

                    if prog == 4 and npcUtil.tradeHasExactly(trade, xi.item.SET_OF_FISH_BONES) then
                        return quest:progressEvent(133)
                    elseif prog == 8 and npcUtil.tradeHasExactly(trade, xi.item.ROLANBERRY) then
                        return quest:progressEvent(137)
                    end
                end,
            },

            onEventFinish =
            {
                -- 11265 "What advice will you give Offa? / Bury it somewhere in
                -- the city. / Conceal the burial spot with a rock."
                [128] = function(player, csid, option, npc)
                    if not isOffa(npc, offaPast) or quest:getVar(player, 'Prog') ~= 0 then
                        return
                    end

                    quest:setVar(player, 'Advice', option)
                    quest:setVar(player, 'Prog', 1)
                end,

                [131] = advance(offaPast, 2, 3),
                [135] = advance(offaPast, 6, 7),

                [133] = function(player, csid, option, npc)
                    if isOffa(npc, offaPast) and quest:getVar(player, 'Prog') == 4 then
                        player:confirmTrade()
                        quest:setVar(player, 'Prog', 5)
                    end
                end,

                [137] = function(player, csid, option, npc)
                    if isOffa(npc, offaPast) and quest:getVar(player, 'Prog') == 8 then
                        player:confirmTrade()
                        quest:setVar(player, 'Prog', 9)
                    end
                end,
            },
        },
    },
}

return quest
