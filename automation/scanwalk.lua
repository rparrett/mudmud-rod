local route = matches[2] or "s,s,s,nw"
local commands = rod.parse_dirs(route)

seq.start("test scan route", function(path)
    for _, command in ipairs(commands) do
        if rod.is_direction(command) then
            rod.move(path, command, 5)
            rod.scan_all(path, 10)
        else
            path:input(command)
        end
    end
end)
