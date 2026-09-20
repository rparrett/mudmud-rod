local weapon = string.trim(matches.weapon or "")
if weapon == "" then
    return
end

-- RoD strips a leading a/an/the from the canonical item description in its
-- disarm message. Prefer an exact configured form, then reconstruct the
-- possible canonical descriptions before using the normal last-word fallback.
local keyword_item = weapon
if rod.item_keywords[weapon] == nil then
    for _, article in ipairs({ "a ", "an ", "the ", "A ", "An ", "The " }) do
        local candidate = article .. weapon
        if rod.item_keywords[candidate] ~= nil then
            keyword_item = candidate
            break
        end
    end
end

local keyword = rod.get_item_keyword(keyword_item)
send("get " .. keyword)
send("wield " .. keyword)
