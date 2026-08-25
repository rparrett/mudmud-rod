local route_spec = matches[2]
if not route_spec then
    rod.echoln({
        { text = "Usage: ", foreground = ansi.bright_red },
        "scanwalk <direction spec or route name>",
    })
    return
end

local commands = rod.parse_dirs(route_spec)
local sequence_name = rod.dirs[route_spec] and "scanwalk " .. route_spec or "scanwalk"

seq.start(sequence_name, function(path)
    for _, command in ipairs(commands) do
        if rod.is_direction(command) then
            rod.move(path, command, 5)
            rod.scan_all(path, 10)
        else
            path:input(command)
        end
    end
end)
