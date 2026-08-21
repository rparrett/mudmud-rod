local argument = matches[2]

local commands = rod.parse_dirs(argument)
for _, command in ipairs(commands) do
    input(command)
end
