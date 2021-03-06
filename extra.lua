-- Utility functions and globals

local bit = require 'bit'

local utils = {}

utils.font = setmetatable({
    init = function (self, file, glyphs) 
        local font = {
            spr = love.graphics.newImage(file),
            glyphs = {},
            print = self.print, testprint = self.testprint
        }

        font.spr:setFilter("nearest", "nearest")
        
        local w = font.spr:getWidth()
        local h = font.spr:getHeight()

        font.charW = w/#glyphs
        font.charH = h
    
        local count = 0
        for char in glyphs:gmatch(".") do
            font.glyphs[char] = love.graphics.newQuad(font.charW*count, 0, font.charW, font.charH, w, h)
            count = count + 1
        end

        return font
    end,

    print = function (font, str, x, y, stopwhen, highlightColor)
        highlightColor = highlightColor or {1, 0, 0, 1}
        x, y = math.floor(x or 0), math.floor(y or 0)

        local count, cx, cy = 0, 0, 0
        local mx, my = 0, 0
        local highlighting = false
        local originColor = {love.graphics.getColor()}

        for char in str:gmatch(".") do
            if stopwhen==count then break end

            if char=="\n" then
                cy = cy + 1
                my = my + 1
                cx = 0
            elseif char=="\t" then
                cx = cx + _TABSIZE
                mx = mx + _TABSIZE
            elseif char=="*" then
                highlighting = not highlighting
                love.graphics.setColor((highlighting and highlightColor) or originColor)
            else
                if font.glyphs[char] then
                    love.graphics.draw(font.spr, font.glyphs[char], x+(cx*font.charW), y+(cy*font.charH))
                end
                cx = cx + 1
                mx = mx + 1
            end
    
            count = count + 1
        end
        love.graphics.setColor(originColor)

        return (mx*font.charW), (my*font.charH)
    end,

    testprint = function(self, x, y)
        love.graphics.draw(self.spr, x, y)
    end
}, { __call = function(self, ...) return self:init(...) end })

utils.mainFont = utils.font("assets/font.png", "ABCDEFGHIJKLMN_OPQRSTUVWXYZabcdefghijklmn_opqrstuvwxyz0123456789!?.,:;><$()[]/\\-+*__='\"")

function utils.lerp(a, b, t) 
    return a * (1-t) + b * t 
end

function utils.sign(n)
    return (n > 0 and 1) or (n == 0 and 0) or -1
end

function utils.normalize(x, y)
    local length = math.sqrt( (x*x) + (y*y) )
    return x / length, y / length
end

function utils.hex(h, a)
    h = h:gsub("#","")
    return tonumber("0x"..h:sub(1,2))/255, tonumber("0x"..h:sub(3,4))/255, tonumber("0x"..h:sub(5,6))/255, a or 1
end

function utils.luma(r, g, b)
    return ((0.2126*r*255) + (0.7152*g*255) + (0.0722*b*255))/255
end

function utils.hsla(h, s, l, a)
    if s == 0 then return l, l, l end
    local function to(p, q, t)
        if t < 0 then t = t + 1 end
        if t > 1 then t = t - 1 end
        if t < .16667 then return p + (q - p) * 6 * t end
        if t < .5 then return q end
        if t < .66667 then return p + (q - p) * (.66667 - t) * 6 end
        return p
    end
    local q = l < .5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    return to(p, q, h + .33334), to(p, q, h), to(p, q, h - .33334), a or 1
end

function utils.convertBin(n) -- https://stackoverflow.com/questions/9079853/lua-print-integer-as-a-binary/9080080
    -- This converts a number onto it's binary representation (string)
    local t = {}
    for _ = 1, 32 do
        n = bit.rol(n, 1)
        table.insert(t, bit.band(n, 1))
    end
    return table.concat(t)
end

function utils.vec2Union(x, y) 
    -- This converts two i16s into one i32 (number type)
    -- Overflows and underflows safely
    return bit.bor(bit.lshift(x % _16CAPACITY, 16), y % _16CAPACITY)
end

function utils.union2Vec(u) 
    -- This converts one i32 (number type) into two i16s
    return bit.rshift(u, 16), bit.band(u, _16CAPACITY)
end

function utils.gotHere()
    local info = debug.getinfo(2, "Sl")
    local lineinfo = info.short_src .. ":" .. info.currentline
    print(lineinfo)
end

function utils.near(grid, object)
    local left  = grid[utils.vec2Union(object.x-1, object.y)]
    local right = grid[utils.vec2Union(object.x+1, object.y)]
    local up    = grid[utils.vec2Union(object.x, object.y-1)]
    local down  = grid[utils.vec2Union(object.x, object.y+1)]
    return (left or right or up or down), left, right, up, down
end

return utils