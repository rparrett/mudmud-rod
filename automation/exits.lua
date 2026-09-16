rod._room_tracking = true
rod._room_exits_working = {}
rod._room_objects_working = {}
rod._room_mobs_working = {}

for direction in matches[2]:gsub("^%s*(.-)%s*$", "%1"):gmatch("%S+") do
    rod._room_exits_working[direction] = true
end
