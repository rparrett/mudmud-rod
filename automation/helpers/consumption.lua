function rod.quaff(item, count)
    count = count or 1
    local container = rod.get_container_keyword("potion")

    for _ = 1, count do
        rod._quaff_count = (rod._quaff_count or 0) + 1

        -- Using q bypasses Realms' anti-quaff behavior in some fights.
        send("q " .. item .. " " .. container)
    end
end

function rod.consume_item(item, count)
    count = count or 1

    if item:sub(1, 4) == "eat " then
        local food = item:sub(5)
        local container = rod.get_container_keyword("food")

        for _ = 1, count do
            send("eat " .. food .. " " .. container)
        end
    else
        rod.quaff(item, count)
    end
end
