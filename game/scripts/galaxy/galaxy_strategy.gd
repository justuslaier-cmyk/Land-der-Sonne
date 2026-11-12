extends RefCounted
class_name GalaxyStrategy

# Pure, deterministic strategic rules. Existing saves are upgraded lazily.
static func prepare(world: Dictionary) -> void:
    GalaxySystems.prepare(world)
    GalaxyAI.prepare(world)
    GalaxyCivilians.prepare(world)
    GalaxyProgress.prepare(world)
    if not world.has("culture"):
        world["culture"] = GalaxyIdentity.culture_defaults(world["empire"])
    if not world.has("planet_colonies"):
        world["planet_colonies"] = {}
    if not world.has("buildings"):
        world["buildings"] = {}
    if not world.has("fleet_doctrine"):
        world["fleet_doctrine"] = "balanced"
    if not world.has("fleet_experience"):
        world["fleet_experience"] = 0
    if not world.has("diplomatic_trust"):
        world["diplomatic_trust"] = {}
    if not world.has("wars"):
        world["wars"] = []
    if not world.has("trade_pacts"):
        world["trade_pacts"] = []
    if not world.has("trade_security"):
        world["trade_security"] = 0
    if not world.has("diplomatic_negotiations"):
        world["diplomatic_negotiations"] = []
    if not world.has("diplomatic_treaties"):
        world["diplomatic_treaties"] = []
    if not world.has("alliances"):
        world["alliances"] = []
    if not world.has("diplomatic_dependencies"):
        world["diplomatic_dependencies"] = {}
    if not world.has("intelligence"):
        world["intelligence"] = {}
    if not world.has("spy_missions"):
        world["spy_missions"] = []
    if not world.has("counterintelligence"):
        world["counterintelligence"] = 0
    if not world.has("policies"):
        world["policies"] = {"focus": 0, "tax": 1}
    if not world["policies"].has("welfare"):
        world["policies"]["welfare"] = 0
    if not world.has("stability"):
        world["stability"] = 70
    if not world.has("governance"):
        world["governance"] = {"rights": 1, "pending": {}, "last_reform": -100}
    var governance: Dictionary = world["governance"]
    if not governance.has("legitimacy"):
        governance["legitimacy"] = 60
    if not governance.has("mandate"):
        governance["mandate"] = 0
    if not governance.has("next_transition"):
        governance["next_transition"] = int(world.get("tick", 0)) + [8, 12, 10, 6][clampi(int(world["empire"].get("government", 0)), 0, 3)]
    if not governance.has("crisis_years"):
        governance["crisis_years"] = 0
    if not world.has("alloys"):
        world["alloys"] = 30
    if not world.has("ship_design"):
        world["ship_design"] = {"hull": 0, "weapon": 0, "engine": 0}
    if not world.has("ship_role"):
        world["ship_role"] = "escort"
    if not world.has("ship_registry"):
        world["ship_registry"] = []
    if not world.has("fleet_command"):
        world["fleet_command"] = {"order": "hold", "admiral": "none", "assignment_year": -1}
    if not world.has("fleet_command_history"):
        world["fleet_command_history"] = []
    if not world.has("fleet_logistics"):
        world["fleet_logistics"] = {"supply": 100, "last_service": -1}
    if not world.has("battle_reports"):
        world["battle_reports"] = []
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

# System claims require a surveyed world, credits and a stationed fleet.
# Individual planet settlement remains a separate, already implemented action.
static func colonize_system(world: Dictionary, star_id: int) -> String:
    prepare(world)
    if star_id < 0 or star_id >= world["stars"].size():
        return "Ungültiges Sternensystem."
    if not world.get("known", []).has(star_id):
        return "Sternensystem noch nicht kartografiert."
    var star: Dictionary = world["stars"][star_id]
    if int(star["owner"]) != -1:
        return "Sternensystem bereits beansprucht."
    if not bool(star["habitable"]):
        return "Keine bewohnbare Welt in diesem Sternensystem."
    var stationed := false
    for fleet in world.get("fleets", []):
        if int(fleet.get("owner", -1)) == 0 and int(fleet.get("location", -1)) == star_id and int(fleet.get("destination", -1)) < 0:
            stationed = true
            break
    if not stationed:
        return "Eine eigene Flotte muss sich im Zielsystem befinden."
    if int(world["credits"]) < 50:
        return "Nicht genügend Credits (50 benötigt)."
    world["credits"] = int(world["credits"]) - 50
    star["owner"] = 0
    world["history"].append("Sternensystem %s kolonisiert." % star["name"])
    return ""

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
    world["planet_colonies"][key] = {"population": 1, "buildings": {}, "environmental_pressure": int(planet["environmental_pressure"]), "capacity": maxi(2, int(planet["size"]) - int(planet["environmental_pressure"]) / 20)}
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
    if kind == "mine" or kind == "factory":
        colony["environmental_pressure"] = mini(100, int(colony.get("environmental_pressure", 0)) + (6 if kind == "mine" else 4))
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

# Government models differ in approval thresholds and enactment time.
# Political blocs respond to the direction of a rights reform. Their
# weights derive from the evolving culture, not a player-controlled slider.
# Public welfare is a bounded treasury expenditure; no household goods are minted.
static func set_welfare(world: Dictionary, level: int) -> bool:
    prepare(world)
    if level < 0 or level > 2:
        return false
    world["policies"]["welfare"] = level
    world["history"].append("Sozialhaushalt: Stufe %d." % level)
    return true

static func settle_public_budget(world: Dictionary) -> void:
    prepare(world)
    var opening := int(world["credits"])
    var receipts := maxi(0, int(world.get("civilian_taxes", 0)))
    # Civilian enterprises already paid these taxes in GalaxyCivilians.tick.
    # This is the one and only transfer of assessed taxes to the treasury.
    world["credits"] = opening + receipts
    var level := clampi(int(world["policies"].get("welfare", 0)), 0, 2)
    var markets: Dictionary = world.get("civilian_worlds", {})
    var active: Array = []
    for key in markets.keys():
        var sid := int(key)
        if sid >= 0 and sid < world["stars"].size() and int(world["stars"][sid]["owner"]) == 0:
            active.append(str(key))
    active.sort_custom(func(a: String, b: String): return int(a) < int(b))
    var budget := mini(maxi(0, int(world["credits"])), active.size() * level * 3)
    var spent := 0
    var recipients: Array = []
    for key in active:
        var market: Dictionary = markets[key]
        var cost := mini(level * 3, budget - spent)
        if cost <= 0:
            break
        # Transfers fund services (not goods or direct household capital).
        var before := int(market["satisfaction"])
        market["satisfaction"] = clampi(before + cost / 3, 0, 100)
        spent += cost
        recipients.append({"system": int(key), "cost": cost, "satisfaction_gain": int(market["satisfaction"]) - before})
    world["credits"] = int(world["credits"]) - spent
    world["public_budget_ledger"] = {"year": int(world["tick"]), "opening": opening,
        "tax_receipts": receipts, "welfare_spending": spent, "closing": int(world["credits"]),
        "recipients": recipients}
    # Approval is recalculated after welfare effects, before governance advances.
    var weighted := 0
    var population := 0
    for key in active:
        var market: Dictionary = markets[key]
        weighted += int(market["population"]) * int(market["satisfaction"])
        population += int(market["population"])
    world["civilian_approval"] = weighted / maxi(1, population)

static func reform_support(world: Dictionary, rights: int) -> Dictionary:
    prepare(world)
    var groups: Dictionary = GalaxyIdentity.social_groups(world["culture"])
    var current := int(world["governance"]["rights"])
    var traditionalists := int(groups["traditionalists"])
    var reformers := int(groups["reformers"])
    var merchants := int(groups["merchants"])
    var supporters := 0
    if rights > current:
        supporters = reformers + merchants / 2
    elif rights < current:
        supporters = traditionalists + merchants / 2
    else:
        supporters = 100
    var opposition := 100 - supporters
    return {"support": supporters, "opposition": opposition,
        "traditionalists": traditionalists, "reformers": reformers,
        "merchants": merchants}

static func propose_rights_reform(world: Dictionary, rights: int) -> bool:
    prepare(world)
    if rights < 0 or rights > 2:
        return false
    var governance: Dictionary = world["governance"]
    if not governance.get("pending", {}).is_empty() or rights == int(governance["rights"]):
        return false
    if int(world["tick"]) - int(governance.get("last_reform", -100)) < 4:
        return false
    var government := clampi(int(world["empire"].get("government", 0)), 0, 3)
    var approval := int(world.get("civilian_approval", 50))
    var threshold: int = [50, 35, 65, 45][government]
    if approval < threshold:
        return false
    var blocs: Dictionary = reform_support(world, rights)
    if int(blocs["support"]) < 30:
        return false
    var delay: int = [3, 2, 4, 3][government]
    var resistance := maxi(0, int(blocs["opposition"]) - 50) / 10
    governance["pending"] = {"rights": rights, "enact_tick": int(world["tick"]) + delay + resistance,
        "support": int(blocs["support"]), "opposition": int(blocs["opposition"])}
    world["history"].append("Gesellschaftsreform eingeleitet: Bürgerrechte Stufe %d." % rights)
    return true

static func advance_governance(world: Dictionary) -> void:
    prepare(world)
    var governance: Dictionary = world["governance"]
    var pending: Dictionary = governance.get("pending", {})
    if pending.is_empty() or int(world["tick"]) < int(pending["enact_tick"]):
        return
    var old_rights := int(governance["rights"])
    var new_rights := int(pending["rights"])
    governance["rights"] = new_rights
    governance["last_reform"] = int(world["tick"])
    governance["pending"] = {}
    var opposition := int(pending.get("opposition", 0))
    world["stability"] = clampi(int(world["stability"]) - abs(new_rights - old_rights) * 3 - opposition / 25, 0, 100)
    world["history"].append("Bürgerrechtsreform in Kraft: Stufe %d." % new_rights)

# Abstract institutional transitions: elections, dynastic succession,
# expert appointments and council rotation have distinct cadences.
# This is not yet a seat-by-seat parliamentary or character simulation.
static func advance_institutions(world: Dictionary) -> void:
    prepare(world)
    var governance: Dictionary = world["governance"]
    var government := clampi(int(world["empire"].get("government", 0)), 0, 3)
    var approval := clampi(int(world.get("civilian_approval", 50)), 0, 100)
    var stability := clampi(int(world.get("stability", 70)), 0, 100)
    var legitimacy := clampi(int(governance["legitimacy"]), 0, 100)
    var groups: Dictionary = GalaxyIdentity.social_groups(world["culture"])
    var dominant := 0
    var weights: Array = [int(groups["traditionalists"]), int(groups["reformers"]), int(groups["merchants"])]
    for i in range(1, weights.size()):
        if int(weights[i]) > int(weights[dominant]):
            dominant = i
    if int(world["tick"]) >= int(governance["next_transition"]):
        var old_mandate := int(governance["mandate"])
        if government == 0:
            governance["mandate"] = dominant
        elif government == 1:
            governance["mandate"] = (old_mandate + 1) % 3
        elif government == 2:
            governance["mandate"] = 1 if int(world.get("science", 0)) >= 20 else 2
        else:
            governance["mandate"] = (old_mandate + 1) % 3
        var cadence: int = [8, 12, 10, 6][government]
        governance["next_transition"] = int(world["tick"]) + cadence
        legitimacy = clampi(legitimacy + (5 if approval >= 50 else -5), 0, 100)
        world["history"].append("%s: institutioneller Machtwechsel, Mandat %d." % [GalaxyIdentity.GOVERNMENTS[government], int(governance["mandate"])])
    var legitimacy_delta := (1 if approval >= 60 else -2 if approval < 35 else 0)
    if stability < 30:
        legitimacy_delta -= 2
    legitimacy = clampi(legitimacy + legitimacy_delta, 0, 100)
    governance["legitimacy"] = legitimacy
    if legitimacy < 25:
        governance["crisis_years"] = int(governance["crisis_years"]) + 1
        world["stability"] = maxi(0, int(world["stability"]) - 2)
        if int(governance["crisis_years"]) == 3:
            world["history"].append("Legitimitaetskrise: Die politische Ordnung verliert Rueckhalt.")
    else:
        governance["crisis_years"] = 0

static func configure_ship(world: Dictionary, hull: int, weapon: int, engine: int) -> bool:
    prepare(world)
    if hull < 0 or hull > 2 or weapon < 0 or weapon > 2 or engine < 0 or engine > 2:
        return false
    world["ship_design"] = {"hull": hull, "weapon": weapon, "engine": engine}
    world["history"].append("Neue Schiffsklasse entworfen.")
    return true

# Roles change tactical contribution and material costs. Existing designs
# default to escorts; engine technology gates advanced propulsion.
static func ship_blueprint(world: Dictionary) -> Dictionary:
    prepare(world)
    var design: Dictionary = world["ship_design"]
    var role := str(world["ship_role"])
    var strength := 3 + int(design["hull"]) * 2 + int(design["weapon"]) * 3 + int(world["research_level"]) / 2
    var alloy_cost := 12 + int(design["hull"]) * 5
    var credit_cost := 30 + int(design["weapon"]) * 10
    if role == "interceptor":
        strength += 1
        alloy_cost += 3
    elif role == "artillery":
        strength += 4
        alloy_cost += 8
        credit_cost += 10
    credit_cost = maxi(0, credit_cost - int(fleet_command_bonuses(world)["shipyard_discount"]))
    var required_propulsion := int(design["engine"])
    var available_propulsion := int(world.get("research_fields", {}).get("propulsion", 0))
    return {"role": role, "strength": strength, "alloys": alloy_cost,
        "credits": credit_cost, "required_propulsion": required_propulsion,
        "allowed": available_propulsion >= required_propulsion}

static func set_ship_role(world: Dictionary, role: String) -> bool:
    prepare(world)
    if not ["escort", "interceptor", "artillery"].has(role):
        return false
    world["ship_role"] = role
    world["history"].append("Schiffsklasse neu ausgerichtet: %s." % role)
    return true

static func ship_strength(world: Dictionary) -> int:
    return int(ship_blueprint(world)["strength"])

static func build_ships(world: Dictionary) -> bool:
    prepare(world)
    var blueprint: Dictionary = ship_blueprint(world)
    if not bool(blueprint["allowed"]):
        return false
    if int(world["credits"]) < int(blueprint["credits"]) or int(world["alloys"]) < int(blueprint["alloys"]):
        return false
    world["credits"] = int(world["credits"]) - int(blueprint["credits"])
    world["alloys"] = int(world["alloys"]) - int(blueprint["alloys"])
    world["fleets"][0]["strength"] = int(world["fleets"][0]["strength"]) + int(blueprint["strength"])
    var design: Dictionary = world["ship_design"]
    world["ship_registry"].append({"year": int(world["tick"]), "role": str(blueprint["role"]),
        "hull": int(design["hull"]), "weapon": int(design["weapon"]),
        "engine": int(design["engine"]), "strength": int(blueprint["strength"]),
        "alloys": int(blueprint["alloys"]), "credits": int(blueprint["credits"])})
    world["history"].append("Kriegsschiffe (%s) fertiggestellt: +%d Flottenstärke." % [str(blueprint["role"]), int(blueprint["strength"])])
    return true

static func declare_war(world: Dictionary, rival_id: int) -> bool:
    prepare(world)
    if not world["contacts"].has(rival_id) or world["wars"].has(rival_id) or world["alliances"].has(rival_id) or world.get("non_aggression", []).has(rival_id) or int(world.get("truce_until", {}).get(str(rival_id), 0)) > int(world["tick"]):
        return false
    world["wars"].append(rival_id)
    world["relations"][str(rival_id)] = -100
    world["history"].append("Krieg gegen %s erklärt." % GalaxySystems.empire_name(world, rival_id))
    return true

# Formal negotiations lock a deposit, take two years, and resolve against
# the diplomatic situation at the time of ratification.
# Contact reveals diplomatic basics, not the rival's hidden strategic stance.
# Missions are deterministic and persist through save/load.
static func intelligence_level(world: Dictionary, rival_id: int) -> int:
    prepare(world)
    if not world["contacts"].has(rival_id):
        return 0
    return clampi(int(world["intelligence"].get(str(rival_id), 1)), 1, 3)

static func launch_spy_mission(world: Dictionary, rival_id: int, kind: String) -> bool:
    prepare(world)
    if not ["recon", "infiltrate"].has(kind) or not world["contacts"].has(rival_id):
        return false
    if world["wars"].has(rival_id) and kind == "infiltrate":
        return false
    for mission in world["spy_missions"]:
        if int(mission["rival"]) == rival_id:
            return false
    var cost := 20 if kind == "recon" else 35
    if int(world["credits"]) < cost:
        return false
    world["credits"] = int(world["credits"]) - cost
    world["spy_missions"].append({"rival": rival_id, "kind": kind,
        "due": int(world["tick"]) + (2 if kind == "recon" else 3)})
    world["history"].append("Geheimdienstoperation gegen %s begonnen." % GalaxySystems.empire_name(world, rival_id))
    return true

static func reinforce_counterintelligence(world: Dictionary) -> bool:
    prepare(world)
    if int(world["credits"]) < 25 or int(world["counterintelligence"]) >= 3:
        return false
    world["credits"] = int(world["credits"]) - 25
    world["counterintelligence"] = int(world["counterintelligence"]) + 1
    world["history"].append("Gegenspionage auf Stufe %d ausgebaut." % int(world["counterintelligence"]))
    return true

static func advance_intelligence(world: Dictionary) -> void:
    prepare(world)
    var waiting: Array = []
    for mission in world["spy_missions"]:
        if int(mission["due"]) > int(world["tick"]):
            waiting.append(mission)
            continue
        var rival := int(mission["rival"])
        var kind := str(mission["kind"])
        var society: Dictionary = world.get("ai_societies", {}).get(str(rival), {})
        var security := clampi(int(society.get("factions", {}).get("security", 20)) / 20, 0, 4)
        var difficulty := security + (2 if kind == "infiltrate" else 0)
        var strength := 3 + int(world.get("research_fields", {}).get("society", 0))
        if strength >= difficulty:
            var level := mini(3, intelligence_level(world, rival) + 1)
            world["intelligence"][str(rival)] = level
            world["history"].append("Geheimdienstbericht zu %s: Informationsstufe %d." % [GalaxySystems.empire_name(world, rival), level])
        else:
            world["diplomatic_trust"][str(rival)] = maxi(-50, int(world["diplomatic_trust"].get(str(rival), 0)) - 5)
            world["history"].append("Spionage gegen %s aufgedeckt: Vertrauen sinkt." % GalaxySystems.empire_name(world, rival))
    world["spy_missions"] = waiting
    # Periodic hostile probes are blocked by an upgraded counterintelligence
    # service; the baseline is deliberately small to avoid runaway penalties.
    if int(world["tick"]) > 0 and int(world["tick"]) % 7 == 0 and not world["contacts"].is_empty():
        if int(world["counterintelligence"]) >= 1:
            world["history"].append("Gegenspionage vereitelt einen fremden Datenzugriff.")
        else:
            world["credits"] = maxi(0, int(world["credits"]) - 3)
            world["history"].append("Fremder Datenzugriff: 3 Credits Sicherheitsverlust.")

static func negotiate_treaty(world: Dictionary, rival_id: int, kind: String) -> bool:
    prepare(world)
    if not ["trade", "non_aggression", "alliance", "dependency"].has(kind):
        return false
    if not world["contacts"].has(rival_id) or world["wars"].has(rival_id):
        return false
    for item in world["diplomatic_negotiations"]:
        if int(item["rival"]) == rival_id:
            return false
    for item in world["diplomatic_treaties"]:
        if int(item["rival"]) == rival_id and str(item["kind"]) == kind:
            return false
    if kind == "trade" and world["trade_pacts"].has(rival_id):
        return false
    if kind == "non_aggression" and world.get("non_aggression", []).has(rival_id):
        return false
    if kind == "alliance" and world["alliances"].has(rival_id):
        return false
    if kind == "dependency" and world["diplomatic_dependencies"].has(str(rival_id)):
        return false
    var score := int(world["relations"].get(str(rival_id), 0)) + int(world["diplomatic_trust"].get(str(rival_id), 0))
    var required: int = {"trade": 15, "non_aggression": 35, "alliance": 65, "dependency": 55}[kind]
    var deposit: int = {"trade": 15, "non_aggression": 20, "alliance": 40, "dependency": 30}[kind]
    if score < required or int(world["credits"]) < deposit:
        return false
    world["credits"] = int(world["credits"]) - deposit
    world["diplomatic_negotiations"].append({"rival": rival_id, "kind": kind,
        "due": int(world["tick"]) + 2, "deposit": deposit, "required": required})
    world["history"].append("Verhandlungen mit %s begonnen: %s." % [GalaxySystems.empire_name(world, rival_id), kind])
    return true

static func advance_diplomacy(world: Dictionary) -> void:
    prepare(world)
    var waiting: Array = []
    for negotiation in world["diplomatic_negotiations"]:
        if int(negotiation["due"]) > int(world["tick"]):
            waiting.append(negotiation)
            continue
        var rival := int(negotiation["rival"])
        var kind := str(negotiation["kind"])
        var score := int(world["relations"].get(str(rival), 0)) + int(world["diplomatic_trust"].get(str(rival), 0))
        if world["wars"].has(rival) or score < int(negotiation["required"]):
            world["history"].append("Verhandlungen mit %s gescheitert: %s." % [GalaxySystems.empire_name(world, rival), kind])
            continue
        var accepted := false
        if kind == "trade":
            accepted = sign_trade(world, rival)
        elif kind == "non_aggression":
            accepted = propose_non_aggression(world, rival)
        elif kind == "alliance":
            accepted = ratify_alliance(world, rival)
        elif kind == "dependency":
            accepted = ratify_dependency(world, rival)
        if accepted:
            world["diplomatic_treaties"].append({"rival": rival, "kind": kind,
                "signed": int(world["tick"]), "deposit": int(negotiation["deposit"])})
        else:
            world["history"].append("Verhandlungen ohne Abschluss: %s." % kind)
    world["diplomatic_negotiations"] = waiting

# Defensive alliances share no automatic fleet ownership, but a rival's
# attack on the player is disallowed while the alliance is in force.
static func ratify_alliance(world: Dictionary, rival_id: int) -> bool:
    prepare(world)
    if not world["contacts"].has(rival_id) or world["wars"].has(rival_id) or world["alliances"].has(rival_id):
        return false
    var score := int(world["relations"].get(str(rival_id), 0)) + int(world["diplomatic_trust"].get(str(rival_id), 0))
    if score < 65:
        return false
    world["alliances"].append(rival_id)
    world["history"].append("Verteidigungsbuendnis mit %s ratifiziert." % GalaxySystems.empire_name(world, rival_id))
    return true

# Dependency is a voluntary economic arrangement, not a conquest or vassal state.
static func ratify_dependency(world: Dictionary, rival_id: int) -> bool:
    prepare(world)
    if not world["contacts"].has(rival_id) or world["wars"].has(rival_id) or world["diplomatic_dependencies"].has(str(rival_id)):
        return false
    var score := int(world["relations"].get(str(rival_id), 0)) + int(world["diplomatic_trust"].get(str(rival_id), 0))
    if score < 55:
        return false
    world["diplomatic_dependencies"][str(rival_id)] = {"tribute": 4, "signed": int(world["tick"])}
    world["history"].append("Wirtschaftliches Abhaengigkeitsabkommen mit %s ratifiziert." % GalaxySystems.empire_name(world, rival_id))
    return true

static func dependency_income(world: Dictionary) -> int:
    prepare(world)
    var total := 0
    for key in world["diplomatic_dependencies"].keys():
        if not world["wars"].has(int(key)):
            total += int(world["diplomatic_dependencies"][key].get("tribute", 0))
    return total

# Patrol investment is paid immediately; freight disruption uses this level.
static func improve_trade_security(world: Dictionary) -> bool:
    prepare(world)
    var level := int(world.get("trade_security", 0))
    var cost := 20 + level * 15
    if level >= 3 or int(world.get("credits", 0)) < cost:
        return false
    world["credits"] = int(world["credits"]) - cost
    world["trade_security"] = level + 1
    world["history"].append("Zivile Handelskonvois werden stärker gesichert (Stufe %d)." % (level + 1))
    return true

static func sign_trade(world: Dictionary, rival_id: int) -> bool:
    prepare(world)
    if not world["contacts"].has(rival_id) or world["wars"].has(rival_id) or world["trade_pacts"].has(rival_id):
        return false
    if int(world["relations"].get(str(rival_id), 0)) + int(world["diplomatic_trust"].get(str(rival_id), 0)) < 15:
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
    if int(world["relations"].get(str(rival_id), 0)) + int(world["diplomatic_trust"].get(str(rival_id), 0)) < 35:
        return false
    if not world.has("non_aggression"):
        world["non_aggression"] = []
    if world["non_aggression"].has(rival_id):
        return false
    world["non_aggression"].append(rival_id)
    world["history"].append("Nichtangriffspakt mit %s vereinbart." % GalaxySystems.empire_name(world, rival_id))
    return true

# Doctrine has strategic trade-offs rather than unconditional combat bonuses.
static func set_fleet_doctrine(world: Dictionary, doctrine: String) -> bool:
    prepare(world)
    if not ["balanced", "assault", "defense", "exploration"].has(doctrine):
        return false
    if str(world["fleet_doctrine"]) == doctrine:
        return false
    world["fleet_doctrine"] = doctrine
    world["history"].append("Flottendoktrin geändert: %s." % doctrine)
    return true

# Phase 12/2: the current simulation has one player fleet. Commands
# are persistent fleet-wide orders, not independent ship or fleet entities.
static func assign_admiral(world: Dictionary, admiral: String) -> bool:
    prepare(world)
    if not ["none", "tactician", "navigator", "quartermaster"].has(admiral):
        return false
    if str(world["fleet_command"]["admiral"]) == admiral:
        return false
    world["fleet_command"]["admiral"] = admiral
    world["fleet_command"]["assignment_year"] = int(world["tick"])
    world["fleet_command_history"].append({"year": int(world["tick"]), "type": "admiral", "value": admiral})
    world["history"].append("Flottenkommando: Admiralsposten %s." % admiral)
    return true

static func set_fleet_order(world: Dictionary, order: String) -> bool:
    prepare(world)
    if not ["hold", "patrol", "assault"].has(order):
        return false
    if str(world["fleet_command"]["order"]) == order:
        return false
    world["fleet_command"]["order"] = order
    world["fleet_command_history"].append({"year": int(world["tick"]), "type": "order", "value": order})
    world["history"].append("Flottenbefehl erteilt: %s." % order)
    return true

static func fleet_command_bonuses(world: Dictionary) -> Dictionary:
    prepare(world)
    var command: Dictionary = world["fleet_command"]
    var admiral := str(command.get("admiral", "none"))
    var order := str(command.get("order", "hold"))
    return {
        "attack": (3 if admiral == "tactician" else 0) + (3 if order == "assault" else 0),
        "shipyard_discount": 5 if admiral == "quartermaster" else 0,
        "range": 25 if admiral == "navigator" else 0,
        "travel_reduction": 1 if admiral == "navigator" else 0
    }

# Supply is an aggregate percentage for the single player fleet.
# It is replenished in friendly territory, consumed in transit and combat.
static func fleet_upkeep(world: Dictionary) -> int:
    prepare(world)
    return maxi(1, ceili(float(maxi(0, int(world["fleets"][0]["strength"]))) / 20.0))

static func service_fleet(world: Dictionary) -> bool:
    prepare(world)
    var fleet: Dictionary = world["fleets"][0]
    var location := int(fleet.get("location", -1))
    if location < 0 or location >= world["stars"].size() or int(fleet.get("destination", -1)) >= 0:
        return false
    if int(world["stars"][location]["owner"]) != 0:
        return false
    var supply := clampi(int(world["fleet_logistics"].get("supply", 100)), 0, 100)
    var strength := maxi(0, int(fleet["strength"]))
    if supply >= 100 and strength >= 12:
        return false
    var alloy_cost := 4
    var credit_cost := 10
    if int(world["alloys"]) < alloy_cost or int(world["credits"]) < credit_cost:
        return false
    world["alloys"] = int(world["alloys"]) - alloy_cost
    world["credits"] = int(world["credits"]) - credit_cost
    world["fleet_logistics"]["supply"] = mini(100, supply + 35)
    fleet["strength"] = mini(12, strength + 2) if strength < 12 else strength
    world["fleet_logistics"]["last_service"] = int(world["tick"])
    world["history"].append("Flottenservice: Nachschub aufgefuellt und gegebenenfalls repariert.")
    return true

static func advance_fleet_logistics(world: Dictionary) -> void:
    prepare(world)
    var fleet: Dictionary = world["fleets"][0]
    var upkeep := fleet_upkeep(world)
    world["credits"] = maxi(0, int(world["credits"]) - upkeep)
    var location := int(fleet.get("location", -1))
    var friendly: bool = location >= 0 and location < world["stars"].size() and int(world["stars"][location]["owner"]) == 0
    var transit := int(fleet.get("destination", -1)) >= 0
    var logistics: Dictionary = world["fleet_logistics"]
    var supply := clampi(int(logistics.get("supply", 100)), 0, 100)
    if transit or not friendly:
        supply = maxi(0, supply - (12 if transit else 7))
    else:
        supply = mini(100, supply + 8)
    logistics["supply"] = supply
    if supply == 0 and int(fleet["strength"]) > 0:
        fleet["strength"] = maxi(0, int(fleet["strength"]) - 1)
        world["history"].append("Flottenverluste durch fehlenden Nachschub.")

static func fleet_attack_power(world: Dictionary) -> int:
    prepare(world)
    var base := int(world["fleets"][0]["strength"])
    var experience := mini(8, int(world["fleet_experience"]) / 3)
    var doctrine := str(world["fleet_doctrine"])
    var supply := clampi(int(world["fleet_logistics"].get("supply", 100)), 0, 100)
    var supply_penalty := 0 if supply >= 50 else maxi(1, ceili(float(base) * float(50 - supply) / 100.0))
    return maxi(0, base + experience + (6 if doctrine == "assault" else 0) + int(fleet_command_bonuses(world)["attack"]) - supply_penalty)

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
    if int(fleet["strength"]) <= 0:
        return "Keine einsatzfähige Flotte."
    var defense := 8 + int(star["resource"]) * 2 + int(world["tick"]) / 8
    for rival_fleet in world["ai_fleets"]:
        if int(rival_fleet["owner"]) == defender and int(rival_fleet["location"]) == star_id:
            defense += int(rival_fleet["strength"])
    var before := int(fleet["strength"])
    var supply_before := clampi(int(world["fleet_logistics"].get("supply", 100)), 0, 100)
    var power := fleet_attack_power(world)
    var victory := power > defense
    if victory:
        star["owner"] = 0
        fleet["strength"] = maxi(1, before - maxi(3, defense / 2))
        world["stability"] = maxi(0, int(world["stability"]) - 3)
        world["fleet_experience"] = mini(60, int(world["fleet_experience"]) + 3)
    else:
        fleet["strength"] = maxi(0, before - maxi(3, defense / 2))
        world["fleet_experience"] = mini(60, int(world["fleet_experience"]) + 1)
    world["fleet_logistics"]["supply"] = maxi(0, supply_before - 20)
    var report := {"year": int(world["tick"]), "system": star_id, "defender": defender,
        "attack": power, "defense": defense, "victory": victory,
        "strength_before": before, "strength_after": int(fleet["strength"]),
        "losses": before - int(fleet["strength"]), "supply_before": supply_before,
        "supply_after": int(world["fleet_logistics"]["supply"])}
    world["battle_reports"].append(report)
    if world["battle_reports"].size() > 40:
        world["battle_reports"].pop_front()
    world["history"].append("%s: %s; Angriff %d, Verteidigung %d, Verluste %d." % [str(star["name"]), "Sieg" if victory else "Niederlage", power, defense, int(report["losses"])])
    return "Sieg! System erobert." if victory else "Niederlage! Flotte beschädigt."

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
    alloys += int(GalaxySystems.technology_bonuses(world)["industry_alloys"])
    var focus := int(world["policies"]["focus"])
    var tax := int(world["policies"]["tax"])
    credits += (tax - 1) * 5 + world["trade_pacts"].size() * 6 + dependency_income(world) + (4 if focus == 0 else 0) + GalaxyLore.artifact_bonus(world, "credits")
    science += (4 if focus == 1 else 0) + GalaxyLore.artifact_bonus(world, "science")
    alloys += (3 if focus == 2 else 0) + GalaxyLore.artifact_bonus(world, "alloys")
    var next_stability := clampi(int(world["stability"]) + (1 if tax == 0 else -1 if tax == 2 else 0) + int(world["governance"]["rights"]) - 1 + int(GalaxySystems.technology_bonuses(world)["society_stability"]), 0, 100)
    if next_stability < 25:
        credits -= 5
    credits -= colony_upkeep(world)
    credits -= fleet_upkeep(world)
    # Predict next-year civilian receipts from an isolated copy, not last year's
    # assessed taxes. This preserves exact deterministic baseline forecasts.
    var projection := world.duplicate(true)
    GalaxySystems.tick(projection)
    GalaxyCivilians.tick(projection)
    var predicted_receipts := maxi(0, int(projection.get("civilian_taxes", 0)))
    var welfare_level := clampi(int(world["policies"].get("welfare", 0)), 0, 2)
    var active_count := 0
    for star in projection["stars"]:
        if int(star["owner"]) == 0:
            active_count += 1
    var welfare_cost := mini(maxi(0, int(world["credits"]) + predicted_receipts), active_count * welfare_level * 3)
    credits += predicted_receipts - welfare_cost
    science += int(GalaxyIdentity.culture_modifiers(world.get("culture", {}))["science"])
    return {"credits": credits, "science": science, "alloys": alloys}

# Colonies are bounded by their carrying capacity. Industrial pressure reduces
# the effective cap; population grows at most one unit per five simulation years.
static func colony_capacity(colony: Dictionary) -> int:
    var baseline := maxi(1, int(colony.get("capacity", 2)))
    var pressure := clampi(int(colony.get("environmental_pressure", 0)), 0, 100)
    return maxi(1, baseline - pressure / 20)

static func colony_upkeep(world: Dictionary) -> int:
    var upkeep := 0
    for key in world.get("planet_colonies", {}).keys():
        var parts := str(key).split(":")
        if parts.size() != 2:
            continue
        var sid := int(parts[0])
        if sid < 0 or sid >= world["stars"].size() or int(world["stars"][sid]["owner"]) != 0:
            continue
        var colony: Dictionary = world["planet_colonies"][key]
        var pressure := clampi(int(colony.get("environmental_pressure", 0)), 0, 100)
        upkeep += pressure / 25
    return upkeep

static func advance_colonies(world: Dictionary) -> void:
    for key in world.get("planet_colonies", {}).keys():
        var parts := str(key).split(":")
        if parts.size() != 2:
            continue
        var sid := int(parts[0])
        if sid < 0 or sid >= world["stars"].size() or int(world["stars"][sid]["owner"]) != 0:
            continue
        var colony: Dictionary = world["planet_colonies"][key]
        var population := maxi(1, int(colony.get("population", 1)))
        var cap := colony_capacity(colony)
        if population > cap:
            population -= 1
        elif population < cap and int(world["tick"]) % 5 == 0:
            population += 1
        colony["population"] = population
        world["planet_colonies"][key] = colony

static func tick(world: Dictionary) -> void:
    prepare(world)
    var opening := {"credits": int(world["credits"]), "science": int(world["science"]), "alloys": int(world["alloys"]), "stability": int(world["stability"])}
    GalaxySystems.tick(world)
    advance_fleet_logistics(world)
    GalaxyCivilians.tick(world)
    settle_public_budget(world)
    GalaxySocietyAudit.record(world)
    advance_diplomacy(world)
    advance_intelligence(world)
    advance_governance(world)
    advance_institutions(world)
    GalaxyIdentity.culture_tick(world["culture"], world["empire"], clampi(int(world.get("credits", 0)) / 4, 0, 100), int(world.get("civilian_approval", 50)), int(world["tick"]))
    advance_colonies(world)
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
    world["credits"] = int(world["credits"]) + credits_bonus + (tax - 1) * 5 + world["trade_pacts"].size() * 6 + dependency_income(world) + GalaxyLore.artifact_bonus(world, "credits")
    world["credits"] = int(world["credits"]) - colony_upkeep(world)
    world["science"] = maxi(0, int(world["science"]) + int(GalaxyIdentity.culture_modifiers(world["culture"])["science"]))
    world["science"] = int(world["science"]) + science_bonus + (4 if focus == 1 else 0) + GalaxyLore.artifact_bonus(world, "science")
    world["alloys"] = int(world["alloys"]) + 2 + alloy_bonus + (3 if focus == 2 else 0) + GalaxyLore.artifact_bonus(world, "alloys")
    var technology: Dictionary = GalaxySystems.technology_bonuses(world)
    world["alloys"] = int(world["alloys"]) + int(technology["industry_alloys"])
    var rights_effect := int(world["governance"]["rights"]) - 1
    world["stability"] = clampi(int(world["stability"]) + (1 if tax == 0 else -1 if tax == 2 else 0) + rights_effect + int(technology["society_stability"]), 0, 100)
    if focus == 0:
        world["credits"] = int(world["credits"]) + 4
    if int(world["stability"]) < 25:
        world["credits"] = maxi(0, int(world["credits"]) - 5)
        if int(world["tick"]) % 5 == 0 and str(world["pending_event"]) == "":
            world["pending_event"] = "political_crisis"
            world["history"].append("Politische Krise: Proteste und Unruhen erschüttern die Kolonien.")
    # Treaty trust grows gradually; hostile relationships erode it.
    for rival in world["ai"]:
        var id := int(rival["id"])
        var key := str(id)
        var trust := int(world["diplomatic_trust"].get(key, 0))
        var active_treaty: bool = world["trade_pacts"].has(id) or world.get("non_aggression", []).has(id)
        var change := -4 if world["wars"].has(id) else 2 if active_treaty else -1
        world["diplomatic_trust"][key] = clampi(trust + change, 0, 50)
    # Autonomous rival behavior advances with the same simulation clock.
    GalaxyAI.tick(world)
    GalaxyProgress.tick(world)
    # Bounded economic history, persisted in ordinary saves.
    if not world.has("economy_history"):
        world["economy_history"] = []
    var changes := {}
    for field in ["credits", "science", "alloys", "stability"]:
        changes[field] = int(world[field]) - int(opening[field])
    world["economy_history"].append({"year": int(world["tick"]) + 2200, "delta": changes, "balance": {"credits": int(world["credits"]), "science": int(world["science"]), "alloys": int(world["alloys"]), "stability": int(world["stability"])}})
    if world["economy_history"].size() > 60:
        world["economy_history"].pop_front()
