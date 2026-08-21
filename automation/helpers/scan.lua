function rod.scan_result()
    local target = rod.settings.scankw
    local result = {
        found = false,
        keyword = target or "",
    }

    if target == nil or target == "" then
        return result
    end

    local lower_target = target:lower()

    for direction, lines in pairs(rod.scan) do
        for _, scan_line in ipairs(lines) do
            local lower_line = scan_line:lower()
            local found = lower_line:find(lower_target, 1, true)
            local fighting = lower_line:find(", fighting", 1, true)
            local body_parts = lower_line:find("shrouded in flowing shadow and light", 1, true)
            local corpse = lower_line:find("corpse of", 1, true)

            if found and not fighting and not body_parts and not corpse then
                result.found = true
                result.direction = direction
                return result
            end
        end
    end

    return result
end
