local current = tostring(msdp.OPPONENT_NAME or event.payload.new_value or "")
local previous = rod._fight_previous_opponent

if previous == nil then
    previous = tostring(event.payload.old_value or "")
end

-- Any opponent update cancels a pending idle notification.
rod._fight_idle_at = nil

if current == previous then
    return
end

if current == "" then
    local ended_at = time.monotonic()
    local payload = {
        opponent = previous,
    }

    local current_exp = tonumber(msdp.EXPERIENCE)
    if rod._fight_started_at and rod._fight_started_exp and current_exp then
        local elapsed = ended_at - rod._fight_started_at
        local gained = current_exp - rod._fight_started_exp

        payload.elapsed = elapsed
        payload.experience_gained = gained

        if elapsed > 0 then
            payload.experience_per_minute = gained / elapsed * 60
        end

        local output = {
            "Fight ended after ",
            { text = string.format("%.1fs", elapsed), foreground = ansi.bright_cyan },
            "; gained ",
            { text = rod.format_exp(gained), foreground = ansi.bright_green, bold = true },
        }

        if payload.experience_per_minute then
            table.insert(output, " XP (")
            table.insert(output, {
                text = rod.format_exp(payload.experience_per_minute) .. "/min",
                foreground = ansi.bright_yellow,
            })
            table.insert(output, ").")
        else
            table.insert(output, " XP.")
        end

        rod.echoln(output)
    end

    emit("rod.fight.end", payload)

    rod._fight_started_at = nil
    rod._fight_started_exp = nil
    rod._fight_idle_at = ended_at + 6
elseif previous == "" then
    rod._fight_started_at = time.monotonic()
    rod._fight_started_exp = tonumber(msdp.EXPERIENCE)

    emit("rod.fight.start", {
        opponent = current,
    })
else
    emit("rod.fight.switch", {
        opponent = current,
        previous_opponent = previous,
    })
end

rod._fight_previous_opponent = current
