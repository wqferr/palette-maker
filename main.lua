local HSV = require "hsv"
local Slider = require "slider"
local ClickMap = require "clickmap"
local ModeController = require "modecontroller"
local ColorContainer = require "colorcontainer"
local EventListener = require "eventlistener"

local gradW, gradH = 200, 30
local cellW, cellH = 20, 20
local gridX, gridY = 50, 50
local gridR, gridC = 15, 15
local gridSpacing = 7

local selectedRow, selectedCol
local selectedCell
local cellFrame, selectFrame

local rgbDisplay, rgbDisplayIcon
local hueGradientData, hueGradient
local satGradientData, satGradient
local valGradientData, valGradient
local sliderCursorImg
local hueSlider, satSlider, valSlider

local keyListener
local sliderController, cellController

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

    valGradientData = love.image.newImageData(gradW, gradH)
    valGradientData:mapPixel(
        function(x, y, r, g, b, a)
            local l = x / gradW

            return HSV.toRGB(0, 0, l)
        end
    )
    valGradient = love.graphics.newImage(valGradientData)

    satGradientData = love.image.newImageData(gradW, gradH)
    satGradientData:mapPixel(
        function(x, y, r, g, b, a)
            local s = x/gradW

            return HSV.toRGB(0, s, 1)
        end
    )
    satGradient = love.graphics.newImage(satGradientData)

    sliderController = ModeController(
        {
            normal = {
                updateCursor = function() end
            },
            grab = {
                __enter = function(controller, p)
                    sliderController.slider = p
                end,
                __exit = function()
                    sliderController.slider = nil
                end,
                updateCursor = function(x)
                    if sliderController.slider then
                        sliderController.slider:setCursorPos(x, 0)
                        updateGradients()
                    end
                end
            }
        },
        "normal"
    )

    sliderCursorImg = love.graphics.newImage("img/cursor.png")
    hueSlider = Slider(
        hueGradient,
        sliderCursorImg,
        -sliderCursorImg:getWidth()/2,
        -sliderCursorImg:getHeight()/8
    )
    hueSlider.x, hueSlider.y = 500, 200

    valSlider = Slider(
        valGradient,
        sliderCursorImg,
        -sliderCursorImg:getWidth()/2,
        -sliderCursorImg:getHeight()/8
    )
    valSlider.x, valSlider.y = 500, 300
    valSlider:setPercent(1)

    satSlider = Slider(
        satGradient,
        sliderCursorImg,
        -sliderCursorImg:getWidth()/2,
        -sliderCursorImg:getHeight()/8
    )
    satSlider.x, satSlider.y = 500, 250
    satSlider:setPercent(0)

    clickmap = ClickMap()

    local click = function(r, x, y)
        sliderController:setMode("grab", r.slider)
    end
    local release = function(r, x, y)
        sliderController:setMode("normal")
    end

    local region = clickmap:newRegion(
        "rect",
        click, release,
        hueSlider.x, hueSlider.y, gradW, gradH
    )
    region.slider = hueSlider

    region = clickmap:newRegion(
        "rect",
        click, release,
        valSlider.x, valSlider.y, gradW, gradH
    )
    region.slider = valSlider

    region = clickmap:newRegion(
        "rect",
        click, release,
        satSlider.x, satSlider.y, gradW, gradH
    )
    region.slider = satSlider

    rgbDisplay = ColorContainer(550, 50, 100, 100, {getRGB()}, "img/rgbFrame.png", true)
    rgbDisplayIcon = love.graphics.newImage("img/rgbDisplay.png")


    cells = {}
    cellFrame = love.graphics.newImage("img/cellFrame.png")
    selectFrame = love.graphics.newImage("img/selection.png")
    
    local clickCell = function(region, x, y, mb)
        if mb == 3 then
            clear(region.cell)
        else
            local h, s, v = region.cell:getHSV()
            hueSlider:setPercent(h / 360)
            satSlider:setPercent(s)
            valSlider:setPercent(v)

            if mb == 1 then
                selectCell(region.row, region.col)
            elseif mb == 2 then
                selectedCell:setHSV(h, s, v)
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
    selectedRow = 1
    selectedCol = 1


    keyListener = EventListener()
    keyListener:register("up", moveSelection)
    keyListener:register("down", moveSelection)
    keyListener:register("left", moveSelection)
    keyListener:register("right", moveSelection)
    keyListener:register("backspace", function(...) clear() end)
    keyListener:register("delete", function(...) clear() end)
    keyListener:register("=",
                         function()
                             if love.keyboard.isDown("lshift")
                                 or love.keyboard.isDown("rshift") then
                                 lighten()
                             end
                         end
                     )
    keyListener:register("-", darken)
end

function love.draw()
    local h, s, v = getHSV()

    h = ("H: %d"):format(h)
    s = ("S: %.2f"):format(s)
    v = ("V: %.2f"):format(v)

    hueSlider:draw(hueSlider.x, hueSlider.y)
    love.graphics.print(h, hueSlider.x + gradW + 10, hueSlider.y + 8)

    valSlider:draw(valSlider.x, valSlider.y)
    love.graphics.print(v, valSlider.x + gradW + 10, valSlider.y + 8)

    satSlider:draw(satSlider.x, satSlider.y)
    love.graphics.print(s, satSlider.x + gradW + 10, satSlider.y + 8)

    rgbDisplay:draw()

    local rgb = ("RGB: %d, %d, %d"):format(getRGB())
    local w = love.graphics.getFont():getWidth(rgb)
    love.graphics.print(rgb, rgbDisplay.x + (rgbDisplay.w - w)/2, rgbDisplay.y + rgbDisplay.h)

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
    sliderController.updateCursor(x - hueSlider.x)
end

function love.mousereleased(x, y, mb)
    clickmap:release(x, y)
end

function love.mousemoved(x, y)
    x = x - hueSlider.x
    x = math.max(0, math.min(x, gradW - 1))
    sliderController.updateCursor(x)
end

function love.keypressed(k)
    keyListener:alert(k)
end



function getHSV()
    local h = (360*hueSlider:getPercent()) % 360
    local s = satSlider:getPercent()
    local v = valSlider:getPercent()

    return h, s, v
end

function getRGB()
    return HSV.toRGB(getHSV())
end

function updateGradients()
    local h, s, v = getHSV()

    valGradientData = love.image.newImageData(gradW, gradH)
    valGradientData:mapPixel(
        function(x, y, r, g, b, a)
            local v = x / gradW

            return HSV.toRGB(h, s, v)
        end
    )
    valGradient = love.graphics.newImage(valGradientData)


    satGradientData = love.image.newImageData(gradW, gradH)
    satGradientData:mapPixel(
        function(x, y, r, g, b, a)
            local s = x/gradW

            return HSV.toRGB(h, s, v)
        end
    )
    satGradient = love.graphics.newImage(satGradientData)

    valSlider:setImage(valGradient)
    satSlider:setImage(satGradient)

    rgbDisplay:setColor(getRGB())
    selectedCell:setColor(getRGB())
end

function updateSliders()
    local h, s, v = selectedCell:getHSV()
    hueSlider:setPercent(h/360)
    satSlider:setPercent(s)
    valSlider:setPercent(v)

    rgbDisplay:setHSV(h, s, v)
end

function clear(cell)
    cell = cell or selectedCell

    cell:setColor(255, 255, 255)
    if cell == selectedCell then
        updateSliders()
    end
end

function selectCell(r, c)
    selectedRow = r
    selectedCol = c
    selectedCell = cells[r][c]
    updateSliders()
end

function lighten()
    local h, s, v = selectedCell:getHSV()
    v = math.min(1, 0.1 + v*1.1)
    selectedCell:setHSV(h, s, v)
    updateSliders()
end

function darken()
    local h, s, v = selectedCell:getHSV()
    v = math.max(0, (v-0.1) / 1.1)
    selectedCell:setHSV(h, s, v)
    updateSliders()
end

nextCell = {
    up = function(r, c)
        if r > 1 then
            return r-1, c
        else
            return r, c
        end
    end,
    down = function(r, c)
        if r < gridR then
            return r+1, c
        else
            return r, c
        end
    end,
    left = function(r, c)
        if c > 1 then
            return r, c-1
        else
            return r, c
        end
    end,
    right = function(r, c)
        if c < gridC then
            return r, c+1
        else
            return r, c
        end
    end
}
setmetatable(
    nextCell,
    {
        __call = function(t, r, c, k)
            return t[k](r, c)
        end
    }
)

function moveSelection(direction)
    local nr, nc = nextCell(selectedRow, selectedCol, direction)
    if nr ~= selectedRow or nc ~= selectedCol then
        local h, s, v = selectedCell:getHSV()
        selectCell(nr, nc)

        local setColor = true

        if love.keyboard.isDown("lctrl") then
            if love.keyboard.isDown("lalt") then
                -- TODO transition
            elseif love.keyboard.isDown("lshift") then
                v = math.max(0, (v-0.1) / 1.1)
            else
                v = math.min(1, 0.1 + v*1.1)
            end
        elseif love.keyboard.isDown("lalt") then
            if love.keyboard.isDown("lshift") then
                s = math.max(0, (s-0.1) / 1.1)
            else
                s = math.min(1, 0.1 + s*1.1)
            end
        else
            setColor = false
        end

        if setColor then
            selectedCell:setHSV(h, s, v)
        end

        updateSliders()
        updateGradients()
        return true
    end
    return false
end
