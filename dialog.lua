local extra = require "extra"
local input = require "input"

return {
    currchar = 0,
    currText = "",
    velocity = 18,
    options = {"next"},
    selection = 1,
    listmode = true,
    bottom = true,
    ready = true,

    backgroundColor = {extra.hex("56687b")},
    selectedColor = {1, 1, 1, 1},
    specialColor = {1, 0.7, 0.9, 1},

    spawn = function(self, text, options, listmode)
        self.currchar = 0
        self.currText = text 
        self.options = options or {"next"}
        self.listmode = listmode
        self.selection = 1
        self.ready = false
    end,

    update = function(self, delta)
        if self.ready then return end
        self.currchar = self.currchar + delta * self.velocity
        if input:isDown("cancel") then
            self.currchar = self.currchar + delta * self.velocity * 2
        end
        self.ready = (self.currchar > #self.currText) and input:isDown("accept")

        local minus = "left"
        local more = "right"
        if self.listmode then
            minus = "up"
            more = "down"
        end
        if input:justDown(minus) then
            self.selection = self.selection -1
            if self.selection < 1 then
                self.selection = #self.options
            end
        end

        if input:justDown(more) then
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

        if self.bottom then
            oy = H - ch - 16
            if self.listmode then
                oy = H - ch - 8
            end
        end

        if self.listmode then 
            ox = 8
            cw = 26*w
        end

        love.graphics.setColor(self.backgroundColor)
        love.graphics.rectangle("fill", ox, oy, cw, ch)
        love.graphics.setColor(self.selectedColor)
        love.graphics.rectangle("line", ox+2, oy+2, cw-3, ch-3)

        love.graphics.setColor(self.selectedColor)
        extra.mainFont:print(self.currText, w + ox, h + oy, math.floor(self.currchar), self.specialColor)

        if (self.currchar > #self.currText) then
            if self.listmode then
                love.graphics.setColor(self.backgroundColor)
                love.graphics.rectangle("fill", ox+cw+1, 8, (_W - cw)-18, H - 16)
                love.graphics.setColor(self.selectedColor)
                love.graphics.rectangle("line", ox+cw+3, 10, (_W - cw)-21, H - 19)
                local offset = ((H - 8)/2) - (#self.options*h)
                for i, v in ipairs(self.options) do
                    love.graphics.setColor(self.selectedColor)
                    if self.selection==i then
                        love.graphics.rectangle("fill", ox+cw+1, offset+9+((h+3)*(i-1)), (_W - cw)-18, h+3)
                        love.graphics.setColor(self.backgroundColor)
                    end

                    extra.mainFont:print(v, ox+5+cw, offset+11+((h+3)*(i-1)), math.floor(self.currchar), 
                    (self.selection==i) and self.backgroundColor or self.specialColor)
                end
            else
                local c = 0
                for i, v in ipairs(self.options) do
                    love.graphics.setColor((self.selection==i) and self.selectedColor or self.backgroundColor)
                    love.graphics.rectangle("fill", c + ox, oy+ch+1, ((#v)*w)+3, h+3)

                    love.graphics.setColor((self.selection==i) and self.backgroundColor or self.selectedColor)
                    extra.mainFont:print(v, c+ox+2, oy+ch+3, math.floor(self.currchar))
                    c = c + ((#v-2)*w)+3+13
                end
            end
        end
        love.graphics.setColor(self.selectedColor)
    end
}