local fallback_container_types = {
    food = true,
    potion = true,
}

local supported_source_kinds = {
    container = true,
    shop = true,
}

local function sorted_keys(value)
    local keys = {}
    for key in pairs(value or {}) do
        table.insert(keys, key)
    end
    table.sort(keys, function(left, right)
        return tostring(left) < tostring(right)
    end)
    return keys
end

local function destination_container_name(container_type, containers)
    container_type = container_type or "main"

    if container_type == "main" or fallback_container_types[container_type] then
        return containers[container_type] or containers.main
    end

    return containers[container_type]
end

local function nonempty_string(value)
    return type(value) == "string" and value ~= ""
end

---Validate a restock configuration without mutating it.
---@param stock? table<string, table>
---@param sources? table<string, table>
---@param containers? table<string, string>
---@param item_keywords? table<string, string>
---@return boolean valid
---@return string[] errors
function rod.validate_restock_config(stock, sources, containers, item_keywords)
    stock = stock or rod.stock
    sources = sources or rod.restock_sources
    containers = containers or rod.containers
    item_keywords = item_keywords or rod.item_keywords

    local errors = {}

    if type(stock) ~= "table" then
        return false, { "rod.stock must be a table" }
    end
    if type(sources) ~= "table" then
        return false, { "rod.restock_sources must be a table" }
    end
    if type(containers) ~= "table" then
        return false, { "rod.containers must be a table" }
    end
    if type(item_keywords) ~= "table" then
        return false, { "rod.item_keywords must be a table" }
    end

    for _, item in ipairs(sorted_keys(stock)) do
        local definition = stock[item]
        local item_label = "stock item '" .. tostring(item) .. "'"

        if not nonempty_string(item) then
            table.insert(errors, "stock item names must be non-empty strings")
        elseif type(definition) ~= "table" then
            table.insert(errors, item_label .. " must have a table definition")
        else
            local quantity = definition.qty
            if type(quantity) ~= "number" or quantity < 0 or quantity % 1 ~= 0 then
                table.insert(errors, item_label .. " qty must be a non-negative integer")
            end

            local container_type = definition.container or "main"
            if not nonempty_string(container_type) then
                table.insert(errors, item_label .. " container must be a non-empty string")
            else
                local container_name = destination_container_name(container_type, containers)
                if not container_name then
                    table.insert(
                        errors,
                        item_label .. " references unknown container '" .. container_type .. "'"
                    )
                elseif not nonempty_string(item_keywords[container_name]) then
                    table.insert(
                        errors,
                        item_label
                            .. " destination container '"
                            .. container_name
                            .. "' has no explicit keyword"
                    )
                end
            end

            if not nonempty_string(item_keywords[item]) then
                table.insert(errors, item_label .. " has no explicit item keyword")
            end

            local source_name = definition.source
            if not nonempty_string(source_name) then
                table.insert(errors, item_label .. " source must be a non-empty string")
            else
                local source = sources[source_name]
                if type(source) ~= "table" then
                    table.insert(
                        errors,
                        item_label .. " references unknown source '" .. source_name .. "'"
                    )
                else
                    if not supported_source_kinds[source.kind] then
                        table.insert(
                            errors,
                            "restock source '"
                                .. source_name
                                .. "' has unsupported kind '"
                                .. tostring(source.kind)
                                .. "'"
                        )
                    end
                    if not nonempty_string(source.room) then
                        table.insert(
                            errors,
                            "restock source '" .. source_name .. "' room must be a non-empty string"
                        )
                    end
                    if source.kind == "container" and not nonempty_string(source.keyword) then
                        table.insert(
                            errors,
                            "restock source '"
                                .. source_name
                                .. "' container keyword must be a non-empty string"
                        )
                    end
                end
            end
        end
    end

    table.sort(errors)
    local unique_errors = {}
    for _, message in ipairs(errors) do
        if unique_errors[#unique_errors] ~= message then
            table.insert(unique_errors, message)
        end
    end

    return #unique_errors == 0, unique_errors
end

---Calculate stock deficits from configuration and observed container snapshots.
---The arguments default to mudmud-rod's current public state but may be supplied for
---independent tests. Call `rod.validate_restock_config` before this helper.
---@param stock? table<string, table>
---@param container_contents? table<string, table<string, number>>
---@param containers? table<string, string>
---@return table<string, table> needs
function rod.compute_restock_needs(stock, container_contents, containers)
    stock = stock or rod.stock
    container_contents = container_contents or rod.container_contents
    containers = containers or rod.containers

    local needs = {}
    for item, definition in pairs(stock) do
        local container_type = definition.container or "main"
        local container_name = destination_container_name(container_type, containers)
        local contents = container_contents[container_name] or {}
        local have = tonumber(contents[item]) or 0
        local desired = definition.qty
        local quantity = math.max(0, desired - have)

        if quantity > 0 then
            needs[item] = {
                qty = quantity,
                desired = desired,
                have = have,
                container = container_type,
                container_name = container_name,
                source = definition.source,
            }
        end
    end

    return needs
end

---Return the distinct physical containers needed by a stock configuration.
---Results are sorted by physical container name for deterministic inspection.
---Call `rod.validate_restock_config` before this helper.
---@param stock? table<string, table>
---@param containers? table<string, string>
---@param item_keywords? table<string, string>
---@return table[] destinations
function rod.restock_destination_containers(stock, containers, item_keywords)
    stock = stock or rod.stock
    containers = containers or rod.containers
    item_keywords = item_keywords or rod.item_keywords

    local by_name = {}
    for _, item in ipairs(sorted_keys(stock)) do
        local definition = stock[item]
        local container_name = destination_container_name(definition.container or "main", containers)
        if not by_name[container_name] then
            by_name[container_name] = {
                name = container_name,
                keyword = item_keywords[container_name],
            }
        end
    end

    local destinations = {}
    for _, container_name in ipairs(sorted_keys(by_name)) do
        table.insert(destinations, by_name[container_name])
    end
    return destinations
end

local function count_needs(needs)
    local item_count = 0
    local unit_count = 0
    for _, need in pairs(needs) do
        item_count = item_count + 1
        unit_count = unit_count + need.qty
    end
    return item_count, unit_count
end

local function stop_preparation(status, messages)
    rod._restock = {
        status = status,
        needs = {},
        errors = messages,
    }

    rod.echoln({
        { text = "Restock preparation stopped.", foreground = ansi.bright_red, bold = true },
    })
    for _, message in ipairs(messages) do
        rod.echoln({
            { text = "- ", foreground = ansi.bright_red },
            message,
        })
    end
    seq.stop()
end

---Append fresh destination-container inspection and deficit calculation to a sequence.
---Each container response may take up to `timeout` seconds; the default is 10.
---@param path MudmudSequencePath
---@param timeout? number
function rod.prepare_restock(path, timeout)
    timeout = timeout or 10

    path:run(function()
        local valid, errors = rod.validate_restock_config()
        if not valid then
            stop_preparation("invalid", errors)
            return
        end

        rod._restock = {
            status = "preparing",
            needs = {},
            containers = rod.restock_destination_containers(),
            container_index = 1,
        }
    end)

    path:retry("prepare restock", function(attempt, retry)
        attempt:run(function()
            local state = rod._restock
            if not state or state.status ~= "preparing" then
                seq.stop()
                return
            end

            local destination = state.containers[state.container_index]
            if not destination then
                retry:done()
                return
            end

            state.current_container = destination.name
            send("exam my." .. destination.keyword)
        end)

        attempt:race(function(first)
            first:event("rod.container.updated", {
                accept = function(event)
                    local state = rod._restock
                    return state
                        and state.status == "preparing"
                        and event.payload.container == state.current_container
                end,
                handler = function()
                    local state = rod._restock
                    state.current_container = nil
                    state.container_index = state.container_index + 1

                    if state.container_index > #state.containers then
                        retry:done()
                    else
                        retry:again()
                    end
                end,
            })

            first:after(timeout, function()
                local state = rod._restock
                local container = state and state.current_container or "unknown container"
                stop_preparation(
                    "timeout",
                    { "Timed out while examining '" .. container .. "'." }
                )
            end)
        end)
    end)

    path:run(function()
        local state = rod._restock
        if not state or state.status ~= "preparing" then
            return
        end

        state.current_container = nil
        state.needs = rod.compute_restock_needs()
        state.status = "prepared"
        state.prepared_at = time.monotonic()

        local item_count, unit_count = count_needs(state.needs)
        if item_count == 0 then
            rod.echoln({
                { text = "Already fully stocked", foreground = ansi.bright_green, bold = true },
                "; stopping the sequence.",
            })
            emit("rod.restock.prepared", {
                needs = state.needs,
                containers = state.containers,
            })
            seq.stop()
            return
        end

        rod.echoln({
            "Restock prepared: ",
            { text = tostring(unit_count), foreground = ansi.bright_cyan, bold = true },
            " unit",
            unit_count == 1 and "" or "s",
            " across ",
            { text = tostring(item_count), foreground = ansi.bright_cyan, bold = true },
            " item",
            item_count == 1 and "" or "s",
            ".",
        })
        emit("rod.restock.prepared", {
            needs = state.needs,
            containers = state.containers,
        })
    end)
end

local function stop_acquisition(message)
    rod.echoln({
        { text = "Restock acquisition stopped: ", foreground = ansi.bright_red, bold = true },
        message,
    })
    seq.stop()
end

local function needs_for_source(needs, source_name)
    local items = {}
    for _, item in ipairs(sorted_keys(needs)) do
        local need = needs[item]
        if need.source == source_name and need.qty > 0 then
            table.insert(items, item)
        end
    end
    return items
end

local function quoted_keyword(keyword)
    if keyword:find(" ", 1, true) then
        return "'" .. keyword .. "'"
    end
    return keyword
end

---Append acquisition of prepared deficits from one configured source.
---All commands for the source are sent together and do not wait for prompts.
---@param path MudmudSequencePath
---@param source_name string
function rod.restock_from(path, source_name)
    path:run(function()
        local state = rod._restock
        if not state or state.status ~= "prepared" then
            stop_acquisition("run rod.prepare_restock first.")
            return
        end

        local source = rod.restock_sources[source_name]
        if type(source) ~= "table" then
            stop_acquisition("unknown source '" .. tostring(source_name) .. "'.")
            return
        end

        local items = needs_for_source(state.needs, source_name)
        if #items == 0 then
            rod.echoln({
                "No stock needed from ",
                { text = source_name, foreground = ansi.bright_cyan },
                ".",
            })
            return
        end

        if not supported_source_kinds[source.kind] then
            stop_acquisition(
                "source '"
                    .. source_name
                    .. "' uses unsupported acquisition kind '"
                    .. tostring(source.kind)
                    .. "'."
            )
            return
        end

        if not rod.assert_room(source.room) then
            seq.stop()
            return
        end

        local unit_count = 0
        for _, item in ipairs(items) do
            local need = state.needs[item]
            local destination_keyword = quoted_keyword(rod.item_keywords[need.container_name])
            local item_keyword = quoted_keyword(rod.item_keywords[item])

            if source.kind == "container" then
                local source_keyword = quoted_keyword(source.keyword)
                send(
                    "fill my."
                        .. destination_keyword
                        .. " "
                        .. need.qty
                        .. " "
                        .. item_keyword
                        .. " "
                        .. source_keyword
                )
            elseif source.kind == "shop" then
                local remaining = need.qty
                while remaining > 0 do
                    local batch = math.min(remaining, 50)
                    send("buy " .. batch .. " " .. item_keyword)

                    if batch > 1 then
                        send("empty 'my.shoppe bag' my." .. destination_keyword)
                        send("drop 'my.shoppe bag'")
                    else
                        send("put " .. item_keyword .. " in my." .. destination_keyword)
                    end

                    remaining = remaining - batch
                end
            end
            unit_count = unit_count + need.qty
        end

        state.requested_sources = state.requested_sources or {}
        state.requested_sources[source_name] = {
            requested_at = time.monotonic(),
            items = #items,
            units = unit_count,
        }

        rod.echoln({
            "Requested ",
            { text = tostring(unit_count), foreground = ansi.bright_cyan, bold = true },
            " unit",
            unit_count == 1 and "" or "s",
            " across ",
            { text = tostring(#items), foreground = ansi.bright_cyan, bold = true },
            " item",
            #items == 1 and "" or "s",
            " from ",
            { text = source_name, foreground = ansi.bright_cyan },
            ".",
        })
    end)
end
