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

local condition_ratings = {
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
    local condition_rating

    if is_weapon then
        maximum_ac = 12
        maximum_ac_known = true
        current_ac = weapon_conditions[condition]
        condition_rating = condition_ratings[condition]
    else
        local known_ac = rod.equipment_ac[entry.name]
        maximum_ac = known_ac or 10
        maximum_ac_known = known_ac ~= nil
        condition_rating = condition_ratings[condition]
        if condition_rating ~= nil then
            current_ac = math.floor(condition_rating * maximum_ac / 10)
        end
    end

    return {
        current_ac = current_ac,
        maximum_ac = maximum_ac,
        maximum_ac_known = maximum_ac_known,
        condition_rating = condition_rating,
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

---Return whether any item in an equipment snapshot is below superb condition.
---@param equipment? table[]
---@return boolean needs_repair
---@return table? item
function rod.needs_repair(equipment)
    equipment = equipment or rod.equipment
    for _, entry in ipairs(equipment) do
        if trimmed_lower(entry.condition) ~= "superb" then
            return true, entry
        end
    end

    return false, nil
end

---Append a fresh equipment survey to a sequence.
---@param path MudmudSequencePath
---@param timeout? number
function rod.survey(path, timeout)
    path:input("survey")
    path:wait_event("rod.equipment.updated", { timeout = timeout or 10 })
end

function rod.equipment_slot_name(slot)
    local normalized = tostring(slot or ""):match("^%s*(.-)%s*$")
    local lower = normalized:lower()

    if lower == "missile wielded" then
        return "missile"
    elseif lower == "dual wielded" then
        return "dual"
    elseif lower:match("^worn%s") then
        return normalized:match("(%S+)$") or normalized
    end

    return normalized
end

local function equipment_condition_style(durability)
    local rating = durability.condition_rating
    if rating == nil then
        return ansi.bright_black, false
    elseif rating >= 10 then
        return ansi.bright_green, false
    elseif rating >= 9 then
        return ansi.bright_green, true
    elseif rating >= 7 then
        return ansi.bright_green, false
    elseif rating >= 5 then
        return ansi.bright_yellow, false
    elseif rating >= 3 then
        return ansi.bright_yellow, true
    elseif rating >= 2 then
        return ansi.yellow, false
    elseif rating >= 1 then
        return ansi.red, false
    end

    return ansi.bright_red, false
end


function rod.update_equipment_status()
    local display = rod.status_header("Equipment")

    if #rod.equipment == 0 then
        table.insert(display, {
            text = "Need survey.",
            foreground = ansi.bright_black,
            italic = true,
        })
        table.insert(display, "\n")
        rod.set_status_section("equipment", display)
        return
    end

    local endangered_names = {}
    if rod.settings.eqstrip then
        for _, entry in ipairs(rod.equipment) do
            local current_ac = rod.equipment_effective_ac(entry)
            if current_ac ~= nil and current_ac < rod.settings.eqstripthresh then
                endangered_names[entry.name] = true
            end
        end
    end

    local rows = {}
    for _, entry in ipairs(rod.equipment) do
        local current_ac, durability = rod.equipment_effective_ac(entry)
        local hits = rod._equipment_hits[entry.name] or 0
        local damaged_by_ac = current_ac ~= nil and current_ac < durability.maximum_ac

        if damaged_by_ac or hits > 0 or endangered_names[entry.name] then
            table.insert(rows, {
                entry = entry,
                current_ac = current_ac,
                durability = durability,
                hits = hits,
                endangered = endangered_names[entry.name] == true,
                at_limit = rod.settings.eqstrip
                    and current_ac ~= nil
                    and current_ac == rod.settings.eqstripthresh,
            })
        end
    end

    table.sort(rows, function(left, right)
        if left.current_ac ~= nil and right.current_ac ~= nil then
            if left.current_ac ~= right.current_ac then
                return left.current_ac < right.current_ac
            end
        elseif left.current_ac ~= nil then
            return true
        elseif right.current_ac ~= nil then
            return false
        end

        local left_rating = left.durability.condition_rating
        local right_rating = right.durability.condition_rating
        if left_rating ~= nil and right_rating ~= nil then
            if left_rating ~= right_rating then
                return left_rating < right_rating
            end
        elseif left_rating ~= nil then
            return true
        elseif right_rating ~= nil then
            return false
        end

        if left.hits ~= right.hits then
            return left.hits > right.hits
        end

        return left.entry.name < right.entry.name
    end)

    if #rows == 0 then
        table.insert(display, {
            text = "All gear is superb.",
            foreground = ansi.bright_green,
        })
        table.insert(display, "\n")
        rod.set_status_section("equipment", display)
        return
    end

    local shown = math.min(#rows, 12)
    for index = 1, shown do
        local row = rows[index]
        local condition_color, condition_bold = equipment_condition_style(row.durability)
        local ac_text
        if row.current_ac == nil then
            ac_text = row.hits > 0 and "-" .. row.hits or "?"
        elseif row.durability.maximum_ac_known then
            ac_text = string.format("%d/%d", row.current_ac, row.durability.maximum_ac)
        else
            ac_text = row.current_ac .. "?"
        end

        local action_text = " "
        local action_color = ansi.default
        if row.endangered then
            action_text = "!"
            action_color = ansi.bright_red
        elseif row.at_limit then
            action_text = "*"
            action_color = ansi.bright_yellow
        end

        table.insert(display, {
            text = rod.equipment_slot_name(row.entry.slot),
            foreground = ansi.bright_black,
            width = 7,
        })
        table.insert(display, " ")
        table.insert(display, {
            text = row.entry.condition,
            foreground = condition_color,
            bold = condition_bold,
            width = 14,
        })
        table.insert(display, {
            text = ac_text,
            foreground = row.endangered and ansi.bright_red
                or row.at_limit and ansi.bright_yellow
                or ansi.default,
            width = 7,
            align = "right",
        })
        table.insert(display, " ")
        table.insert(display, {
            text = action_text,
            foreground = action_color,
            bold = action_text ~= " ",
            width = 1,
        })
        table.insert(display, " ")
        table.insert(display, row.entry.name)
        table.insert(display, "\n")
    end

    if shown < #rows then
        table.insert(display, {
            text = string.format("... %d more damaged items", #rows - shown),
            foreground = ansi.bright_black,
            italic = true,
        })
        table.insert(display, "\n")
    end

    rod.set_status_section("equipment", display)
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

    rod.update_equipment_status()
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
                tts.speak("Removing " .. keyword)
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
    rod.update_equipment_status()
    return true
end
