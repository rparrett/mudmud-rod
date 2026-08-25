local operation = matches.operation
local item = matches.item
local container_definition

if rod.settings.autoloot then
    container_definition = rod.auto_loot[item]
end

if container_definition ~= nil then
    if type(container_definition) ~= "string" then
        error("autoloot container definition for " .. item .. " must be a string")
    end

    local keyword = rod.get_item_keyword(item)
    send("get " .. keyword)

    if container_definition ~= "" then
        send("put " .. keyword .. " " .. rod.get_container_keyword(container_definition))
    end
end

rod._complete_discovery(operation, item)
