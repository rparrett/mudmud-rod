if platform() == "macos" then
    rod.sounds.repop = rod.sounds.repop or "/System/Library/Sounds/Glass.aiff"
    rod.sounds.death = rod.sounds.death or "/System/Library/Sounds/Sosumi.aiff"
end

function rod.play_sound(name, options)
    if not supports("audio") then
        return false
    end

    local source = rod.sounds[name]
    if source == nil then
        return false
    end

    return audio.play(source, options)
end
