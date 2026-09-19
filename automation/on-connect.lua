rod._game_entered = false

if rod._scheduled_reconnect_connecting then
    -- This connection was initiated by the offline reconnect timer. Preserve
    -- its one-shot game-entry callback.
    rod._scheduled_reconnect_connecting = false
else
    -- Any independently established connection supersedes an outstanding
    -- schedule and its callback.
    if rod.cancel_scheduled_reconnect() then
        rod.echoln("Scheduled reconnect canceled because a connection was established.")
    end
end

rod.echoln("Connected!")
