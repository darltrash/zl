local extra = require "extra"
local input = require "input"

local WHITE = {1, 1, 1, 1}
local BLACK = {0, 0, 0, 1}

return {
    currchar = 0,
    currText = "",
    velocity = 18,
    options = {"next"},
    selection = 1,
    bottom = true,
    ready = true,

    spawn = function(self, text, options)
        self.currchar = 0
        self.currText = text 
        self.options = options or {"next"}
        self.selection = 1
        self.ready = false
    end,

    update = function(self, delta)
        if self.ready then return end
        self.currchar = self.currchar + delta * self.velocity
        self.ready = (self.currchar > #self.currText) and input:isDown("accept")

        if input:justDown("left") then
            self.selection = self.selection -1
            if self.selection < 1 then
                self.selection = #self.options
            end
        end

        if input:justDown("right") then
            self.selection = self.selection +1
            if self.selection > #self.options then
                self.selection = 1
            end
        end

    end,

    draw = function(self)
        if self.ready then return end
        local w, h = extra.mainFont.charW, extra.mainFont.charH
        local cw, ch = 34*w, 8*h
        local ox, oy = (_W/2)-(cw/2), 8

        if self.bottom and false then
            oy = h - (ch - 8)
        end

        love.graphics.setColor(BLACK)
        love.graphics.rectangle("fill", ox, oy, cw, ch)

        love.graphics.setColor(WHITE)
        extra.mainFont:print(self.currText, w + ox, h + oy, math.floor(self.currchar), {1, 0.7, 0.9, 1})

        if (self.currchar > #self.currText) then
            local c = 0
            for i, v in ipairs(self.options) do
                love.graphics.setColor((self.selection==i) and WHITE or BLACK)
                love.graphics.rectangle("fill", c + ox, oy+ch+1, ((#v)*w)+3, h+3)

                love.graphics.setColor((self.selection==i) and BLACK or WHITE)
                extra.mainFont:print(v, c+ox+2, oy+ch+3, math.floor(self.currchar))
                c = c + ((#v-2)*w)+3+16
            end
        end
        love.graphics.setColor(WHITE)
    end
}