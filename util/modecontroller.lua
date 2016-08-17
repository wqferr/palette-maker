local ModeController = {}
ModeController.__index = function(t, k)
    local v = ModeController[k]
    if v then
        return v
    end

    return t.modes[t.curMode][k]
end

local function nop() end

function ModeController.new(modes, initMode)
    local mc = {}
    setmetatable(mc, ModeController)

    mc.modes = {}
    for id, mode in pairs(modes) do
        local s = {}

        for k, v in pairs(mode) do
            s[k] = v
        end

        s.__enter = s.__enter or nop
        s.__exit = s.__exit or nop
        mc.modes[id] = s
    end
    
    if initMode == nil then
        mc.curMode = next(o.modes)
    else
        mc.curMode = initMode
    end

    return mc
end

function ModeController:getMode()
    return self.curMode
end

function ModeController:setMode(id, arg)
    self.modes[self.curMode].__exit(self, id, arg)
    self.modes[id].__enter(self, arg)
    self.curMode = id
end

setmetatable(ModeController, {
    __call = function(t, ...)
        return ModeController.new(...)
    end
})

return ModeController
