-----------------------------------
-- Seasonal Events Handler
-----------------------------------
xi = xi or {}
xi.events = xi.events or {}
xi.events.handler = xi.events.handler or {}

-- Seasonal Event Type
SeasonalEvent = {}
SeasonalEvent.__index = SeasonalEvent
SeasonalEvent.__eq = function(c1, c2)
    return c1.id == c2.id
end

function SeasonalEvent:new(id)
    local obj = {}
    setmetatable(obj, self)
    obj.id = id
    obj.isEnabled = false
    obj.enableCheck = function()
        return false
    end

    obj.startFunc = {}
    obj.endFunc = {}
    return obj
end

function SeasonalEvent:setEnableCheck(enableCheck)
    self.enableCheck = enableCheck
    return self
end

function SeasonalEvent:setStartFunction(func)
    self.startFunc = func
    return self
end

function SeasonalEvent:setEndFunction(func)
    self.endFunc = func
    return self
end

-- Login server message shown while the event is active.
-- Accepts a string, or a function returning a string for
-- events whose announcement changes over their run.
function SeasonalEvent:setServerMessage(message)
    self.serverMessage = message
    return self
end

function SeasonalEvent:checkStarting()
    local isEnabled = self.enableCheck()
    if isEnabled then
        print('Starting Seasonal Event: ' .. self.id)
        self:startFunc()
    end

    return self
end

function SeasonalEvent:checkEnding()
    local isEnabled = self:enableCheck()
    if not isEnabled then
        print('Ending Seasonal Event: ' .. self.id)
        self:endFunc()
    end

    return self
end

-- NOTE: Since this is caching require'd tables, this system won't easily
--     : work with Lua hot-reloading (yet)!
xi.events.registeredEvents =
{
    require('scripts/events/starlight_celebration'),
    require('scripts/events/egg_hunt_egg-stravaganza'),
    require('scripts/events/mog_bonanza'),
    require('scripts/events/sunbreeze_festival'),
    require('scripts/events/valentiones_day'),
    require('scripts/events/new_years'),
    require('scripts/events/adventurer_appreciation'),
}

xi.events.handler.getActiveEventMessages = function()
    local messages = ''

    for _, event in pairs(xi.events.registeredEvents) do
        if
            event.serverMessage and
            event.enableCheck()
        then
            local message = event.serverMessage

            if type(message) == 'function' then
                message = message()
            end

            if
                message and
                message ~= ''
            then
                messages = messages .. '\n' .. message .. '\n'
            end
        end
    end

    return messages
end

xi.events.handler.checkSeasonalEvents = function()
    print('Checking Seasonal Events')

    for _, event in pairs(xi.events.registeredEvents) do
        event:checkEnding()
    end

    for _, event in pairs(xi.events.registeredEvents) do
        event:checkStarting()
    end
end

return xi.events.handler
