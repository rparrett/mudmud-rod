if not rod._where_tracking then
    return
end

local name = string.trim(matches.name or "")
local room = string.trim(matches.room or "")
local organization = string.trim(matches.organization or "")

if name == "" or room == "" then
    return
end

table.insert(rod.area_players, {
    name = name,
    room = room,
    org = organization ~= "" and organization or nil,
})
