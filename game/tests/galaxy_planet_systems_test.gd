extends SceneTree

func _initialize() -> void:
    var cases := 0
    var seen_classes: Dictionary = {}
    for seed in [17, 314159, 987654]:
        var settings := GalaxyModel.defaults()
        settings["seed"] = seed
        settings["size"] = 100
        settings["ai_count"] = 12
        var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
        var capitals: Array = [0]
        for rival in world["ai"]:
            capitals.append(int(rival["capital"]))
        for star in world["stars"]:
            var kind := int(star["kind"])
            if kind < 0 or kind > 6:
                _fail("Invalid stellar class")
                return
            seen_classes[kind] = true
            var a: Dictionary = GalaxyCelestials.generate(int(world["settings"]["seed"]), star)
            var b: Dictionary = GalaxyCelestials.generate(int(world["settings"]["seed"]), star)
            if JSON.stringify(a) != JSON.stringify(b):
                _fail("Nondeterministic planetary system")
                return
            if a["planets"].size() < 2 or a["planets"].size() > 9:
                _fail("Planet count out of range")
                return
            for i in range(a["planets"].size()):
                var planet: Dictionary = a["planets"][i]
                if int(planet["orbit"]) != i + 1 or int(planet["size"]) < 5 or int(planet["resources"]) < 1:
                    _fail("Invalid planet data")
                    return
                if planet["moons"].size() > 4:
                    _fail("Too many moons")
                    return
            if capitals.has(int(star["id"])):
                if not bool(star["habitable"]) or not bool(a["planets"][1]["habitable"]):
                    _fail("Capital without a habitable second planet")
                    return
            cases += 1
    if seen_classes.size() != 7:
        _fail("Not all seven stellar classes generated")
        return
    print("GALAXY_PLANET_SYSTEMS_PASS: %d systems, 7 stellar classes, valid capitals" % cases)
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
