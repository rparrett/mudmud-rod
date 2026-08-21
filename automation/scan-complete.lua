local target = event.payload.keyword
if target == nil or target == "" then
    return
end

if event.payload.found then
    echoln({
        "\n[",
        { text = "rod",  foreground = ansi.bright_magenta },
        "] Found '",
        { text = target, foreground = ansi.bright_green,  bold = true },
        "' while scanning ",
        { text = event.payload.direction, foreground = ansi.bright_cyan, bold = true },
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
