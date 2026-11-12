extends RefCounted
class_name GalaxySystems

# Version-1 extensions are optional, preserving existing save games.
static func prepare(world: Dictionary) -> void:
    if not world.has("lanes"):
        world["lanes"] = GalaxyRoutes.build(world["stars"])
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
    if not world.has("research_fields"):
        world["research_fields"] = {"propulsion": 0, "industry": 0, "society": 0}
    if not world.has("research_history"):
        world["research_history"] = []
    if not world.has("research_insights"):
        world["research_insights"] = {"propulsion": 0, "industry": 0, "society": 0}
    if not world.has("research_breakthroughs"):
        world["research_breakthroughs"] = []
    if not world.has("research_exchange_ledger"):
        world["research_exchange_ledger"] = {}
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
    if not world.has("auto_survey"):
        world["auto_survey"] = false
    GalaxyLore.prepare(world)

static func distance(a: Dictionary, b: Dictionary) -> float:
    return Vector2(float(a["x"]), float(a["y"])).distance_to(Vector2(float(b["x"]), float(b["y"])))

static func route_preview(world: Dictionary, target: int) -> Dictionary:
    if target < 0 or target >= world.get("stars", []).size() or not world.get("known", []).has(target):
        return {"allowed": false, "reason": "System unkartiert oder ungültig", "distance": 0.0, "eta": 0}
    if world.get("fleets", []).is_empty():
        return {"allowed": false, "reason": "Keine Flotte", "distance": 0.0, "eta": 0}
    var fleet: Dictionary = world["fleets"][0]
    var origin_id := int(fleet.get("location", -1))
    if origin_id < 0 or origin_id >= world["stars"].size():
        return {"allowed": false, "reason": "Ungültiger Flottenstandort", "distance": 0.0, "eta": 0}
    var separation := distance(world["stars"][origin_id], world["stars"][target])
    var limit := (255.0 if str(world.get("fleet_doctrine", "balanced")) == "exploration" else 220.0) + float(technology_bonuses(world)["fleet_range"]) + float(GalaxyStrategy.fleet_command_bonuses(world)["range"])
    var reason := ""
    if int(fleet.get("owner", -1)) != 0:
        reason = "Keine eigene Flotte"
    elif int(fleet.get("destination", -1)) >= 0:
        reason = "Flotte unterwegs"
    elif origin_id == target:
        reason = "Bereits vor Ort"
    elif separation > limit:
        reason = "Außerhalb der Reichweite"
    return {"allowed": reason == "", "reason": reason, "distance": separation, "eta": maxi(1, ceili(separation / 70.0) - int(GalaxyStrategy.fleet_command_bonuses(world)["travel_reduction"])), "range": limit}

static func survey_preview(world: Dictionary, target: int) -> Dictionary:
    if target < 0 or target >= world.get("stars", []).size():
        return {"allowed": false, "reason": "Ungültiges Ziel"}
    if world.get("known", []).has(target):
        return {"allowed": false, "reason": "Bereits kartografiert"}
    for fleet in world.get("fleets", []):
        if int(fleet.get("owner", -1)) != 0 or int(fleet.get("destination", -1)) >= 0:
            continue
        var origin_id := int(fleet.get("location", -1))
        if origin_id >= 0 and origin_id < world["stars"].size() and distance(world["stars"][origin_id], world["stars"][target]) <= (190.0 if str(world.get("fleet_command", {}).get("order", "hold")) == "patrol" else 170.0):
            return {"allowed": true, "reason": ""}
    return {"allowed": false, "reason": "Keine freie Flotte in 170 Karteneinheiten"}

static func explore(world: Dictionary, target: int) -> bool:
    prepare(world)
    if target < 0 or target >= world["stars"].size():
        return false
    if world["known"].has(target):
        return false
    if not bool(survey_preview(world, target)["allowed"]):
        return false
    var star: Dictionary = world["stars"][target]
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
    var preview: Dictionary = route_preview(world, target)
    if not bool(preview["allowed"]):
        return false
    var fleet: Dictionary = world["fleets"][0]
    var destination: Dictionary = world["stars"][target]
    fleet["destination"] = target
    fleet["eta"] = int(preview["eta"])
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

# Specialised research consumes finite science and follows explicit
# prerequisites; the aggregate level remains for legacy milestones.
# Only laboratories in player-owned systems count as research infrastructure.
static func research_labs(world: Dictionary) -> int:
    var labs := 0
    for key in world.get("buildings", {}).keys():
        var sid := int(key)
        if sid >= 0 and sid < world["stars"].size() and int(world["stars"][sid]["owner"]) == 0:
            labs += maxi(0, int(world["buildings"][key].get("lab", 0)))
    for key in world.get("planet_colonies", {}).keys():
        var parts := str(key).split(":")
        if parts.size() != 2:
            continue
        var sid := int(parts[0])
        if sid >= 0 and sid < world["stars"].size() and int(world["stars"][sid]["owner"]) == 0:
            labs += maxi(0, int(world["planet_colonies"][key].get("buildings", {}).get("lab", 0)))
    return labs

static func technology_bonuses(world: Dictionary) -> Dictionary:
    prepare(world)
    var levels: Dictionary = world["research_fields"]
    return {"fleet_range": int(levels.get("propulsion", 0)) * 12,
        "industry_alloys": int(levels.get("industry", 0)) * research_labs(world),
        "society_stability": int(levels.get("society", 0))}

# Ancient discoveries supply a one-time insight for a matching research field.
# A discipline can never be awarded twice, including after save/load.
static func register_archaeological_insight(world: Dictionary, discipline: String) -> bool:
    prepare(world)
    var mapping := {
        "Sternensegel": "propulsion", "Gravitationsarchitektur": "propulsion",
        "Traumkartografie": "propulsion", "Chronometrie": "propulsion",
        "Sternenmetallurgie": "industry", "Nebelchemie": "industry",
        "Dunkelmaterie-Forschung": "industry", "Resonanztechnik": "industry",
        "Biotechnologie": "society", "Symbiotische Ökologie": "society",
        "Quantenkommunikation": "society", "Präkognitive Sensorik": "society"}
    if not mapping.has(discipline):
        return false
    for discovery in world["research_breakthroughs"]:
        if str(discovery.get("discipline", "")) == discipline:
            return false
    var field: String = mapping[discipline]
    world["research_insights"][field] = int(world["research_insights"].get(field, 0)) + 1
    world["research_breakthroughs"].append({"year": int(world["tick"]),
        "discipline": discipline, "field": field, "consumed": false})
    world["history"].append("Archäologischer Durchbruch: %s erschliesst %s-Forschung." % [discipline, field])
    return true

static func research_preview(world: Dictionary, field: String) -> Dictionary:
    prepare(world)
    if not ["propulsion", "industry", "society"].has(field):
        return {"allowed": false, "reason": "Unbekanntes Forschungsgebiet", "cost": 0}
    var levels: Dictionary = world["research_fields"]
    var level := int(levels.get(field, 0))
    var base_cost := 25 + level * 20
    var insight := int(world["research_insights"].get(field, 0)) > 0
    var cost := maxi(10, base_cost - (10 if insight else 0))
    var prerequisite := ""
    if field == "propulsion" and level >= 1 and int(levels.get("industry", 0)) < 1:
        prerequisite = "Industrie Stufe 1"
    elif field == "industry" and level >= 1 and int(levels.get("society", 0)) < 1:
        prerequisite = "Gesellschaft Stufe 1"
    elif field == "society" and level >= 1 and int(levels.get("propulsion", 0)) < 1:
        prerequisite = "Antrieb Stufe 1"
    var labs_required := maxi(0, level)
    var labs_available := research_labs(world)
    if prerequisite == "" and labs_available < labs_required:
        prerequisite = "Forschungslabore %d/%d" % [labs_available, labs_required]
    var allowed := prerequisite == "" and int(world["science"]) >= cost
    var reason := ("Voraussetzung: " + prerequisite) if prerequisite != "" else ("Nicht genug Forschungspunkte" if int(world["science"]) < cost else "")
    return {"allowed": allowed, "reason": reason, "cost": cost, "level": level}

static func start_research(world: Dictionary, field: String = "propulsion") -> bool:
    var preview: Dictionary = research_preview(world, field)
    if not bool(preview["allowed"]):
        return false
    world["science"] = int(world["science"]) - int(preview["cost"])
    if int(world["research_insights"].get(field, 0)) > 0:
        world["research_insights"][field] = int(world["research_insights"][field]) - 1
        for breakthrough in world["research_breakthroughs"]:
            if str(breakthrough.get("field", "")) == field and not bool(breakthrough.get("consumed", false)):
                breakthrough["consumed"] = true
                break
    world["research_fields"][field] = int(world["research_fields"][field]) + 1
    world["research_level"] = int(world["research_level"]) + 1
    world["research_history"].append({"year": int(world["tick"]), "field": field,
        "level": int(world["research_fields"][field]), "cost": int(preview["cost"])})
    world["history"].append("Forschungsdurchbruch: %s Stufe %d." % [field, int(world["research_fields"][field])])
    return true

# Civilian academic exchange requires laboratories and a ratified trade pact.
# It grants science, not free technology levels, and cannot operate during war.
static func settle_research_exchange(world: Dictionary) -> void:
    prepare(world)
    var labs := research_labs(world)
    var partners := 0
    for rival_id in world.get("trade_pacts", []):
        if world.get("contacts", []).has(rival_id) and not world.get("wars", []).has(rival_id) and not world.get("trade_embargoes", []).has(rival_id):
            partners += 1
    var grant := mini(12, labs * mini(3, partners))
    world["science"] = int(world["science"]) + grant
    world["research_exchange_ledger"] = {"year": int(world.get("tick", 0)),
        "laboratories": labs, "eligible_partners": partners, "science_granted": grant}

static func tick(world: Dictionary) -> void:
    prepare(world)
    GalaxyModel.advance(world)
    settle_research_exchange(world)
    GalaxyLore.tick(world)
    _automated_survey(world)
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

# Optional automation uses the existing exploration range and player fleet.
# It does not reveal distant systems or ignore the exploration rules.
static func _automated_survey(world: Dictionary) -> void:
    if not bool(world.get("auto_survey", false)) or int(world["tick"]) % 2 != 0:
        return
    if str(world.get("pending_event", "")) != "":
        return
    var best_id := -1
    var best_distance := INF
    for fleet in world["fleets"]:
        if int(fleet["owner"]) != 0 or int(fleet["destination"]) >= 0:
            continue
        var origin: Dictionary = world["stars"][int(fleet["location"])]
        for star in world["stars"]:
            var target := int(star["id"])
            if world["known"].has(target):
                continue
            var separation := distance(origin, star)
            if separation <= 170.0 and separation < best_distance:
                best_distance = separation
                best_id = target
    if best_id >= 0:
        explore(world, best_id)

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
    if kind in ["ancient_signal", "ancient_echo", "ancient_awakening"]:
        GalaxyLore.resolve(world, kind, option)
        world["event_counter"] = int(world["event_counter"]) + 1
        return
    if kind == "political_crisis":
        if option == 0:
            world["credits"] = maxi(0, int(world["credits"]) - 45)
            world["stability"] = mini(100, int(world["stability"]) + 22)
            world["history"].append("Politische Krise: Sozialprogramm finanziert; Unruhen beruhigt.")
        else:
            world["credits"] = int(world["credits"]) + 20
            world["stability"] = maxi(0, int(world["stability"]) - 12)
            world["history"].append("Politische Krise: Proteste niedergeschlagen; Bevölkerung radikalisiert.")
    elif kind == "colonies":
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
