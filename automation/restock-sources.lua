-- Remove the short-lived RobRodMod-derived name if this catalog is hot-reloaded.
rod.restock_sources.dspots = nil

local defaults = {
    ds_shelf = {
        kind = "container",
        room = "The Dragon's Hoard",
        keyword = "shelf",
    },
    ds_donation = {
        kind = "container",
        room = "The Dragon's Hoard",
        keyword = "donation",
    },

    xygian = { kind = "shop", room = "Xygian's Mystical Objects" },
    zelah = { kind = "shop", room = "Zelah's Apothecary" },
    poshir = { kind = "shop", room = "Poshir's Scrolls" },
    marsel = { kind = "shop", room = "Quills and Parchments" },
    grillek = { kind = "shop", room = "The Carnivore's Delight" },
    nimmith = { kind = "shop", room = "The Darkhaven Bakery" },
    matilda = { kind = "shop", room = "Matilda's Dairy Products" },
    deren = { kind = "shop", room = "The Young Adventurer's Necessities" },
    farsel = { kind = "shop", room = "The Darkhaven Courier" },
    roichlen = { kind = "shop", room = "The Mortar and Pestle" },
    caornell = { kind = "shop", room = "The Green Man..." },
}

for name, definition in pairs(defaults) do
    rod.restock_sources[name] = rod.restock_sources[name] or definition
end
