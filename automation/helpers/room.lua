local function expected_rooms(value)
    if type(value) == "string" then
        return { value }
    end

    if type(value) ~= "table" then
        error("expected room must be a string or list of strings")
    end

    local rooms = {}
    for index, room in ipairs(value) do
        if type(room) ~= "string" or room == "" then
            error("expected room at index " .. index .. " must be a non-empty string")
        end
        table.insert(rooms, room)
    end

    if #rooms == 0 then
        error("expected room list must not be empty")
    end

    return rooms
end

---Check whether the character is currently in one of the expected MSDP rooms.
---Prints a consistently formatted message when the check fails.
---@param expected string|string[]
---@return boolean allowed
function rod.assert_room(expected)
    local rooms = expected_rooms(expected)
    local current = tostring(msdp.ROOM_NAME or "")

    for _, room in ipairs(rooms) do
        if current == room then
            return true
        end
    end

    local output = {
        { text = "Must be in ", foreground = ansi.bright_yellow },
    }

    if #rooms > 1 then
        table.insert(output, "one of: ")
    end

    for index, room in ipairs(rooms) do
        if index > 1 then
            table.insert(output, index == #rooms and " or " or ", ")
        end
        table.insert(output, {
            text = room,
            foreground = ansi.bright_cyan,
        })
    end

    table.insert(output, ".")
    if current ~= "" then
        table.insert(output, " Current room: ")
        table.insert(output, {
            text = current,
            foreground = ansi.bright_black,
        })
        table.insert(output, ".")
    end

    rod.echoln(output)
    return false
end
