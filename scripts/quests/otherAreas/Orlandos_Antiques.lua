-----------------------------------
-- Orlando's Antiques
-----------------------------------
-- Log ID: 4, Quest ID: 7
-- Orlando !pos -37.268 -9 58.047 249
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.ORLANDOS_ANTIQUES)

local tradeItems =
{
    { id =   564, gil = 200 }, -- Fingernail Sack
    { id =   565, gil = 250 }, -- Teeth Sack
    { id =   566, gil = 200 }, -- Goblin Cup
    { id =   568, gil = 120 }, -- Goblin Die
    { id =   656, gil = 600 }, -- Beastcoin
    { id =   748, gil = 900 }, -- Gold Beastcoin
    { id =   749, gil = 800 }, -- Mythril Beastcoin
    { id =   750, gil = 750 }, -- Silver Beastcoin
    { id =   898, gil = 120 }, -- Chicken Bone
    { id =   900, gil = 100 }, -- Fish Bone
    { id = 16995, gil = 150 }, -- Rotten Meat
}

local function findTrade(trade)
    for _, entry in ipairs(tradeItems) do
        if trade:hasItemQty(entry.id, 8) and trade:getItemCount() == 8 then
            return entry
        elseif trade:hasItemQty(entry.id, 1) then
            return nil, entry.id
        end
    end

    return nil, nil
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.WINDURST) >= 2 and
                player:hasKeyItem(xi.ki.CHOCOBO_LICENSE)
        end,

        [xi.zone.MHAURA] =
        {
            ['Orlando'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(101)
                end,
            },

            onEventFinish =
            {
                [101] = function(player, csid, option, npc)
                    quest:begin(player)
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
            ['Orlando'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(103)
                end,

                onTrade = function(player, npc, trade)
                    local exact, partial = findTrade(trade)
                    if exact then
                        quest:setVar(player, 'Payout', exact.gil)
                        return quest:progressEvent(102, xi.settings.main.GIL_RATE * exact.gil, exact.id)
                    elseif partial then
                        return quest:progressEvent(104)
                    end
                end,
            },

            onEventFinish =
            {
                [102] = function(player, csid, option, npc)
                    player:tradeComplete()
                    player:addFame(xi.fameArea.WINDURST, 10)
                    -- No GIL_RATE here: npcUtil.giveCurrency already applies the
                    -- rate itself (`amount = amount * currencyType[2]`,
                    -- npc_util.lua), so multiplying it in first squared it. This is
                    -- the only double-applying call site in the tree. It is
                    -- invisible today only because GIL_RATE defaults to 1.000
                    -- (settings/default/main.lua:127) -- raise the rate and this
                    -- one quest pays the square of everything else.
                    npcUtil.giveCurrency(player, 'gil', quest:getVar(player, 'Payout'))
                    quest:setVar(player, 'Payout', 0)

                    if player:getQuestStatus(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.ORLANDOS_ANTIQUES) == xi.questStatus.QUEST_ACCEPTED then
                        quest:complete(player)
                    end
                end,
            },
        },
    },
}

return quest
