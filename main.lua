--[[

All the non-code assets (Like .png files and .ogg files) are covered under the CC-BY-SA license,
check out https://creativecommons.org/licenses/by-sa/2.0/legalcode for more info about it.

-------------------------------------------------------------

Copyright (c) 2021 Nelson "darltrash" Lopez.
Copyright (c) 2021 Rafael "Rex" Mata.

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.

]]

love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setLineStyle("rough")
love.graphics.setLineWidth(1)

_BLANK = love.graphics.newImage("assets/blank.png")
_CIRCLE = love.graphics.newImage("assets/circle.png")

_CHUNKWIDTH = 18
_CHUNKHEIGHT = 12
_TILEWIDTH = 16
_TILEHEIGHT = 16
_W, H = _CHUNKWIDTH * _TILEWIDTH, _CHUNKHEIGHT * _TILEHEIGHT

_GAMESCALE = 2
_16CAPACITY = (2^16)-1

_TABSIZE = 4
_DEBUGMODE = os.getenv("ZL_DEBUGMODE")

love.window.setMode(_CHUNKWIDTH*_TILEWIDTH*_GAMESCALE, _CHUNKHEIGHT*_TILEHEIGHT*_GAMESCALE)

local world = require 'world'
if _DEBUGMODE then _G.WORLDREF = world end

function love.update(dt)
    if _DEBUGMODE then require("lovebird").update() end
    world:process(dt)
end

function love.draw()
    world:draw()
end
