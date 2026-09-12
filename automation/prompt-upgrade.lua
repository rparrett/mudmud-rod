local prompt_version = "11"

if line:match("^[~!]" .. prompt_version .. " ") then
    return
end

local level = tonumber(msdp.LEVEL)
local class = msdp.CLASS
if level == nil or class == nil then
    return
end

local now = time.monotonic()
rod._last_prompt_upgrade_at = rod._last_prompt_upgrade_at or -math.huge
if now - rod._last_prompt_upgrade_at < 30 then
    return
end

local no_mana_classes = {
    Thief = true,
    Warrior = true,
}

local vampire_classes = {
    Vampire = true,
    ["Dread vampire"] = true,
}

local function build_prompt(indicator)
    local parts = {
        "&w" .. indicator .. prompt_version .. " ",
        "&z[",
        "&Y%h/%Hhp",
    }

    if vampire_classes[class] then
        table.insert(parts, " &R%b/%Bbp")
    elseif not no_mana_classes[class] then
        table.insert(parts, " &C%m/%Mmp")
    end

    table.insert(parts, " &G%v/%Vmv")

    if level <= 49 then
        table.insert(parts, " &P%xxp")
    end

    table.insert(parts, "&z] ")

    if indicator == "!" then
        table.insert(parts, "&z[&p%n: &r%c&z] ")
    else
        table.insert(parts, "&z[&w%E&z] ")
    end

    table.insert(parts, "&z[&O%L&z] ")
    table.insert(parts, "&w")

    return table.concat(parts)
end

send("prompt " .. build_prompt("&-"))
send("fprompt " .. build_prompt("!"))
rod._last_prompt_upgrade_at = now
