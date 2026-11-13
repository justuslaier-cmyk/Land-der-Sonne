extends SceneTree

# A2: three seeded active player campaigns. All progress uses the public
# gameplay commands and ordinary GalaxyStrategy.tick; no world-state fixtures.
const CASES := [
    {"seed": 72119, "focus": 1, "victory": "exploration", "project": "orbital_archive"},
    {"seed": 82331, "focus": 2, "victory": "prosperity", "project": "unity_beacon"},
    {"seed": 93443, "focus": 0, "victory": "resilience", "project": "stellar_foundry"}
]
const YEARS := 210

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var records: Array = []
    for scenario in CASES:
        var settings := GalaxyModel.defaults()
        settings["seed"] = int(scenario["seed"])
        settings["size"] = 75
        settings["ai_count"] = 4
        settings["difficulty"] = 1
        var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
        GalaxyStrategy.prepare(world)
        if not GalaxyStrategy.set_policy(world, int(scenario["focus"]), 0):
            _fail("Policy failed")
            return
        if not GalaxyStrategy.construct(world, 0, "lab"):
            _fail("Initial laboratory not affordable")
            return
        var peak_colonies := 1
        var real_actions := {"exploration": 0, "movement": 0, "colonization": 0, "research": 0, "diplomacy": 0, "war": 0, "project": 0, "crisis": 0}
        var save_verified := false
        for year in range(YEARS):
            _resolve_pending(world)
            _take_actions(world, scenario, real_actions)
            GalaxyStrategy.tick(world)
            _resolve_pending(world)
            if year == 90:
                if not GalaxyModel.save_game(world, 4):
                    _fail("Checkpoint save failed")
                    return
                var loaded := GalaxyModel.load_game(4)
                if JSON.stringify(loaded) != JSON.stringify(world):
                    _fail("Checkpoint state mismatch")
                    return
                world = loaded
                save_verified = true
            var owned := 0
            for star in world["stars"]:
                if int(star["owner"]) == 0:
                    owned += 1
            peak_colonies = maxi(peak_colonies, owned)
            for field in ["credits", "science", "alloys", "stability"]:
                if int(world.get(field, -1)) < 0:
                    _fail("Negative stock: %s %d %d" % [field, int(scenario["seed"]), year])
                    return
            if not GalaxyContracts.errors(world).is_empty():
                _fail("Contract errors seed %d year %d: %s" % [int(scenario["seed"]), year, str(GalaxyContracts.errors(world).slice(0, 2))])
                return
        if not save_verified or real_actions["exploration"] < 20 or real_actions["movement"] < 2 or peak_colonies < 2 or real_actions["research"] < 3 or real_actions["project"] < 1:
            _fail("Incomplete active campaign: %s actions %s colonies %d" % [str(scenario["victory"]), str(real_actions), peak_colonies])
            return
        if not world["victory_paths"].has(str(scenario["victory"])):
            _fail("Natural victory not reached: %s actions %s state %s" % [str(scenario["victory"]), str(real_actions), str({"known": world["known"].size(), "owned": peak_colonies, "approval": world["civilian_approval"], "crises": world["galactic_crises_survived"], "projects": world["megaproject_completed"]})])
            return
        records.append({"seed": scenario["seed"], "victory": scenario["victory"], "actions": real_actions, "colonies": peak_colonies, "crises": world["galactic_crises_survived"], "completed": world["megaproject_completed"]})
    print("GALAXY_A2_ACTIVE_CAMPAIGNS_PASS: " + JSON.stringify(records))
    quit(0)

func _resolve_pending(world: Dictionary) -> void:
    for attempt in range(3):
        var event := str(world.get("pending_event", ""))
        if event.is_empty():
            return
        GalaxySystems.resolve_event(world, 0)

func _take_actions(world: Dictionary, scenario: Dictionary, actions: Dictionary) -> void:
    var fleet: Dictionary = world["fleets"][0]
    # Survey all reachable stars before advancing the fleet; real survey
    # range and knowledge restrictions are enforced by GalaxySystems.
    var surveyed := 0
    for star in world["stars"]:
        if surveyed >= 5:
            break
        var sid := int(star["id"])
        if bool(GalaxySystems.survey_preview(world, sid)["allowed"]) and GalaxySystems.explore(world, sid):
            surveyed += 1
            actions["exploration"] += 1
    if int(fleet["destination"]) < 0:
        var current := int(fleet["location"])
        if int(world["stars"][current]["owner"]) == -1 and bool(world["stars"][current]["habitable"]) and int(world["credits"]) >= 70:
            if GalaxyStrategy.colonize_system(world, current).is_empty():
                actions["colonization"] += 1
        var target := -1
        var best := INF
        for star in world["stars"]:
            var sid := int(star["id"])
            if sid == current or not world["known"].has(sid):
                continue
            if not bool(GalaxySystems.route_preview(world, sid)["allowed"]):
                continue
            var priority := 0.0
            if int(star["owner"]) == -1 and bool(star["habitable"]):
                priority = -300.0
            elif int(star["owner"]) == -1:
                priority = -100.0
            var dist := GalaxySystems.distance(world["stars"][current], star)
            var score := dist + priority
            if score < best:
                best = score
                target = sid
        if target >= 0 and actions["movement"] < 16 and GalaxySystems.move_fleet(world, target):
            actions["movement"] += 1
    if int(world["credits"]) >= 110 and GalaxySystems.research_labs(world) < 3:
        GalaxyStrategy.construct(world, 0, "lab")
    for field in ["industry", "society", "propulsion"]:
        if int(world["research_level"]) >= 5:
            break
        if GalaxySystems.start_research(world, field):
            actions["research"] += 1
            break
    if str(scenario["victory"]) == "prosperity":
        GalaxyStrategy.set_welfare(world, 2)
    if actions["project"] == 0 and int(world["research_level"]) >= 3 and GalaxyEndgame.start_project(world, str(scenario["project"])):
        actions["project"] += 1
    if str(scenario["victory"]) == "resilience":
        for rival in world["ai"]:
            if actions["war"] >= 2:
                break
            var id := int(rival["id"])
            if world["contacts"].has(id) and GalaxyStrategy.declare_war(world, id):
                actions["war"] += 1
        var crisis: Dictionary = world.get("galactic_crisis", {})
        if str(crisis.get("state", "")) == "active" and int(crisis.get("threat", 0)) > 0:
            if GalaxyEndgame.defend_crisis(world):
                actions["crisis"] += 1

func _fail(message: String) -> void:
    push_error("GALAXY_A2_ACTIVE_CAMPAIGNS_FAILURE: " + message)
    quit(1)
