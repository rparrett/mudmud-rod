if rod._game_entered then
    return
end

rod._game_entered = true

local payload = {
    line = line,
}

emit("rod.game.enter", payload)

local callback = rod._reconnect_after_enter
rod._reconnect_after_enter = nil

if callback then
    local ok, err = pcall(callback, payload)
    if not ok then
        rod.echoln({
            { text = "Post-reconnect callback failed: ", foreground = ansi.bright_red },
            tostring(err),
        })
    end
end
