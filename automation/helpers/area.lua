local terrains = {
    ["0"] = "Inside",
    ["1"] = "City",
    ["2"] = "Field",
    ["3"] = "Forest",
    ["4"] = "Hills",
    ["5"] = "Mountain",
    ["6"] = "Water (Swim)",
    ["7"] = "Water (No Swim)",
    ["8"] = "Underwater",
    ["9"] = "Air",
    ["10"] = "Desert",
    ["11"] = "Unknown",
    ["12"] = "Ocean Floor",
    ["13"] = "Underground",
}

local line_width = 54

local function truncate(value, width)
    if #value <= width then
        return value
    elseif width <= 1 then
        return "~"
    end

    return value:sub(1, width - 1) .. "~"
end

local function world_time_12h(value)
    local hour = tonumber(value)
    if hour == nil then
        return "?"
    end

    local suffix = hour < 12 and "AM" or "PM"
    local twelve_hour = hour % 12
    if twelve_hour == 0 then
        twelve_hour = 12
    end

    return string.format("%d %s", twelve_hour, suffix)
end

function rod.update_area_status()
    local display = rod.status_header("Area")
    local area_name = tostring(msdp.AREA_NAME or "?")
    local geo = tostring(msdp.GEO or "?")
    local terrain = terrains[tostring(msdp.ROOM_TERRAIN or "")] or "?"
    local geo_text = " (" .. geo .. ")"
    local terrain_text = " [" .. terrain .. "]"
    local area_width = math.max(1, line_width - #geo_text - #terrain_text)

    table.insert(display, {
        text = truncate(area_name, area_width),
        foreground = ansi.bright_white,
    })
    table.insert(display, {
        text = geo_text,
        foreground = ansi.bright_cyan,
    })
    table.insert(display, {
        text = terrain_text,
        foreground = ansi.bright_green,
    })
    table.insert(display, "\n")
    table.insert(display, {
        text = "Time: ",
        foreground = ansi.bright_black,
    })
    table.insert(display, {
        text = world_time_12h(msdp.WORLD_TIME),
        foreground = ansi.bright_yellow,
    })
    table.insert(display, "\n")

    rod.set_status_section("area", display)
end

rod.update_area_status()
