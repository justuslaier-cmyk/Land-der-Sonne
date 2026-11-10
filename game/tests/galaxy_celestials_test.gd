extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    var empire := GalaxyModel.empire_defaults()
    var w := GalaxyModel.generate(settings, empire)
    var a := GalaxyCelestials.generate(int(settings["seed"]), w["stars"][0])
    var second := GalaxyCelestials.generate(int(settings["seed"]), w["stars"][0])
    if JSON.stringify(a) != JSON.stringify(second):
        _fail("Planetary generation is not deterministic")
        return
    if a["planets"].size() < 2 or a["planets"].size() > 9:
        _fail("Planet count out of bounds")
        return
    for planet in a["planets"]:
        if planet["moons"].size() > 4 or int(planet["resources"]) < 1:
            _fail("Invalid planet or moon")
            return
    print("GALAXY_CELESTIALS_PASS: deterministic stars, planets, moons and resources")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
