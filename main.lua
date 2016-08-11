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

    picker = ColorPicker(
        gradient, pickerCursorImg,
        -pickerCursorImg:getWidth()/2, -pickerCursorImg:getHeight()/8
    )
end

function love.draw()
    picker:draw(100, 100)
    love.graphics.setColor(picker:getColor())
    love.graphics.rectangle("fill", 500, 100, 50, 50)
    love.graphics.setColor(255, 255, 255)
end

function love.mousemoved(x, y)
    x = x - 100
    x = math.max(0, math.min(x, gradient:getWidth() - 1))
    picker:setCursorPos(x)
end
