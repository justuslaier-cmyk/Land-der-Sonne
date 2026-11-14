extends SceneTree

func _initialize() -> void:
    var world := GalaxyModel.generate(GalaxyModel.defaults(), GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    GalaxyEndgame.prepare(world)
    world["tick"] = 70
    world["wars"] = [1, 2]
    GalaxyEndgame.tick(world)
    if str(world["galactic_crisis"].get("id", "")) != "fracture":
        _fail("First crisis missing")
        return
    world["galactic_crisis"]["threat"] = 0
    GalaxyEndgame.tick(world)
    if int(world["galactic_crises_survived"]) != 1:
        _fail("First crisis not resolved")
        return
    world["tick"] = 71
    GalaxyEndgame.tick(world)
    if str(world["galactic_crisis"].get("state", "")) == "active":
        _fail("Resolved first crisis retriggered")
        return
    world["tick"] = 110
    world["ancient_history"] = {"completed": true}
    GalaxyEndgame.tick(world)
    if str(world["galactic_crisis"].get("id", "")) != "ancient":
        _fail("Second crisis blocked by resolved first crisis")
        return
    world["galactic_crisis"]["threat"] = 0
    GalaxyEndgame.tick(world)
    if int(world["galactic_crises_survived"]) != 2:
        _fail("Second crisis not resolved")
        return
    world["tick"] = 111
    GalaxyEndgame.tick(world)
    if str(world["galactic_crisis"].get("state", "")) == "active":
        _fail("Resolved crises retriggered")
        return
    print("GALAXY_CRISIS_CHAIN_PASS: independent crises, one-time resolution, no retriggers")
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_CRISIS_CHAIN_FAILURE: " + message)
    quit(1)
