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

return {
    playerInteraction = function(npc)
        repeat
            local _r = npc:say("Welcome to darltrashs\ninvisible funking meme\nsweatshop bullshit!", {
                "I wanna buy",
                "I wanna talk",
                "I wanna quit"
            }, true)

            if _r == 1 then
                repeat 
                    local moneystr = "$"..tostring(money)..""

                    local options = {
                        "*< Back" .. (" "):rep(12-#moneystr) .. moneystr,
                    }
                    
                    for _, v in ipairs(menu) do
                        if v.soldOut then
                            table.insert(options, "*SOLD OUT ))))))))))")
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
                            npc:say("Sorry, I dont think you have\nenough money, Maybe come back\nwhen you're a little...\n\n*richer...")
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
                npc:say("Hello! Im *darltrash*!\n(also known as *neil wolfkid*)\n\nI like making games and this is\nmy latest little experiment ;)")
                npc:say("Im currently working on an rpg\nmade with *love2d* which is\nperformant and nice;\n\n*this is a demo of it")
                npc:say("As I can see, You have pressed\nthe *SPECIAL DEBUG BUTTON* so you\nmay know me already lol")
                npc:say("And as you know me,\nyou know im so lazy that i\nwill not write extra dialog and\njust loop it")
                if loop>0 then 
                    npc:say("\n\n*(told ya....)*")
                    if loop>1 then
                        npc:say("\n\n*((dont insist.))*")
                    end
                end
                loop = loop +1
            else
                npc:say("Gooooooodbyeeeee")
            end
        until _r==3
    end
}