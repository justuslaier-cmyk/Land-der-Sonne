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
    # The opposing archaeological decisions must also complete and persist.
    var alternate := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxySystems.prepare(alternate)
    if not GalaxyLore.inspect(alternate, ruin):
        _fail("Alternate story discovery failed")
        return
    GalaxySystems.resolve_event(alternate, 1)
    GalaxyLore.tick(alternate)
    GalaxyLore.tick(alternate)
    GalaxySystems.resolve_event(alternate, 1)
    for i in range(3):
        GalaxyLore.tick(alternate)
    if str(alternate["pending_event"]) != "ancient_awakening":
        _fail("Alternate story finale missing")
        return
    var previous_alloys := int(alternate.get("alloys", 0))
    GalaxySystems.resolve_event(alternate, 1)
    if not bool(alternate["ancient_history"]["completed"]) or int(alternate["ancient_history"]["final_choice"]) != 1:
        _fail("Alternate story did not conclude")
        return
    if int(alternate["alloys"]) != previous_alloys + 35 or str(alternate["pending_event"]) != "":
        _fail("Alternate story reward or event cleanup failed")
        return
    print("GALAXY_LORE_PASS")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
