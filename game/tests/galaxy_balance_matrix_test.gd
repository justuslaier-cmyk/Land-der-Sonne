extends SceneTree

# P5.1: crossed seed × strategy × difficulty experiment with resource/war/endgame telemetry.
# No global randomness: every run is seeded and deterministic; all actions pay normal costs.
const SEEDS := [22071, 45199, 87331]
const YEARS := 85
const STRATEGIES := ["industry", "research", "welfare"]
const CHECKPOINTS := [20, 50, 85]

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    for difficulty in range(3):
        if GalaxyAI.action_interval(difficulty, "expansion") != [9, 6, 4][difficulty]:
            _fail("Expansion difficulty cadence invalid")
            return
        if GalaxyAI.action_interval(difficulty, "recruitment") != [5, 3, 4][difficulty]:
            _fail("Recruitment difficulty cadence invalid")
            return
    var matrix: Array = []
    var fingerprints: Dictionary = {}
    var difficulty_pressure := [0, 0, 0]
    var distinct_strategies := 0
    var total_started := Time.get_ticks_msec()
    for seed_value in SEEDS:
        for difficulty in range(3):
            var distinct: Dictionary = {}
            for strategy_name in STRATEGIES:
                var cfg := GalaxyModel.defaults()
                cfg["seed"] = seed_value
                cfg["size"] = 75
                cfg["ai_count"] = 5
                cfg["difficulty"] = difficulty
                var world := GalaxyModel.generate(cfg, GalaxyModel.empire_defaults())
                GalaxyStrategy.prepare(world)
                match strategy_name:
                    "industry":
                        if not GalaxyStrategy.set_policy(world, 0, 1):
                            _fail("Industry strategy rejected")
                            return
                    "research":
                        if not GalaxyStrategy.set_policy(world, 1, 1):
                            _fail("Research strategy rejected")
                            return
                    "welfare":
                        if not GalaxyStrategy.set_policy(world, 2, 0) or not GalaxyStrategy.set_welfare(world, 2):
                            _fail("Welfare strategy rejected")
                            return
                var snapshots: Array = []
                var start := Time.get_ticks_msec()
                for year in range(YEARS):
                    GalaxyStrategy.tick(world)
                    if not bool(world.get("society_audit", {}).get("valid", false)):
                        _fail("Society audit: %s/%d/%d/%d" % [strategy_name, seed_value, difficulty, year])
                        return
                    for field in ["credits", "science", "alloys", "stability"]:
                        if int(world[field]) < 0:
                            _fail("Negative stock: %s seed %d difficulty %d strategy %s year %d" % [field, seed_value, difficulty, strategy_name, year])
                            return
                    if str(world.get("pending_event", "")) != "":
                        GalaxySystems.resolve_event(world, 0)
                    if CHECKPOINTS.has(year + 1):
                        snapshots.append(_snapshot(world, year + 1))
                var errors: Array = GalaxyContracts.errors(world)
                if not errors.is_empty():
                    _fail("Contract errors: " + str(errors.slice(0, mini(3, errors.size()))))
                    return
                var result := _snapshot(world, YEARS)
                var key := "%d:%d:%s" % [seed_value, difficulty, strategy_name]
                var fingerprint := JSON.stringify(result)
                fingerprints[key] = fingerprint
                distinct[fingerprint] = true
                difficulty_pressure[difficulty] += int(result["ai_systems"])
                matrix.append({"seed": seed_value, "difficulty": difficulty, "strategy": strategy_name,
                    "duration_ms": Time.get_ticks_msec() - start, "checkpoints": snapshots,
                    "result": result})
            if distinct.size() > 1:
                distinct_strategies += 1
    if matrix.size() != 27 or distinct_strategies < 6:
        _fail("Insufficient crossed matrix or strategy differentiation")
        return
    # Same starting seeds and resources, different decision cadence.
    # These are observed diagnostics, not an assumption of strict monotonic outcomes.
    var replay_cfg := GalaxyModel.defaults()
    replay_cfg["seed"] = SEEDS[0]
    replay_cfg["size"] = 75
    replay_cfg["ai_count"] = 5
    replay_cfg["difficulty"] = 1
    var replay := GalaxyModel.generate(replay_cfg, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(replay)
    GalaxyStrategy.set_policy(replay, 1, 1)
    for year in range(YEARS):
        GalaxyStrategy.tick(replay)
        if str(replay.get("pending_event", "")) != "":
            GalaxySystems.resolve_event(replay, 0)
    if JSON.stringify(_snapshot(replay, YEARS)) != fingerprints["%d:1:research" % SEEDS[0]]:
        _fail("Matched-seed deterministic replay mismatch")
        return
    print("GALAXY_BALANCE_MATRIX_PASS: 27 scenarios, %d years each, differentiated blocks %d/9, AI territory by difficulty %s, total_ms %d" % [YEARS, distinct_strategies, str(difficulty_pressure), Time.get_ticks_msec() - total_started])
    print("GALAXY_BALANCE_MATRIX_DATA: " + JSON.stringify(matrix))
    quit(0)

func _snapshot(world: Dictionary, year: int) -> Dictionary:
    var player_systems := 0
    var ai_systems := 0
    for star in world["stars"]:
        var owner := int(star["owner"])
        if owner == 0:
            player_systems += 1
        elif owner > 0:
            ai_systems += 1
    var ai_fleet_strength := 0
    for fleet in world.get("ai_fleets", []):
        ai_fleet_strength += int(fleet.get("strength", 0))
    var ai_research := 0
    for key in world.get("ai_research_fields", {}).keys():
        for field in ["industry", "propulsion", "society"]:
            ai_research += int(world["ai_research_fields"][key].get(field, 0))
    return {"year": year, "credits": int(world["credits"]), "science": int(world["science"]),
        "alloys": int(world["alloys"]), "stability": int(world["stability"]),
        "player_systems": player_systems, "ai_systems": ai_systems,
        "ai_fleet_strength": ai_fleet_strength, "ai_research": ai_research,
        "wars": world.get("wars", []).size(), "milestones": world.get("milestones", []).size(),
        "crises": world.get("crisis_history", []).size(),
        "civilian_approval": int(world.get("civilian_approval", 50))}

func _fail(message: String) -> void:
    push_error("GALAXY_BALANCE_MATRIX_FAILURE: " + message)
    quit(1)
