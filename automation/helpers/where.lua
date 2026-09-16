---Return the first player in the current area who is neither this character
---nor present in the supplied name set.
---@param allowed? table<string, boolean>
---@return boolean found
---@return table? player
function rod.any_unallowed_player_in_area(allowed)
    allowed = allowed or {}
    local character_name = tostring(msdp.CHARACTER_NAME or "")

    for _, player in ipairs(rod.area_players) do
        if player.name ~= character_name and not allowed[player.name] then
            return true, player
        end
    end

    return false, nil
end

function rod.any_player_in_area()
    return rod.any_unallowed_player_in_area()
end
