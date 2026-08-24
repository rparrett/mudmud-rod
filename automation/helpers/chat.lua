local ignored_characters = {
    lucinde = true,
    blorin = true,
    jensen = true,
    phaeba = true,
    kylara = true,
    belesdan = true,
    regis = true,
}

local function chat_color(message_type)
    if message_type == nil or message_type == "achieved" then
        return ansi.bright_yellow
    elseif message_type == "tell" or message_type == "tells you" then
        return ansi.bright_white
    elseif message_type == "ordertalk" or message_type == "ordertalks" then
        return ansi.rgb(4, 247, 174)
    elseif message_type == "group" then
        return ansi.rgb(0, 221, 255)
    elseif message_type == "racetalk" or message_type == "racetalks" then
        return ansi.rgb(0, 0, 119)
    end

    return ansi.bright_cyan
end

function rod.capture_chat(message_type_override)
    local character = matches.char
    if character and ignored_characters[character:lower()] then
        return
    end

    local message_type = message_type_override or matches.msgtype
    local chat_line = line
    local timestamp = time.format("%H:%M:%S")

    rod.buffers.chat:echoln({
        {
            text = timestamp .. " ",
            foreground = ansi.bright_green,
        },
        {
            text = chat_line,
            foreground = chat_color(message_type),
        },
    })

    if message_type == "tell" or message_type == "tells you" then
        emit("rod.chat.tell", {
            character = character or "",
            message = matches.msg or "",
            line = chat_line,
        })
    end
end
