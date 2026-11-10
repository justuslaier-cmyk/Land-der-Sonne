extends RefCounted
class_name GalaxyStrategy

# Pure, deterministic strategic rules. Existing saves are upgraded lazily.
static func prepare(world: Dictionary) -> void:
    GalaxySystems.prepare(world)
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
    if not world["contacts"].has(rival_id) or world["wars"].has(rival_id):
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

static func tick(world: Dictionary) -> void:
    prepare(world)
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
    var focus := int(world["policies"]["focus"])
    var tax := int(world["policies"]["tax"])
    world["credits"] = int(world["credits"]) + credits_bonus + (tax - 1) * 5 + world["trade_pacts"].size() * 6
    world["science"] = int(world["science"]) + science_bonus + (4 if focus == 1 else 0)
    world["alloys"] = int(world["alloys"]) + 2 + alloy_bonus + (3 if focus == 2 else 0)
    world["stability"] = clampi(int(world["stability"]) + (1 if tax == 0 else -1 if tax == 2 else 0), 0, 100)
    if focus == 0:
        world["credits"] = int(world["credits"]) + 4
    if int(world["stability"]) < 25:
        world["credits"] = maxi(0, int(world["credits"]) - 5)
    # AI colonies and their strategic presence are already updated by GalaxySystems.tick.
    # Wars only resolve on player-ordered attacks; no arbitrary automatic conquest.
