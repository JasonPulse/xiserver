-----------------------------------
-- A Discerning Eye -- shared implementation for all four variants
--
-- The quest exists four times over, once per airship route, and all four are
-- byte-for-byte the same design in the client. Rather than copy the logic into
-- four files, they each call xi.discerningEye.sections() with their own ids.
--
-- Retail (bg-wiki "A Discerning Eye (Bastok)" / "(San d'Oria)" / "(Windurst)" /
-- "(Kazham)" -- all four Walkthroughs are the same text):
--   1. Speak to the giver and accept -> {KI} Dropped item.
--   2. The giver shows a picture of an NPC, which you have to memorise.
--   3. Board the next airship.
--   4. Eight near-identical Passengers spawn on the ship.
--   5. Speaking to one offers to return the item. ONE CHANCE ONLY: correct pays
--      500 gil and counts a clear, incorrect fails the quest.
-- Repeatable. Titles at 5 / 20 / 100 clears. Reward is 500 gil and nothing else
-- -- every one of the four bg-wiki pages lists `|Reward=*500 gil` and no fame, so
-- no fame is granted. `FLevel` is empty on the Kazham and San d'Oria pages.
--
-- THE GIVER OWNS EXACTLY ONE CSID in every variant, so there is nothing to
-- disambiguate -- one program covers the offer, the picture, the re-show, the
-- failure and the idle line. Decoded with xidat/csidmsg.py:
--   Eddy      17727617 -> zone 232 idx 129, csid   723, msgs 8531-8546  (753 B)
--   Grin      17744023 -> zone 236 idx 151, csid   295, msgs 8868-8883  (752 B)
--   Pygmalion 17760442 -> zone 240 idx 186, csid 10019, msgs 12801-12816 (753 B)
--   Swift     17801340 -> zone 250 idx 124, csid 10018, msgs 10677-10692 (753 B)
-- Sixteen messages and the same program size in all four. Swift's set reads:
--   10677 "If you are boarding the airship, might I ask you a favor?"
--   10678 "A passenger who intended to board the next flight dropped this..."
--   10679 "I cannot leave my post, so I was wondering if you could return it..."
--   10680 "Return the dropped item? / Gladly. / Sorry, I'm a busy man/woman."
--   10681 "Thank you! The passenger who dropped the item looked like this."
--   10682 "Have you memorized the image?"
--   10683 "Have you got it? / I got it. / Not yet."
--   10684 "The passenger who dropped the item should be on the next flight."
--   10685 "I leave the rest in your capable hands."
--   10686 "I'm sorry to have bothered you with such a trivial request." (declined)
--   10687 "Oh, the airship has already left..."
--   10688 "You were unable to meet with the rightful owner of the item?" (failed)
--   10689 "What, you've forgotten already?"
--   10690 "Have you forgotten? / Yes. / No."
--   10691 "The passenger looked like this." (re-shows the picture)
--   10692 "It's my job to look out for suspicious characters coming in on the
--         airships."
--
-- OPTION 0 ACCEPTS, and this is proven rather than assumed: the accept prompt is
-- the fourth message of each giver's block and reads identically in all of them,
-- with "Gladly." as the FIRST selection line -- Eddy 8534, Pygmalion 12804,
-- Swift 10680, Grin 8871. (The previous stubs all tested `option == 1`, which is
-- the decline.)
--
-- Airship side, identical in all four zones. `xi-dat events <zone>` shows the
-- eight Passengers each owning exactly two csids -- Nth passenger by ascending
-- entity id owns 100+N (idle chat) and 110+N (the offer and the reward):
--   zone 223 San d'Oria 0x010DF005-0x010DF00C  17690629-17690636
--   zone 224 Bastok     0x010E0004-0x010E000B  17694724-17694731
--   zone 225 Windurst   0x010E1004-0x010E100B  17698820-17698827
--   zone 226 Kazham     0x010E2004-0x010E200B  17702916-17702923
-- Kazham's csid 111 -> msgs 7076-7086, which carries both outcomes twice over:
--   7076 "Return the dropped item? / Yes. / No."
--   7078 "Oh, thanks... I'm not sure that this belongs to me, though..." WRONG
--   7079 "Wow, thanks... I don't really remember dropping anything, though..." WRONG
--   7080 "Thank you! I've been looking all over the place for this!"       RIGHT
--   7081 "Thank you! I don't know what I would've done if I had lost this!" RIGHT
--   7082 "Please take this as a token of my gratitude."  -- the 500 gil
--
-- The Passengers really are distinguished the way bg-wiki says. Their npc_list
-- look strings differ only in head / hands / legs / feet, i.e. hair-or-hat,
-- gloves and legwear. Bastok and Windurst share one look set with three head
-- groups, so hands and legs are what separate them; San d'Oria and Kazham give
-- all eight a distinct head.
--
-- NEEDS AN IN-GAME PROBE: the giver's program reads fdi0/fdi1, so it takes two
-- input params, and the picture has to be one of them. Passing the chosen
-- passenger index as param 0 is inferred from that two-param signature, not
-- decoded -- confirm with `!cs 723` / `295` / `10019` / `10018`. If it is wrong
-- the quest simply fails to show the right picture; it cannot mispay, because the
-- payout lives on the airship and is gated on the stored target index.
-----------------------------------

xi.discerningEye = xi.discerningEye or {}

local clearTitles =
{
    { clears = 100, title = xi.title.EXTREMELY_DISCERNING_INDIVIDUAL },
    { clears =  20, title = xi.title.VERY_DISCERNING_INDIVIDUAL     },
    { clears =   5, title = xi.title.DISCERNING_INDIVIDUAL          },
}

-- config fields:
--   logId, questId      the quest's own log and id
--   giverZone, giverName, giverCsid
--   airshipZone         the matching xi.zone.*_JEUNO_AIRSHIP
--   passengers          the 8 entity ids, ascending, which is csid order
--   clearsVar           charvar holding this variant's clear count
--   fameLevel           optional fame requirement; nil means ungated
--   fameArea            required alongside fameLevel
xi.discerningEye.sections = function(quest, config)
    local airshipID = zones[config.airshipZone]

    local function passengerIndex(npc)
        for index, id in ipairs(config.passengers) do
            if id == npc:getID() then
                return index
            end
        end

        return 0
    end

    local function grantClear(player)
        local clears = player:getCharVar(config.clearsVar) + 1
        player:setCharVar(config.clearsVar, clears)

        for _, tier in ipairs(clearTitles) do
            if clears >= tier.clears then
                player:setTitle(tier.title)
                break
            end
        end
    end

    local function eligible(player)
        if config.fameLevel == nil then
            return true
        end

        return player:getFameLevel(config.fameArea) >= config.fameLevel
    end

    local sections =
    {
        -- The giver offers. Repeatable, so COMPLETED is eligible too, and a
        -- player who guessed wrong is back here with the quest still ACCEPTED and
        -- Target cleared, which is the retry path.
        {
            check = function(player, status, vars)
                return (status == xi.questStatus.QUEST_AVAILABLE or
                        status == xi.questStatus.QUEST_COMPLETED or
                        (status == xi.questStatus.QUEST_ACCEPTED and vars.Target == 0)) and
                    eligible(player) and
                    not player:hasKeyItem(xi.ki.DROPPED_ITEM)
            end,

            [config.giverZone] =
            {
                [config.giverName] =
                {
                    onTrigger = function(player, npc)
                        -- Pick the passenger before showing the picture: the
                        -- picture has to match whoever the airship will accept.
                        local target = math.random(1, #config.passengers)
                        quest:setVar(player, 'Target', target)

                        return quest:progressEvent(config.giverCsid, { [0] = target - 1 })
                    end,
                },

                onEventFinish =
                {
                    [config.giverCsid] = function(player, csid, option, npc)
                        -- Option 0 is "Gladly."; anything else declines.
                        if option ~= 0 or not npcUtil.giveKeyItem(player, xi.ki.DROPPED_ITEM) then
                            quest:setVar(player, 'Target', 0)
                            return
                        end

                        local status = player:getQuestStatus(config.logId, config.questId)

                        -- Already ACCEPTED means this is a retry after a wrong
                        -- guess: the fresh key item and target are all that is
                        -- needed.
                        if status == xi.questStatus.QUEST_COMPLETED then
                            player:addQuest(config.logId, config.questId)
                        elseif status == xi.questStatus.QUEST_AVAILABLE then
                            quest:begin(player)
                        end
                    end,
                },
            },
        },

        -- Aboard the airship: one guess only.
        {
            check = function(player, status, vars)
                return status == xi.questStatus.QUEST_ACCEPTED and
                    vars.Target ~= 0
            end,

            [config.airshipZone] =
            {
                -- MY BUG, fixed: every Passenger row ships as npc_list.status = 2
                -- (DISAPPEAR) in all four airship zones and nothing revealed them,
                -- so the airship half of the quest had no NPCs at all -- the giver
                -- side worked, then the player boarded to an empty deck and the
                -- 500 gil was unreachable. setStatus is global for a non-instanced
                -- zone, but the airship is a short transit zone and retail shows
                -- these passengers to everyone aboard, so a global reveal is right.
                onZoneIn = function(player, prevZone)
                    for _, id in ipairs(config.passengers) do
                        local npc = GetNPCByID(id)

                        if npc then
                            npc:setStatus(xi.status.NORMAL)
                        end
                    end

                    return -1
                end,

                ['Passenger'] =
                {
                    onTrigger = function(player, npc)
                        local index = passengerIndex(npc)

                        if index == 0 then
                            return
                        end

                        if not player:hasKeyItem(xi.ki.DROPPED_ITEM) then
                            return quest:event(100 + index)
                        end

                        return quest:progressEvent(110 + index)
                    end,
                },

                onEventFinish = {},
            },

            -- The giver's idle line while the hunt is live, plus his re-show of
            -- the picture.
            [config.giverZone] =
            {
                [config.giverName] =
                {
                    onTrigger = function(player, npc)
                        return quest:event(config.giverCsid, { [0] = quest:getVar(player, 'Target') - 1 })
                    end,
                },
            },
        },
    }

    -- 111-118 all resolve the same way, so build the handlers rather than
    -- repeating the body eight times. Each is scoped to its own Passenger by
    -- csid, and the payout is gated on the target stored when the picture was
    -- shown, so a wrong guess cannot pay.
    local handlers = sections[2][config.airshipZone].onEventFinish

    for index = 1, #config.passengers do
        handlers[110 + index] = function(player, csid, option, npc)
            if option ~= 0 or not player:hasKeyItem(xi.ki.DROPPED_ITEM) then
                return
            end

            player:delKeyItem(xi.ki.DROPPED_ITEM)

            if quest:getVar(player, 'Target') == index then
                local reward = xi.settings.main.GIL_RATE * 500

                player:addGil(reward)
                player:messageSpecial(airshipID.text.GIL_OBTAINED, reward)
                grantClear(player)
                player:completeQuest(config.logId, config.questId)
            end

            -- Right or wrong the item is gone and the attempt is spent. Clearing
            -- Target routes the player back to the giver, whose "You were unable
            -- to meet with the rightful owner" line covers the failure and who can
            -- hand out a fresh item.
            quest:setVar(player, 'Target', 0)
        end
    end

    return sections
end
