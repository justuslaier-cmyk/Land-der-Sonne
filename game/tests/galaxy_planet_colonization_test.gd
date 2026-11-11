extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 271828
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    var system: Dictionary = GalaxyCelestials.generate(int(world["settings"]["seed"]), world["stars"][0])
    var replay: Dictionary = GalaxyCelestials.generate(int(world["settings"]["seed"]), world["stars"][0])
    if JSON.stringify(system) != JSON.stringify(replay):
        _fail("Planet descriptors are not deterministic")
        return
    for planet in system["planets"]:
        if str(planet.get("climate", "")).is_empty() or str(planet.get("ecology", "")).is_empty():
            _fail("Missing climate or ecology")
            return
        if int(planet["environmental_pressure"]) < 0 or int(planet["environmental_pressure"]) > 100:
            _fail("Environmental pressure outside range")
            return
        if bool(planet["habitable"]) and bool(planet["terraformable"]):
            _fail("Habitable planet flagged for terraforming")
            return
    var target := 1
    var before := int(world["credits"])
    if not GalaxyStrategy.settle_planet(world, 0, target):
        _fail("Cannot colonize guaranteed habitable capital planet")
        return
    var colony: Dictionary = GalaxyStrategy.planet_colony(world, 0, target)
    if int(colony["capacity"]) < 2 or int(colony["environmental_pressure"]) != int(system["planets"][target]["environmental_pressure"]):
        _fail("Colony did not persist environmental baseline and carrying capacity")
        return
    if int(world["credits"]) != before - 50:
        _fail("Colonization cost mismatch")
        return
    if GalaxyStrategy.settle_planet(world, 0, target):
        _fail("Duplicate colony accepted")
        return
    var baseline := int(colony["environmental_pressure"])
    if not GalaxyStrategy.construct_planet(world, 0, target, "mine"):
        _fail("Could not construct mine")
        return
    colony = GalaxyStrategy.planet_colony(world, 0, target)
    if int(colony["environmental_pressure"]) != mini(100, baseline + 6):
        _fail("Mining did not change environmental pressure")
        return
    if GalaxyStrategy.settle_planet(world, -1, 0) or GalaxyStrategy.settle_planet(world, 0, 999):
        _fail("Invalid colonization target accepted")
        return
    print("GALAXY_PLANET_COLONIZATION_PASS: descriptors, costs, capacity and mining pressure")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
