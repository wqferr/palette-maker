local HSV = require "hsv"

local ColorContainer = {}
ColorContainer.__index = ColorContainer

local NO_FRAME = love.image.newImageData(1, 1)
NO_FRAME:setPixel(0, 0, 0, 0, 0, 0)
NO_FRAME = love.graphics.newImage(NO_FRAME)

function ColorContainer.new(x, y, w, h, color, frame, frameMode)
    local c = {}
    setmetatable(c, ColorContainer)

    c.x = x
    c.y = y
    c.w = w
    c.h = h
    c.color = color or {0, 0, 1}

    if type(frame) == "string" then
        c.frame = love.graphics.newImage(frame)
    else
        c.frame = frame or NO_FRAME
    end

    c.frameMode = frameMode or false

    return c
end

function ColorContainer:getRGB()
    return HSV.toRGB(self:getHSV())
end

function ColorContainer:getHSV()
    return unpack(self.color)
end

function ColorContainer:setRGB(r, g, b)
    self:setHSV(HSV.fromRGB(r, g, b))
end

function ColorContainer:setHSV(h, s, v)
    if not h then
        h = self.color[1]
    end
    self.color = {h, s, v}
end

function ColorContainer:draw()
    local prevColor = {love.graphics.getColor()}

    love.graphics.setColor(self:getRGB())
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    if not self.frameMode then
        love.graphics.setColor(prevColor)
    end

    love.graphics.draw(self.frame, self.x, self.y)

    love.graphics.setColor(prevColor)
end


setmetatable(
    ColorContainer,
    {
        __call = function(t, ...)
            return ColorContainer.new(...)
        end
    }
)

return ColorContainer
