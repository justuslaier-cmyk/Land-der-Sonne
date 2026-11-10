extends SceneTree

func _initialize() -> void:
    var config := GalaxyModel.defaults()
    config["seed"] = 161803
    config["size"] = 80
    config["ai_count"] = 4
    var world := GalaxyModel.generate(config, GalaxyModel.empire_defaults())
    GalaxySystems.prepare(world)
    if world["fleets"].size() != 1 or world["known"].size() != 1:
        _fail("Simulation defaults missing")
        return
    var nearby := -1
    for star in world["stars"]:
        if int(star["id"]) != 0 and GalaxySystems.distance(world["stars"][0], star) <= 170.0:
            nearby = int(star["id"])
            break
    if nearby < 0 or not GalaxySystems.explore(world, nearby):
        _fail("First exploration failed")
        return
    if not world["known"].has(nearby):
        _fail("Exploration was not recorded")
        return
    var initial_tick := int(world["tick"])
    for i in range(15):
        GalaxySystems.tick(world)
        if str(world["pending_event"]) != "":
            GalaxySystems.resolve_event(world, 0)
    if int(world["tick"]) != initial_tick + 15:
        _fail("Simulation tick count incorrect")
        return
    if world["history"].is_empty():
        _fail("History missing")
        return
    var before := JSON.stringify(world)
    if not GalaxyModel.save_game(world):
        _fail("Expanded save failed")
        return
    var after := GalaxyModel.load_game()
    if after.is_empty() or JSON.stringify(after) != before:
        _fail("Expanded save roundtrip mismatch")
        return
    print("GALAXY_SYSTEMS_PASS: exploration, economy, AI ticks, events, history, persistence")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
