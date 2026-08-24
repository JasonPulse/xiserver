-----------------------------------
-- Velkkovert Operations
-----------------------------------
-- Log ID: 9, Quest ID: 123
-- Zaffeld           : Eastern Adoulin (J-8), entity 17830131
-- Congregation Site : Cirdas Caverns (E-7), entity 17883969
-- Rocky Outcrop     : Dho Gates (G-8), entity 17891727
-- !addquest 9 123
-----------------------------------
-- Retail (bg-wiki "Velkkovert Operations").
-- |Start=Zaffeld, Eastern Adoulin (J-8) |Fame=Adoulin |Repeatable=No
-- |Previous=Thorn in the Side |Next=The Good, the Bad, the Clement
-- |Reward=500 EXP, 1,000 Bayld
--   1. Talk to Zaffeld in Eastern Adoulin (J-8).
--   2. Check the Congregation Site on the east side of (E-7) in Cirdas Caverns.
--   3. Check the Rocky Outcrop at (G-8) in Dho Gates.
--   4. Kill 5 Velkk in the area west of the Rocky Outcrop.
--   5. Check the Rocky Outcrop again to complete the quest.
--
-- CSIDS PROBED LIVE ON THE PUPPET, one !cs per id, read back off the chat log:
--   Eastern Adoulin 5047 -> Zaffeld on the failed capture, then Nashu: "those
--       mothers of malevolence have entered into negotiations with...the Velkk!"
--                                                                    THE OFFER
--   Eastern Adoulin 5048 -> Nashu: "Have you decided to help me dig up what the
--       Blackthorn Coven is planning?"                              the re-ask
--   Eastern Adoulin 5049 -> Zaffeld: "Nashu asked me to remind you to muster at
--       E-7 of Cirdas Caverns"                                    the reminder
--   Cirdas Caverns 27 -> Nashu and the Velkk Brezit-Kyorgul at the site
--   Cirdas Caverns 28 -> Nashu: "Let us tarry no longer...to Dho Gates!"
--   Dho Gates 14 -> Nashu spotting Mligni-Vorgut and asking you to thin the herd,
--       "Hmmm...I think 5 should do the trick"
--   Dho Gates 15 -> "You will need to slay 5 of the Velkk that dirty this area"
--                                                                  the reminder
--   Dho Gates 16 -> the closing scene                              THE TURN-IN
--
-- THIS FILE PREVIOUSLY USED 5054/5055/5056 AND PUT THE TURN-IN ON ZAFFELD. Both
-- were wrong. 5054 is The Good, the Bad, the Clement (Nashu going to parlay with
-- the coven), and bg-wiki step 4 puts the turn-in on the Rocky Outcrop.
--
-- ITS PREREQUISITE IS THORN IN THE SIDE, which is built alongside this, so the
-- completion check is real rather than a fame stand-in.
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.VELKKOVERT_OPERATIONS)

local congregationSite = 17883969
local rockyOutcrop     = 17891727
local velkkWanted      = 5

local velkkNames =
{
    'Velkk_Punisher',
    'Velkk_Vaticinator',
    'Velkk_Ravager',
    'Velkk_Manipulator',
    'Velkk_Trampler',
    'Velkk_Dreadnought',
    'Velkk_Archmagus',
    'Velkk_Cyclonicist',
    'Velkk_Reaver',
    'Velkk_Stormcaller',
    'Velkk_Berserker',
    'Velkk_Magus',
}

quest.reward =
{
    fameArea = xi.fameArea.ADOULIN,
    bayld    = 1000,
    exp      = 500,
}

local siteActions =
{
    onTrigger = function(player, npc)
        if npc:getID() == congregationSite and quest:getVar(player, 'Site') == 0 then
            return quest:progressEvent(27)
        end
    end,
}

local outcropActions =
{
    onTrigger = function(player, npc)
        if npc:getID() ~= rockyOutcrop then
            return
        end

        if quest:getVar(player, 'Site') ~= 1 then
            return
        end

        if quest:getVar(player, 'Outcrop') == 0 then
            return quest:progressEvent(14)
        elseif quest:getVar(player, 'Velkk') >= velkkWanted then
            return quest:progressEvent(16)
        end

        return quest:event(15)
    end,
}

local velkkKill =
{
    onMobDeath = function(mob, player, optParams)
        if quest:getVar(player, 'Outcrop') ~= 1 then
            return
        end

        local killed = quest:getVar(player, 'Velkk')

        if killed < velkkWanted then
            quest:setVar(player, 'Velkk', killed + 1)
        end
    end,
}

local function dhoGatesZone()
    local zone =
    {
        ['Rocky_Outcrop'] = outcropActions,

        onEventFinish =
        {
            [14] = function(player, csid, option, npc)
                quest:setVar(player, 'Outcrop', 1)
            end,

            [16] = function(player, csid, option, npc)
                quest:complete(player)
            end,
        },
    }

    for _, name in ipairs(velkkNames) do
        zone[name] = velkkKill
    end

    return zone
end

quest.sections =
{
    -- Section: offer
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.ADOULIN, xi.quest.id.adoulin.THORN_IN_THE_SIDE)
        end,

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Zaffeld'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(5047)
                end,
            },

            onEventFinish =
            {
                [5047] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                        quest:setVar(player, 'Site', 0)
                        quest:setVar(player, 'Outcrop', 0)
                        quest:setVar(player, 'Velkk', 0)
                    end
                end,
            },
        },
    },

    -- Section: the caverns, the gates, and five Velkk
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.CIRDAS_CAVERNS] =
        {
            ['Congregation_Site'] = siteActions,

            onEventFinish =
            {
                [27] = function(player, csid, option, npc)
                    quest:setVar(player, 'Site', 1)
                end,
            },
        },

        [xi.zone.DHO_GATES] = dhoGatesZone(),

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Zaffeld'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(5049)
                end,
            },
        },
    },
}

return quest
