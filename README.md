# mudmud-rod

An automation pack for Realms of Despair.

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

### Rod settings

The current defaults are:

| Setting | Default | Purpose |
| --- | --- | --- |
| `sanc` | `true` | Auto-quaff sanctuary potions |
| `sanckw` | `"sanctuary"` | Sanctuary potion keyword |
| `quaff` | `true` | Auto-quaff healing potions |
| `quaffkw` | `"maroon"` | Healing potion keyword |
| `quaffthresh` | `20` | Quaff when this much HP is missing |
| `mquaff` | `true` | Auto-quaff mana potions |
| `mquaffkw` | `"blue"` | Mana potion keyword |
| `mquaffthresh` | `100` | Quaff when this much mana is missing |
| `attack` | `"strike"` | Secondary attack command |
| `scankw` | unset | Keyword reported by scan automation |

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
