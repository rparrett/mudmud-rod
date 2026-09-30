local resource_fields = {
    health = {
        value = "HEALTH",
        maximum = "HEALTH_MAX",
    },
    mana = {
        value = "MANA",
        maximum = "MANA_MAX",
    },
}

local supported_thresholds = {
    health = true,
    health_percent = true,
    mana = true,
    mana_percent = true,
}

local function threshold_met(resource_name, minimum, minimum_percent)
    if minimum == nil and minimum_percent == nil then
        return true
    end

    local fields = resource_fields[resource_name]
    local value = tonumber(msdp[fields.value])
    if value == nil then
        return false
    end

    if minimum ~= nil and value < minimum then
        return false
    end

    if minimum_percent ~= nil then
        local maximum = tonumber(msdp[fields.maximum])
        if maximum == nil or maximum <= 0 or value < maximum * minimum_percent / 100 then
            return false
        end
    end

    return true
end

---Return whether all requested health and mana minimums are currently met.
---Absolute thresholds use `health` and `mana`; percentage thresholds use
---`health_percent` and `mana_percent`.
---@param thresholds { health?: number, health_percent?: number, mana?: number, mana_percent?: number }
---@return boolean
function rod.resources_at_least(thresholds)
    if type(thresholds) ~= "table" then
        error("resource thresholds must be a table")
    end

    local count = 0
    for name, value in pairs(thresholds) do
        if not supported_thresholds[name] then
            error("unsupported resource threshold '" .. tostring(name) .. "'")
        end
        if type(value) ~= "number" then
            error(name .. " must be a number")
        end
        count = count + 1
    end

    if count == 0 then
        error("at least one resource threshold is required")
    end

    return threshold_met("health", thresholds.health, thresholds.health_percent)
        and threshold_met("mana", thresholds.mana, thresholds.mana_percent)
end
