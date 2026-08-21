if rod._fight_idle_at and now() >= rod._fight_idle_at then
    rod._fight_idle_at = nil

    if msdp.OPPONENT_NAME == nil or msdp.OPPONENT_NAME == "" then
        emit("rod.fight.idle")
    end
end
