local extra = require 'extra'
local shaders = require 'shaders'

return {
    tileset = love.graphics.newImage("assets/test_tileset.png"),
    _tilesetCache = {};

    spriteset = nil, -- TODO

    chunks = {},
    chunkrefs = {},

    animDirection = { x = 0, y = 0, p = 0, active = false },

    systems = require("systems"),

    generateChunk = function(self, id)
        local c = {
            id = id,
            actors = {},
            tiles = {},
            grids = {
                collision = {}
            }
        }

        local floor = extra.vec2Union(5, 1)
        local collider = extra.vec2Union(3, 3)
        for x = 0, _CHUNKWIDTH do
            for y = 0, _CHUNKHEIGHT do
                local t = {
                    p = extra.vec2Union(x, y),
                    t = floor
                }

                if (x==0 or y==0 or x==_CHUNKWIDTH-1 or y==_CHUNKHEIGHT-1) and not ((x>3 and x<_CHUNKWIDTH-4) or (y>3 and y<_CHUNKHEIGHT-4)) then
                    c.grids.collision[t.p] = true
                    t.t = collider
                end
                table.insert(c.tiles, t)
            end
        end
        return c
    end,

    transport = function(self, x, y, actor) -- Only supports going to near chunks rn
        self.nextChunkID = extra.vec2Union(x, y)
        if not self.chunks[self.nextChunkID] then 
            self.chunks[self.nextChunkID] = self:generateChunk(self.nextChunkID)
        end
        self.nextChunk = self.chunks[self.nextChunkID]
        self.nextChunk.prerender = self:renderTiles(self.nextChunk)

        if actor then
            local newGen = {}
            for _, _actor in ipairs(self.curChunk.actors) do
                if not (_actor.die or _actor==actor) then 
                    table.insert(newGen, _actor) 
                end
            end
            self.curChunk.actors = newGen

            actor.x = actor.x % _CHUNKWIDTH
            actor.y = actor.y % _CHUNKHEIGHT

            actor._x = actor.x*_TILEWIDTH
            actor._y = actor.y*_TILEHEIGHT

            table.insert(self.nextChunk.actors, actor)
        end

        local _x, _y = extra.union2Vec(self.curChunkID)
        self.animDirection = {x=x-_x, y=y-_y, p = 100, active=true }
    end,

    renderTiles = function(self, chunk)
        local canvas = love.graphics.newCanvas(_CHUNKWIDTH*_TILEWIDTH, _CHUNKHEIGHT*_TILEHEIGHT)
        canvas:setFilter("nearest", "nearest")

        love.graphics.reset()
        love.graphics.setCanvas(canvas)
            
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.clear(0, 0, 0, 0)

            local w, h = self.tileset:getWidth(), self.tileset:getHeight()
            for _, tile in ipairs(chunk.tiles) do
                local x, y = extra.union2Vec(tile.p)

                if not self._tilesetCache[tile.t] then
                    local tx, ty = extra.union2Vec(tile.t)
                    self._tilesetCache[tile.t] = love.graphics.newQuad(tx*_TILEWIDTH, ty*_TILEHEIGHT, _TILEWIDTH, _TILEHEIGHT, w, h)
                end

                love.graphics.draw(self.tileset, self._tilesetCache[tile.t], x*_TILEWIDTH, y*_TILEHEIGHT)

                if chunk.grids.collision[tile.p] and false then 
                    love.graphics.setColor(0, 0, 1, 1)
                    love.graphics.draw(self.tileset, self._tilesetCache[tile.t], x*_TILEWIDTH, y*_TILEHEIGHT)
                    love.graphics.setColor(1, 1, 1, 1)
                end 
            end
        love.graphics.setCanvas()

        return canvas
    end,

    process = function(self, delta)
        if not self.curChunk then
            -- We'll assume this is a new world
            local chunk = self:generateChunk(0)

            table.insert(self.chunkrefs, chunk)
            self.chunks[0] = chunk
            self.curChunk = chunk
            table.insert(self.curChunk.actors, {s=999, x = 3, y = 3})

            self.curChunkID = 0
        end

        self.animDirection.p = extra.lerp(self.animDirection.p, 0, delta*10)
        if self.animDirection.active and self.animDirection.p<0.2 then 
            self.animDirection.active = false 
            self.curChunk.prerender = nil
            self.curChunk = self.nextChunk
            self.curChunkID = self.nextChunkID
        end

        if self.animDirection.active then return end
        local newGen = {}
        for _, actor in ipairs(self.curChunk.actors) do
            actor.ox = actor.ox or actor.x
            actor.oy = actor.oy or actor.y
            actor.v = actor.v or 0

            if actor._moving then
                actor.v = math.min(1, actor.v + delta * 6)
                if actor.v == 1 then
                    actor._moving = false
                    actor.v = 0
                    actor.ox = actor.x
                    actor.oy = actor.y
                end
            else
                actor._moving = actor.ox ~= actor.x or actor.oy ~= actor.y 
            end
            

            self.systems[actor.s](actor, delta, self.curChunk, self)

            if not actor.die then 
                table.insert(newGen, actor) 
            end
            actor._movingBefore = actor._moving
        end
        self.curChunk.actors = newGen
    end,

    draw = function(self)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.scale(_GAMESCALE)

        if not self.curChunk.prerender then 
            self.curChunk.prerender = self:renderTiles(self.curChunk)
        end
        
        local _a = self.animDirection.p/100
        local _offsetX = _CHUNKWIDTH*_TILEWIDTH*self.animDirection.x
        local _offsetY = _CHUNKHEIGHT*_TILEHEIGHT*self.animDirection.y

        love.graphics.draw(self.curChunk.prerender, _offsetX*_a, _offsetY*_a)
        if self.nextChunk then
            love.graphics.draw(self.nextChunk.prerender, _offsetX*(2-_a), _offsetY*(2-_a))
        end
        
        --[[love.graphics.setColor(extra.hex("2c1e74"))
        local mx, my = love.mouse.getPosition()
        if self.curChunk.grids.collision[extra.vec2Union(
            math.floor(math.floor(mx/_GAMESCALE)/_TILEWIDTH), 
            math.floor(math.floor(my/_GAMESCALE)/_TILEHEIGHT) )] then 
                extra.mainFont:print("touching", 2, 1) 
        end]]

        local posx, posy = extra.union2Vec(self.curChunkID) 
        local str = "chunk x"..posx.." y"..posy

        love.graphics.setColor(extra.hex("D58863"))
        extra.mainFont:print(str, 3, 2)

        love.graphics.setColor(extra.hex("2c1e74"))
        extra.mainFont:print(str, 2, 1)

        if self.animDirection.active then return end
        for _, actor in ipairs(self.curChunk.actors) do
            local _x = actor.ox - (actor.ox - actor.x) * actor.v
            local _y = actor.oy - (actor.oy - actor.y) * actor.v + 0.5
            love.graphics.rectangle("fill", math.floor(_x * _TILEWIDTH), math.floor(_y * _TILEHEIGHT), _TILEWIDTH, _TILEHEIGHT) 
        end
    end
}