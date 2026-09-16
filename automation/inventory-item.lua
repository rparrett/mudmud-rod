if not rod._inventory_tracking then
    return
end

local item = string.trim(matches.item or "")
if item == "" then
    return
end

local quantity = tonumber(matches.quantity) or 1
rod._inventory_working[item] = (rod._inventory_working[item] or 0) + quantity
