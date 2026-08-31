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
    path:race(function(first)
        first:event("msdp.ROOM_NAME", {
            payload = { new_value = room_name },
        })
        first:after(timeout or 20)
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
