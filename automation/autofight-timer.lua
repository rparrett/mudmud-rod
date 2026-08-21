local last_run = rod._last_autofight_at

if last_run == nil or now() - last_run >= 1 then
    rod.autofight()
end
