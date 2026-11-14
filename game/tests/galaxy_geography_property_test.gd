extends SceneTree

# Package C1: seed replay, star IDs, homeworld and AI-capital invariants.
func _initialize() -> void:
    var count := 0
    for shape in range(3):
        for size in [20, 60, 120, 250]:
            for seed in [1, 1729, 20261112]:
                var settings := GalaxyModel.defaults()
                settings["shape"] = shape
                settings["size"] = size
                settings["seed"] = seed
                settings["ai_count"] = mini(20, size / 5)
                var first := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
                var second := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
                if JSON.stringify(first) != JSON.stringify(second):
                    _fail("seed replay differs: %d %d %d" % [shape, size, seed])
                    return
                if first["stars"].size() != size or first["ai"].size() != settings["ai_count"]:
                    _fail("star or AI count mismatch")
                    return
                if int(first["stars"][0]["owner"]) != 0 or not bool(first["stars"][0]["habitable"]):
                    _fail("player capital not habitable")
                    return
                var occupied := {0: true}
                for i in range(size):
                    if int(first["stars"][i]["id"]) != i:
                        _fail("non-contiguous star IDs")
                        return
                for rival in first["ai"]:
                    var capital: int = int(rival["capital"])
                    if capital < 1 or capital >= size or occupied.has(capital):
                        _fail("duplicate or invalid AI capital")
                        return
                    occupied[capital] = true
                    if int(first["stars"][capital]["owner"]) != int(rival["id"]) or not bool(first["stars"][capital]["habitable"]):
                        _fail("AI capital ownership or habitability")
                        return
                count += 1
    print("GALAXY_GEOGRAPHY_PROPERTY_PASS: %d deterministic seed/shape/size configurations" % count)
    quit(0)

func _fail(reason: String) -> void:
    push_error("GALAXY_GEOGRAPHY_PROPERTY_FAILURE: " + reason)
    quit(1)
