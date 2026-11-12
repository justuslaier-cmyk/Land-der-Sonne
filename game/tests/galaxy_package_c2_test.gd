extends SceneTree

# Package C2: legal-range multihop reachability, fleet-gated claiming and save.
func _initialize() -> void:
    for shape in range(3):
        for size in [20, 60, 120, 250]:
            for seed in [1, 1729, 20261112]:
                var settings := GalaxyModel.defaults()
                settings["shape"] = shape
                settings["size"] = size
                settings["seed"] = seed
                settings["ai_count"] = mini(20, size / 5)
                var sample := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
                if not GalaxyRoutes.valid(sample["stars"], sample["lanes"]):
                    _fail("Invalid lane graph")
                    return
                if not GalaxyRoutes.fully_reachable(sample["stars"], 170.0):
                    _fail("Unreachable system: %d %d %d" % [shape, size, seed])
                    return
    var config := GalaxyModel.defaults()
    config["seed"] = 221122
    var world := GalaxyModel.generate(config, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    var target := -1
    for star in world["stars"]:
        if int(star["id"]) == 0 or int(star["owner"]) != -1 or not bool(star["habitable"]):
            continue
        if GalaxySystems.distance(world["stars"][0], star) <= 170.0:
            target = int(star["id"])
            break
    if target < 0:
        _fail("No neutral habitable target within initial range")
        return
    var snapshot := JSON.stringify(world)
    if GalaxyStrategy.colonize_system(world, target).is_empty() or JSON.stringify(world) != snapshot:
        _fail("Unsurveyed system claimed or rejected action mutated state")
        return
    if not GalaxySystems.explore(world, target):
        _fail("Expected survey failed")
        return
    if GalaxyStrategy.colonize_system(world, target).is_empty():
        _fail("Remote colonization accepted")
        return
    if not GalaxySystems.move_fleet(world, target):
        _fail("Valid fleet movement rejected")
        return
    if GalaxyStrategy.colonize_system(world, target).is_empty():
        _fail("Colonization accepted while fleet in transit")
        return
    var eta: int = int(world["fleets"][0]["eta"])
    for step in range(eta):
        GalaxySystems.tick(world)
    if int(world["fleets"][0]["location"]) != target:
        _fail("Fleet failed to arrive")
        return
    var before_claim := int(world["credits"])
    if GalaxyStrategy.colonize_system(world, target) != "":
        _fail("Stationed fleet cannot claim system")
        return
    if int(world["credits"]) != before_claim - 50 or int(world["stars"][target]["owner"]) != 0:
        _fail("Claim did not transfer ownership or deduct exactly 50 credits")
        return
    if GalaxyStrategy.colonize_system(world, target).is_empty() or int(world["credits"]) != before_claim - 50:
        _fail("Duplicate claim accepted")
        return
    if not GalaxyModel.save_game(world, 4):
        _fail("Colony save failed")
        return
    if JSON.stringify(GalaxyModel.load_game(4)) != JSON.stringify(world):
        _fail("Colony and fleet save/load mismatch")
        return
    print("GALAXY_PACKAGE_C2_PASS: 36 reachable seed configurations and fleet-gated colony roundtrip")
    quit(0)

func _fail(reason: String) -> void:
    push_error("GALAXY_PACKAGE_C2_FAILURE: " + reason)
    quit(1)
