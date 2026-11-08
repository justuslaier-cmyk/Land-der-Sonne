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

static func distance(a: Dictionary, b: Dictionary) -> float:
    return Vector2(float(a["x"]), float(a["y"])).distance_to(Vector2(float(b["x"]), float(b["y"])))

static func explore(world: Dictionary, target: int) -> bool:
    prepare(world)
    if target < 0 or target >= world["stars"].size():
        return false
    if world["known"].has(target):
        return false
    var origin: Dictionary = world["stars"][0]
    var star: Dictionary = world["stars"][target]
    if distance(origin, star) > 270.0:
        return false
    world["known"].append(target)
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
        if int(world["tick"]) % 6 == id % 6 and int(world["ai_treasury"][key]) >= 45:
            var capital: Dictionary = world["stars"][int(rival["capital"])]
            var candidate := -1
            var closest := 999999.0
            for star in world["stars"]:
                if int(star["owner"]) != -1 or not bool(star["habitable"]):
                    continue
                var d := distance(capital, star)
                if d < closest and d < 150.0:
                    closest = d
                    candidate = int(star["id"])
            if candidate >= 0:
                world["stars"][candidate]["owner"] = id
                world["ai_treasury"][key] = int(world["ai_treasury"][key]) - 45
                world["history"].append("%s gründet eine Kolonie auf %s." % [rival["name"], world["stars"][candidate]["name"]])
    # Periodic events are tied to actual simulated conditions and a deterministic cadence.
    if str(world["pending_event"]) == "" and int(world["tick"]) > 3 and int(world["tick"]) % 7 == 0:
        if colonies >= 2:
            world["pending_event"] = "colonies"
        elif int(world["credits"]) >= 130:
            world["pending_event"] = "market"
        else:
            world["pending_event"] = "signal"

static func resolve_event(world: Dictionary, option: int) -> void:
    prepare(world)
    var kind := str(world["pending_event"])
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
