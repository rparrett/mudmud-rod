local count = tonumber(matches[2])
local command = matches[3]

if count > 100 then
    rod.echoln({
        { text = "Command repetition cannot exceed 100.", foreground = ansi.bright_red },
    })
    return
end

for _ = 1, count do
    input(command)
end
