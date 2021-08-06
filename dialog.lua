local extra = require "extra"

return {
    currchar = 0,
    currText = "",
    velocity = 18,
    options = {"ok"},
    selection = 1,
    bottom = true,
    ready = true,

    spawn = function(self, text, options)
        self.currchar = 0
        self.currText = text 
        self.options = options or {"ok"}
        self.selection = 1
        self.ready = false
    end,

    update = function(self, delta)
        if self.ready then return end
        self.currchar = self.currchar + delta * self.velocity
        if (self.currchar > #self.currText) then
            self.ready = love.keyboard.isDown("x")
        end

        if love.keyboard.isDown("left") then
            self.selection = self.selection -1
            if self.selection < 1 then
                self.selection = #self.options
            end
        end

        if love.keyboard.isDown("right") then
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

        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle("fill", ox, oy, cw, ch)

        love.graphics.setColor(1, 1, 1, 1)
        extra.mainFont:print(self.currText, w + ox, h + oy, math.floor(self.currchar), {1, 1, 0, 1})

        if (self.currchar > #self.currText) then
            local o = ""
            for i, v in ipairs(self.options) do
                local h = (self.selection==i) and "*" or ""
                local t = (#self.options~=i) and ", " or ""
                o = o .. h .. v .. t .. h
            end
            print("'"..o.."'")

            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.rectangle("fill", 8, 13+(34*8), ((#o-2)*w)+4, 11)
            love.graphics.setColor(.57, .57, .57, 1)
            extra.mainFont:print(o, 10, 14+(7*h), math.floor(self.currchar), {1, 1, 1, 1})
        end
        love.graphics.setColor(1, 1, 1, 1)
    end
}