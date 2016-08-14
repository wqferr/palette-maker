-- Multi Stated Object

local MSO = {}
MSO.__index = function(t, k)
    local v = MSO[k]
    if v then
        return v
    end

    return t:getState()[k]
end

local function nop() end

function MSO.new(states, initState)
    local o = {}
    setmetatable(o, MSO)

    o.states = {}
    for id, state in pairs(states) do
        local s = {}

        for k, v in pairs(state) do
            s[k] = v
        end

        s.__enter = s.__enter or nop
        s.__exit = s.__exit or nop
        o.states[id] = s
    end
    
    if initState == nil then
        o.curState = next(o.states)
    else
        o.curState = initState
    end

    return o
end

function MSO:getState()
    return self.states[self.curState]
end

function MSO:getCurState()
    return self.curState
end

function MSO:setState(id)
    self:getState().__exit(self, id)
    self:getState().__enter(self)
    self.curState = id
end

setmetatable(MSO, {
    __call = function(t, ...)
        return MSO.new(...)
    end
})

return MSO
