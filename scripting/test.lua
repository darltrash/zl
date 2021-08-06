return {
    playerInteraction = function(npc)
        npc:say("Hello! It seems you have pressed\nthe *Special Button For Super\nSpecific Debugging Scenes* or\n*S.B.F.S.S.D.S*!")
        local _r = npc:say("Do you like either pizza or\npasta?", {"Macarroni", "MUSHROOM...", "HOT DOG"})
        if _r==1 then
            npc:say("Great taste!\n\nI like macarronis a lot because\ni like *CHEESE*")
        elseif _r==2 then
            npc:say("maruo")
        else
            npc:say("GOOD, TASTE GOOD")
        end
    end
}