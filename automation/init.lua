rod = rod or {}
rod.room = rod.room or {}
rod.room.exits = rod.room.exits or {}
rod.area_players = rod.area_players or {}
rod.scan = rod.scan or {}
rod.settings = rod.settings or {}
rod.containers = rod.containers or {}
rod.auto_loot = rod.auto_loot or {}
rod.affects_by_name = rod.affects_by_name or {}
rod.equipment = rod.equipment or {}
rod.equipment_ac = rod.equipment_ac or {}
rod.sounds = rod.sounds or {}

rod._equipment_hits = rod._equipment_hits or {}
rod._equipment_remove_counts = rod._equipment_remove_counts or {}
rod._equipment_remove_order = rod._equipment_remove_order or {}
rod._equipment_removal_sent = rod._equipment_removal_sent or {}
rod._equipment_survey_pending = rod._equipment_survey_pending or false
rod._equipment_survey_inflight = rod._equipment_survey_inflight or false
rod._equipment_tracking_survey = rod._equipment_tracking_survey or false
rod._repop_sightings = rod._repop_sightings or {}
rod._where_tracking = rod._where_tracking or false

-- Monotonic timestamps are meaningful only within the current Lua runtime.
rod._last_send_at = time.monotonic()

rod.containers.main = rod.containers.main or "Dracocutis of the Isorla"

if rod.settings.sanc == nil then rod.settings.sanc = true end
if rod.settings.sanckw == nil then rod.settings.sanckw = "sanctuary" end
if rod.settings.quaff == nil then rod.settings.quaff = true end
if rod.settings.quaffkw == nil then rod.settings.quaffkw = "maroon" end
if rod.settings.quaffthresh == nil then rod.settings.quaffthresh = 20 end
if rod.settings.quaffsperdrink == nil then rod.settings.quaffsperdrink = 8 end
if rod.settings.springkw == nil then rod.settings.springkw = "mystical" end
if rod.settings.mquaff == nil then rod.settings.mquaff = true end
if rod.settings.mquaffkw == nil then rod.settings.mquaffkw = "blue" end
if rod.settings.mquaffthresh == nil then rod.settings.mquaffthresh = 100 end
if rod.settings.attack == nil then rod.settings.attack = "strike" end
if rod.settings.scankw == nil then rod.settings.scankw = "" end
if rod.settings.autoloot == nil then rod.settings.autoloot = true end
if rod.settings.eqstrip == nil then rod.settings.eqstrip = true end
if rod.settings.eqstripthresh == nil then rod.settings.eqstripthresh = 4 end
if rod.settings.eqsurveyhits == nil then rod.settings.eqsurveyhits = 3 end
