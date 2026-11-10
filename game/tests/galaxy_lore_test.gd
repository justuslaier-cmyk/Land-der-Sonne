extends SceneTree

func _initialize() -> void:
    var world := GalaxyModel.generate(GalaxyModel.defaults(), GalaxyModel.empire_defaults())
    GalaxySystems.prepare(world)
    var original: Dictionary = world["ancient_history"].duplicate(true)
    var other := GalaxyModel.generate(GalaxyModel.defaults(), GalaxyModel.empire_defaults())
    GalaxySystems.prepare(other)
    if original != other["ancient_history"]:
        _fail("Ancient history not deterministic")
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
    if not bool(world["ancient_history"]["completed"]):
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
