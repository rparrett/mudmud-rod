local function discovery_command(operation, target)
    if target and target ~= "" then
        return operation .. " " .. target
    end

    return operation
end

local function discovery_label(operation)
    return operation == "search" and "Auto-searching" or "Auto-digging"
end

function rod._start_discovery(operation, target, times)
    if times < 1 or times > 100 then
        rod.echoln({
            { text = "Invalid " .. operation .. " count: ", foreground = ansi.bright_red },
            tostring(times),
            ". Use a number from 1 to 100.",
        })
        return
    end

    rod["_" .. operation] = {
        target = target,
        times = times,
        attempt = 1,
        command = discovery_command(operation, target),
    }

    send(rod["_" .. operation].command)
end

function rod._retry_discovery(operation)
    local state_key = "_" .. operation
    local state = rod[state_key]
    if not state then
        return
    end

    if state.attempt >= state.times then
        rod[state_key] = nil
        rod.echoln(discovery_label(operation) .. " complete.")
        emit("rod." .. operation, {
            found = false,
            target = state.target or "",
            attempts = state.attempt,
        })
        return
    end

    state.attempt = state.attempt + 1
    send(state.command)
end

function rod._complete_discovery(operation, item)
    local state_key = "_" .. operation
    local state = rod[state_key]
    rod[state_key] = nil

    emit("rod." .. operation, {
        found = true,
        item = item,
        target = state and state.target or "",
        attempts = state and state.attempt or 1,
    })
end
