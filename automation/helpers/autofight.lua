function rod.autofight()
    if msdp.WAIT_TIME == nil or msdp.WAIT_TIME ~= "" then
        return
    end

    if msdp.OPPONENT_NAME == nil or msdp.OPPONENT_NAME == "" then
        return
    end

    local health = tonumber(msdp.HEALTH)
    local health_max = tonumber(msdp.HEALTH_MAX)
    local mana = tonumber(msdp.MANA)
    local mana_max = tonumber(msdp.MANA_MAX)

    if not health or not health_max or not mana or not mana_max then
        return
    end

    rod._last_autofight_at = time.monotonic()

    local missing_health = health_max - health
    local missing_mana = mana_max - mana

    if rod.settings.sanc and rod.sanctuary_rounds() == -1 then
        rod.consume_item(rod.settings.sanckw)
    elseif rod.settings.quaff and missing_health >= rod.settings.quaffthresh then
        rod.consume_item(rod.settings.quaffkw)
    elseif rod.settings.mquaff and missing_mana >= rod.settings.mquaffthresh then
        rod.consume_item(rod.settings.mquaffkw)
    elseif rod.settings.attack ~= "" then
        send(rod.settings.attack)
    end
end
