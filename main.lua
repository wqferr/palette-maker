local HSV = require "hsv"

local gradientData, gradient
local cursor

function love.load()
    gradientData = love.image.newImageData(200, 30)

    gradientData:mapPixel(
        function(x, y, r, g, b, a)
            local h = x / gradientData:getWidth() * 360

            return HSV.toRGB(h, 1, 1)
        end
    )
    gradient = love.graphics.newImage(gradientData)

    cursor = love.graphics.newImage("img/cursor.png")
end

function love.draw()
    local x = math.min(gradient:getWidth()-1, love.mouse.getX())
    local y = gradient:getHeight()/8 + 1
    love.graphics.draw(gradient, 0, y)
    love.graphics.draw(cursor, x - cursor:getWidth()/2, 0)
end

