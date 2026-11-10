extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 271828
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxySystems.prepare(world)
    var original: Dictionary = world["ancient_history"].duplicate(true)
    var other := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxySystems.prepare(other)
    if original != other["ancient_history"]:
        _fail("Ancient history not deterministic")
        return
    if world["ancient_sites"].size() < 3:
        _fail("Missing independent fallen cultures")
        return
    var site := int(world["ancient_sites"][0]["star_id"])
    if not GalaxyLore.inspect(world, site) or world["artifacts"].size() != 1:
        _fail("Ancient artifact discovery failed")
        return
    world["science"] = 50
    if not GalaxyLore.analyze_artifact(world, 0):
        _fail("Artifact analysis failed")
        return
    if GalaxyLore.analyze_artifact(world, 0):
        _fail("Artifact analysis duplicated")
        return
    if world["ancient_technology"].is_empty():
        _fail("Ancient technology was not unlocked")
        return
    if GalaxyLore.inspect(world, site):
        _fail("Artifact discovered twice")
        return
    var ruin := int(original["ruins"][0])
    if not GalaxyLore.inspect(world, ruin) or str(world["pending_event"]) != "ancient_signal":
        _fail("Ruins did not trigger opening event")
        return
    GalaxySystems.resolve_event(world, 0)
    if int(world["ancient_history"]["stage"]) != 2:
        _fail("Story branch not persisted")
        return
    GalaxyLore.tick(world)
    GalaxyLore.tick(world)
    if str(world["pending_event"]) != "ancient_echo":
        _fail("Follow-up event missing")
        return
    GalaxySystems.resolve_event(world, 0)
    for i in range(3):
        GalaxyLore.tick(world)
    if str(world["pending_event"]) != "ancient_awakening":
        _fail("Third story chapter did not awaken")
        return
    GalaxySystems.resolve_event(world, 0)
    if not bool(world["ancient_history"]["completed"]) or int(world["ancient_history"]["final_choice"]) != 0:
        _fail("Story did not conclude")
        return
    if GalaxyLore.inspect(world, ruin):
        _fail("Ruins rediscovered twice")
        return
    print("GALAXY_LORE_PASS")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
