rod.buffers = rod.buffers or {}
rod.buffers.chat = screen.buffer("net.robparrett.mudmud-rod.chat")
rod.buffers.status = screen.buffer("net.robparrett.mudmud-rod.status")

if supports("screen_layout") and platform() ~= "ios" then
    screen.set_layout({
        id = "net.robparrett.mudmud-rod.three-pane",
        root = {
            id = "net.robparrett.mudmud-rod.main-sidebar",
            split = "columns",
            ratio = 0.66,
            first = {
                buffer = "main",
            },
            second = {
                id = "net.robparrett.mudmud-rod.sidebar",
                split = "rows",
                ratio = 0.50,
                first = {
                    buffer = "net.robparrett.mudmud-rod.chat",
                    wrap = true,
                    scroll_x = false,
                    scroll_y = true,
                },
                second = {
                    buffer = "net.robparrett.mudmud-rod.status",
                    wrap = false,
                    scroll_x = false,
                    scroll_y = false,
                    font_size = 10,
                },
            },
        },
    })
end
