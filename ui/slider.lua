
local Slider = {}
Slider.__index = Slider


function Slider.new(image, cursorImg, cursorOffX, cursorOffY)
    local s = {}
    setmetatable(s, Slider)

    s.image = image
    s.cursor = {
        x = 0,
        y = 0,
        offX = cursorOffX or 0,
        offY = cursorOffY or 0,
        img = cursorImg
    }

    return s
end

function Slider:getCursorPos()
    return self.cursor.x, self.cursor.y
end

function Slider:setCursorPos(x, y)
    if x then
        self.cursor.x = x
    end
    if y then
        self.cursor.y = y
    end
end

function Slider:getPercent()
    return self.cursor.x / (self:getWidth()-1)
end

function Slider:setPercent(p)
    self.cursor.x = p * (self:getWidth()-1)
end

function Slider:setImage(img)
    self.image = img
end

function Slider:getWidth()
    return self.image:getWidth()
end

function Slider:getHeight()
    return self.image:getHeight()
end

function Slider:draw(x, y)
    love.graphics.draw(self.image, x, y)
    love.graphics.draw(self.cursor.img, x + self.cursor.x + self.cursor.offX, y + self.cursor.y + self.cursor.offY)
end

setmetatable(Slider, {
    __call = function(t, ...)
        return Slider.new(...)
    end
})


return Slider
