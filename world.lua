local extra = require 'extra'
local shaders = require 'shaders'
local dialog = require 'dialog'

return {
    tileset = love.graphics.newImage("assets/test_tileset.png"),
    _tilesetCache = {};

    spriteset = nil, -- TODO

    chunks = {},
    chunkrefs = {},

    animDirection = { x = 0, y = 0, p = 0, active = false },

    systems = require("systems"), -- Load all actor systems
    timer = 0,

    mainCanvas = love.graphics.newCanvas(_TILEWIDTH*_CHUNKWIDTH, _TILEHEIGHT*_CHUNKHEIGHT),

    darkcolor = {73/255, 0, 151/255, 1},  -- Gradient map pallete
    lightcolor = {extra.hex("e45b78")},

    generateChunk = function(self, id) -- Generates chunk
        local c = {
            id = id,
            actors = {},
            tiles = {},
            grids = {
                collision = {},
                player = {}
            }
        }

        -- TODO: Get rid of this bullshit code and actually do a map loader or a random generator

        local floor = extra.vec2Union(4, 1)
        local cache = {}
        for x = 0, _CHUNKWIDTH do
            for y = 0, _CHUNKHEIGHT do
                local t = {
                    p = extra.vec2Union(x, y),
                    t = floor
                }

                table.insert(c.tiles, t)
                cache[t.p] = t
            end
        end
        for x = 1, _CHUNKWIDTH-2 do
            if x==1 then
                cache[extra.vec2Union(x, 1)].t = extra.vec2Union(2, 0)
                cache[extra.vec2Union(x, _CHUNKHEIGHT-2)].t = extra.vec2Union(2, 1)
            elseif x==_CHUNKWIDTH-2 then
                cache[extra.vec2Union(x, 1)].t = extra.vec2Union(3, 0)
                cache[extra.vec2Union(x, _CHUNKHEIGHT-2)].t = extra.vec2Union(3, 1)
            else
                cache[extra.vec2Union(x, 1)].t = extra.vec2Union(0, 0)
                cache[extra.vec2Union(x, _CHUNKHEIGHT-2)].t = extra.vec2Union(1, 1)
            end
        end

        for y = 2, _CHUNKHEIGHT-3 do
            cache[extra.vec2Union(1, y)].t = extra.vec2Union(0, 1)
            cache[extra.vec2Union(_CHUNKWIDTH-2, y)].t = extra.vec2Union(1, 0)
        end

        for x=2, _CHUNKWIDTH-3 do
            for y=2, _CHUNKHEIGHT-3 do
                cache[extra.vec2Union(x, y)].t = extra.vec2Union(3 + love.math.random(1, 3), 0) 
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
            actor.ox = nil
            actor.oy = nil
            actor.v = 0
            actor._moving = false
            actor._movingBefore = false
            
            actor._x = actor.x * _TILEWIDTH
            actor._y = actor.y * _TILEHEIGHT

            table.insert(self.nextChunk.actors, actor)
        end

        local _x, _y = extra.union2Vec(self.curChunkID)
        self.animDirection = {x=x-_x, y=y-_y, p = 100, active=true }
    end,

    renderTiles = function(self, chunk)
        local canvas = love.graphics.newCanvas(_CHUNKWIDTH*_TILEWIDTH, _CHUNKHEIGHT*_TILEHEIGHT)

        love.graphics.setCanvas(canvas) -- PRERENDER EVERYTHINNNNNNNNNNNGGGG
            love.graphics.clear(0, 0, 0, 0)

            local posx, posy = extra.union2Vec(chunk.id) 
            local str = "chunk x*"..posx.."* y*"..posy.."*"

            love.graphics.setColor(1, 1, 1, 1)

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

            love.graphics.setColor(extra.hex("000000")) -- Also a cool chunk count thing :)
            extra.mainFont:print(str, 1, 1, nil, {0, .4, 1, 1})
        love.graphics.setCanvas()

        return canvas
    end,

    process = function(self, delta)
        self.timer = self.timer + delta
        if not self.curChunk then
            -- We'll assume this is a new world
            local chunk = self:generateChunk(0)

            table.insert(self.chunkrefs, chunk)
            self.chunks[0] = chunk
            self.curChunk = chunk
            table.insert(self.curChunk.actors, {s=999, x = 3, y = 3}) -- TEST PLAYER
            table.insert(self.curChunk.actors, {s=998, x = 3, y = 3, _scr_scriptset = require "scripting.test"}) -- TEST DIALOG THING

            self.curChunkID = 0
        end

        self.animDirection.p = extra.lerp(self.animDirection.p, 0, delta*10) -- Chunk transition animation
        if self.animDirection.active and self.animDirection.p<0.2 then 
            self.animDirection.active = false 
            self.curChunk.prerender = nil
            self.curChunk = self.nextChunk
            self.curChunkID = self.nextChunkID
            self.nextChunk = nil
            self.nextChunkID = nil
        end

        if self.animDirection.active then return end
        local newGen = {}
        for _, actor in ipairs(self.curChunk.actors) do -- for each "actor"/entity, animate them
            actor.ox = actor.ox or actor.x
            actor.oy = actor.oy or actor.y
            actor.v = actor.v or 0

            if actor._moving then
                actor.v = math.min(1, actor.v + delta * (actor.vel or 6))
                if actor.v == 1 then
                    actor._moving = false
                    actor.v = 0
                    actor.ox = actor.x
                    actor.oy = actor.y
                end
            else
                actor._moving = actor.ox ~= actor.x or actor.oy ~= actor.y 
            end
            
            self.systems[actor.s](actor, delta, self.curChunk, self) -- Process the actor

            if not actor.die then -- if actor is dying, then skip it next time
                table.insert(newGen, actor) 
            end
            actor._movingBefore = actor._moving
        end
        self.curChunk.actors = newGen

        if not self.curChunk.prerender then -- If tiles havent been prerendered:
            self.curChunk.prerender = self:renderTiles(self.curChunk) -- then do it now.
        end
        dialog:update(delta)
    end,

    draw = function(self)
        local _a = self.animDirection.p/100
        local _offsetX = _CHUNKWIDTH  * _TILEWIDTH  * self.animDirection.x
        local _offsetY = _CHUNKHEIGHT * _TILEHEIGHT * self.animDirection.y

        love.graphics.setCanvas(self.mainCanvas) -- Render everything onto "canvas"
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.draw(self.curChunk.prerender, 0, 0)
        if self.nextChunk then -- If transitioning into a new chunk, render it with an offset (animation)
            local f = math.floor
            love.graphics.draw(self.nextChunk.prerender, f(_offsetX*_a), f(_offsetY*_a)) 

            -- Animation gradient stuff

            love.graphics.setColor(0, 0, 0, (1-_a)*0.6)
            local w, h = _CHUNKWIDTH  * _TILEWIDTH, _CHUNKHEIGHT  * _TILEHEIGHT

            love.graphics.setShader(shaders.gradient)
            shaders.gradient:send("dir", 1)
            shaders.gradient:send("a", 0) -- Draw from down to up
            love.graphics.draw(_BLANK, f(_offsetX*_a), f(_offsetY*_a)+h, 0, w, h)

            shaders.gradient:send("a", 1) -- Draw from up to down
            love.graphics.draw(_BLANK, f(_offsetX*_a), f(_offsetY*_a)-h, 0, w, h)

            shaders.gradient:send("dir", 0)
            shaders.gradient:send("a", 0) -- Draw from left to right
            love.graphics.draw(_BLANK, f(_offsetX*_a)+w, f(_offsetY*_a), 0, w, h)
            shaders.gradient:send("a", 1) -- Draw from right to left
            love.graphics.draw(_BLANK, f(_offsetX*_a)-w, f(_offsetY*_a), 0, w, h)
            love.graphics.setShader() -- reset
        end

        love.graphics.setColor(1, 1, 1, 1)
        if not self.animDirection.active then
            for _, actor in ipairs(self.curChunk.actors) do
                local _x = actor.ox - (actor.ox - actor.x) * actor.v
                local _y = actor.oy - (actor.oy - actor.y) * actor.v
                love.graphics.rectangle("fill", math.floor(_x * _TILEWIDTH), math.floor(_y * _TILEHEIGHT), _TILEWIDTH, _TILEHEIGHT) 
            end
        end
        love.graphics.setColor(extra.hex("000000")) -- Also a cool chunk count thing :)
        extra.mainFont:print("FPS: *"..love.timer.getFPS(), 1, 9, nil, {0, .4, 1, 1})

        love.graphics.setColor(1, 1, 1, 1)

        dialog:draw()
        
        love.graphics.setCanvas()
        love.graphics.setShader(shaders.mapper)
        shaders.mapper:send("amount", 0.4)
        shaders.mapper:sendColor("dark", self.darkcolor)
        shaders.mapper:sendColor("light", self.lightcolor)
        love.graphics.draw(self.mainCanvas, 0, 0, 0, _GAMESCALE) -- Render canvas with cool gradient mapping

        love.graphics.setShader()
    end
}