local HSV = require "hsv"
local ColorPicker = require "colorpicker"
local ClickMap = require "clickmap"
local ModeController = require "modecontroller"

local gradW, gradH = 200, 30

local hueGradientData, hueGradient
local satGradientData, satGradient
local lightGradientData, lightGradient
local pickerCursorImg
local huePicker, satPicker, lightPicker

function love.load()
    pickerCM = ClickMap()

    hueGradientData = love.image.newImageData(gradW, gradH)
    hueGradientData:mapPixel(
        function(x, y, r, g, b, a)
            local h = x/gradW * 360

            return HSV.toRGB(h, 1, 1)
        end
    )
    hueGradient = love.graphics.newImage(hueGradientData)

    lightGradientData = love.image.newImageData(gradW, gradH)
    lightGradientData:mapPixel(
        function(x, y, r, g, b, a)
            local l = x / gradW

            return HSV.toRGB(1, 1, l)
        end
    )
    lightGradient = love.graphics.newImage(lightGradientData)

    satGradientData = love.image.newImageData(gradW, gradH)
    satGradientData:mapPixel(
        function(x, y, r, g, b, a)
            local s = x/gradW

            return HSV.toRGB(1, s, 1)
        end
    )
    satGradient = love.graphics.newImage(satGradientData)

    pickerCursorImg = love.graphics.newImage("img/cursor.png")

    pickerController = ModeController(
        {
            normal = {
                updateCursor = function() end
            },
            grab = {
                __enter = function(controller, p)
                    pickerController.picker = p
                end,
                __exit = function()
                    pickerController.picker = nil
                end,
                updateCursor = function(x)
                    if pickerController.picker then
                        pickerController.picker:setCursorPos(x, 0)
                        updateGradients()
                    end
                end
            }
        },
        "normal"
    )

    huePicker = ColorPicker(
        hueGradient,
        pickerCursorImg,
        -pickerCursorImg:getWidth()/2,
        -pickerCursorImg:getHeight()/8
    )
    huePicker.x, huePicker.y = 500, 200

    lightPicker = ColorPicker(
        lightGradient,
        pickerCursorImg,
        -pickerCursorImg:getWidth()/2,
        -pickerCursorImg:getHeight()/8
    )
    lightPicker.x, lightPicker.y = 500, 250
    lightPicker:setPercent(1)

    satPicker = ColorPicker(
        satGradient,
        pickerCursorImg,
        -pickerCursorImg:getWidth()/2,
        -pickerCursorImg:getHeight()/8
    )
    satPicker.x, satPicker.y = 500, 300
    satPicker:setPercent(1)

    local click = function(r, x, y)
        pickerController:setMode("grab", r.picker)
    end
    local release = function(r, x, y)
        pickerController:setMode("normal")
    end

    local region = pickerCM:newRegion(
        "rect",
        click, release,
        huePicker.x, huePicker.y, gradW, gradH
    )
    region.picker = huePicker

    region = pickerCM:newRegion(
        "rect",
        click, release,
        lightPicker.x, lightPicker.y, gradW, gradH
    )
    region.picker = lightPicker

    region = pickerCM:newRegion(
        "rect",
        click, release,
        satPicker.x, satPicker.y, gradW, gradH
    )
    region.picker = satPicker
end

function love.draw()
    huePicker:draw(huePicker.x, huePicker.y)
    satPicker:draw(satPicker.x, satPicker.y)
    lightPicker:draw(lightPicker.x, lightPicker.y)

    love.graphics.setColor(getRGB())
    love.graphics.rectangle("fill", 500, 100, 50, 50)
    love.graphics.setColor(255, 255, 255)
end

function love.mousepressed(x, y, mb)
    local r = pickerCM:click(x, y)
    pickerController.updateCursor(x - huePicker.x)
end

function love.mousereleased(x, y, mb)
    pickerCM:release(x, y)
end

function love.mousemoved(x, y)
    x = x - huePicker.x
    x = math.max(0, math.min(x, gradW - 1))
    pickerController.updateCursor(x)
end



function getHSV()
    local h = 360 * huePicker:getPercent()
    local s = satPicker:getPercent()
    local v = lightPicker:getPercent()

    return h, s, v
end

function getRGB()
    return HSV.toRGB(getHSV())
end

function updateGradients()
    local h = (360 * huePicker:getPercent()) % 360

    lightGradientData = love.image.newImageData(gradW, gradH)
    lightGradientData:mapPixel(
        function(x, y, r, g, b, a)
            local v = x / gradW

            return HSV.toRGB(h, 1, v)
        end
    )
    lightGradient = love.graphics.newImage(lightGradientData)


    local v = lightPicker:getPercent()

    satGradientData = love.image.newImageData(gradW, gradH)
    satGradientData:mapPixel(
        function(x, y, r, g, b, a)
            local s = x/gradW

            return HSV.toRGB(h, s, v)
        end
    )
    satGradient = love.graphics.newImage(satGradientData)

    lightPicker:setPalette(lightGradient)
    satPicker:setPalette(satGradient)
end
