extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 246810
    settings["ai_count"] = 4
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    if not world.has("culture") or world["ai_cultures"].size() != 4:
        _fail("Player or rival cultures missing")
        return
    var snapshot := JSON.stringify(world["culture"])
    GalaxyStrategy.prepare(world)
    if JSON.stringify(world["culture"]) != snapshot:
        _fail("Repeated preparation reset culture")
        return
    var first: Dictionary = world["culture"]
    for year in range(1, 42):
        GalaxyIdentity.culture_tick(first, world["empire"], 75, 80, year)
    if int(first["generation"]) != 2 or first["history"].size() != 2:
        _fail("Cultural generations or historical memory incorrect")
        return
    for field in ["tradition", "openness", "solidarity", "commercialism"]:
        if int(first[field]) < 0 or int(first[field]) > 100:
            _fail("Cultural dimension outside bounds")
            return
    var original := JSON.stringify(first)
    var replay := GalaxyIdentity.culture_defaults(world["empire"])
    for year in range(1, 42):
        GalaxyIdentity.culture_tick(replay, world["empire"], 75, 80, year)
    if JSON.stringify(replay) != original:
        _fail("Cultural development is nondeterministic")
        return
    var rival: Dictionary = world["ai"][0]
    var rival_culture: Dictionary = world["ai_cultures"][str(rival["id"])]
    var rival_before := JSON.stringify(rival_culture)
    GalaxyIdentity.culture_tick(rival_culture, rival, 10, 20, 1)
    if JSON.stringify(rival_culture) == rival_before:
        _fail("Rival culture did not evolve")
        return
    if not GalaxyModel.save_game(world):
        _fail("Culture save failed")
        return
    var loaded := GalaxyModel.load_game()
    if JSON.stringify(loaded["culture"]) != JSON.stringify(world["culture"]) or JSON.stringify(loaded["ai_cultures"]) != JSON.stringify(world["ai_cultures"]):
        _fail("Cultural state did not survive save/load")
        return
    print("GALAXY_CULTURE_PASS: independent cultures, generational memory and persistence")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
