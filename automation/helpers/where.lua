function rod.any_player_in_area()
    local character_name = tostring(msdp.CHARACTER_NAME or "")

    for _, player in ipairs(rod.area_players) do
        if player.name ~= character_name then
            return true
        end
    end

    return false
end
