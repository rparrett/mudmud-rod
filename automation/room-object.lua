if not rod._room_tracking then
    return
end

-- The Exits line starts the snapshot and also matches the deliberately broad
-- room-object pattern. It is metadata, not room contents.
if string.starts_with(line, "Exits:") then
    return
end

local item = string.trim(matches.item or "")
if item ~= "" then
    table.insert(rod._room_objects_working, item)
end
