local Button = {}
Button.__index = Button

Button.new = function(text, x, y, w, h, states, initState)
    local b = {}
    setmetatable(b, Button)

    self:setText(text)

    b.x = x
    b.y = y
    b.w = w
    b.h = h

    b.states = {}

    for k, v in pairs(states) do
        self:addState(v)
    end

    b.state = initState or next(states)

    return b
end

function Button:draw()
    local c = {love.graphics.getColor()}

    love.graphics.setColor(self:getColor())
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    love.graphics.setColor(self:getTextColor())
    love.graphics.draw(self.text, self.textX, self.textY)

    love.graphics.setColor(c)
end

function Button:containsPoint(x, y)
    return x >= self.x and y >= self.y
            and x <= self.x + self.w and y <= self.y + self.h
end

function Button:getColor()
    return self:getState().color
end

function Button:getTextColor()
    return self:getState().textColor
end

function Button:getText()
    return self.text
end

function Button:setText(text)
    if type(text) == "string" then
        text = love.graphics.newText(love.graphics.getFont(), text)
    end

    self.text = text
    self.textX = (self.x+self.text:getWidth()) / 2
    self.textY = (self.y+self.text:getHeight()) / 2
end

function Button:addState(id, state)
    local s = {}

    s.color = state.color or {30, 30, 30}
    s.textColor = state.textColor or {170, 170, 170}
    s.enter = state.enter or function() end

    b.states[id] = s
end

function Button:setState(stateId)
    local prevState = self.state
    self.state = stateId
    self:getState().enter(self, prevState)
end

function Button:getState()
    return self.states[self.state]
end

function Button:getStateId()
    return self.state
end

return Button
