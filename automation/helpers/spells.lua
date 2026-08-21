function rod.spell_rounds(name)
    local rounds = tonumber(rod.affects_by_name[name:lower()])
    if rounds and rounds > -1 then
        return rounds
    end

    return -1
end

function rod.sanctuary_rounds()
    local rounds = -1
    local sanctuary_spells = {
        "sanctuary",
        "sacral divinity",
        "nadur dion",
    }

    for _, name in ipairs(sanctuary_spells) do
        rounds = math.max(rounds, rod.spell_rounds(name))
    end

    return rounds
end
