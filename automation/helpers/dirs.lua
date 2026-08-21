local directions = {
    n = true,
    ne = true,
    e = true,
    se = true,
    s = true,
    sw = true,
    w = true,
    nw = true,
    u = true,
    d = true,
    north = true,
    northeast = true,
    east = true,
    southeast = true,
    south = true,
    southwest = true,
    west = true,
    northwest = true,
    up = true,
    down = true,
}

function rod.is_direction(command)
    return directions[command:lower()] == true
end

function rod.parse_dirs(spec)
    if type(spec) ~= "string" then
        error("command list must be a string")
    end

    spec = rod.dirs[spec] or spec

    local commands = {}
    for raw_item in spec:gmatch("[^,;:]+") do
        local item = raw_item:match("^%s*(.-)%s*$")

        if item ~= "" then
            local count, command = item:match("^#%s*(%d+)%s*(.-)%s*$")
            if not count then
                count, command = item:match("^(%d+)%s*(%a.*)$")
            end

            if not count or command == "" then
                count = 1
                command = item
            else
                count = tonumber(count)
            end

            if count > 1000 then
                error("command repetition cannot exceed 1000")
            end

            for _ = 1, count do
                table.insert(commands, command)
            end
        end
    end

    if #commands == 0 then
        error("command list is empty")
    end

    return commands
end
