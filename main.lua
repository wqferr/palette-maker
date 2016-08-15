local HSV = require "hsv"
local Slider = require "slider"
local ClickMap = require "clickmap"
local ModeController = require "modecontroller"
local ColorContainer = require "colorcontainer"
local EventListener = require "eventlistener"

local DEFAULT_FILE_NAME = "palette.png"

local gradW, gradH = 200, 30
local cellW, cellH = 20, 20
local gridX, gridY = 50, 50
local gridR, gridC = 16, 16
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

local fileName

local fonts

function love.load(arg)
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

    rgbDisplay = ColorContainer(550, 50, 100, 100, {0, 0, 1}, "img/rgbFrame.png", true)
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
                {0, 0, 1}, cellFrame
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
    keyListener:register("s",
                         function()
                             if love.keyboard.isDown("lctrl")
                                 or love.keyboard.isDown("rctrl") then
                                 save()
                             end
                         end
                    )

    fonts = {
        [12] = love.graphics.getFont(),
        [16] = love.graphics.newFont(16)
    }

    if arg[2] then
        fileName = arg[2]
        read()
    else
        fileName = DEFAULT_FILE_NAME
    end
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
    
    local midX = math.ceil(gridX + ((gridC+1) * (gridSpacing+cellW)) / 2)

    love.graphics.print("ctrl: increase brightness", gridX, math.ceil(gridY + (gridR+0.6)*(gridSpacing+cellH)))
    love.graphics.print("shift + ctrl: decrease brightness", gridX, math.ceil(gridY + (gridR+1.2)*(gridSpacing+cellH)))
    love.graphics.print("alt: increase saturation", gridX, math.ceil(gridY + (gridR+1.8)*(gridSpacing+cellH)))
    love.graphics.print("shift + alt: decrease saturation", gridX, math.ceil(gridY + (gridR+2.4)*(gridSpacing+cellH)))
    love.graphics.print(
        "ctrl + alt: color interpolation",
        gridX, math.ceil(gridY + (gridR+3)*(gridSpacing + cellH))
    )
    love.graphics.print("ctrl + shift + alt: copy", gridX, math.ceil(gridY + (gridR+3.6)*(gridSpacing+cellH)))

    love.graphics.print("ctrl + s: save", midX, math.ceil(gridY + (gridR+0.6)*(gridSpacing+cellH)))
    love.graphics.print("+: increase brightness", midX, math.ceil(gridY + (gridR+1.2)*(gridSpacing+cellH)))
    love.graphics.print("-: decrease brightness", midX, math.ceil(gridY + (gridR+1.8)*(gridSpacing+cellH)))
    love.graphics.print("backspace: reset brightness and saturation", midX, math.ceil(gridY + (gridR+2.4)*(gridSpacing+cellH)))

    love.graphics.setFont(fonts[16])
    love.graphics.print("Movement controls:", gridX, math.ceil(gridY + (gridR-0.2)*(gridSpacing+cellH)))
    love.graphics.print("Other controls:", midX, math.ceil(gridY + (gridR-0.2)*(gridSpacing+cellH)))
    love.graphics.setFont(fonts[12])
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

    rgbDisplay:setHSV(getHSV())
    selectedCell:setHSV(getHSV())
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

    cell:setHSV(nil, 0, 1)
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
    local r0, c0 = selectedRow, selectedCol
    local nxt = nextCell[direction]
    local r1, c1 = nxt(selectedRow, selectedCol)

    if r1 ~= selectedRow or c1 ~= selectedCol then
        local h, s, v = selectedCell:getHSV()
        selectCell(r1, c1)

        local setColor = true

        if love.keyboard.isDown("lctrl") then
            if love.keyboard.isDown("lalt") then
                -- if shift is held then it will copy the color
                -- to the next cell without any changes
                if not love.keyboard.isDown("lshift") then
                    setColor = false

                    local r2, c2 = nextFilledCell(r0, c0, direction)
                    if r2 then
                        local d = dist(r0, c0, r2, c2)

                        local h0, s0, v0 = cells[r0][c0]:getHSV()
                        local h2, s2, v2 = cells[r2][c2]:getHSV()
                        local dh, ds, dv = h2-h0, s2-s0, v2-v0
                        dh, ds, dv = dh/d, ds/d, dv/d

                        -- Linear interpolation of H, S and V
                        local i = 1
                        while r1 ~= r2 or c1 ~= c2 do
                            cells[r1][c1]:setHSV(
                                h0 + i*dh,
                                s0 + i*ds,
                                v0 + i*dv
                            )
                            r1, c1 = nxt(r1, c1)
                            i = i + 1
                        end
                        selectCell(r0, c0)
                    end
                end
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

function nextFilledCell(r, c, direction)
    local nxt = nextCell[direction]
    local nr, nc

    repeat
        nr, nc = nxt(r, c)
        if nr == r and nc == c then
            return nil
        else
            r, c = nr, nc
        end
    until not cells[r][c]:isWhite()

    return r, c
end

function dist(r1, c1, r2, c2)
    return math.abs(r2-r1) + math.abs(c2-c1)
end

function read()
    if love.filesystem.exists(fileName) then
        local data, err = love.filesystem.newFileData(fileName)
        if data then
            local paletteData = love.image.newImageData(data)
            paletteData:mapPixel(
                function(x, y, r, g, b, a)
                    cells[y+1][x+1]:setRGB(r, g, b)
                    return r, g, b
                end
            )
        else
            love.window.showMessageBox("Error reading file", "The palette could not be recovered", "error")
        end
    end
end

function save()
    local paletteData = love.image.newImageData(gridC, gridR)
    paletteData:mapPixel(
        function(x, y, r, g, b, a)
            return cells[y+1][x+1]:getRGB()
        end
    )
    local fileData = paletteData:encode("png")

    local file = io.open(fileName, "w+")
    if file then
        file:write(fileData:getString())
        file:close()
    else
        love.window.showMessageBox("Error writing file", "The palette could not be saved", "error")
    end
end
