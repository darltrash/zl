-- Utility functions and globals

local bit = require 'bit'

local utils = {}

function utils.convertBin(n) -- https://stackoverflow.com/questions/9079853/lua-print-integer-as-a-binary/9080080
    -- This converts a number onto it's binary representation (string)
    local t = {}
    for _ = 1, 32 do
        n = bit.rol(n, 1)
        table.insert(t, bit.band(n, 1))
    end
    return table.concat(t)
end

function utils.vec2Union(v) 
    -- This converts two i16s into one i32 (number type)
    -- Overflows and underflows safely
    return bit.bor(bit.lshift(v.x % _16CAPACITY, 16), v.y % _16CAPACITY)
end

function utils.union2Vec(u) 
    -- This converts one i32 (number type) into two i16s
    return {x = bit.rshift(u, 16), y = bit.band(u, _16CAPACITY)}
end

return utils