function rod.get_container(container_type)
    container_type = container_type or "main"
    local name = rod.containers[container_type] or rod.containers.main

    return {
        name = name,
        keyword = rod.item_keywords[name],
    }
end

function rod.get_container_keyword(container_type)
    local container = rod.get_container(container_type)
    if container.keyword == nil then
        error("no keyword configured for container item " .. tostring(container.name))
    end

    return container.keyword
end
