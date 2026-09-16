# mudmud-rod

A `mudmud` automation pack for Realms of Despair.

## Setup and defaults

Add a profile-local **Script** automation in Mudmud for configuration that should be applied every
time that profile connects. The pack initializes first, and the profile script can then override
its defaults. Leave the script at Mudmud's default priority of 5 (or otherwise use a priority after
2); the pack's initialization and catalogs run at priorities 1 and 2.

### Containers

Autofight needs to know which container holds consumables. The only default container is:

```lua
rod.containers.main = "Dracocutis of the Isorla"
```

Potion and food lookups fall back to `main` when no type-specific container is configured. If the
profile does not use Dracocutis, override `main`. A typical profile script might contain:

```lua
rod.containers.main = "a large, black rucksack"
rod.containers.potion = "a Gnomish crafted metal potion container"
rod.containers.food = "a laundry basket"
```

Container names must exactly match an entry in `rod.item_keywords`. Common items are included with
the pack. Add a profile-specific item before assigning it as a container:

```lua
rod.item_keywords["a custom leather bag"] = "leather-bag"
rod.containers.main = "a custom leather bag"
```

### mudmud-rod settings

The current defaults are:

| Setting | Default | Purpose |
| --- | --- | --- |
| `sanc` | `true` | Auto-quaff sanctuary potions |
| `sanckw` | `"sanctuary"` | Sanctuary potion keyword |
| `quaff` | `true` | Auto-quaff healing potions |
| `quaffkw` | `"maroon"` | Healing potion keyword |
| `quaffthresh` | `20` | Quaff when this much HP is missing |
| `quaffsperdrink` | `8` | Quaffs between drinks from a spring |
| `springkw` | `"mystical"` | Drinking spring keyword |
| `mquaff` | `true` | Auto-quaff mana potions |
| `mquaffkw` | `"blue"` | Mana potion keyword |
| `mquaffthresh` | `100` | Quaff when this much mana is missing |
| `attack` | `"strike"` | Secondary attack command |
| `scankw` | unset | Keyword reported by scan automation |
| `autoloot` | `true` | Auto-loot configured search and dig items |
| `eqstrip` | `true` | Strip equipment before it breaks |
| `eqstripthresh` | `4` | Strip equipment below this estimated AC |
| `eqsurveyhits` | `3` | Equipment damage hits before requesting a survey |

Use `set` while connected to display the available commands and current values:

```text
set
set sanc off
set quaffthresh 50
set attack circle
set scankw dragon
set scankw unset
```

These commands change the current connection's Lua state. Put durable overrides in the profile's
Script automation instead:

```lua
rod.settings.quaffthresh = 50
rod.settings.attack = "circle"
rod.settings.scankw = "dragon"
```

Chat notifications are delivered by posting plain text to an
[ntfy.sh](https://ntfy.sh/) topic URL. Configure the topic before enabling either notification
type:

```text
set ntfyurl https://ntfy.sh/your-private-topic
set notifytells on
set notifyyells on
```

The `autoloot` setting can be toggled with `set autoloot on` and `set autoloot off`. Its item mapping
is separate configuration and must be managed in profile Lua. `rod.auto_loot` keys are exact
revealed item names. Values name entries in `rod.containers`; use an empty string to get an item
without putting it into a container:

```lua
rod.auto_loot = {
    ["a large stone with a flat top"] = "main",
    ["a piece of duck meat"] = "",
}
```

Add an exact entry to `rod.item_keywords` when the item's final word is not a sufficient keyword.

### Equipment condition tracking

mudmud-rod surveys damaged equipment and removes items before they break. This behavior is
controlled by the `eqstrip`, `eqstripthresh`, and `eqsurveyhits` settings above.

Add maximum AC values for unrecognized armor in profile Lua when needed:

```lua
rod.equipment_ac["a custom breastplate"] = 20
```

### Room and inventory snapshots

Each completed room display leaves its current exits, bright-magenta mobs, and other displayed
contents available in `rod.room.exits`, `rod.room.mobs`, and `rod.room.other`. The same values are
included in the `rod.room` event payload.

Running `inventory` replaces `rod.inventory` at the following prompt and emits
`rod.inventory.updated`. Item names are exact and quantities default to one when RoD does not show
a count. Helpers are available for both top-level inventory and examined configured containers:

```lua
rod.inventory_item_count("a solomonic crucifix")
rod.has_inventory_item("a solomonic crucifix", 2)

rod.container_item_count("a glowing maroon potion", "potion")
rod.has_container_item("a glowing maroon potion", 20, "potion")
```

### Scheduled reconnects

Scheduled reconnects use an offline-capable timer and do not occupy the sequencer. The optional
callback runs once after mudmud-rod detects that the character has entered the game again:

```lua
rod.schedule_reconnect(30 * 60, function()
    input("visage")
end)
```

Use `rod.cancel_scheduled_reconnect()` to cancel the pending reconnect and callback. It returns
`true` when there was something to cancel. `rod.scheduled_reconnect_in()` returns the remaining
delay in seconds, or `nil` when no reconnect is scheduled.
