-----------------------------------
-- Title Changer NPC Functions
-----------------------------------
xi = xi or {}
xi.titleChanger = xi.titleChanger or {}

local function titleMask(player, titleGroup)
    local returnValue = 0
    local titles = {}

    if titleGroup and titleGroup.title then
        titles = titleGroup.title
    end

    for i = 1, 28 do
        if titles[i] == nil or titles[i] == 0 or not player:hasTitle(titles[i]) then
            returnValue = bit.bor(returnValue, bit.lshift(1, i))
        end
    end

    return returnValue
end

-----------------------------------
-- public title changer functions
-----------------------------------

xi.titleChanger.onTrigger = function(player, eventId, titleInfo)
    player:startEvent(
        eventId,
        titleMask(player, titleInfo[1]),
        titleMask(player, titleInfo[2]),
        titleMask(player, titleInfo[3]),
        titleMask(player, titleInfo[4]),
        titleMask(player, titleInfo[5]),
        titleMask(player, titleInfo[6]),
        1,
        player:getGil()
    )
end

xi.titleChanger.onEventFinish = function(player, csid, option, eventId, titleInfo)
    if csid == eventId then
        local group = titleInfo[bit.rshift(option, 8) + 1]
        if group then
            local title = group.title[option % 256]

            -- OWNERSHIP MUST BE RE-CHECKED SERVER-SIDE. titleMask above already
            -- computes exactly this -- it flags every title the player does NOT
            -- have so the client greys it out -- but that is only a UI hint, and
            -- this handler trusted the returned option outright.
            -- CLuaBaseEntity::setTitle is documented "Updates the player's current
            -- title AND ADDS TO THEIR PROFILE" (it calls charutils::setTitle), so
            -- selecting a title you do not own GRANTED it for the group's gil cost.
            -- These tables include quest-gated titles -- Tuh_Almobankha's list
            -- carries BENNU_DEPLUMER, RANI_DECROWNER and the other Abyssea NM
            -- titles, which the Cavernous Maw quests test with hasTitle() as their
            -- completion gate. That made this a gil-priced bypass of those quests.
            -- A title changer should only ever re-display titles already earned.
            if title and player:hasTitle(title) and player:delGil(group.cost) then
                player:setTitle(title)
            end
        end
    end
end
