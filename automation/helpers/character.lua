local favor_ranks = {
    loved = 1,
    cherished = 2,
    honored = 3,
    praised = 4,
    favored = 5,
    respected = 6,
    liked = 7,
    tolerated = 8,
    ignored = 9,
    shunned = 10,
    disliked = 11,
    dishonored = 12,
    disowned = 13,
    abandoned = 14,
    despised = 15,
    hated = 16,
    damned = 17,
}

local style_colors = {
    D = ansi.rgb(0, 191, 255),
    E = ansi.cyan,
    S = ansi.bright_white,
    A = ansi.rgb(255, 165, 0),
    B = ansi.red,
}

local function capitalize(value)
    local text = tostring(value or "")
    if text == "" then
        return text
    end

    return text:sub(1, 1):upper() .. text:sub(2):lower()
end

local function alignment_name_and_color(value)
    local alignment = tonumber(value) or 0
    local name

    if alignment > 900 then
        name = "Devout"
    elseif alignment > 700 then
        name = "Noble"
    elseif alignment > 350 then
        name = "Honorable"
    elseif alignment > 100 then
        name = "Worthy"
    elseif alignment > -100 then
        name = "Neutral"
    elseif alignment > -350 then
        name = "Base"
    elseif alignment > -700 then
        name = "Evil"
    elseif alignment > -900 then
        name = "Ignoble"
    else
        name = "Fiendish"
    end

    if alignment > 350 then
        return alignment, name, ansi.bright_white
    elseif alignment < -350 then
        return alignment, name, ansi.bright_red
    end

    return alignment, name, ansi.bright_black
end


local function favor_color(favor)
    local rank = favor_ranks[favor]
    if rank == nil then
        return ansi.bright_black
    elseif rank <= 4 then
        return ansi.bright_white
    elseif rank <= 6 then
        return ansi.white
    elseif rank <= 8 then
        return ansi.bright_black
    elseif rank <= 11 then
        return ansi.yellow
    elseif rank <= 14 then
        return ansi.rgb(255, 140, 0)
    end

    return ansi.red
end

local column_width = 27

local function append_cell(display, label, value, foreground)
    table.insert(display, {
        text = label,
        foreground = ansi.bright_black,
    })
    table.insert(display, {
        text = value,
        foreground = foreground,
        width = column_width - #label,
    })
end

local function append_style_cell(display, selected)
    table.insert(display, {
        text = "Style: ",
        foreground = ansi.bright_black,
    })

    local styles = { "E", "D", "S", "A", "B" }
    local selected_style = tostring(selected or "S"):upper()
    local used_width = #"Style: "
    for index, style in ipairs(styles) do
        if index > 1 then
            table.insert(display, " ")
            used_width = used_width + 1
        end

        local is_selected = style == selected_style
        local text = is_selected and "(" .. style .. ")" or style
        table.insert(display, {
            text = text,
            foreground = is_selected and style_colors[style] or ansi.bright_black,
        })
        used_width = used_width + #text
    end

    table.insert(display, { text = "", width = column_width - used_width })
end

function rod.update_character_status()
    local character_name = tostring(msdp.CHARACTER_NAME or "")
    local class = tostring(msdp.CLASS or "")
    local title = character_name ~= "" and character_name or "Character"
    if class ~= "" then
        title = title .. " (" .. class .. ")"
    end

    local display = rod.status_header(title)
    local alignment, alignment_name, alignment_color = alignment_name_and_color(msdp.ALIGNMENT)
    local favor = tostring(msdp.FAVOR or "ignored"):lower()

    append_cell(
        display,
        "Align: ",
        string.format("%s (%s)", alignment_name, alignment),
        alignment_color
    )
    append_cell(display, "Favor: ", capitalize(favor), favor_color(favor))
    table.insert(display, "\n")
    append_style_cell(display, msdp.COMBAT_STYLE)
    -- Reserved for Global IP once Mudmud exposes cross-profile connection data.
    table.insert(display, { text = "", width = column_width })
    table.insert(display, "\n")

    rod.set_status_section("character", display)
end

rod.update_character_status()
