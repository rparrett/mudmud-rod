local term = matches[2]
local lower_term = term and term:lower()
local names = {}

for name in pairs(rod.dirs) do
    if not lower_term or name:lower():find(lower_term, 1, true) then
        table.insert(names, name)
    end
end

table.sort(names)

if #names == 0 then
    echoln({
        "[",
        { text = "rod", foreground = ansi.bright_magenta },
        "] No matching walks.",
    })
    return
end

for _, name in ipairs(names) do
    echoln({
        { text = name, foreground = ansi.bright_cyan, width = 24 },
        rod.dirs[name],
    })
end
