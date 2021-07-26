local extra = require 'extra'
local shaders = require 'shaders'

return {
    tileset = love.graphics.newImage("assets/test_tileset.png"),
    _tilesetCache = {};

    spriteset = nil, -- TODO

    chunks = {},
    chunkrefs = {},

    systems = require("systems"),

    generateChunk = function(self, id)
        local c = {
            id = id,
            actors = { {s=999, x = 3, y = 3} },
            tiles = {},
            grids = {
                collision = {}
            }
        }

        local floor = extra.vec2Union(5, 1)
        local collider = extra.vec2Union(1, 1)
        for x = 0, _CHUNKWIDTH do
            for y = 0, _CHUNKHEIGHT do
                local t = {
                    p = extra.vec2Union(x, y)
                }

                if love.math.random(1, 5)==5 then
                    c.grids.collision[t.p] = true
                    t.t = collider
                else
                    t.t = floor
                end
                table.insert(c.tiles, t)
            end
        end

        
        for x = 1, 30 do
            local p = extra.vec2Union(love.math.random(0, _CHUNKWIDTH), love.math.random(0, _CHUNKWIDTH))
            c.grids.collision[p] = true
            table.insert(c.tiles, {
                p = p,
                t = floor
            })
        end

        c.prerender = self:renderTiles(c)
        return c
    end,

    renderTiles = function(self, chunk)
        local canvas = love.graphics.newCanvas(_CHUNKWIDTH*_TILEWIDTH, _CHUNKHEIGHT*_TILEHEIGHT)
        canvas:setFilter("nearest", "nearest")

        love.graphics.setCanvas(canvas)
            love.graphics.clear(0, 0, 0, 0)

            local w, h = self.tileset:getWidth(), self.tileset:getHeight()
            for _, tile in ipairs(chunk.tiles) do
                local x, y = extra.union2Vec(tile.p)

                if not self._tilesetCache[tile.t] then
                    local tx, ty = extra.union2Vec(tile.t)
                    self._tilesetCache[tile.t] = love.graphics.newQuad(tx*_TILEWIDTH, ty*_TILEHEIGHT, _TILEWIDTH, _TILEHEIGHT, w, h)
                end

                love.graphics.draw(self.tileset, self._tilesetCache[tile.t], x*_TILEWIDTH, y*_TILEHEIGHT)

                if chunk.grids.collision[tile.p] then 
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

            self.curChunkID = 0
        end

        local newGen = {}
        for _, actor in ipairs(self.curChunk.actors) do
            if not actor.die then table.insert(newGen, actor) end

            actor._x = extra.lerp(actor._x or actor.x*_TILEWIDTH, actor.x*_TILEWIDTH, delta*16) 
            actor._y = extra.lerp(actor._y or actor.y*_TILEWIDTH, actor.y*_TILEWIDTH, delta*16)
            actor._moving = math.abs(actor._x - (actor.x*_TILEWIDTH))>0.3 or math.abs(actor._y - (actor.y*_TILEWIDTH))>0.3

            self.systems[actor.s](actor, delta, self.curChunk, self)
        end
        self.curChunk.actors = newGen
    end,

    draw = function(self)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.scale(_GAMESCALE)

        love.graphics.draw(self.curChunk.prerender, 0, 0, 0)
        
        love.graphics.setColor(extra.hex("2c1e74"))
        local mx, my = love.mouse.getPosition()
        if self.curChunk.grids.collision[extra.vec2Union(
            math.floor(math.floor(mx/_GAMESCALE)/_TILEWIDTH), 
            math.floor(math.floor(my/_GAMESCALE)/_TILEHEIGHT) )] then 
                extra.mainFont:print("touching", 2, 1) 
        end

        local posx, posy = extra.union2Vec(self.curChunkID) 
        local str = "chunk x"..posx.." y"..posy

        love.graphics.setColor(extra.hex("D58863"))
        extra.mainFont:print(str, 3, 2)

        love.graphics.setColor(extra.hex("2c1e74"))
        extra.mainFont:print(str, 2, 1)

        for _, actor in ipairs(self.curChunk.actors) do
            love.graphics.rectangle("fill", actor._x, actor._y, _TILEWIDTH, _TILEHEIGHT) 
        end
    end
}