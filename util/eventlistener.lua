local EventListener = {}
EventListener.__index = EventListener

function EventListener.new()
    local h = {}
    setmetatable(h, EventListener)

    h.events = {}

    return h
end

function EventListener:register(eventName, handler)
    local l = self.events[eventName] or {}
    table.insert(l, handler)
    self.events[eventName] = l
end

function EventListener:alert(eventName, ...)
    local handlers = self.events[eventName]
    if handlers then
        for i, f in ipairs(handlers) do
            f(eventName, ...)
        end
    end
end

setmetatable(
    EventListener,
    {
        __call = function(t, ...)
            return EventListener.new(...)
        end
    }
)
return EventListener
