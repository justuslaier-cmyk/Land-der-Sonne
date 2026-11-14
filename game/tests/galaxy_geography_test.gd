extends SceneTree

func _initialize() -> void:
    var cases := 0
    for size in [20, 60, 250]:
        for shape in range(3):
            for seed in [17, 314159]:
                var settings := GalaxyModel.defaults()
                settings["size"] = size
                settings["ai_count"] = mini(20, size / 5)
                settings["shape"] = shape
                settings["seed"] = seed
                var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
                var lanes: Array = world["lanes"]
                if not GalaxyRoutes.valid(world["stars"], lanes):
                    _fail("Disconnected or invalid lane graph: %s/%s/%s" % [size, shape, seed])
                    return
                if JSON.stringify(lanes) != JSON.stringify(GalaxyRoutes.build(world["stars"])):
                    _fail("Nondeterministic lane generation")
                    return
                var legacy: Dictionary = world.duplicate(true)
                legacy.erase("lanes")
                GalaxySystems.prepare(legacy)
                if JSON.stringify(legacy["lanes"]) != JSON.stringify(lanes):
                    _fail("Legacy save did not reconstruct identical lanes")
                    return
                var ids: Dictionary = {}
                for star in world["stars"]:
                    var id := int(star["id"])
                    if ids.has(id):
                        _fail("Duplicate star ID")
                        return
                    ids[id] = true
                    if absf(float(star["x"])) > 350.0 or absf(float(star["y"])) > 350.0:
                        _fail("Galaxy star outside expected map extent")
                        return
                cases += 1
    print("GALAXY_GEOGRAPHY_PASS: %d scaled deterministic connected galaxies" % cases)
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
