local HSV = require "hsv"
local ColorPicker = require "colorpicker"

local gradientData, gradient
local pickerCursorImg
local picker

function love.load()
    gradientData = love.image.newImageData(200, 30)

    gradientData:mapPixel(
        function(x, y, r, g, b, a)
            local h = x / gradientData:getWidth() * 360

            return HSV.toRGB(h, 1, 1)
        end
    )
    gradient = love.graphics.newImage(gradientData)
    pickerCursorImg = love.graphics.newImage("img/cursor.png")

    picker = ColorPicker(gradient, pickerCursorImg)
end

function love.draw()

end

