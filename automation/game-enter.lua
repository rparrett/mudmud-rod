if rod._game_entered then
    return
end

rod._game_entered = true
emit("rod.game.enter", {
    line = line,
})
