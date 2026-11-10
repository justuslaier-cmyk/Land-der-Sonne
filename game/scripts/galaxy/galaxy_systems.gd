extends RefCounted
class_name GalaxySystems

# Version-1 extensions are optional, preserving existing save games.
static func prepare(world: Dictionary) -> void:
    if not world.has("fleets"):
        world["fleets"] = [{"owner": 0, "location": 0, "strength": 12, "destination": -1, "eta": 0}]
    if not world.has("relations"):
        var relations: Dictionary = {}
        for rival in world["ai"]:
            relations[str(rival["id"])] = 0
        world["relations"] = relations
    if not world.has("contacts"):
        world["contacts"] = []
    if not world.has("known"):
        world["known"] = [0]
    if not world.has("research_level"):
        world["research_level"] = 0
    if not world.has("pending_event"):
        world["pending_event"] = ""
    if not world.has("event_counter"):
        world["event_counter"] = 0
    if not world.has("ai_treasury"):
        world["ai_treasury"] = {}
    if not world.has("industry"):
        world["industry"] = 0
    if not world.has("ambient_event_log"):
        world["ambient_event_log"] = []
    GalaxyLore.prepare(world)

static func distance(a: Dictionary, b: Dictionary) -> float:
    return Vector2(float(a["x"]), float(a["y"])).distance_to(Vector2(float(b["x"]), float(b["y"])))

static func explore(world: Dictionary, target: int) -> bool:
    prepare(world)
    if target < 0 or target >= world["stars"].size():
        return false
    if world["known"].has(target):
        return false
    var star: Dictionary = world["stars"][target]
    var reachable := false
    for fleet in world["fleets"]:
        if int(fleet["owner"]) != 0 or int(fleet["destination"]) >= 0:
            continue
        var origin: Dictionary = world["stars"][int(fleet["location"])]
        if distance(origin, star) <= 170.0:
            reachable = true
    if not reachable:
        return false
    world["known"].append(target)
    GalaxyLore.inspect(world, target)
    world["science"] = int(world["science"]) + 4
    world["history"].append("Sternensystem %s kartografiert." % star["name"])
    if int(star["owner"]) > 0 and not world["contacts"].has(int(star["owner"])):
        world["contacts"].append(int(star["owner"]))
        world["history"].append("Erstkontakt mit %s." % empire_name(world, int(star["owner"])))
    return true

static func empire_name(world: Dictionary, empire_id: int) -> String:
    if empire_id == 0:
        return str(world["empire"]["name"])
    for rival in world["ai"]:
        if int(rival["id"]) == empire_id:
            return str(rival["name"])
    return "Unbekannt"

static func diplomatic_action(world: Dictionary, rival_id: int, action: String) -> String:
    prepare(world)
    if not world["contacts"].has(rival_id):
        return "Noch kein Erstkontakt."
    var key := str(rival_id)
    var relation := int(world["relations"].get(key, 0))
    if action == "gift":
        if int(world["credits"]) < 30:
            return "Nicht genügend Credits."
        world["credits"] = int(world["credits"]) - 30
        world["relations"][key] = mini(100, relation + 18)
        world["history"].append("Diplomatisches Geschenk an %s." % empire_name(world, rival_id))
        return "Beziehungen verbessert."
    if action == "threat":
        world["relations"][key] = maxi(-100, relation - 22)
        world["history"].append("Ultimatum an %s." % empire_name(world, rival_id))
        return "Beziehungen verschlechtert."
    if action == "trade":
        if relation < 15:
            return "Handelsvertrag benötigt Beziehungen von mindestens +15."
        world["relations"][key] = mini(100, relation + 4)
        world["credits"] = int(world["credits"]) + 25
        world["history"].append("Handelsabkommen mit %s abgeschlossen." % empire_name(world, rival_id))
        return "Handelsabkommen: +25 Credits."
    return "Unbekannte diplomatische Aktion."

static func move_fleet(world: Dictionary, target: int) -> bool:
    prepare(world)
    if target < 0 or target >= world["stars"].size() or not world["known"].has(target):
        return false
    var fleet: Dictionary = world["fleets"][0]
    if int(fleet["destination"]) >= 0 or int(fleet["location"]) == target:
        return false
    var origin: Dictionary = world["stars"][int(fleet["location"])]
    var destination: Dictionary = world["stars"][target]
    var travel := distance(origin, destination)
    if travel > 220.0:
        return false
    fleet["destination"] = target
    fleet["eta"] = maxi(1, ceili(travel / 70.0))
    world["history"].append("Expedition nach %s gestartet (%d Jahre)." % [destination["name"], fleet["eta"]])
    return true

static func build_fleet(world: Dictionary) -> bool:
    prepare(world)
    if int(world["credits"]) < 65:
        return false
    world["credits"] = int(world["credits"]) - 65
    world["fleets"][0]["strength"] = int(world["fleets"][0]["strength"]) + 5
    world["history"].append("Fünf Flottenstärkepunkte gebaut.")
    return true

static func start_research(world: Dictionary) -> bool:
    prepare(world)
    var cost := 25 + int(world["research_level"]) * 15
    if int(world["science"]) < cost:
        return false
    world["science"] = int(world["science"]) - cost
    world["research_level"] = int(world["research_level"]) + 1
    world["history"].append("Forschung abgeschlossen: Stufe %d." % int(world["research_level"]))
    return true

static func tick(world: Dictionary) -> void:
    prepare(world)
    GalaxyModel.advance(world)
    GalaxyLore.tick(world)
    _ambient_event(world)
    for fleet in world["fleets"]:
        if int(fleet["destination"]) >= 0:
            fleet["eta"] = int(fleet["eta"]) - 1
            if int(fleet["eta"]) <= 0:
                fleet["location"] = int(fleet["destination"])
                fleet["destination"] = -1
                fleet["eta"] = 0
                world["history"].append("Flotte erreicht %s." % world["stars"][int(fleet["location"])]["name"])
    var colonies := 0
    var production := 0
    for star in world["stars"]:
        if int(star["owner"]) == 0:
            colonies += 1
            production += int(star["resource"])
    world["credits"] = int(world["credits"]) + colonies * 2 + production / 3
    world["industry"] = int(world["industry"]) + production
    # Deterministic AI economic simulation, independent of the player's decisions.
    for rival in world["ai"]:
        var id := int(rival["id"])
        var key := str(id)
        var owned := 0
        for star in world["stars"]:
            if int(star["owner"]) == id:
                owned += 1
        world["ai_treasury"][key] = int(world["ai_treasury"].get(key, 50)) + owned * 4
    # Rival expansion is handled by GalaxyAI to avoid duplicate claims and costs.
    # Periodic events are tied to actual simulated conditions and a deterministic cadence.
    if str(world["pending_event"]) == "" and int(world["tick"]) > 3 and int(world["tick"]) % 7 == 0:
        if colonies >= 2:
            world["pending_event"] = "colonies"
        elif int(world["credits"]) >= 130:
            world["pending_event"] = "market"
        else:
            world["pending_event"] = "signal"

# Small incidents are automatic; only consequential stories interrupt the player.
static func _ambient_event(world: Dictionary) -> void:
    var year := int(world["tick"])
    var frequency := int(world["settings"].get("events", 50))
    if frequency <= 0 or year == 0:
        return
    var rng := RandomNumberGenerator.new()
    rng.seed = int(world["settings"]["seed"]) * 151 + year * 10007
    if rng.randi_range(1, 100) > clampi(frequency / 4, 1, 25):
        return
    var incidents := [
        ["Ein ungewöhnlicher Meteorschauer liefert seltene Mineralien.", "alloys", 4],
        ["Ein stiller Sonnensturm beschädigt Handelsrelais.", "credits", -7],
        ["Forschende registrieren einen rätselhaften Gravitationsimpuls.", "science", 6],
        ["Eine kurze Kommunikationsstörung verunsichert die Kolonien.", "stability", -2],
        ["Ein neuer Handelsweg belebt die Randsektoren.", "credits", 9],
        ["Die Messung einer fremden Radiowelle liefert neue Erkenntnisse.", "science", 4]
    ]
    var incident: Array = incidents[rng.randi_range(0, incidents.size() - 1)]
    var field: String = incident[1]
    world[field] = maxi(0, int(world.get(field, 0)) + int(incident[2]))
    world["history"].append(str(incident[0]))
    world["ambient_event_log"].append({"year": year, "text": incident[0], "effect": incident[2], "resource": field})

static func resolve_event(world: Dictionary, option: int) -> void:
    prepare(world)
    var kind := str(world["pending_event"])
    if kind in ["ancient_signal", "ancient_echo"]:
        GalaxyLore.resolve(world, kind, option)
        world["event_counter"] = int(world["event_counter"]) + 1
        return
    if kind == "colonies":
        if option == 0:
            world["credits"] = int(world["credits"]) - 20
            world["science"] = int(world["science"]) + 35
            world["history"].append("Kolonialrat: Forschungsvorhaben finanziert.")
        else:
            world["credits"] = int(world["credits"]) + 30
            world["history"].append("Kolonialrat: Exportförderung beschlossen.")
    elif kind == "market":
        if option == 0:
            world["credits"] = int(world["credits"]) - 40
            world["science"] = int(world["science"]) + 45
            world["history"].append("Marktkrise: Technologiefonds gegründet.")
        else:
            world["credits"] = int(world["credits"]) + 20
            world["history"].append("Marktkrise: Staatsreserven verkauft.")
    else:
        if option == 0:
            world["science"] = int(world["science"]) + 20
            world["history"].append("Unbekanntes Signal wissenschaftlich analysiert.")
        else:
            world["credits"] = int(world["credits"]) + 30
            world["history"].append("Unbekanntes Signal kommerziell verwertet.")
    world["event_counter"] = int(world["event_counter"]) + 1
    world["pending_event"] = ""
