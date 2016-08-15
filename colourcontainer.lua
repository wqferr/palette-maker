local HSV = require "hsv"

local ColourContainer = {}
ColourContainer.__index = ColourContainer

local NO_FRAME = love.image.newImageData(1, 1)
NO_FRAME:setPixel(0, 0, 0, 0, 0, 0)
NO_FRAME = love.graphics.newImage(NO_FRAME)

function ColourContainer.new(x, y, w, h, colour, frame, frameMode)
    local c = {}
    setmetatable(c, ColourContainer)

    c.x = x
    c.y = y
    c.w = w
    c.h = h
    c.colour = colour or {0, 0, 1}

    if type(frame) == "string" then
        c.frame = love.graphics.newImage(frame)
    else
        c.frame = frame or NO_FRAME
    end

    c.frameMode = frameMode or false

    return c
end

function ColourContainer:getRGB()
    return HSV.toRGB(self:getHSV())
end

function ColourContainer:getHSV()
    return unpack(self.colour)
end

function ColourContainer:setRGB(r, g, b)
    self:setHSV(HSV.fromRGB(r, g, b))
end

function ColourContainer:setHSV(h, s, v)
    if not h then
        h = self.colour[1]
    end
    self.colour = {h, s, v}
end

function ColourContainer:isWhite()
    local h, s, v = self:getHSV()
    return s == 0 and v == 1
end

function ColourContainer:draw()
    local prevColour = {love.graphics.getColor()}

    love.graphics.setColor(self:getRGB())
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    if not self.frameMode then
        love.graphics.setColor(prevColour)
    end

    love.graphics.draw(self.frame, self.x, self.y)

    love.graphics.setColor(prevColour)
end


setmetatable(
    ColourContainer,
    {
        __call = function(t, ...)
            return ColourContainer.new(...)
        end
    }
)

return ColourContainer
