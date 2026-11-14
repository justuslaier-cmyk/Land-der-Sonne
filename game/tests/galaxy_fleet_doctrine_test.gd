extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 915771
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    var base := GalaxyStrategy.fleet_attack_power(world)
    if not GalaxyStrategy.set_fleet_doctrine(world, "assault"):
        _fail("Cannot select assault doctrine")
        return
    if GalaxyStrategy.fleet_attack_power(world) != base + 6:
        _fail("Assault doctrine bonus not applied")
        return
    if GalaxyStrategy.set_fleet_doctrine(world, "invalid"):
        _fail("Invalid doctrine was accepted")
        return
    if not GalaxyStrategy.set_fleet_doctrine(world, "defense"):
        _fail("Cannot select defensive doctrine")
        return
    if GalaxyStrategy.fleet_attack_power(world) != base:
        _fail("Assault bonus leaked into defensive doctrine")
        return
    world["fleet_experience"] = 30
    if GalaxyStrategy.fleet_attack_power(world) != base + 8:
        _fail("Veteran experience bonus missing or uncapped")
        return
    if not GalaxyStrategy.set_fleet_doctrine(world, "exploration"):
        _fail("Cannot select exploration doctrine")
        return
    if world["fleet_doctrine"] != "exploration":
        _fail("Exploration doctrine not persisted")
        return
    print("GALAXY_FLEET_DOCTRINE_PASS")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
