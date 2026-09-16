if rod._room_tracking then
    rod.room.exits = rod._room_exits_working or {}
    local mobs = rod._room_mobs_working or {}
    local mob_counts = {}
    for _, mob in ipairs(mobs) do
        mob_counts[mob] = (mob_counts[mob] or 0) + 1
    end

    local other = {}
    for _, object in ipairs(rod._room_objects_working or {}) do
        local remaining = mob_counts[object] or 0
        if remaining > 0 then
            mob_counts[object] = remaining - 1
        else
            table.insert(other, object)
        end
    end

    rod.room.mobs = mobs
    rod.room.other = other
    rod._room_exits_working = nil
    rod._room_objects_working = nil
    rod._room_mobs_working = nil

    rod._room_tracking = false
    emit("rod.room", {
        exits = rod.room.exits,
        mobs = rod.room.mobs,
        other = rod.room.other,
    })
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

if rod._inventory_tracking then
    local items = rod._inventory_working or {}

    rod.inventory = items
    rod._inventory_tracking = false
    rod._inventory_working = {}

    emit("rod.inventory.updated", {
        items = items,
    })
end

if rod._scan_direction then
    local scan_result = rod.scan_result()
    rod._scan_direction = nil
    emit("rod.scan", scan_result)
end
