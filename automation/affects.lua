local affects = {}
local affects_order = {}

local function parse_affect(chunk)
    local name, duration = chunk:match("^%s*([^,]-)%s*,%s*(%d+)%s*$")
    if name and duration then
        local normalized_name = name:lower()
        affects[normalized_name] = tonumber(duration)
        table.insert(affects_order, {
            name = name,
            normalized_name = normalized_name,
        })
    end
end

local function parse_affects(value)
    if type(value) ~= "string" then
        return
    end

    for chunk in (value .. "\007"):gmatch("(.-)\007+") do
        parse_affect(chunk)
    end
end

local value = msdp.AFFECTS
if type(value) == "table" then
    for _, chunk in ipairs(value) do
        parse_affects(chunk)
    end
else
    parse_affects(value)
end

rod.affects_by_name = affects
emit("rod.affects.updated", { affects = affects })

local function affect_style(name, duration)
    if name == "sanctuary" or name == "sacral divinity" or name == "nadur dion" then
        return { foreground = ansi.bright_white, bold = true }
    elseif name == "blindness" then
        local true_sight = affects["true sight"]
        if not true_sight or true_sight < duration then
            return { foreground = ansi.bright_red }
        end
    elseif name == "true sight" then
        return { foreground = ansi.rgb(186, 230, 253), bold = true }
    elseif name == "poison" then
        return { foreground = ansi.rgb(217, 249, 157), bold = true }
    end

    return {}
end

local columns = 3
local column_width = 18
local display = rod.status_header("Affects")

for i = 1, #affects_order, columns do
    for column = 0, columns - 1 do
        local affect = affects_order[i + column]
        if affect then
            local duration = affects[affect.normalized_name]
            local duration_text = " (" .. duration .. ")"
            local maximum_name_length = column_width - #duration_text - 1
            local display_name = affect.name

            if #display_name > maximum_name_length then
                display_name = display_name:sub(1, maximum_name_length - 1) .. "~"
            end

            local style = affect_style(affect.normalized_name, duration)
            style.text = display_name
            table.insert(display, style)
            table.insert(display, {
                text = duration_text,
                width = column_width - #display_name,
            })
        end
    end

    table.insert(display, "\n")
end

rod.set_status_section("affects", display)
