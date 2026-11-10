extends SceneTree

func _initialize() -> void:
    var world := GalaxyModel.generate(GalaxyModel.defaults(), GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    var system := GalaxyCelestials.generate(int(world["settings"]["seed"]), world["stars"][0])
    var index := -1
    for i in range(system["planets"].size()):
        if bool(system["planets"][i]["habitable"]):
            index = i
            break
    if index < 0:
        _fail("Home system must have habitable world")
        return
    var key := GalaxyStrategy.planet_key(0, index)
    if not GalaxyStrategy.settle_planet(world, 0, index):
        _fail("Could not settle valid home planet")
        return
    if GalaxyStrategy.settle_planet(world, 0, index):
        _fail("Duplicate colony accepted")
        return
    if GalaxyStrategy.construct_planet(world, 0, index, "invalid"):
        _fail("Invalid building accepted")
        return
    world["credits"] = 1000
    if not GalaxyStrategy.construct_planet(world, 0, index, "mine"):
        _fail("Could not build mine")
        return
    var before := int(world["credits"])
    GalaxyStrategy.tick(world)
    if int(world["credits"]) <= before:
        _fail("Mine did not produce credits")
        return
    if not world["planet_colonies"].has(key):
        _fail("Colony state lost")
        return
    print("GALAXY_PLANET_ECONOMY_PASS")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
