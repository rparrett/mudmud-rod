function rod.move(path, dir, timeout)
    path:input(dir)
    path:race(function(move)
        move:event("rod.room")
        move:after(timeout or 5, function()
            echoln({
                "[",
                { text = "rod", foreground = ansi.bright_magenta },
                "] Move ",
                { text = dir, foreground = ansi.bright_cyan },
                " timed out; continuing.",
            })
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
