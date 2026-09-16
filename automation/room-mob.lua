if not rod._room_tracking then
    return
end

if string.starts_with(line, "Exits:") then
    return
end

local item = string.trim(matches.item or "")
if item ~= "" then
    table.insert(rod._room_mobs_working, item)
end
