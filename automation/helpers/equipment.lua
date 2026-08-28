local weapon_slots = {
    ["wielded"] = true,
    ["dual wielded"] = true,
    ["missile wielded"] = true,
}

local weapon_conditions = {
    ["superb"] = 12,
    ["excellent"] = 11,
    ["very good"] = 10,
    ["good"] = 9,
    ["bit of wear"] = 8,
    ["run down"] = 7,
    ["need repair"] = 6,
    ["great need"] = 5,
    ["dire need"] = 4,
    ["badly worn"] = 3,
    ["worthless"] = 2,
    ["almost broken"] = 1,
    ["broken"] = 0,
}

local armor_conditions = {
    ["superb"] = 10,
    ["excellent"] = 10,
    ["very good"] = 9,
    ["good"] = 8,
    ["bit of wear"] = 7,
    ["run down"] = 6,
    ["need repair"] = 5,
    ["great need"] = 4,
    ["dire need"] = 3,
    ["badly worn"] = 2,
    ["worthless"] = 1,
    ["almost broken"] = 0,
    ["broken"] = 0,
}

local function trimmed_lower(value)
    return tostring(value or ""):match("^%s*(.-)%s*$"):lower()
end

function rod.equipment_durability(entry)
    local slot = trimmed_lower(entry.slot)
    local condition = trimmed_lower(entry.condition)
    local is_weapon = weapon_slots[slot] == true
    local maximum_ac
    local maximum_ac_known
    local current_ac
    local durability_10

    if is_weapon then
        maximum_ac = 12
        maximum_ac_known = true
        current_ac = weapon_conditions[condition]
        if current_ac ~= nil then
            durability_10 = current_ac / 12 * 10
        end
    else
        local known_ac = rod.equipment_ac[entry.name]
        maximum_ac = known_ac or 10
        maximum_ac_known = known_ac ~= nil
        durability_10 = armor_conditions[condition]
        if durability_10 ~= nil then
            current_ac = math.floor(durability_10 * maximum_ac / 10)
        end
    end

    return {
        current_ac = current_ac,
        maximum_ac = maximum_ac,
        maximum_ac_known = maximum_ac_known,
        durability_10 = durability_10,
        is_weapon = is_weapon,
    }
end

function rod.equipment_effective_ac(entry)
    local durability = rod.equipment_durability(entry)
    if durability.current_ac == nil then
        return nil, durability
    end

    local hits = rod._equipment_hits[entry.name] or 0
    return math.max(0, durability.current_ac - hits), durability
end

function rod.wearing_item(item_name)
    for _, entry in ipairs(rod.equipment) do
        if entry.name == item_name then
            return true
        end
    end

    return false
end

function rod.queue_equipment_survey()
    rod._equipment_survey_pending = true
end

function rod.queue_endangered_equipment()
    if not rod.settings.eqstrip then
        return false
    end

    local groups = {}
    local group_order = {}
    for _, entry in ipairs(rod.equipment) do
        local group = groups[entry.name]
        if not group then
            group = { count = 0, endangered = false }
            groups[entry.name] = group
            table.insert(group_order, entry.name)
        end

        group.count = group.count + 1
        local effective_ac = rod.equipment_effective_ac(entry)
        if effective_ac ~= nil and effective_ac < rod.settings.eqstripthresh then
            group.endangered = true
        end
    end

    local queued = false
    for _, item_name in ipairs(group_order) do
        local group = groups[item_name]
        if group.endangered
            and not rod._equipment_removal_sent[item_name]
            and rod._equipment_remove_counts[item_name] == nil
        then
            rod._equipment_remove_counts[item_name] = group.count
            table.insert(rod._equipment_remove_order, item_name)
            queued = true
        end
    end

    if queued then
        rod.queue_equipment_survey()
    end

    return queued
end

function rod.record_equipment_damage(item_name)
    rod._equipment_hits[item_name] = (rod._equipment_hits[item_name] or 0) + 1
    rod.queue_endangered_equipment()

    local total_hits = 0
    for _, hits in pairs(rod._equipment_hits) do
        total_hits = total_hits + hits
    end

    if total_hits >= rod.settings.eqsurveyhits then
        rod.queue_equipment_survey()
    end
end

function rod.flush_equipment_actions()
    local sent_actions = false
    local now = time.monotonic()

    if rod._equipment_survey_inflight
        and rod._equipment_survey_started_at
        and now - rod._equipment_survey_started_at >= 10
    then
        rod._equipment_survey_inflight = false
        rod._equipment_survey_started_at = nil
    end

    if rod.settings.eqstrip then
        for _, item_name in ipairs(rod._equipment_remove_order) do
            local count = rod._equipment_remove_counts[item_name] or 0
            local keyword = rod.get_item_keyword(item_name)
            for _ = 1, count do
                send("remove " .. keyword)
                sent_actions = true
            end

            if count > 0 then
                rod._equipment_removal_sent[item_name] = true
            end
        end
    end

    rod._equipment_remove_counts = {}
    rod._equipment_remove_order = {}

    if rod._equipment_survey_pending and not rod._equipment_survey_inflight then
        rod._equipment_survey_pending = false
        rod._equipment_survey_inflight = true
        rod._equipment_survey_started_at = now
        send("survey")
        sent_actions = true
    end

    return sent_actions
end

function rod.begin_equipment_survey()
    rod._equipment_tracking_survey = true
    rod._equipment_survey_inflight = true
    rod._equipment_survey_pending = false
    rod._equipment_survey_working = {}
    rod._equipment_survey_hit_snapshot = {}
    for item_name, hits in pairs(rod._equipment_hits) do
        rod._equipment_survey_hit_snapshot[item_name] = hits
    end
end

function rod.track_equipment_survey_entry(slot, condition, item_name)
    if not rod._equipment_tracking_survey then
        return
    end

    table.insert(rod._equipment_survey_working, {
        slot = slot:match("^%s*(.-)%s*$"),
        condition = condition:match("^%s*(.-)%s*$"),
        name = item_name:match("^%s*(.-)%s*$"),
    })
end

function rod.complete_equipment_survey()
    if not rod._equipment_tracking_survey then
        return false
    end

    local completed = rod._equipment_survey_working or {}
    local followup_survey_pending = rod._equipment_survey_pending
    local hit_snapshot = rod._equipment_survey_hit_snapshot or {}
    rod._equipment_tracking_survey = false
    rod._equipment_survey_working = nil
    rod._equipment_survey_hit_snapshot = nil
    rod._equipment_survey_inflight = false
    rod._equipment_survey_started_at = nil
    rod._equipment_survey_pending = followup_survey_pending

    if #completed == 0 then
        return false
    end

    rod.equipment = completed
    local remaining_hits = {}
    for item_name, hits in pairs(rod._equipment_hits) do
        local remaining = hits - (hit_snapshot[item_name] or 0)
        if remaining > 0 then
            remaining_hits[item_name] = remaining
        end
    end
    rod._equipment_hits = remaining_hits
    rod._equipment_removal_sent = {}

    rod._unknown_equipment_conditions = rod._unknown_equipment_conditions or {}
    for _, entry in ipairs(completed) do
        local durability = rod.equipment_durability(entry)
        if durability.current_ac == nil then
            local key = entry.slot .. "\031" .. entry.condition
            if not rod._unknown_equipment_conditions[key] then
                rod._unknown_equipment_conditions[key] = true
                rod.echoln({
                    { text = "Unknown equipment condition: ", foreground = ansi.bright_red },
                    entry.condition,
                    " (",
                    entry.slot,
                    ").",
                })
            end
        end
    end

    rod.queue_endangered_equipment()
    emit("rod.equipment.updated", {
        items = completed,
    })
    return true
end
