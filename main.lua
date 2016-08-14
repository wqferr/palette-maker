local HSV = require "hsv"
local Slider = require "slider"
local ClickMap = require "clickmap"
local ModeController = require "modecontroller"
local ColorContainer = require "colorcontainer"

local gradW, gradH = 200, 30
local cellW, cellH = 20, 20
local gridX, gridY = 50, 50
local gridR, gridC = 15, 15
local gridSpacing = 7

local selectedCell
local cellFrame, selectFrame

local rgbPicker, rgbPickerIcon
local hueGradientData, hueGradient
local satGradientData, satGradient
local lightGradientData, lightGradient
local pickerCursorImg
local huePicker, satPicker, lightPicker

local cells

function love.load()
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

            return HSV.toRGB(0, 0, l)
        end
    )
    lightGradient = love.graphics.newImage(lightGradientData)

    satGradientData = love.image.newImageData(gradW, gradH)
    satGradientData:mapPixel(
        function(x, y, r, g, b, a)
            local s = x/gradW

            return HSV.toRGB(0, s, 1)
        end
    )
    satGradient = love.graphics.newImage(satGradientData)

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

    pickerCursorImg = love.graphics.newImage("img/cursor.png")
    huePicker = Slider(
        hueGradient,
        pickerCursorImg,
        -pickerCursorImg:getWidth()/2,
        -pickerCursorImg:getHeight()/8
    )
    huePicker.x, huePicker.y = 500, 200

    lightPicker = Slider(
        lightGradient,
        pickerCursorImg,
        -pickerCursorImg:getWidth()/2,
        -pickerCursorImg:getHeight()/8
    )
    lightPicker.x, lightPicker.y = 500, 300
    lightPicker:setPercent(1)

    satPicker = Slider(
        satGradient,
        pickerCursorImg,
        -pickerCursorImg:getWidth()/2,
        -pickerCursorImg:getHeight()/8
    )
    satPicker.x, satPicker.y = 500, 250
    satPicker:setPercent(0)

    clickmap = ClickMap()

    local click = function(r, x, y)
        pickerController:setMode("grab", r.picker)
    end
    local release = function(r, x, y)
        pickerController:setMode("normal")
    end

    local region = clickmap:newRegion(
        "rect",
        click, release,
        huePicker.x, huePicker.y, gradW, gradH
    )
    region.picker = huePicker

    region = clickmap:newRegion(
        "rect",
        click, release,
        lightPicker.x, lightPicker.y, gradW, gradH
    )
    region.picker = lightPicker

    region = clickmap:newRegion(
        "rect",
        click, release,
        satPicker.x, satPicker.y, gradW, gradH
    )
    region.picker = satPicker

    rgbPicker = ColorContainer(550, 50, 100, 100, {getRGB()}, "img/rgbFrame.png", true)
    rgbPickerIcon = love.graphics.newImage("img/rgbPicker.png")


    cells = {}
    cellFrame = love.graphics.newImage("img/cellFrame.png")
    selectFrame = love.graphics.newImage("img/selection.png")
    
    local clickCell = function(region, x, y, mb)
        if mb == 3 then
            region.cell:setColor(255, 255, 255)
            if region.cell == selectedCell then
                huePicker:setPercent(0)
                satPicker:setPercent(0)
                lightPicker:setPercent(1)
            end
        else
            local r, g, b = region.cell:getColor()
            local h, s, v = HSV.fromRGB(r/255, g/255, b/255)
            huePicker:setPercent(h / 360)
            satPicker:setPercent(s)
            lightPicker:setPercent(v)

            if mb == 1 then
                selectedCell = cells[region.row][region.col]
            elseif mb == 2 then
                selectedCell:setColor(255*r, 255*g, 255*b)
            end
        end

        updateGradients()
    end

    local nop = function() end

    for i = 1, gridR do
        cells[i] = {}

        for j = 1, gridC do
            local x, y = gridX + (j-1) * (gridSpacing + cellW),
                         gridY + (i-1) * (gridSpacing + cellH)

            local c = ColorContainer(
                x, y, cellW, cellH,
                {255, 255, 255}, cellFrame
            )
            local region = clickmap:newRegion("rect", clickCell, nop, x, y, cellW, cellH)
            region.cell = c
            region.row = i
            region.col = j

            cells[i][j] = c
        end
    end
    selectedCell = cells[1][1]
end

function love.draw()
    local h, s, v = getHSV()

    h = ("H: %d"):format(h)
    s = ("S: %.2f"):format(s)
    v = ("V: %.2f"):format(v)

    huePicker:draw(huePicker.x, huePicker.y)
    love.graphics.print(h, huePicker.x + gradW + 10, huePicker.y + 8)

    lightPicker:draw(lightPicker.x, lightPicker.y)
    love.graphics.print(v, lightPicker.x + gradW + 10, lightPicker.y + 8)

    satPicker:draw(satPicker.x, satPicker.y)
    love.graphics.print(s, satPicker.x + gradW + 10, satPicker.y + 8)

    rgbPicker:draw()
    --love.graphics.draw(rgbPickerIcon, rgbPicker.x, rgbPicker.y)

    local rgb = ("RGB: %d, %d, %d"):format(getRGB())
    local w = love.graphics.getFont():getWidth(rgb)
    love.graphics.print(rgb, rgbPicker.x + (rgbPicker.w - w)/2, rgbPicker.y + rgbPicker.h)

    for i, row in ipairs(cells) do
        for j, cell in ipairs(row) do
            cell:draw()
        end
    end

    if selectedCell then
        love.graphics.draw(selectFrame, selectedCell.x - 5, selectedCell.y - 5)
    end
end

function love.mousepressed(x, y, mb)
    local r = clickmap:click(x, y, mb)
    pickerController.updateCursor(x - huePicker.x)
end

function love.mousereleased(x, y, mb)
    clickmap:release(x, y)
end

function love.mousemoved(x, y)
    x = x - huePicker.x
    x = math.max(0, math.min(x, gradW - 1))
    pickerController.updateCursor(x)
end



function getHSV()
    local h = (360*huePicker:getPercent()) % 360
    local s = satPicker:getPercent()
    local v = lightPicker:getPercent()

    return h, s, v
end

function getRGB()
    return HSV.toRGB(getHSV())
end

function updateGradients()
    local h, s, v = getHSV()

    lightGradientData = love.image.newImageData(gradW, gradH)
    lightGradientData:mapPixel(
        function(x, y, r, g, b, a)
            local v = x / gradW

            return HSV.toRGB(h, s, v)
        end
    )
    lightGradient = love.graphics.newImage(lightGradientData)


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

    rgbPicker:setColor(getRGB())
    selectedCell:setColor(getRGB())
end
