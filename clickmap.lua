local ClickMap = {}
ClickMap.__index = ClickMap

ClickMap.shapes = {}

function ClickMap.new(offX, offY)
    local cm = {}
    setmetatable(cm, ClickMap)

    cm.regions = {}
    cm:setOffset(offX, offY)

    return cm
end

function ClickMap.registerShape(name, new, check)
    if ClickMap.shapes[name] then
        return false
    end
    local s = {
        new = new,
        check = check
    }
    s.__index = s

    ClickMap.shapes[name] = s
    return true
end

function ClickMap:newRegion(shape, click, release, x, y, ...)
    local s = ClickMap.shapes[shape]
    local r = s.new(x, y, ...)
    setmetatable(r, s)
    r.click = click
    r.release = release

    table.insert(self.regions, r)
    return r
end

function ClickMap:setOffset(ox, oy)
    self.offX = ox or 0
    self.offY = oy or 0
end

function ClickMap:check(x, y)
    x = x - self.offX
    y = y - self.offY

    local region

    for _, r in ipairs(self.regions) do
        if r:check(x, y) then
            region = r
        end
    end

    return region
end

function ClickMap:click(x, y)
    local r = self:check(x, y)
    if r then
        self.clickedRegion = r
        return r:click(x, y)
    end
    return nil
end

function ClickMap:release(x, y)
    self.clickedRegion:release(x, y)
    self.clickedRegion = nil
end

function ClickMap:getClickedRegion()
    return self.clickedRegion
end

function ClickMap:foreach(f)
    for _, r in ipairs(self.regions) do
        f(r)
    end
end

ClickMap.registerShape(
    "rect",
    {
        new = function(x, y, w, h)
            return {
                x = x,
                y = y,
                w = w,
                h = h
            }
        end,
        check = function(region, x, y)
            if x < region.x or y < region.y then
                return false
            end
            return x < region.x + region.w and
                    y < region.y + region.h
        end
    }
)
ClickMap.registerShape(
    "circle",
    {
        new = function(x, y, r)
            return {
                x = x,
                y = y,
                r = r
            }
        end,
        check = function(region, x, y)
            local dx, dy = x - region.x, y - region.y
            return dx*dx + dy*dy <= region.r*region.r
        end
    }
)

return ClickMap
