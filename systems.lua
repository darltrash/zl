local ex = require "extra"
local dialog = require "dialog"
local input = require "input"

local scripting = {
    handle = {},
    say = function(self, message, options, listmode)
        if type(message)~="string" then
            local info = debug.getinfo(2, "Sl")
            message = "*ERROR*, " .. info.short_src .. ":" .. info.currentline
        end

        dialog:spawn(message, options, listmode)
        coroutine.yield(2) -- DIALOG
        return dialog.selection
    end
}

return {
    [998] = function(actor, delta, chunk, world) -- DEBUG SCRIPTING TEST
        local AWAIT, NEXT, DIALOG, MOVEMENT = 0, 1, 2, 3

        if (not actor._scr_script) and actor._scr_scriptset then
            if ex.near(chunk.grids.player, actor) and input:isDown("DEBUGBUTTON_01") then 
                actor._scr_script = coroutine.create(actor._scr_scriptset.playerInteraction) 
            end
            actor._src_state = NEXT
            return 
        end

        local _a = actor._src_state

        if _a==NEXT then
            scripting.handle = actor
            _, actor._src_state = coroutine.resume(actor._scr_script, scripting)
            if coroutine.status(actor._scr_script)=="dead" then
                actor._scr_script = nil
            end

        elseif _a==DIALOG and dialog.ready then
            actor._src_state = NEXT
            
        elseif _a==MOVEMENT then
            print("NOT IMPLEMENTED LOL")
            actor._src_state = NEXT

        end
    end,

    [999] = function(actor, delta, chunk, world) -- DEBUG PLAYER
        actor.id = "PLAYERDEBUG"
        actor.vel = 10
        local cols = chunk.grids.collision

        if dialog.ready and not actor._moving then
            local _pos = ex.vec2Union(actor.x, actor.y)
            local _y = actor.y
            if input:isDown("up") then
                _y = actor.y - 1
            end
            if input:isDown("down") then
                _y = actor.y + 1
            end
            if not cols[ex.vec2Union(actor.x, _y)] then
                actor.y = _y
            end

            local _x = actor.x
            if input:isDown("left") then
                _x = actor.x - 1
            end
            if input:isDown("right") then
                _x = actor.x + 1
            end
            if not cols[ex.vec2Union(_x, actor.y)] then
                actor.x = _x
            end

            if _pos~=ex.vec2Union(actor.y, actor.y) then
                chunk.grids.player[_pos] = false
                chunk.grids.player[ex.vec2Union(actor.x, actor.y)] = actor
            end
        end

        -- CHUNK CAMERA MOVEMENT SYSTEM... THING

        local _chunkX, _chunkY = ex.union2Vec(world.curChunkID)
        if actor.x<0 then 
            world:transport(_chunkX-1, _chunkY, actor)
        end
        if actor.x>_CHUNKWIDTH then 
            world:transport(_chunkX+1, _chunkY, actor)
        end

        if actor.y<0 then 
            world:transport(_chunkX, _chunkY-1, actor)
        end
        if actor.y>_CHUNKHEIGHT then 
            world:transport(_chunkX, _chunkY+1, actor)
        end
    end,
}