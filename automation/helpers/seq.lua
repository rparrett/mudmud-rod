function rod.move(path, dir, timeout)
    path:input(dir)
    path:wait_event("rod.room", {
        timeout = timeout or 3,
    })
end
