local bar_width = 43

local function opponent_health()
    local health = tonumber(msdp.OPPONENT_HEALTH)
    if health == nil then
        return nil
    end

    return math.max(0, math.min(100, health))
end

function rod.update_opponent_status()
    local display = rod.status_header("Opponent")
    local name = tostring(msdp.OPPONENT_NAME or "")
    local level = tostring(msdp.OPPONENT_LEVEL or "")
    local health = opponent_health()
    local has_opponent = name ~= ""
    local name_and_level = has_opponent and name or "None"
    if has_opponent and level ~= "" then
        name_and_level = name_and_level .. " (" .. level .. ")"
    end

    table.insert(display, {
        text = "Name: ",
        foreground = ansi.bright_black,
    })
    table.insert(display, {
        text = name_and_level,
        foreground = has_opponent and ansi.bright_white or ansi.bright_black,
        bold = has_opponent,
        width = 48,
    })
    table.insert(display, "\n")

    local bar
    if health == nil or health <= 0 then
        bar = string.rep(" ", bar_width)
    elseif health >= 100 then
        bar = string.rep("=", bar_width)
    else
        local head = math.max(1, math.floor(health * bar_width / 100))
        bar = string.rep("=", head - 1) .. ">" .. string.rep(" ", bar_width - head)
    end

    table.insert(display, {
        text = "HP: ",
        foreground = ansi.bright_black,
    })
    table.insert(display, {
        text = "[",
        foreground = ansi.bright_black,
    })
    table.insert(display, {
        text = bar,
        foreground = ansi.bright_red,
    })
    table.insert(display, {
        text = "]",
        foreground = ansi.bright_black,
    })
    table.insert(display, {
        text = health and string.format(" %3d%%", math.floor(health + 0.5)) or "   ?%",
        foreground = health and ansi.bright_red or ansi.bright_black,
        bold = health ~= nil,
    })
    table.insert(display, "\n")

    rod.set_status_section("opponent", display)
end

rod.update_opponent_status()
