local extra = require 'extra'
local shaders = require 'shaders'

return {
    tileset = love.graphics.newImage("assets/test_tileset.png"),
    _tilesetCache = {};

    spriteset = nil, -- TODO

    chunks = {},
    chunkrefs = {},

    generateChunk = function(self, id)
        local c = {
            id = id,
            actors = {},
            tiles = {},
            collisionMap = {},
        }

        local _cache = {}
        for x = 1, 40 do
            local r = 0
            repeat
                r = extra.vec2Union({ x = love.math.random(0, _CHUNKWIDTH), y = love.math.random(0, _CHUNKHEIGHT) })
            until not _cache[r]
            c.collisionMap[r] = true
            table.insert(c.tiles, {
                p = r, t = extra.vec2Union({ x = love.math.random(0, 10), y = love.math.random(0, 4) })
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
                local p = extra.union2Vec(tile.p)

                if not self._tilesetCache[tile.t] then
                    local t = extra.union2Vec(tile.t)
                    self._tilesetCache[tile.t] = love.graphics.newQuad(t.x*_TILEWIDTH, t.y*_TILEHEIGHT, _TILEWIDTH, _TILEHEIGHT, w, h)
                end

                love.graphics.draw(self.tileset, self._tilesetCache[tile.t], p.x*_TILEWIDTH, p.y*_TILEHEIGHT)
            end
        love.graphics.setCanvas()

        return canvas
    end,

    process = function(self, delta)
        if love.keyboard.isDown("g") or not self.curChunk then
            -- We'll assume this is a new world
            local chunk = self:generateChunk(0)

            table.insert(self.chunkrefs, chunk)
            self.chunks[0] = chunk
            self.curChunk = chunk

            self.curChunkID = 0
        end

        for _, actor in ipairs(self.curChunk.actors) do
            local gridpos = extra.union2Vec(actor.p)
            love.graphics.rectangle("fill", gridpos.x*_TILEWIDTH, gridpos.y*_TILEHEIGHT, _TILEWIDTH, _TILEHEIGHT) 
        end
    end,

    draw = function(self)
        love.graphics.draw(self.curChunk.prerender, 0, 0, 0, _GAMESCALE)

        local mx, my = love.mouse.getPosition()
        if self.curChunk.collisionMap[extra.vec2Union({
            x = math.floor(math.floor(mx/_GAMESCALE)/_TILEWIDTH),
            y = math.floor(math.floor(my/_GAMESCALE)/_TILEHEIGHT),
        })] then love.graphics.print("TOUCHING", 3, 16) end

        love.graphics.print(love.timer.getFPS(), 3, 3)
    end
}