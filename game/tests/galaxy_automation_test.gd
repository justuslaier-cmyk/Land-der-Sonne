extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 614299
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    if bool(world.get("auto_survey", true)):
        _fail("Exploration automation must default to manual")
        return
    var original: int = world["known"].size()
    GalaxySystems.tick(world)
    GalaxySystems.tick(world)
    if world["known"].size() != original:
        _fail("Manual exploration unexpectedly surveyed a star")
        return
    world["auto_survey"] = true
    var found_reachable := false
    for star in world["stars"]:
        if world["known"].has(int(star["id"])):
            continue
        if GalaxySystems.distance(world["stars"][0], star) <= 170.0:
            found_reachable = true
            break
    GalaxySystems.tick(world)
    GalaxySystems.tick(world)
    if found_reachable and world["known"].size() <= original:
        _fail("Automated exploration failed to survey reachable system")
        return
    for id in world["known"]:
        if int(id) == 0:
            continue
        if GalaxySystems.distance(world["stars"][0], world["stars"][int(id)]) > 170.0:
            _fail("Automated survey ignored fleet range")
            return
    print("GALAXY_AUTOMATION_PASS")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
