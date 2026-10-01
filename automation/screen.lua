rod.buffers = rod.buffers or {}
rod.buffers.chat = screen.buffer("net.robparrett.mudmud-rod.chat")
rod.buffers.status = screen.buffer("net.robparrett.mudmud-rod.status")

local function chat_pane(rows)
    local pane = {
        buffer = "net.robparrett.mudmud-rod.chat",
        wrap = true,
        scroll_x = false,
        scroll_y = true,
    }
    pane.rows = rows
    return pane
end

if supports("screen_layout") then
    local current_platform = platform()
    local mobile = current_platform == "ios" or current_platform == "android"

    if mobile then
        screen.set_layout({
            id = "net.robparrett.mudmud-rod.mobile-chat",
            root = {
                id = "net.robparrett.mudmud-rod.main-chat",
                split = "rows",
                first = {
                    buffer = "main",
                },
                second = chat_pane(8),
            },
        })
    else
        screen.set_layout({
            id = "net.robparrett.mudmud-rod.three-pane",
            root = {
                id = "net.robparrett.mudmud-rod.main-sidebar",
                split = "columns",
                first = {
                    buffer = "main",
                },
                second = {
                    id = "net.robparrett.mudmud-rod.sidebar",
                    cols = 54,
                    split = "rows",
                    ratio = 0.35,
                    first = chat_pane(),
                    second = {
                        buffer = "net.robparrett.mudmud-rod.status",
                        wrap = false,
                        scroll_x = false,
                        scroll_y = false,
                    },
                },
            },
        })
    end
end
