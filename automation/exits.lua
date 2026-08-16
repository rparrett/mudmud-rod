rod._room_tracking = true

for direction in matches[2]:gsub("^%s*(.-)%s*$", "%1"):gmatch("%S+") do
    rod.room.exits[direction] = true
end
