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
        mc.curMode = next(mc.modes)
    else
        mc.curMode = initMode
    end

    local m = mc.modes[mc.curMode]
    if m.__enter then
        m.__enter(mc)
    end

    return mc
end

function ModeController:getMode()
    return self.curMode
end

function ModeController:setMode(id, ...)
    local prev = self.curMode
    self.modes[self.curMode].__exit(self, id, ...)
    self.curMode = id
    self.modes[id].__enter(self, prev, ...)
end

setmetatable(ModeController, {
    __call = function(t, ...)
        return ModeController.new(...)
    end
})

return ModeController
