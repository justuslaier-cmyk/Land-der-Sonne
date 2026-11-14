extends SceneTree

const SEEDS := [22071, 45199, 87331]
const YEARS := 110

func _initialize() -> void:
    var total_started := Time.get_ticks_msec()
    var results: Array = []
    var differences := 0
    for seed_value in SEEDS:
        var scenario_results: Array = []
        for strategy_id in range(3):
            var settings := GalaxyModel.defaults()
            settings["seed"] = seed_value
            settings["size"] = 100
            settings["ai_count"] = 8
            var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
            GalaxyStrategy.prepare(world)
            var replay := world.duplicate(true)
            if strategy_id == 0:
                GalaxyStrategy.set_welfare(world, 2)
                GalaxyStrategy.set_welfare(replay, 2)
            elif strategy_id == 1:
                GalaxyStrategy.set_market_automation(world, true, 40)
                GalaxyStrategy.set_market_automation(replay, true, 40)
            else:
                GalaxyStrategy.set_propaganda(world, 2)
                GalaxyStrategy.set_propaganda(replay, 2)
            var started := Time.get_ticks_msec()
            for year in range(YEARS):
                world["tick"] = year
                replay["tick"] = year
                GalaxyStrategy.tick(world)
                GalaxyStrategy.tick(replay)
                if not bool(world.get("society_audit", {}).get("valid", false)):
                    _fail("Audit invalid: seed %d strategy %d year %d" % [seed_value, strategy_id, year])
                    return
                for key in ["credits", "science", "alloys", "stability"]:
                    if int(world[key]) != int(replay[key]):
                        _fail("Replay mismatch: seed %d strategy %d year %d %s" % [seed_value, strategy_id, year, key])
                        return
                    if int(world[key]) < 0:
                        _fail("Negative balance: seed %d strategy %d year %d %s" % [seed_value, strategy_id, year, key])
                        return
                if JSON.stringify(world.get("narrative_chronicle", [])) != JSON.stringify(replay.get("narrative_chronicle", [])):
                    _fail("Narrative replay mismatch")
                    return
                if str(world.get("pending_event", "")) != "":
                    GalaxySystems.resolve_event(world, 0)
                    GalaxySystems.resolve_event(replay, 0)
            var fingerprint := "%d/%d/%d/%d" % [int(world["credits"]), int(world["science"]), int(world["alloys"]), int(world["stability"])]
            scenario_results.append(fingerprint)
            results.append({"seed": seed_value, "strategy": strategy_id, "years": YEARS,
                "duration_ms": Time.get_ticks_msec() - started, "final": fingerprint,
                "chronicle": world.get("narrative_chronicle", []).size(),
                "milestones": world.get("milestones", []).size()})
            if not GalaxyContracts.errors(world).is_empty():
                _fail("Final contract invalid: seed %d strategy %d" % [seed_value, strategy_id])
                return
        if scenario_results[0] != scenario_results[1] or scenario_results[1] != scenario_results[2]:
            differences += 1
    if differences == 0:
        _fail("No policy-sensitive outcomes in matched-seed scenarios")
        return
    print("GALAXY_PACKAGE_H1_PASS: %d campaigns x %d years, matched-seed policy differences=%d; %d ms; %s" % [results.size(), YEARS, differences, Time.get_ticks_msec() - total_started, JSON.stringify(results)])
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_PACKAGE_H1_FAILURE: " + message)
    quit(1)
