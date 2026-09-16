local health = tonumber(event.payload.new_value)
local previous_health = tonumber(event.payload.old_value)
local health_max = tonumber(msdp.HEALTH_MAX)

if health ~= nil
    and health_max ~= nil
    and health_max > 0
    and health >= health_max
    and (previous_health == nil or previous_health < health_max)
then
    emit("rod.health.full", {
        health = health,
        health_max = health_max,
        previous_health = previous_health,
    })
end
