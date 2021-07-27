local kb = love.keyboard
local ex = require "extra"

return {
    [999] = function(actor, delta, chunk, world) -- DEBUG PLAYER
        actor.id = "PLAYERDEBUG"
        local cols = chunk.grids.collision

        if not actor._moving then
            local _y = actor.y
            if kb.isDown("up") then
                _y = actor.y - 1
            end
            if kb.isDown("down") then
                _y = actor.y + 1
            end
            if not cols[ex.vec2Union(actor.x, _y)] then
                actor.y = _y
            end

            local _x = actor.x
            if kb.isDown("left") then
                _x = actor.x - 1
            end
            if kb.isDown("right") then
                _x = actor.x + 1
            end
            if not cols[ex.vec2Union(_x, actor.y)] then
                actor.x = _x
            end
        end

        -- Yeah sorry for this mess, haha

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