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
    if not world.has("ai_military_assessments"):
        world["ai_military_assessments"] = {}
    if not world.has("ai_fleet_logistics"):
        world["ai_fleet_logistics"] = {}
    if not world.has("ai_war_exhaustion"):
        world["ai_war_exhaustion"] = {}
    if not world.has("ai_societies"):
        world["ai_societies"] = {}
    if not world.has("ai_science"):
        world["ai_science"] = {}
    if not world.has("ai_research_fields"):
        world["ai_research_fields"] = {}
    for rival in world["ai"]:
        var key := str(rival["id"])
        if not world["ai_science"].has(key):
            world["ai_science"][key] = 0
        if not world["ai_research_fields"].has(key):
            world["ai_research_fields"][key] = {"propulsion": 0, "industry": 0, "society": 0}
        if not world.has("ai_cultures"):
            world["ai_cultures"] = {}
        if not world["ai_cultures"].has(key):
            world["ai_cultures"][key] = GalaxyIdentity.culture_defaults(rival)
        if not world["ai_societies"].has(key):
            var temperament := int(rival["temperament"])
            world["ai_societies"][key] = {"population": 18 + int(rival["id"]) * 3, "prosperity": 50, "legitimacy": 62 - temperament * 4, "inequality": 25 + temperament * 7, "factions": {"reform": 20, "security": 20, "commerce": 20}, "last_crisis": -20, "migration": 0}
        if not world["ai_intentions"].has(key):
            world["ai_intentions"][key] = {"stance": "expansion", "last_action": 0}

# Difficulty changes decision cadence, never grants free resources, technology or combat power.
# 0: relaxed, 1: established baseline, 2: aggressive resource-constrained rival.
static func action_interval(difficulty: int, action: String) -> int:
    var level := clampi(difficulty, 0, 2)
    if action == "expansion":
        return [9, 6, 4][level]
    if action == "recruitment":
        return [5, 3, 4][level]
    return 1

static func tick(world: Dictionary) -> void:
    prepare(world)
    var year := int(world["tick"])
    var difficulty := clampi(int(world.get("settings", {}).get("difficulty", 1)), 0, 2)
    var expansion_interval := action_interval(difficulty, "expansion")
    var recruitment_interval := action_interval(difficulty, "recruitment")
    # One ownership scan per year rather than one full-galaxy scan per rival.
    var ownership: Dictionary = GalaxyAISpatialIndex.build(world)
    for rival in world["ai"]:
        var id := int(rival["id"])
        var key := str(id)
        var treasury := int(world["ai_treasury"].get(key, 0))
        var temperament := int(rival["temperament"])
        var capital := int(rival["capital"])
        # The AI buys research from its own accumulated science, never free unlocks.
        # The same first-tier 25-point cost applies to player research.
        var fields: Dictionary = world["ai_research_fields"][key]
        if year % 5 == id % 5 and int(world["ai_science"][key]) >= 25:
            var priorities := ["propulsion", "industry", "society"] if temperament == 0 else ["industry", "society", "propulsion"] if temperament == 1 else ["society", "propulsion", "industry"]
            for field in priorities:
                if int(fields.get(field, 0)) > 0:
                    continue
                world["ai_science"][key] = int(world["ai_science"][key]) - 25
                fields[field] = 1
                _record(world, "%s finanziert Forschung: %s." % [str(rival["name"]), field])
                break
        _society_tick(world, rival, treasury, year, ownership)
        var fleet: Dictionary = {}
        for candidate in world["ai_fleets"]:
            if int(candidate["owner"]) == id:
                fleet = candidate
                break
        if fleet.is_empty():
            continue
        # F3: rival fleets pay real upkeep from their own treasury and
        # consume supplies outside owned territory. Friendly ports replenish.
        if not world["ai_fleet_logistics"].has(key):
            world["ai_fleet_logistics"][key] = {"supply": 100, "maintenance_paid": 0, "attrition": 0}
        var logistics: Dictionary = world["ai_fleet_logistics"][key]
        var upkeep := maxi(1, ceili(float(maxi(1, int(fleet["strength"]))) / 20.0))
        var paid := mini(upkeep, maxi(0, int(world["ai_treasury"].get(key, 0))))
        world["ai_treasury"][key] = int(world["ai_treasury"].get(key, 0)) - paid
        logistics["maintenance_paid"] = int(logistics.get("maintenance_paid", 0)) + paid
        var fleet_location := int(fleet["location"])
        var friendly_port: bool = fleet_location >= 0 and fleet_location < world["stars"].size() and int(world["stars"][fleet_location]["owner"]) == id
        var supply := clampi(int(logistics.get("supply", 100)), 0, 100)
        supply = mini(100, supply + 8) if friendly_port and paid == upkeep else maxi(0, supply - (9 if not friendly_port else 4))
        logistics["supply"] = supply
        if supply == 0 and int(fleet["strength"]) > 1:
            fleet["strength"] = int(fleet["strength"]) - 1
            logistics["attrition"] = int(logistics.get("attrition", 0)) + 1
        var exhaustion := clampi(int(world["ai_war_exhaustion"].get(key, 0)) + (3 if world["wars"].has(id) else -4), 0, 100)
        world["ai_war_exhaustion"][key] = exhaustion
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
            var plan: Dictionary = GalaxyAIPlanner.evaluate(world, rival, fleet)
            world["ai_intentions"][key] = {"stance": str(plan["stance"]), "last_action": year, "scores": plan["scores"], "reasons": plan["reasons"]}
            # A compact, bounded decision trace for replay/debugging and future UI.
            var decisions: Array = world.get("ai_decision_log", [])
            decisions.append({"year": year, "empire_id": id, "stance": str(plan["stance"]), "scores": plan["scores"].duplicate(true), "reasons": plan["reasons"].duplicate(true)})
            if decisions.size() > 240:
                decisions.pop_front()
            world["ai_decision_log"] = decisions
        # Expansion is a strategic investment. Pay for it before optional fleet
        # reinforcement; otherwise 28-credit recruitment consumes every
        # 45-credit colonisation reserve in the same turn.
        treasury = int(world["ai_treasury"].get(key, 0))
        if year % expansion_interval == id % expansion_interval and treasury >= 50 and str(world["ai_intentions"][key]["stance"]) != "reformen":
            _expand(world, rival, fleet)
        # Each action reads the live treasury after the previous transaction.
        treasury = int(world["ai_treasury"].get(key, 0))
        # Preserve the next affordable 50-credit colony instead of spending
        # its reserve on 28-credit recruitment between expansion turns.
        var has_nearby_colony := false
        # Higher difficulties reserve more earned treasury for accelerated
        # expansion; no free resources, strength or technology are granted.
        var reserve_limit := [78, 120, 160][difficulty]
        if treasury >= 49 and treasury < reserve_limit:
            var origin: Dictionary = world["stars"][int(fleet["location"])]
            for candidate in world["stars"]:
                if int(candidate["owner"]) == -1 and bool(candidate["habitable"]) and GalaxySystems.distance(origin, candidate) < 160.0:
                    has_nearby_colony = true
                    break
        if year % recruitment_interval == id % recruitment_interval and treasury >= 28 and not has_nearby_colony:
            var strength := 2 + temperament
            fleet["strength"] = int(fleet["strength"]) + strength
            world["ai_treasury"][key] = treasury - 28
            _record(world, "%s verstärkt seine Flotten um %d." % [rival["name"], strength])
        if year % 12 == id % 12 and temperament >= 2 and str(world["ai_intentions"][key]["stance"]) == "militarisierung":
            _rival_tension(world, rival, fleet)
        # Explainable military intent: only observed owned systems are considered.
        # No omniscient player fleet or hidden stockpile values are read.
        world["ai_military_assessments"][key] = {"year": year, "at_war": world["wars"].has(id),
            "fleet_strength": int(fleet["strength"]), "stance": str(world["ai_intentions"][key]["stance"]),
            "reason": "Krieg: Grenzsysteme prüfen" if world["wars"].has(id) else "Frieden: keine Angriffe"}
        # F2: bounded defensive response; explicit AI command remains traceable.
        var assessment: Dictionary = world["ai_military_assessments"][key]
        assessment["doctrine"] = "defend" if int(fleet["strength"]) < 12 else "patrol"
        assessment["supply_estimate"] = int(logistics["supply"])
        assessment["upkeep_paid"] = paid
        assessment["war_exhaustion"] = exhaustion
        assessment["reason"] = "Nachschub kritisch: Rückzug erforderlich" if supply < 20 else str(assessment["reason"])
        # Player systems are attacked only during a declared war.
        if not world["wars"].has(id) or year % 4 != id % 4 or supply < 20 or exhaustion >= 85:
            continue
        var target := -1
        var closest := 999999.0
        var origin: Dictionary = world["stars"][int(fleet["location"])]
        for star in world["stars"]:
            if int(star["owner"]) != 0:
                continue
            var distance := GalaxySystems.distance(origin, star)
            if distance < closest and distance <= 175.0 + float(world["ai_research_fields"][key].get("propulsion", 0)) * 12.0:
                closest = distance
                target = int(star["id"])
        if target < 0:
            continue
        fleet["location"] = target
        logistics["supply"] = maxi(0, int(logistics["supply"]) - 18)
        var defending := 8 + int(world["stars"][target]["resource"]) * 2 + (6 if str(world.get("fleet_doctrine", "balanced")) == "defense" else 0)
        for colony_key in world["planet_colonies"].keys():
            if str(colony_key).begins_with(str(target) + ":"):
                var colony: Dictionary = world["planet_colonies"][colony_key]
                defending += int(colony.get("buildings", {}).get("fort", 0)) * 8
        # Rival attacks obey the same low-supply combat penalty as the player.
        var base_power := int(fleet["strength"])
        var attack_supply := clampi(int(logistics["supply"]), 0, 100)
        var penalty := 0 if attack_supply >= 50 else maxi(1, ceili(float(base_power) * float(50 - attack_supply) / 100.0))
        var power := maxi(0, base_power - penalty + int(world["ai_research_fields"][key].get("industry", 0)) * 2)
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
static func _society_tick(world: Dictionary, rival: Dictionary, treasury: int, year: int, ownership: Dictionary) -> void:
    var id := int(rival["id"])
    var key := str(id)
    var society: Dictionary = world["ai_societies"][key]
    var identity: Dictionary = GalaxyIdentity.modifiers(rival)
    var culture_effects: Dictionary = GalaxyIdentity.culture_modifiers(world["ai_cultures"][key])
    identity["capital"] = int(identity["capital"]) + int(culture_effects["capital"])
    identity["legitimacy"] = int(identity["legitimacy"]) + int(culture_effects["legitimacy"])
    var owner_summary: Dictionary = ownership.get(key, {"count": 0, "resources": 0})
    var owned: int = int(owner_summary["count"])
    var resources: int = int(owner_summary["resources"])
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
    legitimacy = clampi(legitimacy + (1 if prosperity >= 55 else -2 if prosperity < 30 else 0) - (1 if inequality >= 60 else 0) + int(identity["legitimacy"]) + int(world["ai_research_fields"][key].get("society", 0)), 0, 100)
    var growth := maxi(0, 1 + int(identity["growth"])) if prosperity >= 40 and population < capacity else 0
    var emigration := 1 if prosperity < 25 and population > 10 else 0
    population = maxi(5, population + growth - emigration)
    GalaxyIdentity.culture_tick(world["ai_cultures"][key], rival, prosperity, clampi(100 - inequality, 0, 100), year)
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
        if int(star["owner"]) != -1 or not bool(star["habitable"]):
            continue
        var d := GalaxySystems.distance(source, star)
        if d < distance:
            best = int(star["id"])
            distance = d
    if best < 0:
        return
    world["stars"][best]["owner"] = id
    world["ai_treasury"][str(id)] = int(world["ai_treasury"].get(str(id), 0)) - 50
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
