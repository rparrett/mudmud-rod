local scheduled = rod._scheduled_reconnect
if not scheduled or time.monotonic() < scheduled.due_at then
    return
end

-- Clear the deadline before reconnecting so this fires exactly once. The Lua
-- runtime survives the connection cycle, allowing the callback to be handed
-- off to the game-entry trigger.
rod._scheduled_reconnect = nil
rod._reconnect_after_enter = scheduled.callback

rod.echoln("Reconnecting now.")
connection.reconnect()
