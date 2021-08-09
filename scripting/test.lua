local menu = {
    {name="fortines card", price=19},
    {name="borgir",        price=20},
    {name="peeza",         price=21},
    {name="sussy amog",    price=99},
    {name="fnf funko pop", price=02},
    {name="linux 7",       price=00}
}

local money = 99
local loop = 0
local easter

return {
    playerInteraction = function(npc)
        repeat
            local _r = npc:say("Welcome to *darltrash's\nsweatshop*!", {
                "I wanna buy",
                "I wanna talk",
                easter or "*ENABLE SUPERTRIP",
                "I wanna quit"
            }, true)

            if _r == 1 then
                repeat 
                    local moneystr = "$"..tostring(money)..""

                    local options = {
                        "*< Back " .. ("-"):rep(10-#moneystr) .. " " .. moneystr,
                    }
                    
                    for _, v in ipairs(menu) do
                        if v.soldOut then
                            table.insert(options, "*SOLD OUT /////////")
                        else
                            local price = tostring(v.price)
                            if #price==1 then price = price .. " " end
                            local h = (v.price>money) and "*" or ""
                            table.insert(options, h.."$"..price..h.." "..v.name)
                        end
                    end
                    local r = npc:say("Select what you want!", options, true)
                    if r > 1 then
                        if menu[r-1].soldOut then
                            npc:say("Sorry, *thats not available...*")
                        elseif menu[r-1].price > money then
                            npc:say("Sorry, I don't think you have\nenough money, Maybe come back\nwhen you're a little, mmm...\n\n*...richer")
                        else
                            if npc:say("Are you sure you want to\nbuy it?", {"Absolutely", "Nooope"}, true)==1 then
                                money = money - menu[r-1].price
                                menu[r-1].soldOut = true
                                npc:say("*KACHING!* Thanks for buying\nfrom us!")
                            end
                        end
                    end
                until r == 1
            elseif _r==2 then
                npc:say("Hello! I'm *darltrash*!\n(also known as *neil wolfkid*)\n\nI like making games and this is\nmy latest little experiment ;)")
                npc:say("I'm currently working on an rpg\nmade with *love2d* which is\nperformant and nice;\n\n*this is a demo of it")
                npc:say("As I can see, You have pressed\nthe *SPECIAL DEBUG BUTTON* so you\nmay know me already lol")
                npc:say("And as you know me,\nyou know im so lazy that i\nwill not write extra dialog and\njust loop it")
                if loop>0 then 
                    npc:say("\n\n*(told ya....)*")
                    if loop>1 then
                        npc:say("\n\n*((don't insist.))*")
                    end
                end
                loop = loop +1
            elseif _r==3 then
                if easter then 
                    npc:say("told ya.")
                else
                    if npc:say("Are you entirely sure you want\nto enable the *SUPERTRIP MODE*?\n\n*(you wont be able to disable it)", {"yes", "no"})==1 then
                        require("world").cosmic = true
                        easter = "*I TOLD YA"
                    end
                end
            else
                npc:say("Gooooooodbyeeeee")
                break
            end
        until false
    end
}