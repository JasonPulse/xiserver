-----------------------------------
-- Hazy Prospects
-----------------------------------
-- Log ID: 8, Quest ID: 46
-- Harith      : Abyssea - Attohwa (G-10), entity 17658618
-- Dark Miasma : Abyssea - Attohwa, entities 17658570 .. 17658591
-- !addquest 8 46
-----------------------------------
-- Retail (bg-wiki "Hazy Prospects").
-- |Start=Harith (A) (G-10), Abyssea - Attohwa  |Fame=aatt |FLevel=2
-- |Previous=None  |Repeatable= (blank, so once only)
-- |Reward=KI Miasmal counteragent recipe, KI Jade abyssite of lenity
--   1. "Speak to Harith (A) at (G-10) to accept the quest and obtain KI Miasmal
--      counteragent recipe."
--   2. "Craft, or otherwise obtain, one or more Miasmal Counteragents. The item can
--      only be crafted with the recipe in possession."
--   3. "Search the area for any targetable, path-blocking Dark Miasma, and trade the
--      counteragent to extinguish the miasma."
--      "You will not receive a message when you trade the M. Counteragent."
--   4. Report back to Harith.
--
-- CSIDS VERIFIED ON THE LIVE CLIENT. Each was fired at the puppet in Abyssea -
-- Attohwa and the text it rendered was read back off the chat stream:
--   361 -> "...Hm? A matter demands my utmost concentration. Please leave me."
--          the fame gate, which is why the check below is not status-only
--   362 -> "...Hm? Come closer. Yes, you just might have what it takes..." through
--          "I would ask you to procure the reagent, synthesize the solution, and then
--          go test it for me, all in one fell swoop!"              THE OFFER
--   363 -> "Synthesize the solution, test it on a miasma, and report back to me your
--          findings. A simple enough task, no?"                    the reminder
--   364 -> "Brilliant! Thanks to you, we've made a crucial discovery: that my theory
--          was one hundred percent as flawless as I thought it was!"  the turn-in
--   365 -> "Though my <counteragent> is remarkably effective in dispersing miasmas, a
--          larger problem remains."                        the post-completion line
--
-- Do NOT take these from csidmsg.py. Its attribution is positional and it was wrong
-- for this expansion more than once; 361-365 above are what the client actually drew.
--
-- THE MIASMAS EACH HAVE THEIR OWN INTERNAL NAME. All 22 display as "Dark Miasma" but
-- npc_list gives them _071 through _07m one apiece, and the interaction framework
-- keys on the internal name, so every one has to be registered. Hooking only _071
-- would wire up exactly one of the twenty-two.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.HAZY_PROSPECTS)

-- _071 .. _079 then _07a .. _07m. Built rather than typed out so the list cannot
-- drift from the twenty-two entities that actually exist.
local miasmaNames = {}

for i = 1, 9 do
    table.insert(miasmaNames, string.format('_07%d', i))
end

for c = string.byte('a'), string.byte('m') do
    table.insert(miasmaNames, '_07' .. string.char(c))
end

-- bg-wiki says the miasmas "disappear occasionally" but publishes no respawn figure,
-- so this is our tuning, in the same spirit as the martello regeneration rate. It
-- only controls how long an extinguished cloud stays gone.
local miasmaRespawn = 300

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_ATTOHWA,
    keyItem  = xi.ki.JADE_ABYSSITE_OF_LENITY,
}

-- Extinguishing a cloud. bg-wiki is explicit that the trade produces NO message, so
-- the only feedback is the miasma going away.
local extinguishAction =
{
    onTrade = function(player, npc, trade)
        if npcUtil.tradeHasExactly(trade, xi.item.PHIAL_OF_MIASMAL_COUNTERAGENT) then
            quest:setVar(player, 'Tested', 1)
            npc:hideNPC(miasmaRespawn)

            return true
        end
    end,
}

local attohwa =
{
    ['Harith'] =
    {
        onTrigger = function(player, npc)
            if quest:getVar(player, 'Tested') == 0 then
                return quest:event(363)
            end

            return quest:progressEvent(364)
        end,
    },

    onEventFinish =
    {
        [364] = function(player, csid, option, npc)
            if quest:complete(player) then
                quest:setVar(player, 'Tested', 0)
            end
        end,
    },
}

for _, miasmaName in ipairs(miasmaNames) do
    attohwa[miasmaName] = extinguishAction
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ABYSSEA_ATTOHWA) >= 2
        end,

        [xi.zone.ABYSSEA_ATTOHWA] =
        {
            ['Harith'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(362)
                end,
            },

            onEventFinish =
            {
                [362] = function(player, csid, option, npc)
                    quest:begin(player)
                    npcUtil.giveKeyItem(player, xi.ki.MIASMAL_COUNTERAGENT_RECIPE)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_ATTOHWA] = attohwa,
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_ATTOHWA] =
        {
            ['Harith'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(365)
                end,
            },
        },
    },
}

return quest
