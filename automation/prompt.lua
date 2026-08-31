if rod._room_tracking then
    emit("rod.room")

    rod._room_tracking = false
end

if rod._where_tracking then
    rod._where_tracking = false
    emit("rod.where", {
        area = rod.where_area,
        players = rod.area_players,
    })
end

if rod._scan_direction then
    local scan_result = rod.scan_result()
    rod._scan_direction = nil
    emit("rod.scan", scan_result)
end
