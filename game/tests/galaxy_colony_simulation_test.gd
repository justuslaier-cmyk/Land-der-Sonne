extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 271828
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    if not GalaxyStrategy.settle_planet(world, 0, 1):
        _fail("Capital colony creation failed")
        return
    var key := GalaxyStrategy.planet_key(0, 1)
    var colony: Dictionary = world["planet_colonies"][key]
    colony["capacity"] = 8
    colony["environmental_pressure"] = 0
    colony["population"] = 1
    world["planet_colonies"][key] = colony
    world["tick"] = 5
    GalaxyStrategy.advance_colonies(world)
    if int(world["planet_colonies"][key]["population"]) != 2:
        _fail("Colony failed to grow under capacity")
        return
    world["tick"] = 6
    GalaxyStrategy.advance_colonies(world)
    if int(world["planet_colonies"][key]["population"]) != 2:
        _fail("Colony grew outside growth interval")
        return
    colony = world["planet_colonies"][key]
    colony["environmental_pressure"] = 100
    colony["population"] = 8
    world["planet_colonies"][key] = colony
    if GalaxyStrategy.colony_capacity(colony) != 3:
        _fail("Pollution did not reduce carrying capacity")
        return
    if GalaxyStrategy.colony_upkeep(world) != 4:
        _fail("Pollution upkeep mismatch")
        return
    GalaxyStrategy.advance_colonies(world)
    if int(world["planet_colonies"][key]["population"]) != 7:
        _fail("Overcrowded colony failed to shrink")
        return
    var forecast: Dictionary = GalaxyStrategy.income_forecast(world)
    colony = world["planet_colonies"][key]
    colony["environmental_pressure"] = 0
    world["planet_colonies"][key] = colony
    var clean: Dictionary = GalaxyStrategy.income_forecast(world)
    if int(clean["credits"]) - int(forecast["credits"]) != 4:
        _fail("Forecast did not account for pollution upkeep")
        return
    var replay: Dictionary = world.duplicate(true)
    GalaxyStrategy.advance_colonies(world)
    GalaxyStrategy.advance_colonies(replay)
    if JSON.stringify(world["planet_colonies"]) != JSON.stringify(replay["planet_colonies"]):
        _fail("Colony simulation is nondeterministic")
        return
    print("GALAXY_COLONY_SIMULATION_PASS: growth, ecological cap, upkeep, forecast and replay")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
