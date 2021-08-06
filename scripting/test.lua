return {
    playerInteraction = function(npc)
        npc:say("Ah, I have seen that you have\npressed DEBUGBUTTON_01")
        npc:say("I will now ask you the *PASSCODE*\nSelect the right word", {"darltrash", "darltrash", "darltrash"})
        npc:say("Select the right word", {"fucking", "fucking", "fucking"})
        npc:say("Select the right word", {"SUCKS", "SUCKS", "SUCKS"})
        npc:say("Select the right word", {"at", "at", "at"})
        npc:say("Select the right word", {"gamedev", "design", "music"})
        npc:say("Correct! Prepare to die.")
        love.event.quit()
    end
}