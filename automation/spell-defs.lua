local function target(regex)
    return { regex = regex, target = true }
end

local function self(regex)
    return { regex = regex, self_only = true }
end

rod.cast_patterns = {
    retry = {
        "You get a mental block mid-way through the casting.",
        "You lost your concentration.",
        "A tickle in your nose prevents you from keeping your concentration.",
        "Something distracts you, and you lose your concentration.",
        "A twitch in your eye disrupts your concentration for a moment.",
        "An itch on your leg keeps you from properly casting your spell.",
        "Something in your throat prevents you from uttering the proper phrase.",
    },
    terminal = {
        "You don't have enough mana.",
        "They aren't here.",
    },
    you_failed_by_spell = {
        summon = "retry",
    },
}

-- {{target}} is replaced with the requested target before a sequence matcher is
-- registered. This prevents another caster's result for somebody else from
-- completing our cast. Patterns without a target are necessarily unfiltered.
-- "You failed." completes a cast by default. A definition can override the
-- shared per-spell behavior above when another exception is discovered.
rod.spells = {
    ["ogre might"] = {
        complete = {
            target("^{{target}}'s muscles ripple as they are infused with the might of an ogre\\.$"),
            self("^The unfettered power of an ogre flows through (?<target>You)r muscles\\.$"),
        },
    },
    sagacity = {
        complete = {
            target("^{{target}} grows serious as wisdom takes root within \\w+\\.$"),
            self("^The wisdom of (?<target>You)r elders blossoms within you\\.$"),
        },
    },
    ["elven beauty"] = {
        complete = {
            target("^{{target}}'s ears grow pointed and \\w+ voice takes on a musical aspect\\.$"),
            self("^(?<target>You)r face is blessed with elven features as you grow more attractive\\.$"),
        },
    },
    ["trollish vigor"] = {
        complete = {
            target("^{{target}}'s face contorts with a bestial vigor\\.$"),
            self("^(?<target>You) sense a bestial vigor consume you\\.$"),
        },
    },
    ["dragon wit"] = {
        complete = {
            target("^{{target}}'s eyes glimmer with the wit of the dragon\\.$"),
            self("^(?<target>You) mind awakens in reception to the dragon's wit\\.$"),
        },
    },
    slink = {
        complete = {
            target("^{{target}} suddenly appears more agile\\.\\.\\.$"),
            self("^(?<target>You) suddenly feel more nimble\\.\\.\\.$"),
        },
    },
    float = {
        complete = {
            target("^{{target}} begins to float in mid-air\\.\\.\\.$"),
            self("^(?<target>You) begin to float in mid-air\\.\\.\\.$"),
        },
    },
    fly = {
        complete = {
            target("^{{target}} rises into the currents of air\\.\\.\\.$"),
            self("^(?<target>You) rise into the currents of air\\.\\.\\.$"),
        },
    },
    shield = {
        complete = {
            target("^A force shield of shimmering blue surrounds {{target}}\\.$"),
        },
    },
    valiance = {
        complete = {
            target("^{{target}} is surrounded by an aura which protects \\w+ from paralysis\\.$"),
            self("^A magical resistance to paralysis consumes (?<target>You)\\.$"),
        },
    },
    ["inner warmth"] = {
        complete = {
            target("^A mysterious warmth radiates from {{target}}\\.\\.\\.$"),
            self("^A comforting warmth spreads through (?<target>You)r frame\\.$"),
        },
    },
    ["aqua breath"] = {
        complete = {
            target("^{{target}}'s lungs take on the ability to breathe water\\.\\.\\.$"),
            self("^(?<target>You)r lungs take on the ability to breathe water\\.\\.\\.$"),
        },
    },
    iceshield = {
        complete = {
            target("^A glistening hail of ice encompasses {{target}}\\.$"),
        },
    },
    fireshield = {
        complete = {
            target("^Mystical flames rise to enshroud {{target}}\\.$"),
        },
    },
    shockshield = {
        complete = {
            target("^Torrents of cascading energy form around {{target}}\\.$"),
        },
    },
    infravision = {
        complete = {
            target("^{{target}}'s eyes dart about as they grow accustomed to infravision\\.$"),
            self("^Heat appears red through (?<target>You)r eyes\\.$"),
        },
    },
    scry = {
        complete = {
            target("^{{target}}'s eyes glaze over as \\w+ endures a vision\\.\\.\\.$"),
            self("^(?<target>You) receive a revelatory vision\\.\\.\\.$"),
        },
    },
    armor = {
        complete = {
            target("^{{target}}'s armor begins to glow softly as it is enhanced by a cantrip\\.$"),
            self("^(?<target>You)r armor begins to glow softly as it is enhanced by a cantrip\\.$"),
        },
    },
    bless = {
        complete = {
            target("^You lay the blessing of your god upon {{target}}\\.$"),
            self("^A powerful blessing is laid upon (?<target>You)\\.$"),
        },
    },
    acidward = {
        complete = {
            target("^Streams of green energy form a protective ward around {{target}}\\.$"),
            self("^Streams of green energy form a protective ward\\.$"),
        },
    },
    resilience = {
        complete = {
            target("^You bless {{target}} with a holy resilience\\.$"),
            self("^(?<target>You) feel resilient\\.$"),
        },
    },
    nimbus = {
        complete = {
            target("^A glowing nimbus of light envelops {{target}}\\.$"),
        },
    },
    sanctuary = {
        complete = {
            target("^A luminous aura spreads slowly over {{target}}'s body\\.$"),
        },
    },
    midas = {
        complete = {
            "^You transmogrify .+ to gold!$",
        },
        retry = {
            { regex = "^A yellowish glow slowly seeps over .+, leaving behind pure gold\\.$" },
        },
    },
    ["create spring"] = {
        complete = {
            "^Tracing a ring before you, the graceful flow of a mystical spring emerges\\.$",
        },
    },
    heal = {
        complete = {
            target("^You lay a hand of healing upon {{target}}\\.$"),
            self("^A warm feeling fills (?<target>You)r body\\.$"),
        },
    },
    ["sacral divinity"] = {
        complete = {
            self("^A shroud of glittering light slowly wraps itself around (?<target>You)\\.$"),
        },
    },
    ["divine armor"] = {
        complete = {
            self("^A blessing from your deity, a divine armor forms about (?<target>You)\\.$"),
            self("^Your deity grants (?<target>You) no blessings\\.$"),
        },
    },
    ["solomonic invocation"] = {
        complete = {
            "^A brilliant sphere of light coalesces into a gleaming silver cross\\.$",
        },
    },
    tend = {
        complete = {
            self("^(?<target>You)r wounds are soothed and lessened\\.$"),
        },
        retry = {
            "This attempt fails to tend any wounds.",
        },
    },
    lucidity = {
        prefix = false,
        complete = {
            self("^(?<target>You)r form slowly takes on the appearance of fog\\.$"),
        },
        retry = {
            "You fail to change your body's form.",
        },
    },
    forest = {
        prefix = false,
        complete = {
            self("^(?<target>You) softly recite a meaningful prayer to the spirits of the forest\\.$"),
        },
        retry = {
            "You softly recite a forest prayer and mispronounce several words.",
        },
    },
    mercuria = {
        prefix = false,
        complete = {
            self("^(?<target>You)r actions and reactions accelerate to exceptional speeds\\.$"),
        },
        retry = {
            "You are unable to push your body past its natural boundaries.",
        },
    },
    camouflage = {
        prefix = false,
        complete = {
            self("^(?<target>You) blend into your surroundings and proceed silently\\.$"),
        },
        retry = {
            "You fail to camouflage yourself.",
        },
    },
    heighten = {
        prefix = false,
        complete = {
            self("^(?<target>You) concentrate on heightening your defenses\\.$"),
        },
        retry = {
            "You fail to heighten your defenses.",
        },
    },
    granite = {
        prefix = false,
        complete = {
            self("^(?<target>You)r skin takes on the appearance and texture of granite\\.$"),
        },
        retry = {
            "You fail to change your skin's texture.",
        },
    },
    ["remove hex"] = {
        complete = {
            target("^You lift the hex from {{target}}\\.$"),
            target("^{{target}} has no items in their possession that are hexed\\.$"),
        },
    },
    ["elemental supremacy"] = {
        complete = {
            target("^Three elemental fields begin to orbit around {{target}}\\.$"),
        },
    },
    enchant = {
        complete = {
            "^.+ gleams with flecks of blue energy\\.$",
            "^Your magic twists and winds around .+ but cannot take hold\\.$",
        },
    },
    recharge = {
        complete = {
            "^A .+ glows brightly for a few seconds\\.\\.\\.$",
            "^A .+ glows with a blinding magical luminescence\\.$",
            "^A .+ feels warm to the touch\\.$",
            "^A .+ disintegrates into a void\\.$",
            "^Nothing happens\\.$",
        },
    },
    ["continual light"] = {
        complete = {
            "^Shards of iridescent light collide to form a dazzling ball\\.\\.\\.$",
        },
    },
    ["create food"] = {
        complete = {
            "^A magic mushroom appears in your hands\\.$",
        },
    },
    ["create fire"] = {
        complete = {
            "^A small cloud of vaporous flame bursts forth before you\\.$",
        },
    },
    crusade = {
        complete = {
            "^You raise your voice to the gods for assistance and declare a holy crusade\\.$",
            "^You beseech the gods to help in your crusade but there is no answer\\.$",
        },
    },
    ["dispel magic"] = {
        complete = {
            "^You pass your hands around your body\\.\\.\\.$",
        },
    },
    acumen = {
        complete = {
            "^Knowledges long forgotten swirl in your memories\\.$",
        },
    },
    adamant = {
        complete = {
            "^Your bone condenses and solidifies while your skin grows thick and tough\\.$",
        },
    },
    adroitness = {
        complete = {
            "^Your movements become more fluid and nimble\\.$",
        },
    },
    brawn = {
        complete = {
            "^Your frame is wracked with pain as your muscles expand and ripple\\.$",
        },
    },
    sapience = {
        complete = {
            "^The virtue of wisdom expands your mind in ways previously inconceivable\\.$",
        },
    },
    rapture = {
        complete = {
            "^Minor flaws in your appearance vanish as your social grace comes to the fore\\.$",
        },
    },
    ["pass door"] = {
        complete = {
            "^You turn translucent\\.$",
        },
    },
    invis = {
        complete = {
            target("^{{target}} fades? out of existence\\.$"),
        },
    },
    refresh = {
        complete = {
            self("^Blooming vitality flows through (?<target>You)\\.$"),
            target("^You allow blooming vitality to flow from you to {{target}}\\.$"),
        },
    },
    ["antimagic shell"] = {
        complete = {
            self("^A shimmering translucent shell forms about you\\.$"),
        },
    },
    ["ethereal shield"] = {
        complete = {
            self("^You fade from the mundane energy continuum\\.$"),
        },
    },
    demonskin = {
        complete = {
            self("^Your skin becomes thick and leathery, similar to that of a demon\\.$"),
        },
    },
    dragonskin = {
        complete = {
            self("^Your flesh changes to emulate the scaly skin of a dragon\\.$"),
        },
    },
    shadowform = {
        complete = {
            self("^You dematerialize to shadow form\\.$"),
        },
    },
    ["eldritch sphere"] = {
        complete = {
            self("^A magical eldritch sphere forms about you\\.\\.\\.$"),
        },
    },
    ["true sight"] = {
        complete = {
            self("^Your vision is elevated to the highest plane\\.$"),
        },
    },
    ["voice of reason"] = {
        complete = {
            self("^You calmly reason to yourself about the benefits of reason and balance\\.$"),
        },
    },
    ["mystical vision"] = {
        complete = {
            self("^Your eyes tingle slightly as mystical visions are unleashed\\.$"),
        },
    },
    ["ethereal web"] = {
        complete = {
            self("^You weave an ethereal web about your body\\.$"),
        },
    },
    ["inner balance"] = {
        complete = {
            self("^You inhale deeply and attune yourself to the movements of the universe\\.$"),
        },
    },
    ["remove curse"] = {
        complete = {
            target("^{{target}} has no curses afflicting them\\.$"),
            target("^You dispel the curses afflicting {{target}}\\.$"),
        },
    },
    falcon = {
        complete = {
            self("^Your eyes blur as they change focus to sense hidden forms\\.$"),
        },
        retry = {
            "Your eyes blur but you can not focus on hidden forms.",
        },
    },
}
