local kb = love.keyboard
local ex = require "extra"

return {
    [999] = function(actor, delta, chunk, world) -- DEBUG PLAYER
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
    end,
}