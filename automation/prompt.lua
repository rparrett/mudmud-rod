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

if rod._container_tracking then
    local container = rod._container_tracking
    local items = rod._container_contents_working or {}

    rod.container_contents[container] = items
    rod._container_tracking = nil
    rod._container_contents_working = {}

    emit("rod.container.updated", {
        container = container,
        items = items,
    })
end

if rod._scan_direction then
    local scan_result = rod.scan_result()
    rod._scan_direction = nil
    emit("rod.scan", scan_result)
end
