function rod.get_item_keyword(item)
    local keyword = rod.item_keywords[item] or item:match("(%S+)$") or item

    if keyword:find(" ", 1, true) then
        return "'" .. keyword .. "'"
    end

    return keyword
end
