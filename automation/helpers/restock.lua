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
