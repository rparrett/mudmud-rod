local function has_keyword(value)
    return type(value) == "string" and value ~= ""
end

local function can_see_opponent(opponent)
    return opponent ~= "You cannot see your opponent."
end

local function needs_blindness_cure()
    local blindness_rounds = rod.spell_rounds("blindness")
    local true_sight_rounds = rod.spell_rounds("true sight")

    return blindness_rounds > true_sight_rounds and true_sight_rounds < 3
end

local function healing_quaff_count(missing_health)
    if missing_health > rod.settings.quaffamt * 2 then
        return 2
    end

    return 1
end

function rod.autofight()
    if msdp.WAIT_TIME == nil or msdp.WAIT_TIME ~= "" then
        return
    end

    local opponent = msdp.OPPONENT_NAME
    if opponent == nil or opponent == "" then
        return
    end

    rod.flush_equipment_actions()

    local health = tonumber(msdp.HEALTH)
    local health_max = tonumber(msdp.HEALTH_MAX)
    local mana = tonumber(msdp.MANA)
    local mana_max = tonumber(msdp.MANA_MAX)

    if not health or not health_max or not mana or not mana_max then
        return
    end

    rod._last_autofight_at = time.monotonic()

    local missing_health = health_max - health
    local missing_mana = mana_max - mana
    local can_see = can_see_opponent(opponent)

    if can_see
        and rod.settings.truesight
        and needs_blindness_cure()
        and has_keyword(rod.settings.blindkw)
    then
        rod.consume_item(rod.settings.blindkw)
    elseif can_see
        and rod.settings.truesight
        and rod.spell_rounds("true sight") == -1
        and has_keyword(rod.settings.truesightkw)
    then
        rod.consume_item(rod.settings.truesightkw)
    elseif can_see
        and rod.settings.sanc
        and rod.sanctuary_rounds() == -1
        and has_keyword(rod.settings.sanckw)
    then
        rod.consume_item(rod.settings.sanckw)
    elseif can_see
        and rod.settings.quaff
        and has_keyword(rod.settings.equaffkw)
        and missing_health > rod.settings.equaffthresh
    then
        rod.consume_item(rod.settings.equaffkw, 2)
    elseif can_see
        and rod.settings.quaff
        and has_keyword(rod.settings.quaffkw)
        and missing_health >= rod.settings.quaffthresh
    then
        rod.consume_item(rod.settings.quaffkw, healing_quaff_count(missing_health))
    elseif can_see
        and rod.settings.mquaff
        and has_keyword(rod.settings.mquaffkw)
        and missing_mana >= rod.settings.mquaffthresh
    then
        rod.consume_item(rod.settings.mquaffkw)
    elseif rod.settings.attack ~= "" then
        send(rod.settings.attack)
    end
end
