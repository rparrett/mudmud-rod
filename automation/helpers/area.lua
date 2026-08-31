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

local function minutes(seconds)
    return string.format("%dm", math.floor(seconds / 60 + 0.5))
end

local function repop_report(area_name)
    local info = rod.repop_info and rod.repop_info[area_name]
    local sighting = rod._repop_sightings[area_name]

    if sighting then
        local ago_seconds = math.max(0, time.now() - sighting.timestamp)
        if info and info.timer_minutes then
            local average_seconds = info.timer_minutes * 60
            local estimated_seconds = math.max(0, average_seconds - ago_seconds)
            return string.format(
                "Repop: %s ago, %s avg, %s est to go",
                minutes(ago_seconds),
                minutes(average_seconds),
                minutes(estimated_seconds)
            )
        end

        return string.format("Repop: %s ago, ? avg, ? est to go", minutes(ago_seconds))
    end

    if info and info.timer_minutes then
        return string.format("Repop: unknown, %sm avg", info.timer_minutes)
    end

    return "Repop: unknown"
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
    local time_text = world_time_12h(msdp.WORLD_TIME)
    local time_prefix = "Time: "
    local repop_prefix = "  "
    table.insert(display, { text = time_prefix, foreground = ansi.bright_black })
    table.insert(display, {
        text = time_text,
        foreground = ansi.bright_yellow,
    })
    table.insert(display, repop_prefix)
    table.insert(display, {
        text = repop_report(area_name),
        foreground = ansi.bright_black,
        width = math.max(1, line_width - #time_prefix - #time_text - #repop_prefix),
    })
    table.insert(display, "\n")

    rod.set_status_section("area", display)
end

rod.update_area_status()
