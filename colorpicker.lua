
local ColorPicker = {}
ColorPicker.__index = ColorPicker


function ColorPicker.new(palette, cursorImg, cursorOffX, cursorOffY)
    local cp = {}
    setmetatable(cp, ColorPicker)

    cp.palette = palette
    cp.cursor = {
        x = 0,
        y = 0,
        offX = cursorOffX or 0,
        offY = cursorOffY or 0,
        img = cursorImg
    }

    return cp
end

function ColorPicker:getCursorPos()
    return self.cursor.x, self.cursor.y
end


function ColorPicker:setCursorPos(x, y)
    if x then
        self.cursor.x = x
    end
    if y then
        self.cursor.y = y
    end
end

function ColorPicker:getColor()
    return self.palette:getData():getPixel(
        self.cursor.x, self.cursor.y
    )
end

function ColorPicker:getWidth()
    return self.palette:getWidth()
end

function ColorPicker:getHeight()
    return self.palette:getHeight()
end

function ColorPicker:draw(x, y)
    love.graphics.draw(self.palette, x, y)
    love.graphics.draw(self.cursor.img, x + self.cursor.x + self.cursor.offX, y + self.cursor.y + self.cursor.offY)
end

setmetatable(ColorPicker, {
    __call = function(t, ...)
        return ColorPicker.new(...)
    end
})


return ColorPicker
