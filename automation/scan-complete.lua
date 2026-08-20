local target = rod.settings.scankw
if target == nil or target == "" then
    return
end

local lower_target = target:lower()
local found_direction

for direction, lines in pairs(rod.scan) do
    for _, scan_line in ipairs(lines) do
        local lower_line = scan_line:lower()
        local found = lower_line:find(lower_target, 1, true)
        local fighting = lower_line:find(", fighting", 1, true)
        local body_parts = lower_line:find("shrouded in flowing shadow and light", 1, true)
        local corpse = lower_line:find("corpse of", 1, true)

        if found and not fighting and not body_parts and not corpse then
            found_direction = direction
            break
        end
    end

    if found_direction then
        break
    end
end

if found_direction then
    echoln({
        "\n[",
        { text = "rod",  foreground = ansi.bright_magenta },
        "] Found '",
        { text = target, foreground = ansi.bright_green,  bold = true },
        "' while scanning ",
        { text = found_direction, foreground = ansi.bright_cyan, bold = true },
        ".",
    })
else
    echoln({
        "\n[",
        { text = "rod",  foreground = ansi.bright_magenta },
        "] '",
        { text = target, foreground = ansi.bright_red,    bold = true },
        "' was not found.",
    })
end
