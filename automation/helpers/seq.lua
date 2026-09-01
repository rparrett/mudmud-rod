function rod.move(path, direction, timeout)
    timeout = timeout or 5

    path:retry("move " .. direction, function(attempt, retry)
        attempt:input(direction)

        attempt:race(function(first)
            first:event("rod.room", {
                handler = function()
                    retry:done()
                end,
            })

            first:line("No way!  You are still fighting!", function()
                rod.echoln({
                    "Movement blocked; waiting to retry ",
                    { text = direction, foreground = ansi.bright_cyan },
                    ".",
                })
            end)

            first:after(timeout, function()
                retry:again()
            end)
        end)

        attempt:race(function(first)
            first:event("rod.fight.end")
            first:after(3)
        end)
    end)
end

function rod.wait_until_fight_idle(path, timeout)
    timeout = timeout or 3

    path:retry("wait until fight idle", function(attempt, retry)
        attempt:race(function(first)
            first:event("rod.fight.idle", {
                handler = function()
                    retry:done()
                end,
            })

            first:after(timeout, function()
                local opponent = tostring(msdp.OPPONENT_NAME or "")
                if opponent == "" and rod._fight_idle_at == nil then
                    retry:done()
                else
                    retry:again()
                end
            end)
        end)
    end)
end

function rod.wait_until_msdp_room(path, room_name, timeout)
    timeout = timeout or 20

    path:retry("wait for MSDP room " .. room_name, function(attempt, retry)
        attempt:run(function()
            if tostring(msdp.ROOM_NAME or "") == room_name then
                retry:done()
            end
        end)

        attempt:race(function(first)
            first:event("msdp.ROOM_NAME", {
                payload = { new_value = room_name },
                handler = function()
                    retry:done()
                end,
            })
            first:after(timeout, function()
                rod.echoln({
                    { text = "MSDP room wait timed out: ", foreground = ansi.bright_yellow },
                    { text = room_name, foreground = ansi.bright_cyan },
                    ".",
                })
                retry:done()
            end)
        end)
    end)
end

local function quoted_cast_name(name)
    if name:find(" ", 1, true) then
        return "'" .. name .. "'"
    end

    return name
end

local function add_cast_pattern(first, pattern, handler)
    if type(pattern) == "string" then
        first:line(pattern, handler)
    elseif pattern.regex then
        first:regex(pattern.regex, {
            case_insensitive = pattern.case_insensitive == true,
            handler = handler,
        })
    elseif pattern.line then
        first:line(pattern.line, {
            case_insensitive = pattern.case_insensitive == true,
            handler = handler,
        })
    else
        error("cast pattern must be a line string or a pattern table")
    end
end

---Append a server-output-driven cast to a sequence path.
---`timeout` limits how long one individual cast attempt may wait for a
---recognized response; it resets after every retry. `max_retries` defaults to
---five, in addition to the initial attempt.
---@param path MudmudSequencePath
---@param spell string
---@param options? { target?: string, command?: string, timeout?: number, max_retries?: integer }
function rod.cast(path, spell, options)
    options = options or {}

    local spell_name = tostring(spell):lower()
    local definition = rod.spell_definition(spell_name)
    if not definition then
        error("no spell definition for '" .. spell_name .. "'")
    end

    local target = options.target and tostring(options.target) or nil
    local command_name = tostring(options.command or definition.command or spell_name)
    local command = quoted_cast_name(command_name)
    if definition.prefix ~= false then
        command = "c " .. command
    end
    if target and target ~= "" then
        command = command .. " " .. target
    end

    local timeout = options.timeout or 14
    local max_retries = options.max_retries
    if max_retries == nil then
        max_retries = 5
    end
    if type(max_retries) ~= "number" or max_retries < 0 or max_retries % 1 ~= 0 then
        error("cast max_retries must be a non-negative integer")
    end

    local completion_patterns = rod.spell_completion_patterns(spell_name, target)
    local retry_count = 0

    path:run(function()
        retry_count = 0
    end)
    path:retry("cast " .. spell_name, function(attempt, retry)
        attempt:send(command)
        attempt:race(function(first)
            local function complete(status)
                return function(match)
                    emit("rod.cast.complete", {
                        spell = spell_name,
                        target = target,
                        status = status,
                        line = match.line,
                    })
                    retry:done()
                end
            end

            local function retry_cast(match)
                if retry_count >= max_retries then
                    error(
                        "cast '"
                            .. spell_name
                            .. "' exhausted "
                            .. max_retries
                            .. " retries: "
                            .. match.line
                    )
                end

                retry_count = retry_count + 1
                retry:again()
            end

            local function terminal_failure(match)
                error("cast '" .. spell_name .. "' failed: " .. match.line)
            end

            for _, regex in ipairs(completion_patterns) do
                first:regex(regex, {
                    case_insensitive = true,
                    handler = complete("success"),
                })
            end

            local you_failed = definition.you_failed
                or rod.cast_patterns.you_failed_by_spell[spell_name]
                or "complete"
            if you_failed == "retry" then
                first:line("You failed.", retry_cast)
            elseif you_failed == "terminal" then
                first:line("You failed.", terminal_failure)
            else
                first:line("You failed.", complete("already"))
            end

            for _, pattern in ipairs(definition.retry or {}) do
                add_cast_pattern(first, pattern, retry_cast)
            end
            for _, pattern in ipairs(rod.cast_patterns.retry) do
                add_cast_pattern(first, pattern, retry_cast)
            end
            for _, pattern in ipairs(rod.cast_patterns.terminal) do
                add_cast_pattern(first, pattern, terminal_failure)
            end

            first:after(timeout, function()
                error("cast '" .. spell_name .. "' timed out after " .. timeout .. " seconds")
            end)
        end)
    end)
end

function rod.scan_all(path, timeout)
    path:input("scan all")
    path:wait_event("rod.scan", {
        timeout = timeout or 10,
        handler = function(scan_event)
            if scan_event.payload.found then
                seq.pause()
            end
        end,
    })
end

local function await_discovery(path, command, event_name, operation, timeout)
    local discovery_state
    local state_key = "_" .. operation

    path:input(command)
    path:run(function()
        discovery_state = rod[state_key]
    end)
    path:race(function(first)
        first:event(event_name)
        first:after(timeout or 45, function()
            if rod[state_key] == discovery_state then
                rod[state_key] = nil
            end
        end)
    end)
end

function rod.search(path, command, timeout)
    await_discovery(path, command or "search", "rod.search", "search", timeout)
end

function rod.dig(path, command, timeout)
    await_discovery(path, command or "dig", "rod.dig", "dig", timeout)
end
