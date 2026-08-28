local buffs = {
    { spell = "protection", potion = "protection" },
    { spell = "blazeward", potion = "blazeward" },
    { spell = "inner warmth", potion = "inner" },
    { spell = "demonskin", potion = "demonskin" },
    { spell = "dragonskin", potion = "dragonskin" },
    { spell = "shadowform", potion = "shadowform" },
    { spell = "grounding", potion = "grounding" },
    { spell = "antimagic shell", potion = "antimagic" },
    { spell = "ethereal web", potion = "web" },
    { spell = "ethereal shield", potion = "shield" },
    { spell = "sanctuary", potion = "sanctuary" },
    { spell = "eldritch sphere", potion = "eldritch" },
}

-- TODO: Treat protection as active when equipment tracking shows an item
-- matching "the Storm" is being worn.
local protection_from_equipment = false

for _, buff in ipairs(buffs) do
    if rod.affects_by_name[buff.spell] == nil
        and not (buff.spell == "protection" and protection_from_equipment)
    then
        rod.quaff(buff.potion)
    end
end
