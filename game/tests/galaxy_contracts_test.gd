extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 314159
    settings["size"] = 80
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    if not _check(world, "initial world"):
        return
    var second := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(second)
    for year in range(12):
        GalaxyStrategy.tick(world)
        GalaxyStrategy.tick(second)
        if not _check(world, "year " + str(year + 1)):
            return
        if JSON.stringify(world) != JSON.stringify(second):
            _fail("Same seed and same commands diverged in year " + str(year + 1))
            return
    var broken: Dictionary = world.duplicate(true)
    broken["stars"][0]["owner"] = 999
    if GalaxyContracts.errors(broken).is_empty():
        _fail("Invalid owner not detected")
        return
    broken = world.duplicate(true)
    broken["civilian_worlds"]["0"]["goods"] = -1
    if GalaxyContracts.errors(broken).is_empty():
        _fail("Negative goods not detected")
        return
    if not GalaxyModel.save_game(world):
        _fail("Save failed")
        return
    var loaded := GalaxyModel.load_game()
    if not _check(loaded, "loaded world"):
        return
    if JSON.stringify(loaded) != JSON.stringify(world):
        _fail("Save roundtrip changed simulation state")
        return
    print("GALAXY_CONTRACTS_PASS: world integrity, deterministic ticks, negative tests, persistence")
    quit(0)

func _check(world: Dictionary, context: String) -> bool:
    var problems: Array = GalaxyContracts.errors(world)
    if not problems.is_empty():
        _fail(context + ": " + str(problems))
        return false
    return true

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
