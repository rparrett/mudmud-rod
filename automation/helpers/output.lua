function rod.echoln(value)
    echoln({
        "[",
        { text = "rod", foreground = ansi.bright_magenta },
        "] ",
        value or "",
    })
end

function rod.format_exp(value)
    if math.abs(value) < 10000 then
        return string.format("%.0f", value)
    end

    return string.format("%.1fk", value / 1000)
end
