extends SceneTree

# P5.2: measured 250-star / 20-rival campaign runs, save/resume and memory.
# All timings are runner-specific observations, not target-hardware guarantees.
const SEEDS := [20261112, 731927, 110317]
const YEARS := 180
const SLOT := 4

func _initialize() -> void:
    var results: Array = []
    for seed_value in SEEDS:
        var cfg := GalaxyModel.defaults()
        cfg["seed"] = seed_value
        cfg["size"] = 250
        cfg["ai_count"] = 20
        var start_us := Time.get_ticks_usec()
        var world := GalaxyModel.generate(cfg, GalaxyModel.empire_defaults())
        GalaxyStrategy.prepare(world)
        var generation_us := Time.get_ticks_usec() - start_us
        if world["stars"].size() != 250 or world["ai"].size() != 20:
            _fail("Invalid maximum galaxy setup")
            return
        var continuous := world.duplicate(true)
        var resumed := world.duplicate(true)
        var times: Array = []
        var mem_peak := OS.get_static_memory_usage()
        var checkpoints: Array = []
        for year in range(YEARS):
            start_us = Time.get_ticks_usec()
            GalaxyStrategy.tick(continuous)
            if str(continuous.get("pending_event", "")) != "":
                GalaxySystems.resolve_event(continuous, 0)
            times.append(Time.get_ticks_usec() - start_us)
            if year < YEARS / 2:
                GalaxyStrategy.tick(resumed)
                if str(resumed.get("pending_event", "")) != "":
                    GalaxySystems.resolve_event(resumed, 0)
            if (year + 1) % 30 == 0:
                var problems: Array = GalaxyContracts.errors(continuous)
                if not problems.is_empty():
                    _fail("Contract seed %d year %d: %s" % [seed_value, year + 1, str(problems)])
                    return
                checkpoints.append({"year": year + 1, "credits": int(continuous["credits"]),
                    "systems": _owned(continuous), "elapsed_tick_us": times[times.size() - 1]})
                mem_peak = maxi(mem_peak, OS.get_static_memory_usage())
        if not GalaxyModel.save_game(resumed, SLOT):
            _fail("Could not save maximum galaxy")
            return
        var path := GalaxyModel.slot_path(SLOT)
        var save_bytes := FileAccess.get_file_as_bytes(path).size()
        var loaded := GalaxyModel.load_game(SLOT)
        if loaded.is_empty() or JSON.stringify(loaded) != JSON.stringify(resumed):
            _fail("Large save did not restore exact state")
            return
        for year in range(YEARS / 2, YEARS):
            GalaxyStrategy.tick(loaded)
            if str(loaded.get("pending_event", "")) != "":
                GalaxySystems.resolve_event(loaded, 0)
        if JSON.stringify(loaded) != JSON.stringify(continuous):
            _fail("Save/resume diverged seed " + str(seed_value))
            return
        var sorted := times.duplicate()
        sorted.sort()
        var total_us := 0
        for duration in times:
            total_us += int(duration)
        results.append({"seed": seed_value, "stars": 250, "ai": 20, "years": YEARS,
            "generation_ms": float(generation_us) / 1000.0,
            "mean_tick_ms": float(total_us) / float(times.size()) / 1000.0,
            "p95_tick_ms": float(sorted[int(ceil(float(sorted.size()) * 0.95)) - 1]) / 1000.0,
            "max_tick_ms": float(sorted[sorted.size() - 1]) / 1000.0,
            "memory_peak_bytes": mem_peak, "save_bytes": save_bytes,
            "checkpoints": checkpoints})
        for suffix in ["", ".bak", ".previous", ".tmp"]:
            var full := path + suffix
            if FileAccess.file_exists(full):
                DirAccess.remove_absolute(ProjectSettings.globalize_path(full))
    print("GALAXY_MAX_SCALE_CAMPAIGN_PASS: " + JSON.stringify(results))
    quit(0)

func _owned(world: Dictionary) -> int:
    var result := 0
    for star in world["stars"]:
        if int(star["owner"]) == 0:
            result += 1
    return result

func _fail(reason: String) -> void:
    push_error("GALAXY_MAX_SCALE_CAMPAIGN_FAILURE: " + reason)
    quit(1)
