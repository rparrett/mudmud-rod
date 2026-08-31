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

local function regex_escape(value)
    return (tostring(value):gsub("([^%w_])", "\\%1"))
end

function rod.spell_definition(name)
    return rod.spells[tostring(name):lower()]
end

function rod.spell_completion_patterns(name, requested_target)
    local definition = rod.spell_definition(name)
    if not definition then
        error("no spell definition for '" .. tostring(name) .. "'")
    end

    local target_name = requested_target and tostring(requested_target) or nil
    local self_target = target_name and target_name:lower() == "self"
    local target_regex

    if target_name == nil then
        target_regex = "(?<target>\\w+)"
    elseif self_target then
        target_regex = "(?<target>You)"
    else
        target_regex = "(?<target>" .. regex_escape(target_name) .. ")"
    end

    local patterns = {}
    for _, entry in ipairs(definition.complete or {}) do
        if type(entry) == "string" then
            table.insert(patterns, entry)
        elseif not entry.self_only or target_name == nil or self_target then
            local regex = entry.regex
            if entry.target then
                regex = regex:gsub("{{target}}", target_regex)
            end
            table.insert(patterns, regex)
        end
    end

    return patterns
end
