return {
    keypool = {},
    associated = {
        up = "up",
        down = "down",
        left = "left",
        right = "right",

        accept = "x",
        cancel = "z",
        menu = "c",

        DEBUGBUTTON_01 = "p"
    },

    isDown = function (self, key)
        return love.keyboard.isDown(self.associated[key] or "7") -- Shhhhhh
    end,

    justDown = function (self, key)
        local a, rt = love.keyboard.isDown(self.associated[key] or "7") -- Shhhhhh
        rt = a and not self.keypool[key]
        self.keypool[key] = a
        return rt
    end
}