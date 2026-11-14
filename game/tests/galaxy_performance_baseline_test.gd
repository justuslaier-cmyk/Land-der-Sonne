extends SceneTree

# Reproducible baseline, not a hard FPS or release-performance acceptance.
func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 20261112
    settings["size"] = 250
    settings["ai_count"] = 20
    var started := Time.get_ticks_msec()
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    var generation_ms := Time.get_ticks_msec() - started
    started = Time.get_ticks_msec()
    for i in range(30):
        GalaxyStrategy.tick(world)
    var simulation_ms := Time.get_ticks_msec() - started
    var errors := GalaxyContracts.errors(world)
    if not errors.is_empty():
        push_error("GALAXY_PERFORMANCE_FAILURE: " + str(errors))
        quit(1)
        return
    print("GALAXY_PERFORMANCE_BASELINE: stars=250 ai=20 years=30 generation_ms=%d simulation_ms=%d tick=%d" % [generation_ms, simulation_ms, int(world["tick"])])
    quit(0)
