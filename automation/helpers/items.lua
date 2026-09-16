function rod.get_item_keyword(item)
    local keyword = rod.item_keywords[item] or item:match("(%S+)$") or item

    if keyword:find(" ", 1, true) then
        return "'" .. keyword .. "'"
    end

    return keyword
end

local function item_count(items, item_name)
    if type(item_name) ~= "string" or item_name == "" then
        error("item name must be a non-empty string", 3)
    end

    return tonumber(items and items[item_name]) or 0
end

local function has_item(items, item_name, quantity)
    quantity = quantity or 1
    if type(quantity) ~= "number" or quantity < 0 or quantity % 1 ~= 0 then
        error("item quantity must be a non-negative integer", 3)
    end

    return item_count(items, item_name) >= quantity
end

---Return the quantity in the latest top-level inventory snapshot.
---@param item_name string
---@return integer quantity
function rod.inventory_item_count(item_name)
    return item_count(rod.inventory, item_name)
end

---Check the latest top-level inventory snapshot for an item quantity.
---@param item_name string
---@param quantity? integer Defaults to one.
---@return boolean
function rod.has_inventory_item(item_name, quantity)
    return has_item(rod.inventory, item_name, quantity)
end

---Return an item's quantity in the latest snapshot of a configured container.
---@param item_name string
---@param container_type? string Defaults to `main`.
---@return integer quantity
function rod.container_item_count(item_name, container_type)
    local container = rod.get_container(container_type)
    return item_count(rod.container_contents[container.name], item_name)
end

---Check the latest snapshot of a configured container for an item quantity.
---@param item_name string
---@param quantity? integer Defaults to one.
---@param container_type? string Defaults to `main`.
---@return boolean
function rod.has_container_item(item_name, quantity, container_type)
    local container = rod.get_container(container_type)
    return has_item(rod.container_contents[container.name], item_name, quantity)
end
