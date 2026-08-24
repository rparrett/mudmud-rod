local idle_for = time.monotonic() - rod._last_send_at

if idle_for >= 9 * 60 and connection.connected() then
    rod._anti_idle_abbreviated = not rod._anti_idle_abbreviated
    send(rod._anti_idle_abbreviated and "tim" or "time")
end
