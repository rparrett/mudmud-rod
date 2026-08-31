if not rod._container_tracking then
    return
end

local item = string.trim(matches.item or "")
if item == "" then
    return
end

local quantity = tonumber(matches.quantity) or 1
local previous = rod._container_contents_working[item] or 0
rod._container_contents_working[item] = previous + quantity
