local health = tonumber(event.payload.new_value)
local previous_health = tonumber(event.payload.old_value)
local health_max = tonumber(msdp.HEALTH_MAX)

if rod.resources_at_least({ health_percent = 100 })
    and health ~= nil
    and health_max ~= nil
    and (previous_health == nil or previous_health < health_max)
then
    emit("rod.health.full", {
        health = health,
        health_max = health_max,
        previous_health = previous_health,
    })
end
