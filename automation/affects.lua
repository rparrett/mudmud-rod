local affects = {}

local function parse_affect(chunk)
    local name, duration = chunk:match("^%s*([^,]-)%s*,%s*(%d+)%s*$")
    if name and duration then
        affects[name:lower()] = tonumber(duration)
    end
end

local value = msdp.AFFECTS
if type(value) == "string" then
    for chunk in (value .. "\007"):gmatch("(.-)\007+") do
        parse_affect(chunk)
    end
elseif type(value) == "table" then
    for _, chunk in ipairs(value) do
        parse_affect(chunk)
    end
end

rod.affects_by_name = affects
