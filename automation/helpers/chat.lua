local ignored_characters = {
    -- mobs
    lucinde = true,
    blorin = true,
    jensen = true,
    phaeba = true,
    kylara = true,
    belesdan = true,
    regis = true,
    doris = true,
    aegir = true,
    marsel = true,
    torton = true,
    ceana = true,
    -- bots
    cyndl = true,
    aen = true,
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

local function send_notification(chat_line)
    local url = rod.settings.ntfyurl
    if type(url) ~= "string" or url == "" then
        return
    end

    local profile = connection.info().profile
    http.request({
        url = url,
        method = "POST",
        headers = {
            ["Content-Type"] = "text/plain; charset=utf-8",
        },
        body = "[" .. profile .. "] " .. chat_line,
        timeout = 10,
        max_response_bytes = 65536,
    }, function(response, request_error)
        if request_error then
            rod.echoln({
                { text = "Chat notification failed: ", foreground = ansi.bright_yellow },
                request_error.message,
            })
        elseif response.status < 200 or response.status >= 300 then
            rod.echoln({
                { text = "Chat notification failed: ", foreground = ansi.bright_yellow },
                "HTTP ",
                tostring(response.status),
                ".",
            })
        end
    end)
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

    if message_type == "tells you" and rod.settings.notifytells then
        send_notification(chat_line)
    elseif message_type == "yells" and rod.settings.notifyyells then
        send_notification(chat_line)
    end
end
