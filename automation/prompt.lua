if rod._room_tracking then
    emit("rod.room")

    rod._room_tracking = false
end

if rod._scan_direction then
    rod._scan_direction = nil
    emit("rod.scan")
end
