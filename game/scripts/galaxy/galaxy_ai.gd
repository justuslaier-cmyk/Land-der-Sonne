extends RefCounted
class_name GalaxyAI

# Deterministic strategic AI: rival economies, patrols, tensions and defensive battles.
# Each empire acts on the same calendar, independent of UI or player clicks.
static func prepare(world: Dictionary) -> void:
    if not world.has("ai_intentions"):
        world["ai_intentions"] = {}
    if not world.has("ai_conflicts"):
        world["ai_conflicts"] = []
    if not world.has("ai_activity"):
        world["ai_activity"] = []
    for rival in world["ai"]:
        var key := str(rival["id"])
        if not world["ai_intentions"].has(key):
            world["ai_intentions"][key] = {"stance": "expansion", "last_action": 0}

static func tick(world: Dictionary) -> void:
    prepare(world)
    var year := int(world["tick"])
    for rival in world["ai"]:
        var id := int(rival["id"])
        var key := str(id)
        var treasury := int(world["ai_treasury"].get(key, 0))
        var temperament := int(rival["temperament"])
        var capital := int(rival["capital"])
        var fleet: Dictionary = {}
        for candidate in world["ai_fleets"]:
            if int(candidate["owner"]) == id:
                fleet = candidate
                break
        if fleet.is_empty():
            continue
        if year % 3 == id % 3 and treasury >= 28:
            var strength := 2 + temperament
            fleet["strength"] = int(fleet["strength"]) + strength
            world["ai_treasury"][key] = treasury - 28
            _record(world, "%s verstärkt seine Flotten um %d." % [rival["name"], strength])
        if year % 4 == id % 4:
            var targets: Array = []
            for star in world["stars"]:
                if int(star["owner"]) == id:
                    targets.append(int(star["id"]))
            if targets.size() > 1:
                var index := posmod(year / 4 + id, targets.size())
                fleet["location"] = targets[index]
                _record(world, "%s verlegt eine Patrouille nach %s." % [rival["name"], world["stars"][targets[index]]["name"]])
            else:
                fleet["location"] = capital
        if year % 9 == id % 9:
            var stance := "expansion"
            if temperament >= 2 and int(fleet["strength"]) >= 18:
                stance = "militarisierung"
            elif treasury >= 100:
                stance = "handel"
            world["ai_intentions"][key] = {"stance": stance, "last_action": year}
        # Hostility is restricted to empires actually at war with the player.
        if not world["wars"].has(id) or year % 4 != id % 4:
            continue
        var target := -1
        var closest := 999999.0
        var origin: Dictionary = world["stars"][int(fleet["location"])]
        for star in world["stars"]:
            if int(star["owner"]) != 0:
                continue
            var distance := GalaxySystems.distance(origin, star)
            if distance < closest and distance <= 175.0:
                closest = distance
                target = int(star["id"])
        if target < 0:
            continue
        fleet["location"] = target
        var defending := 8 + int(world["stars"][target]["resource"]) * 2
        for colony_key in world["planet_colonies"].keys():
            if str(colony_key).begins_with(str(target) + ":"):
                var colony: Dictionary = world["planet_colonies"][colony_key]
                defending += int(colony.get("buildings", {}).get("fort", 0)) * 8
        var power := int(fleet["strength"])
        if power > defending + 5:
            world["stars"][target]["owner"] = id
            fleet["strength"] = maxi(2, power - defending / 2)
            world["stability"] = maxi(0, int(world["stability"]) - 5)
            _record(world, "%s erobert %s nach einem Flottenangriff." % [rival["name"], world["stars"][target]["name"]])
        else:
            fleet["strength"] = maxi(1, power - 4)
            _record(world, "%s greift %s an; die Verteidigung hält." % [rival["name"], world["stars"][target]["name"]])

static func _record(world: Dictionary, entry: String) -> void:
    world["history"].append(entry)
    world["ai_activity"].append({"year": int(world["tick"]), "text": entry})
    if world["ai_activity"].size() > 100:
        world["ai_activity"].pop_front()
