rod._scheduled_reconnect = rod._scheduled_reconnect or nil
rod._reconnect_after_enter = rod._reconnect_after_enter or nil

local function format_delay(seconds)
    local whole_seconds = math.floor(seconds)
    local minutes = math.floor(whole_seconds / 60)
    local remainder = whole_seconds % 60

    if minutes > 0 and remainder > 0 then
        return string.format("%d minute%s and %d second%s",
            minutes, minutes == 1 and "" or "s",
            remainder, remainder == 1 and "" or "s")
    elseif minutes > 0 then
        return string.format("%d minute%s", minutes, minutes == 1 and "" or "s")
    end

    return string.format("%d second%s", whole_seconds, whole_seconds == 1 and "" or "s")
end

---Cancel a pending reconnect and any callback waiting for the next game entry.
---@return boolean canceled Whether anything was canceled.
function rod.cancel_scheduled_reconnect()
    local canceled = rod._scheduled_reconnect ~= nil or rod._reconnect_after_enter ~= nil
    rod._scheduled_reconnect = nil
    rod._reconnect_after_enter = nil
    return canceled
end

---Schedule a reconnect without occupying the sequencer.
---A new schedule replaces any pending reconnect or post-entry callback.
---@param delay_seconds number
---@param post_connect_callback? fun(payload: table)
function rod.schedule_reconnect(delay_seconds, post_connect_callback)
    if type(delay_seconds) ~= "number"
        or delay_seconds ~= delay_seconds
        or delay_seconds == math.huge
        or delay_seconds == -math.huge
        or delay_seconds < 0
    then
        error("reconnect delay must be a finite, non-negative number", 2)
    end

    if post_connect_callback ~= nil and type(post_connect_callback) ~= "function" then
        error("post-reconnect callback must be a function or nil", 2)
    end

    rod.cancel_scheduled_reconnect()
    rod._scheduled_reconnect = {
        due_at = time.monotonic() + delay_seconds,
        callback = post_connect_callback,
    }

    rod.echoln({
        "Reconnect scheduled in ",
        { text = format_delay(delay_seconds), foreground = ansi.bright_cyan },
        ".",
    })
end

---Return the seconds remaining before a scheduled reconnect, or nil.
---@return number? seconds
function rod.scheduled_reconnect_in()
    local scheduled = rod._scheduled_reconnect
    if not scheduled then
        return nil
    end

    return math.max(0, scheduled.due_at - time.monotonic())
end
