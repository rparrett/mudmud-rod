local definitions = {
    { name = "sanc", kind = "boolean", usage = "<on|off>", description = "Auto-quaff sanctuary potions" },
    { name = "sanckw", kind = "string", usage = "<text|unset>", description = "Keyword for sanctuary potions" },
    { name = "quaff", kind = "boolean", usage = "<on|off>", description = "Auto-quaff" },
    { name = "quaffkw", kind = "string", usage = "<text|unset>", description = "Keyword for healing potions" },
    { name = "quaffthresh", kind = "number", usage = "<number>", description = "Quaff when this much HP is missing" },
    { name = "mquaff", kind = "boolean", usage = "<on|off>", description = "Auto-quaff mana" },
    { name = "mquaffkw", kind = "string", usage = "<text|unset>", description = "Keyword for mana potions" },
    { name = "mquaffthresh", kind = "number", usage = "<number>", description = "Quaff when this much mana is missing" },
    { name = "attack", kind = "string", usage = "<text|unset>", description = "Command for secondary attacks" },
    { name = "scankw", kind = "string", usage = "<text|unset>", description = "Keyword to search for when scanning" },
    { name = "autoloot", kind = "boolean", usage = "<on|off>", description = "Auto-loot revealed search and dig items" },
}

local function display_value(definition)
    local value = rod.settings[definition.name]

    if definition.kind == "boolean" then
        return value and "on" or "off"
    end

    if definition.kind == "string" and value == "" then
        return "(not set)"
    end

    return tostring(value)
end

local function display_settings()
    echoln({
        "\n[",
        { text = "rod", foreground = ansi.bright_magenta, bold = true },
        "] Settings",
    })

    for _, definition in ipairs(definitions) do
        echoln({
            "  set ",
            { text = definition.name, foreground = ansi.bright_cyan, width = 14 },
            { text = definition.usage, foreground = ansi.bright_black, width = 14 },
            definition.description,
            " [",
            { text = display_value(definition), foreground = ansi.bright_green },
            "]",
        })
    end
end

local setting_name = matches[2]
local setting_text = matches[3]

if not setting_name then
    display_settings()
    return
end

local definition
for _, candidate in ipairs(definitions) do
    if candidate.name == setting_name then
        definition = candidate
        break
    end
end

if not definition then
    echoln({
        { text = "Unknown rod setting: ", foreground = ansi.bright_red },
        setting_name,
    })
    display_settings()
    return
end

if not setting_text then
    echoln({
        { text = "Usage: ", foreground = ansi.bright_red },
        "set ",
        definition.name,
        " ",
        definition.usage,
    })
    return
end

local value
if definition.kind == "boolean" then
    local normalized = setting_text:lower()
    if normalized == "true" or normalized == "on" then
        value = true
    elseif normalized == "false" or normalized == "off" then
        value = false
    else
        echoln({
            { text = "Invalid boolean: ", foreground = ansi.bright_red },
            setting_text,
            ". Use on, off, true, or false.",
        })
        return
    end
elseif definition.kind == "number" then
    value = tonumber(setting_text)
    if value == nil then
        echoln({
            { text = "Invalid number: ", foreground = ansi.bright_red },
            setting_text,
        })
        return
    end
elseif setting_text == "unset" then
    value = ""
else
    value = setting_text
end

rod.settings[definition.name] = value
echoln({
    "[",
    { text = "rod", foreground = ansi.bright_magenta },
    "] ",
    { text = definition.name, foreground = ansi.bright_cyan },
    " = ",
    { text = display_value(definition), foreground = ansi.bright_green },
})
