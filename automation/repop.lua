local area_names = rod.repop_areas_by_message[matches[1]] or {}
local timestamp = time.now()
local play_sound = false

for _, area_name in ipairs(area_names) do
    rod._repop_sightings[area_name] = {
        timestamp = timestamp,
    }

    local info = rod.repop_info[area_name]
    if info and not info.silent then
        play_sound = true
    end
end

if play_sound then
    rod.play_sound("repop")
end

emit("rod.repop", {
    message = matches[1],
    areas = area_names,
    timestamp = timestamp,
})

rod.update_area_status()
