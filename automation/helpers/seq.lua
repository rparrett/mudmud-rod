function rod.move(path, direction, timeout)
    timeout = timeout or 5

    path:retry(function(attempt, retry)
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
