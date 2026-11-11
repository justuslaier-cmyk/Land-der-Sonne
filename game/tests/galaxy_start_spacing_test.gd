extends SceneTree

func _initialize() -> void:
    for shape in range(3):
        for seed in [1, 17, 314159, 1234567]:
            var settings := GalaxyModel.defaults()
            settings["size"] = 100
            settings["ai_count"] = 12
            settings["shape"] = shape
            settings["seed"] = seed
            var empire := GalaxyModel.empire_defaults()
            var world := GalaxyModel.generate(settings, empire)
            var repeat := GalaxyModel.generate(settings, empire)
            if JSON.stringify(world) != JSON.stringify(repeat):
                _fail("Galaxy seed replay diverged")
                return
            if GalaxyContracts.errors(world).size() > 0:
                _fail("Invalid generated world: " + str(GalaxyContracts.errors(world)))
                return
            if not bool(world["stars"][0]["habitable"]) or int(world["stars"][0]["owner"]) != 0:
                _fail("Player capital not habitable or unowned")
                return
            var capitals: Array = [0]
            for rival in world["ai"]:
                var capital := int(rival["capital"])
                if capitals.has(capital) or not bool(world["stars"][capital]["owner"] == int(rival["id"])):
                    _fail("Duplicate or invalid rival capital")
                    return
                capitals.append(capital)
            # Farthest-first invariant: at each step, the chosen capital is
            # the candidate with the greatest distance to its nearest prior capital.
            var selected: Array = [0]
            for rival in world["ai"]:
                var chosen := int(rival["capital"])
                var chosen_score := _nearest(world["stars"], chosen, selected)
                for candidate in range(1, world["stars"].size()):
                    if selected.has(candidate):
                        continue
                    if _nearest(world["stars"], candidate, selected) > chosen_score + 0.001:
                        _fail("Rival capital was not farthest-first")
                        return
                selected.append(chosen)
    print("GALAXY_START_SPACING_PASS: 12 fixed-seed galaxies across three shapes")
    quit(0)

func _nearest(stars: Array, candidate: int, selected: Array) -> float:
    var p := Vector2(float(stars[candidate]["x"]), float(stars[candidate]["y"]))
    var nearest := INF
    for index in selected:
        var star: Dictionary = stars[int(index)]
        nearest = minf(nearest, p.distance_squared_to(Vector2(float(star["x"]), float(star["y"]))))
    return nearest

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
