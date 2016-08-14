local HSV = {}
local toRGBFunctions = {
    [0] = function(c, x)
        return c, x, 0
    end,
    function(c, x)
        return x, c, 0
    end,
    function(c, x)
        return 0, c, x
    end,
    function(c, x)
        return 0, x, c
    end,
    function(c, x)
        return x, 0, c
    end,
    function(c, x)
        return c, 0, x
    end
}

local function maxi(...)
    local args = {...}
    local m, mi = args[1], 1

    for i = 2, #args do
        if args[i] > m then
            m = args[i]
            mi = i
        end
    end

    return m, mi
end

local hueFunctions = {
    function(r, g, b, c)
        return ((g-b)/c) % 6
    end,
    function(r, g, b, c)
        return ((b-r)/c) + 2
    end,
    function(r, g, b, c)
        return ((r-g)/c) + 4
    end
}

function HSV.fromRGB(r, g, b)
    local m, M, dominant = math.min(r, g, b), maxi(r, g, b)
    local chroma = M - m
    local H, S, V

    V = M
    
    if chroma == 0 then
        H = 0
        S = 0
    else
        H = 60 * hueFunctions[dominant](r, g, b, chroma)
        S = chroma / V
    end

    return H, S, V
end

function HSV.toRGB(h, s, v)
    local chroma = v * s
    local r, g, b

    if chroma == 0 then
        r, g, b = 0, 0, 0
    else
        local H = h / 60
        local x = chroma * (1 - math.abs(H%2 - 1))
        r, g, b = toRGBFunctions[math.floor(H)](chroma, x)
    end

    local m = v - chroma
    r, g, b = r + m, g + m, b + m
    return 255*r, 255*g, 255*b
end

return HSV
