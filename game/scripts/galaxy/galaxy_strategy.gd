extends RefCounted
class_name GalaxyStrategy

# Pure, deterministic strategic rules. Existing saves are upgraded lazily.
static func prepare(world: Dictionary) -> void:
    GalaxySystems.prepare(world)
    if not world.has("planet_colonies"):
        world["planet_colonies"] = {}
    if not world.has("buildings"):
        world["buildings"] = {}
    if not world.has("wars"):
        world["wars"] = []
    if not world.has("trade_pacts"):
        world["trade_pacts"] = []
    if not world.has("policies"):
        world["policies"] = {"focus": 0, "tax": 1}
    if not world.has("stability"):
        world["stability"] = 70
    if not world.has("alloys"):
        world["alloys"] = 30
    if not world.has("ship_design"):
        world["ship_design"] = {"hull": 0, "weapon": 0, "engine": 0}
    if not world.has("ai_fleets"):
        var fleets: Array = []
        for rival in world["ai"]:
            fleets.append({"owner": int(rival["id"]), "location": int(rival["capital"]), "strength": 10 + int(rival["temperament"]) * 3})
        world["ai_fleets"] = fleets

# Colonies are keyed by system and orbital index. Old system-wide buildings remain
# supported for backwards-compatible saves, but new construction is planet-specific.
static func planet_key(star_id: int, planet_index: int) -> String:
    return "%d:%d" % [star_id, planet_index]

static func planet_colony(world: Dictionary, star_id: int, planet_index: int) -> Dictionary:
    prepare(world)
    return world["planet_colonies"].get(planet_key(star_id, planet_index), {})

static func settle_planet(world: Dictionary, star_id: int, planet_index: int) -> bool:
    prepare(world)
    if star_id < 0 or star_id >= world["stars"].size():
        return false
    var star: Dictionary = world["stars"][star_id]
    if int(star["owner"]) != 0:
        return false
    var system := GalaxyCelestials.generate(int(world["settings"]["seed"]), star)
    if planet_index < 0 or planet_index >= system["planets"].size():
        return false
    var planet: Dictionary = system["planets"][planet_index]
    if not bool(planet["habitable"]):
        return false
    var key := planet_key(star_id, planet_index)
    if world["planet_colonies"].has(key) or int(world["credits"]) < 50:
        return false
    world["credits"] = int(world["credits"]) - 50
    world["planet_colonies"][key] = {"population": 1, "buildings": {}}
    world["history"].append("Kolonie auf %s gegründet." % str(planet["name"]))
    return true

static func construct_planet(world: Dictionary, star_id: int, planet_index: int, kind: String) -> bool:
    prepare(world)
    if not ["mine", "lab", "factory", "fort"].has(kind):
        return false
    if star_id < 0 or star_id >= world["stars"].size() or int(world["stars"][star_id]["owner"]) != 0:
        return false
    var key := planet_key(star_id, planet_index)
    if not world["planet_colonies"].has(key):
        return false
    var colony: Dictionary = world["planet_colonies"][key]
    var built: Dictionary = colony.get("buildings", {})
    if int(built.get(kind, 0)) >= 3 or int(world["credits"]) < building_cost(kind):
        return false
    world["credits"] = int(world["credits"]) - building_cost(kind)
    built[kind] = int(built.get(kind, 0)) + 1
    colony["buildings"] = built
    world["planet_colonies"][key] = colony
    world["history"].append("%s auf Planet %d in %s errichtet." % [kind, planet_index + 1, world["stars"][star_id]["name"]])
    return true

static func building_cost(kind: String) -> int:
    match kind:
        "mine": return 45
        "lab": return 60
        "factory": return 55
        "fort": return 70
    return 999999

static func construct(world: Dictionary, star_id: int, kind: String) -> bool:
    prepare(world)
    if star_id < 0 or star_id >= world["stars"].size() or int(world["stars"][star_id]["owner"]) != 0:
        return false
    if not ["mine", "lab", "factory", "fort"].has(kind):
        return false
    var cost := building_cost(kind)
    if int(world["credits"]) < cost:
        return false
    var key := str(star_id)
    var entries: Dictionary = world["buildings"].get(key, {})
    if int(entries.get(kind, 0)) >= 3:
        return false
    world["credits"] = int(world["credits"]) - cost
    entries[kind] = int(entries.get(kind, 0)) + 1
    world["buildings"][key] = entries
    world["history"].append("%s auf %s errichtet (Stufe %d)." % [kind, world["stars"][star_id]["name"], int(entries[kind])])
    return true

static func set_policy(world: Dictionary, focus: int, tax: int) -> bool:
    prepare(world)
    if focus < 0 or focus > 2 or tax < 0 or tax > 2:
        return false
    world["policies"] = {"focus": focus, "tax": tax}
    world["history"].append("Reichspolitik geändert: Schwerpunkt %d, Steuern %d." % [focus, tax])
    return true

static func configure_ship(world: Dictionary, hull: int, weapon: int, engine: int) -> bool:
    prepare(world)
    if hull < 0 or hull > 2 or weapon < 0 or weapon > 2 or engine < 0 or engine > 2:
        return false
    world["ship_design"] = {"hull": hull, "weapon": weapon, "engine": engine}
    world["history"].append("Neue Schiffsklasse entworfen.")
    return true

static func ship_strength(world: Dictionary) -> int:
    prepare(world)
    var design: Dictionary = world["ship_design"]
    return 3 + int(design["hull"]) * 2 + int(design["weapon"]) * 3 + int(world["research_level"]) / 2

static func build_ships(world: Dictionary) -> bool:
    prepare(world)
    var alloy_cost := 12 + int(world["ship_design"]["hull"]) * 5
    var credit_cost := 30 + int(world["ship_design"]["weapon"]) * 10
    if int(world["credits"]) < credit_cost or int(world["alloys"]) < alloy_cost:
        return false
    world["credits"] = int(world["credits"]) - credit_cost
    world["alloys"] = int(world["alloys"]) - alloy_cost
    world["fleets"][0]["strength"] = int(world["fleets"][0]["strength"]) + ship_strength(world)
    world["history"].append("Kriegsschiffe fertiggestellt: +%d Flottenstärke." % ship_strength(world))
    return true

static func declare_war(world: Dictionary, rival_id: int) -> bool:
    prepare(world)
    if not world["contacts"].has(rival_id) or world["wars"].has(rival_id) or world.get("non_aggression", []).has(rival_id) or int(world.get("truce_until", {}).get(str(rival_id), 0)) > int(world["tick"]):
        return false
    world["wars"].append(rival_id)
    world["relations"][str(rival_id)] = -100
    world["history"].append("Krieg gegen %s erklärt." % GalaxySystems.empire_name(world, rival_id))
    return true

static func sign_trade(world: Dictionary, rival_id: int) -> bool:
    prepare(world)
    if not world["contacts"].has(rival_id) or world["wars"].has(rival_id) or world["trade_pacts"].has(rival_id):
        return false
    if int(world["relations"].get(str(rival_id), 0)) < 15:
        return false
    world["trade_pacts"].append(rival_id)
    world["history"].append("Dauerhafter Handelsvertrag mit %s geschlossen." % GalaxySystems.empire_name(world, rival_id))
    return true

static func offer_peace(world: Dictionary, rival_id: int) -> bool:
    prepare(world)
    if not world["wars"].has(rival_id):
        return false
    var relation := int(world["relations"].get(str(rival_id), -100))
    var treasury := int(world["credits"])
    if relation < -80 and treasury < 70:
        return false
    if relation < -80:
        world["credits"] = treasury - 70
    world["wars"].erase(rival_id)
    world["relations"][str(rival_id)] = -25
    if not world.has("truce_until"):
        world["truce_until"] = {}
    world["truce_until"][str(rival_id)] = int(world["tick"]) + 5
    world["history"].append("Friedensvertrag mit %s geschlossen." % GalaxySystems.empire_name(world, rival_id))
    return true

static func propose_non_aggression(world: Dictionary, rival_id: int) -> bool:
    prepare(world)
    if not world["contacts"].has(rival_id) or world["wars"].has(rival_id):
        return false
    if int(world["relations"].get(str(rival_id), 0)) < 35:
        return false
    if not world.has("non_aggression"):
        world["non_aggression"] = []
    if world["non_aggression"].has(rival_id):
        return false
    world["non_aggression"].append(rival_id)
    world["history"].append("Nichtangriffspakt mit %s vereinbart." % GalaxySystems.empire_name(world, rival_id))
    return true

static func attack(world: Dictionary, star_id: int) -> String:
    prepare(world)
    if star_id < 0 or star_id >= world["stars"].size():
        return "Ungültiges Ziel."
    var star: Dictionary = world["stars"][star_id]
    var defender := int(star["owner"])
    if defender <= 0 or not world["wars"].has(defender):
        return "Kein Kriegszustand mit dem Besitzer."
    var fleet: Dictionary = world["fleets"][0]
    if int(fleet["location"]) != star_id or int(fleet["destination"]) >= 0:
        return "Flotte muss sich im Zielsystem befinden."
    var defense := 8 + int(star["resource"]) * 2 + int(world["tick"]) / 8
    for rival_fleet in world["ai_fleets"]:
        if int(rival_fleet["owner"]) == defender and int(rival_fleet["location"]) == star_id:
            defense += int(rival_fleet["strength"])
    var power := int(fleet["strength"])
    if power > defense:
        star["owner"] = 0
        fleet["strength"] = maxi(1, power - maxi(3, defense / 2))
        world["stability"] = maxi(0, int(world["stability"]) - 3)
        world["history"].append("%s im Krieg erobert. Flottenstärke: %d." % [star["name"], int(fleet["strength"])])
        return "Sieg! System erobert."
    fleet["strength"] = maxi(0, power - maxi(3, defense / 2))
    world["history"].append("Angriff auf %s gescheitert." % star["name"])
    return "Niederlage! Flotte beschädigt."

# Transparent projection of player-controlled recurring income. Excludes
# unpredictable events, rival actions and one-off expenditure.
static func income_forecast(world: Dictionary) -> Dictionary:
    prepare(world)
    var credits := 3 + (2 if int(world["empire"]["trait"]) == 1 else 0)
    var science := 2 + (2 if int(world["empire"]["trait"]) == 0 else 0)
    var alloys := 2
    var owned := 0
    var production := 0
    for star in world["stars"]:
        if int(star["owner"]) == 0:
            owned += 1
            production += int(star["resource"])
    credits += owned * 2 + int(production / 3)
    for key in world["buildings"].keys():
        var sid := int(key)
        if sid < 0 or sid >= world["stars"].size() or int(world["stars"][sid]["owner"]) != 0:
            continue
        var built: Dictionary = world["buildings"][key]
        credits += int(built.get("mine", 0)) * (2 + int(world["stars"][sid]["resource"]))
        science += int(built.get("lab", 0)) * 4
        alloys += int(built.get("factory", 0)) * 3
    for key in world["planet_colonies"].keys():
        var parts := str(key).split(":")
        if parts.size() != 2:
            continue
        var sid := int(parts[0])
        var pid := int(parts[1])
        if sid < 0 or sid >= world["stars"].size() or int(world["stars"][sid]["owner"]) != 0:
            continue
        var planets: Array = GalaxyCelestials.generate(int(world["settings"]["seed"]), world["stars"][sid])["planets"]
        if pid < 0 or pid >= planets.size():
            continue
        var built: Dictionary = world["planet_colonies"][key].get("buildings", {})
        credits += int(built.get("mine", 0)) * (2 + int(planets[pid]["resources"]))
        science += int(built.get("lab", 0)) * 4
        alloys += int(built.get("factory", 0)) * 3
    var focus := int(world["policies"]["focus"])
    var tax := int(world["policies"]["tax"])
    credits += (tax - 1) * 5 + world["trade_pacts"].size() * 6 + (4 if focus == 0 else 0) + GalaxyLore.artifact_bonus(world, "credits")
    science += (4 if focus == 1 else 0) + GalaxyLore.artifact_bonus(world, "science")
    alloys += (3 if focus == 2 else 0) + GalaxyLore.artifact_bonus(world, "alloys")
    var next_stability := clampi(int(world["stability"]) + (1 if tax == 0 else -1 if tax == 2 else 0), 0, 100)
    if next_stability < 25:
        credits -= 5
    return {"credits": credits, "science": science, "alloys": alloys}

static func tick(world: Dictionary) -> void:
    prepare(world)
    var opening := {"credits": int(world["credits"]), "science": int(world["science"]), "alloys": int(world["alloys"]), "stability": int(world["stability"])}
    GalaxySystems.tick(world)
    var science_bonus := 0
    var alloy_bonus := 0
    var credits_bonus := 0
    for key in world["buildings"].keys():
        var star_id := int(key)
        if star_id < 0 or star_id >= world["stars"].size() or int(world["stars"][star_id]["owner"]) != 0:
            continue
        var entry: Dictionary = world["buildings"][key]
        credits_bonus += int(entry.get("mine", 0)) * (2 + int(world["stars"][star_id]["resource"]))
        science_bonus += int(entry.get("lab", 0)) * 4
        alloy_bonus += int(entry.get("factory", 0)) * 3
    for key in world["planet_colonies"].keys():
        var parts := str(key).split(":")
        if parts.size() != 2:
            continue
        var sid := int(parts[0])
        if sid < 0 or sid >= world["stars"].size() or int(world["stars"][sid]["owner"]) != 0:
            continue
        var colony: Dictionary = world["planet_colonies"][key]
        var built: Dictionary = colony.get("buildings", {})
        var planets: Array = GalaxyCelestials.generate(int(world["settings"]["seed"]), world["stars"][sid])["planets"]
        var pid := int(parts[1])
        if pid < 0 or pid >= planets.size():
            continue
        var resources := int(planets[pid]["resources"])
        credits_bonus += int(built.get("mine", 0)) * (2 + resources)
        science_bonus += int(built.get("lab", 0)) * 4
        alloy_bonus += int(built.get("factory", 0)) * 3
    var focus := int(world["policies"]["focus"])
    var tax := int(world["policies"]["tax"])
    world["credits"] = int(world["credits"]) + credits_bonus + (tax - 1) * 5 + world["trade_pacts"].size() * 6 + GalaxyLore.artifact_bonus(world, "credits")
    world["science"] = int(world["science"]) + science_bonus + (4 if focus == 1 else 0) + GalaxyLore.artifact_bonus(world, "science")
    world["alloys"] = int(world["alloys"]) + 2 + alloy_bonus + (3 if focus == 2 else 0) + GalaxyLore.artifact_bonus(world, "alloys")
    world["stability"] = clampi(int(world["stability"]) + (1 if tax == 0 else -1 if tax == 2 else 0), 0, 100)
    if focus == 0:
        world["credits"] = int(world["credits"]) + 4
    if int(world["stability"]) < 25:
        world["credits"] = maxi(0, int(world["credits"]) - 5)
        if int(world["tick"]) % 5 == 0 and str(world["pending_event"]) == "":
            world["pending_event"] = "political_crisis"
            world["history"].append("Politische Krise: Proteste und Unruhen erschüttern die Kolonien.")
    # Autonomous rival behavior advances with the same simulation clock.
    GalaxyAI.tick(world)
    # Bounded economic history, persisted in ordinary saves.
    if not world.has("economy_history"):
        world["economy_history"] = []
    var changes := {}
    for field in ["credits", "science", "alloys", "stability"]:
        changes[field] = int(world[field]) - int(opening[field])
    world["economy_history"].append({"year": int(world["tick"]) + 2200, "delta": changes, "balance": {"credits": int(world["credits"]), "science": int(world["science"]), "alloys": int(world["alloys"]), "stability": int(world["stability"])}})
    if world["economy_history"].size() > 60:
        world["economy_history"].pop_front()
