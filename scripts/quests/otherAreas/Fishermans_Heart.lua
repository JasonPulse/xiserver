-----------------------------------
-- Fisherman's Heart
-----------------------------------
-- Log ID: 4, Quest ID: 11
-- Katsunaga : Mhaura (H-9)
--
-- Retail (bg-wiki "Fisherman's Heart"): requires Fishing skill 20. Speak to
-- Katsunaga, then trade him a Gugru Tuna and he reports your fishing history.
-- Repeatable.
--
-- CSIDs decoded offline with xidat/csidmsg.py (blob + data[] resolution, see
-- that file's header for the three fixes that make it work). Each id was
-- confirmed by reading the messages it emits against `xi-dat dialog 249`:
--   190 -> 7078  'I have nothing to say to one who has never held a fishing
--                 rod'                       => Fishing skill 0
--   191 -> 7079,7080  'you have dabbled...but you still have a long way to go'
--                                            => has skill, below the gate
--   192 -> 7081-7085  the offer; 7082 is the Yes/No selection and 7085 is
--                     'I only ask you to bring me ${item}'
--   193 -> 7086-7089  turn-in; 7087 casts/catches, 7088 longest/heaviest
--   194 -> 7090  'If you want me to tell you about your past catches, bring
--                 me ${item}'                => reminder while accepted
-- The previous stub fired csid 100, which Katsunaga does not own.
-----------------------------------
local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.FISHERMANS_HEART)

-- bg-wiki lists the reward as the fishing-history readout itself (delivered by
-- the csid 193 cutscene) plus the Accuracy/Evasion Vorseal unlock -- no gil, no
-- item, no fame. Mhaura is Selbina/Rabao fame territory in any case, not
-- Windurst, and since the quest is repeatable a fame payout here would have been
-- an unbounded fame farm.
quest.reward = {}

local fishingGate = 20

local function tradedGugruTuna(trade)
    return npcUtil.tradeHasExactly(trade, xi.item.GUGRU_TUNA_1) or
        npcUtil.tradeHasExactly(trade, xi.item.GUGRU_TUNA_2)
end

-- Katsunaga sizes the player up by Fishing skill before he will talk shop.
--
-- Must use getCharSkillLevel, not getSkillLevel. Fishing is skill index 48, and
-- for indices 48-57 charutils.cpp:3861 packs WorkingSkills as
-- (RealSkills.skill / 10) * 0x20 + RealSkills.rank -- so getSkillLevel returns
-- a packed value, and comparing it against a linear threshold silently moves
-- the gate (200 would have been reached at real fishing skill ~7, not 20).
-- getCharSkillLevel returns RealSkills.skill directly, which is skill * 10;
-- this is the convention every other skill-gated quest here uses.
local function greetingEvent(player)
    local fishing = player:getCharSkillLevel(xi.skill.FISHING) / 10

    if fishing == 0 then
        return 190
    elseif fishing < fishingGate then
        return 191
    end

    return nil
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.WINDURST) >= 2
        end,

        [xi.zone.MHAURA] =
        {
            ['Katsunaga'] =
            {
                onTrigger = function(player, npc)
                    local turnAway = greetingEvent(player)
                    if turnAway then
                        return quest:progressEvent(turnAway)
                    end

                    return quest:progressEvent(192)
                end,
            },

            onEventFinish =
            {
                [192] = function(player, csid, option, npc)
                    if option == 0 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED or
                status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.MHAURA] =
        {
            ['Katsunaga'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(194)
                end,

                onTrade = function(player, npc, trade)
                    if tradedGugruTuna(trade) then
                        return quest:progressEvent(193)
                    end
                end,
            },

            onEventFinish =
            {
                [193] = function(player, csid, option, npc)
                    player:confirmTrade()
                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
