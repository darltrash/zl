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

local extra = require "extra"
local utf8 = require "utf8"

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

function love.errorhandler(msg)
        msg = tostring(msg)

        print((debug.traceback("Error: " .. tostring(msg), 3):gsub("\n[^\n]+$", "")))

        if not love.window or not love.graphics or not love.event then
            return
        end

        if not love.graphics.isCreated() or not love.window.isOpen() then
            local success, status = pcall(love.window.setMode, 800, 600)
            if not success or not status then
                return
            end
        end

        if love.mouse then
            love.mouse.setVisible(true)
            love.mouse.setGrabbed(false)
            love.mouse.setRelativeMode(false)
            if love.mouse.isCursorSupported() then
                love.mouse.setCursor()
            end
        end
        if love.joystick then
            -- Stop all joystick vibrations.
            for i,v in ipairs(love.joystick.getJoysticks()) do
                v:setVibration()
            end
        end
        if love.audio then love.audio.stop() end

        love.graphics.reset()
        love.graphics.setColor(1, 1, 1, 1)

        local trace = debug.traceback()

        love.graphics.origin()

        local sanitizedmsg = {}
        for char in msg:gmatch(utf8.charpattern) do
            table.insert(sanitizedmsg, char)
        end
        sanitizedmsg = table.concat(sanitizedmsg)

        local err = {}

        table.insert(err, "*Error:*")
        table.insert(err, sanitizedmsg)

        if #sanitizedmsg ~= #msg then
            table.insert(err, "Invalid UTF-8 string in error message.")
        end

        table.insert(err, "\n")

        for l in trace:gmatch("(.-)\n") do
            if not l:match("boot.lua") then
                l = l:gsub("stack traceback:", "*>> Traceback "..string.rep("<", 25).."*\n")
                table.insert(err, l)
            end
        end

        table.insert(err, "\n*"..string.rep(">", 38).."*\n")

        local p = table.concat(err, "\n")

        p = p:gsub("\t", "")
        p = p:gsub("%[string \"(.-)\"%]", "%1")

        local function draw()
            love.graphics.clear(22/255, 22/255, 27/255) -- Eigengrau
            love.graphics.scale(_GAMESCALE)
            extra.mainFont:print(p, 8, 8, nil, {1, 48/255, 73/255})
            love.graphics.present()
            love.graphics.reset()
        end

        local fullErrorText = p
        local function copyToClipboard()
            if not love.system then return end
            love.system.setClipboardText(fullErrorText)
            p = p .. "\n*Copied to clipboard!*"
            draw()
        end

        if love.system then
            p = p .. "\n\nPress *Ctrl+C* or *tap* to copy this error\n"
        end

        return function()
            love.event.pump()

            for e, a, b, c in love.event.poll() do
                if e == "quit" then
                    return 1
                elseif e == "keypressed" and a == "escape" then
                    return 1
                elseif e == "keypressed" and a == "c" and love.keyboard.isDown("lctrl", "rctrl") then
                    copyToClipboard()
                elseif e == "touchpressed" then
                    local name = love.window.getTitle()
                    if #name == 0 or name == "Untitled" then name = "Game" end
                    local buttons = {"OK", "Cancel"}
                    if love.system then
                        buttons[3] = "Copy to clipboard"
                    end
                    local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
                    if pressed == 1 then
                        return 1
                    elseif pressed == 3 then
                        copyToClipboard()
                    end
                end
            end

            draw()

            if love.timer then
                love.timer.sleep(0.1)
            end
        end
end