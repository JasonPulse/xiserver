-----------------------------------
-- Heaven Cent
-----------------------------------
-- Log ID: 2, Quest ID: 49
-- Ropunono  : Windurst Waters (F-7), the Optistery
-- Iron Door : Maze of Shakhrami (K-9, second map)
-- Chests    : Maze of Shakhrami, behind the Iron Door
-----------------------------------
-- Retail (bg-wiki "Heaven Cent"), not repeatable:
--   1. Speak to Ropunono to begin.
--   2. Trade an Ahriman Lens to Ropunono.
--   3. Go to the Maze of Shakhrami and kill Wights for a Rusty Key.
--   4. Trade the Rusty Key to the Iron Door at (K-9) on the second map. Inside
--      are several chests; three hold constellation coins.
--   5. Any coin you pick gives a Shelling Piece.
--   6. Trade the Shelling Piece to Ropunono -> 4,800 gil and the title
--      Night Sky Navigator.
-- The puzzle is that the coin must show the constellations in their true
-- positions. The correct sky is: Odin north, Alexander northeast, Shiva east,
-- Garuda southeast, Titan south, Ramuh southwest, Leviathan west, Ifrit
-- northwest. A coin that disagrees is a forgery and Ropunono rejects it.
--
-- CSIDs decoded, not guessed. Ropunono is entity 17752090 (npc_list:28812);
-- (17752090-16777216) = 974874, 974874//4096 = 238 rem 26 -> Windurst Waters,
-- 0x010EE01A. Read against `xi-dat dialog 238`:
--   283 -> 7968, 7969 "Windurst is protected by the stars. Here at the Optistery,
--          we record the position of the stars every night for posterity's sake."
--   284 -> the FIRST TALK, which is what begins the quest. 7970 "Things are a
--          total blur lately... I'm having trouble focusing...", 7971 "take the
--          constellation of Ifrit that shines in the northwest sky", 7972 "This
--          telescope is really old, so perhaps it's the telescope and not me! It
--          must be time to change its stellar mirror.", 7973 "the material needed
--          to make stellar mirrors is only dropped by powerful monsters found in
--          the Northlands"
--   285 -> 7974 "This telescope is really old, and it's about time to change its
--          stellar mirror." -- the repeat pre-lens talk.
--   288 -> the AHRIMAN LENS TRADE. 7980 "Ah! What's this? It can't really be
--          ${article} ${item-article: 1}, can it!?", 7984 "In order to do that, we
--          need ${article} ${item-article: 2}. These are the ancient shell coins
--          made in the era of the first Star Sibyl.", 7986 "I'd be willing to pay
--          you back greatly"
--   289 -> 7987 "If only I had ${article} ${item-article: 2}, I'd be able to
--          inscribe the correct star positions onto the ${item-singular: 1}."
--   292 -> the SHELLING PIECE TURN-IN. 7993 "Wow! I never thought you'd actually
--          find one of these! What, did you travel back in time to ancient
--          Windurst or something?", 7995 "I'm so in debt to you. Please accept
--          this as a token of my appreciation..." -- the 4,800 gil.
--   293 -> 7996 "Oh then, Odin's to the north. Right and, Titan's to the south.
--          Shivers, Shiva's to the east. And then, Leviathan's to the west." --
--          post-completion, and incidentally a confirmation of the correct sky.
--   296 -> the FORGERY path. 8003 "Huh? Hold on a second... This is a fake...!
--          It's funny money!", 8004 "The positioning of the constellations isn't
--          right on this coin. I guess you'll have to search harder to find a real
--          one."
--   297 -> 8005 "there were too many forgeries of the old shell coins, so we
--          Tarutaru abandoned them for gil instead", 8006 "Please find me a coin
--          with the correct positioning of the constellations on it."
--
-- Maze of Shakhrami side: the Iron Door is '_5i0' = 17588759 ->
-- (17588759-16777216) = 811543, 811543//4096 = 198 rem 535, 0x010C6217, and
-- `xi-dat events 198` shows it owning exactly 41 and 42. Zone 198's messages
-- 7080 "The chest is too rusty to open." and 7081 "The lock is broken and cannot
-- be opened." belong to the same group. The chests are '_5i2'-'_5i7' =
-- 17588752-17588757, and the coin csids run 43-52 in pairs:
-- 0x010C6212 (17588754) -> 46,47; 0x010C6213 (17588755) -> 48,49;
-- 0x010C6214 (17588756) -> 50,51; and the zone-global 0x7FFFFFF0 owns 43,44,45.
-- The coin outcome messages are the heart of the puzzle:
--   7083 "Take this coin? / Yes. / No."
--   7084 Alexander northeast   7085 Shiva east   7086 Odin north
--   7087 Odin EAST (forgery)   7088 Titan NORTH (forgery)
--   7089 Leviathan SOUTH (forgery)   7090 Shiva WEST (forgery)
--   7091 Ifrit northwest
--   7078 "Inside, there is a pile of coins with constellations drawn on them."
--   7079 "The chest looks empty."   7082 "You already have ${article}
--   ${item-article: 0}."
-- So four of the eight coin results are genuine and four are forgeries, which is
-- exactly the real/fake split bg-wiki describes -- and note there is only ONE
-- Shelling Piece item id, so genuine-versus-forged has to be carried in a var,
-- not by a second item. That is what 'CoinReal' below does.
--
-- WHAT THE STUB DID WRONG: it used 284 (the first-talk that BEGINS the quest) as
-- the Ahriman Lens trade, and 285 (the repeat pre-lens talk) as the Shelling
-- Piece turn-in -- so two of its three csids were the wrong events. It then
-- skipped the Wights, the Rusty Key, the Iron Door and the chests entirely by
-- auto-granting a free Shelling Piece on zone-in to the Maze of Shakhrami, which
-- removed the whole puzzle.
--
-- xi.item.SHELLING_PIECE was MISSING from the enum; the stub hardcoded 545 as a
-- bare local. 545 is correct (sql/item_basic.sql:540 'shelling_piece') and the
-- enum has now been added. xi.item.RUSTY_KEY = 543 already existed
-- (item.lua:178) and is confirmed against item_basic.sql:538.
--
-- bg-wiki lists no fame, so the stub's 30 is gone. 4,800 gil and the title
-- Night Sky Navigator (131) are both retail.
--
-- CONFIDENCE NOTE, stated plainly: Ropunono's ids 283-297 are each pinned by a
-- quoted line. The 41-versus-42 split on the Iron Door, and which of the chest
-- csid pairs belongs to which chest, are NOT pinned that way -- they are inferred
-- from ownership and adjacency. So the Iron Door uses 41 for the locked state and
-- 42 for the opened state, and each chest is given the pair its own entity owns,
-- with the zone-global trio 43/44/45 left unused rather than assigned by guess.
-- Confirm the door split with !cs 41 / !cs 42.
--
-- STILL SIMPLIFIED: the Rusty Key comes from Wight drops on retail. Wiring that
-- means a mob_droplist row, which is a data change outside this file, so the key
-- is not granted here -- the door checks for it and says so if you lack it.
-----------------------------------
local shakhramiID = zones[xi.zone.MAZE_OF_SHAKHRAMI]

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.HEAVEN_CENT)

quest.reward =
{
    gil   = 4800,
    title = xi.title.NIGHT_SKY_NAVIGATOR,
}

-- The eight possible coin results, message 7084 through 7091. `real` follows the
-- true sky, which post-completion line 7996 independently confirms.
local coins =
{
    { offset = 0, real = true  }, -- 7084 Alexander northeast
    { offset = 1, real = true  }, -- 7085 Shiva east
    { offset = 2, real = true  }, -- 7086 Odin north
    { offset = 3, real = false }, -- 7087 Odin east
    { offset = 4, real = false }, -- 7088 Titan north
    { offset = 5, real = false }, -- 7089 Leviathan south
    { offset = 6, real = false }, -- 7090 Shiva west
    { offset = 7, real = true  }, -- 7091 Ifrit northwest
}

-- Each chest gets the csid pair its own entity owns. The zone-global 43/44/45 are
-- deliberately not assigned: their owner is 0x7FFFFFF0, not a chest.
local chests =
{
    ['_5i4'] = { look = 46, take = 47 },
    ['_5i5'] = { look = 48, take = 49 },
    ['_5i6'] = { look = 50, take = 51 },
}

local function chestSection()
    -- The Maze of Shakhrami table is built as its own local before it goes into
    -- the section literal. Assigning the chest entries onto
    -- `section[MAZE_OF_SHAKHRAMI]` after the fact made the language server unify
    -- the value type of every integer-keyed zone table, and because
    -- WINDURST_WATERS holds `['Ropunono'] = quest:event(...)` it settled on
    -- TEvent -- so each `{ onTrigger = ... }` chest handler was reported as a
    -- TEvent "missing required fields id, options". Building this table
    -- separately keeps its shape inferred from its own literal, which already
    -- contains a handler table.
    local shakhrami =
    {
        -- 41 while shut, 42 once the Rusty Key has opened it.
        ['_5i0'] =
        {
            onTrigger = function(player, npc)
                if quest:getVar(player, 'Door') == 1 then
                    return quest:event(42)
                end

                return quest:event(41)
            end,

            onTrade = function(player, npc, trade)
                if npcUtil.tradeHasExactly(trade, xi.item.RUSTY_KEY) then
                    return quest:progressEvent(42)
                end
            end,
        },

        onEventFinish =
        {
            [42] = function(player, csid, option, npc)
                if quest:getVar(player, 'Door') ~= 1 then
                    player:confirmTrade()
                    quest:setVar(player, 'Door', 1)
                end
            end,
        },
    }

    for name, ids in pairs(chests) do
        shakhrami[name] =
        {
            onTrigger = function(player, npc)
                if quest:getVar(player, 'Door') ~= 1 then
                    return quest:messageSpecial(shakhramiID.text.NOTHING_OUT_OF_ORDINARY)
                end

                return quest:progressEvent(ids.take, { [0] = xi.item.SHELLING_PIECE })
            end,
        }

        shakhrami.onEventFinish[ids.take] = function(player, csid, option, npc)
            -- 7083 "Take this coin? / Yes. / No."
            if option ~= 0 or quest:getVar(player, 'Door') ~= 1 then
                return
            end

            local coin = coins[math.random(1, #coins)]

            if not npcUtil.giveItem(player, xi.item.SHELLING_PIECE) then
                return
            end

            player:messageSpecial(shakhramiID.text.COIN_CONSTELLATION_OFFSET + coin.offset)
            quest:setVar(player, 'CoinReal', coin.real and 1 or 0)
        end
    end

    return {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Lens == 1 and
                not player:hasItem(xi.item.SHELLING_PIECE)
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Ropunono'] = quest:event(289, { [1] = xi.item.AHRIMAN_LENS, [2] = xi.item.SHELLING_PIECE }),
        },

        [xi.zone.MAZE_OF_SHAKHRAMI] = shakhrami,
    }
end

quest.sections =
{
    -- 284 is the first talk, and it is what begins the quest.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Ropunono'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(284)
                end,
            },

            onEventFinish =
            {
                [284] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    -- Accepted, lens not yet handed over: 285 is the repeat pre-lens talk.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Lens == 0
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Ropunono'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(285)
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.AHRIMAN_LENS) then
                        return quest:progressEvent(288, { [1] = xi.item.AHRIMAN_LENS, [2] = xi.item.SHELLING_PIECE })
                    end
                end,
            },

            onEventFinish =
            {
                [288] = function(player, csid, option, npc)
                    player:confirmTrade()
                    quest:setVar(player, 'Lens', 1)
                end,
            },
        },
    },

    chestSection(),

    -- Coin in hand. A genuine one pays out at 292; a forgery gets 296 and has to
    -- be replaced.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Lens == 1 and
                player:hasItem(xi.item.SHELLING_PIECE)
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Ropunono'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'CoinReal') == 1 then
                        return quest:event(289, { [1] = xi.item.AHRIMAN_LENS, [2] = xi.item.SHELLING_PIECE })
                    end

                    return quest:event(297, { [2] = xi.item.SHELLING_PIECE })
                end,

                onTrade = function(player, npc, trade)
                    if not npcUtil.tradeHasExactly(trade, xi.item.SHELLING_PIECE) then
                        return
                    end

                    if quest:getVar(player, 'CoinReal') == 1 then
                        return quest:progressEvent(292, { [1] = xi.item.AHRIMAN_LENS })
                    end

                    return quest:progressEvent(296)
                end,
            },

            onEventFinish =
            {
                [292] = function(player, csid, option, npc)
                    player:confirmTrade()
                    quest:complete(player)
                end,

                -- 8003 "This is a fake...! It's funny money!" -- the forgery is
                -- taken and the hunt resumes.
                [296] = function(player, csid, option, npc)
                    player:confirmTrade()
                    quest:setVar(player, 'CoinReal', 0)
                end,
            },
        },
    },

    -- 7996, post-completion.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Ropunono'] = quest:event(293),
        },
    },
}

return quest
