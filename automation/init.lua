rod = rod or {}
rod.room = rod.room or {}
rod.room.exits = rod.room.exits or {}
rod.scan = rod.scan or {}
rod.settings = rod.settings or {}

if rod.settings.quaff == nil then rod.settings.quaff = true end
if rod.settings.quaffkw == nil then rod.settings.quaffkw = "maroon" end
if rod.settings.quaffthresh == nil then rod.settings.quaffthresh = 20 end
if rod.settings.mquaff == nil then rod.settings.mquaff = true end
if rod.settings.mquaffkw == nil then rod.settings.mquaffkw = "blue" end
if rod.settings.mquaffthresh == nil then rod.settings.mquaffthresh = 100 end
if rod.settings.attack == nil then rod.settings.attack = "strike" end
if rod.settings.scankw == nil then rod.settings.scankw = "" end
