extends RefCounted
class_name GalaxyAI

# Deterministic strategic AI: rival economies, patrols, tensions and defensive battles.
# Each empire acts on the same calendar, independent of UI or player clicks.
static func prepare(world: Dictionary) -> void:
    GalaxyIdentity.assign_rival_identities(world)
    if not world.has("ai_intentions"):
        world["ai_intentions"] = {}
    if not world.has("ai_conflicts"):
        world["ai_conflicts"] = []
    if not world.has("ai_activity"):
        world["ai_activity"] = []
    if not world.has("ai_societies"):
        world["ai_societies"] = {}
    for rival in world["ai"]:
        var key := str(rival["id"])
        if not world["ai_societies"].has(key):
            var temperament := int(rival["temperament"])
            world["ai_societies"][key] = {"population": 18 + int(rival["id"]) * 3, "prosperity": 50, "legitimacy": 62 - temperament * 4, "inequality": 25 + temperament * 7, "factions": {"reform": 20, "security": 20, "commerce": 20}, "last_crisis": -20, "migration": 0}
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
        _society_tick(world, rival, treasury, year)
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
        if year % 6 == id % 6 and treasury >= 45:
            _expand(world, rival, fleet)
        if year % 12 == id % 12 and temperament >= 2:
            _rival_tension(world, rival, fleet)
        # Player systems are attacked only during a declared war.
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
        var defending := 8 + int(world["stars"][target]["resource"]) * 2 + (6 if str(world.get("fleet_doctrine", "balanced")) == "defense" else 0)
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


# Persistent social dynamics: prosperity, legitimacy, inequality, migration and
# competing civic factions evolve from each empire's actual material conditions.
static func _society_tick(world: Dictionary, rival: Dictionary, treasury: int, year: int) -> void:
    var id := int(rival["id"])
    var key := str(id)
    var society: Dictionary = world["ai_societies"][key]
    var identity: Dictionary = GalaxyIdentity.modifiers(rival)
    var owned := 0
    var resources := 0
    for star in world["stars"]:
        if int(star["owner"]) == id:
            owned += 1
            resources += int(star["resource"])
    var population := int(society["population"])
    var prosperity := int(society["prosperity"])
    var inequality := int(society["inequality"])
    var legitimacy := int(society["legitimacy"])
    var capacity := maxi(12, owned * 28)
    var employment := mini(100, int(float(capacity) / float(maxi(1, population)) * 100.0))
    var material_change := (2 if treasury > 80 else -2 if treasury < 15 else 0) + (1 if resources >= owned * 3 else -1)
    prosperity = clampi(prosperity + material_change - (2 if employment < 75 else 0) + int(identity["capital"]), 0, 100)
    inequality = clampi(inequality + (1 if prosperity < 35 else -1 if prosperity > 70 else 0), 0, 100)
    var faction_reform := clampi(20 + inequality / 2 + (35 - prosperity) / 2, 0, 100)
    var faction_security := clampi(15 + int(rival["temperament"]) * 12 + (50 - legitimacy) / 3, 0, 100)
    var faction_commerce := clampi(20 + prosperity / 3 - inequality / 5, 0, 100)
    legitimacy = clampi(legitimacy + (1 if prosperity >= 55 else -2 if prosperity < 30 else 0) - (1 if inequality >= 60 else 0) + int(identity["legitimacy"]), 0, 100)
    var growth := maxi(0, 1 + int(identity["growth"])) if prosperity >= 40 and population < capacity else 0
    var emigration := 1 if prosperity < 25 and population > 10 else 0
    population = maxi(5, population + growth - emigration)
    society["population"] = population
    society["prosperity"] = prosperity
    society["inequality"] = inequality
    society["legitimacy"] = legitimacy
    society["migration"] = int(society["migration"]) - emigration
    society["factions"] = {"reform": faction_reform, "security": faction_security, "commerce": faction_commerce}
    # Civil unrest has material consequences; the government can recover.
    if legitimacy < 25 and year - int(society["last_crisis"]) >= 6:
        society["last_crisis"] = year
        world["ai_treasury"][key] = maxi(0, int(world["ai_treasury"].get(key, 0)) - 18)
        society["legitimacy"] = mini(100, legitimacy + 9)
        _record(world, "Regierungskrise in %s: Reformbewegungen erzwingen Zugeständnisse; der Staatshaushalt leidet." % rival["name"])
    elif emigration > 0 and year % 4 == id % 4:
        _record(world, "Auswanderungswelle aus %s: Familien verlassen wirtschaftlich geschwächte Kolonien." % rival["name"])
    elif year % 10 == id % 10:
        var leading := "Reformbewegung" if faction_reform >= faction_security and faction_reform >= faction_commerce else "Sicherheitsfraktion" if faction_security >= faction_commerce else "Handelsbund"
        _record(world, "Gesellschaft in %s: %s gewinnt Einfluss (Wohlstand %d, Legitimität %d, Bevölkerung %d)." % [rival["name"], leading, prosperity, int(society["legitimacy"]), population])


static func _expand(world: Dictionary, rival: Dictionary, fleet: Dictionary) -> void:
    var id := int(rival["id"])
    var source: Dictionary = world["stars"][int(fleet["location"])]
    var best := -1
    var distance := 160.0
    for star in world["stars"]:
        if int(star["owner"]) != -1:
            continue
        var d := GalaxySystems.distance(source, star)
        if d < distance:
            best = int(star["id"])
            distance = d
    if best < 0:
        return
    world["stars"][best]["owner"] = id
    world["ai_treasury"][str(id)] = int(world["ai_treasury"].get(str(id), 0)) - 45
    fleet["location"] = best
    _record(world, "%s besiedelt %s." % [rival["name"], world["stars"][best]["name"]])

static func _rival_tension(world: Dictionary, rival: Dictionary, fleet: Dictionary) -> void:
    var id := int(rival["id"])
    var source: Dictionary = world["stars"][int(fleet["location"])]
    var target := -1
    var closest := 135.0
    for star in world["stars"]:
        var owner := int(star["owner"])
        if owner <= 0 or owner == id:
            continue
        var d := GalaxySystems.distance(source, star)
        if d < closest:
            target = int(star["id"])
            closest = d
    if target < 0:
        return
    var defender := int(world["stars"][target]["owner"])
    var key := "%d:%d" % [mini(id, defender), maxi(id, defender)]
    if not world["ai_conflicts"].has(key):
        world["ai_conflicts"].append(key)
        _record(world, "Grenzkonflikt zwischen %s und %s um %s." % [rival["name"], GalaxySystems.empire_name(world, defender), world["stars"][target]["name"]])
    var defense := 9 + int(world["stars"][target]["resource"]) * 3
    for other in world["ai_fleets"]:
        if int(other["owner"]) == defender and int(other["location"]) == target:
            defense += int(other["strength"])
    if int(fleet["strength"]) > defense + 7:
        world["stars"][target]["owner"] = id
        fleet["strength"] = maxi(2, int(fleet["strength"]) - defense / 2)
        fleet["location"] = target
        _record(world, "%s erobert %s von %s." % [rival["name"], world["stars"][target]["name"], GalaxySystems.empire_name(world, defender)])
    else:
        fleet["strength"] = maxi(1, int(fleet["strength"]) - 2)
        _record(world, "Die Verteidigung von %s hält dem Angriff von %s stand." % [world["stars"][target]["name"], rival["name"]])

static func _record(world: Dictionary, entry: String) -> void:
    world["history"].append(entry)
    world["ai_activity"].append({"year": int(world["tick"]), "text": entry})
    if world["ai_activity"].size() > 100:
        world["ai_activity"].pop_front()
