extends SceneTree

func _initialize() -> void:
    var config := GalaxyModel.defaults()
    config["seed"] = 123456
    config["size"] = 80
    config["ai_count"] = 3
    var world := GalaxyModel.generate(config, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    GalaxyAI.prepare(world)
    if world["ai_intentions"].size() != 3:
        _fail("AI strategic states not initialized")
        return
    for i in range(18):
        GalaxyStrategy.tick(world)
        if str(world["pending_event"]) != "":
            GalaxySystems.resolve_event(world, 0)
    if world["ai_activity"].is_empty():
        _fail("AI never acted")
        return
    if world["ai_fleets"][0]["strength"] <= 10:
        _fail("AI did not build fleets")
        return
    var total_owned := 0
    for star in world["stars"]:
        if int(star["owner"]) > 0:
            total_owned += 1
    if total_owned <= 3:
        _fail("AI empires never expanded")
        return
    world["contacts"].append(1)
    world["relations"]["1"] = 40
    if not GalaxyStrategy.propose_non_aggression(world, 1):
        _fail("Non-aggression diplomacy failed")
        return
    if GalaxyStrategy.declare_war(world, 1):
        _fail("Non-aggression pact did not prevent war")
        return
    world["non_aggression"].erase(1)
    if not GalaxyStrategy.declare_war(world, 1):
        _fail("War declaration failed")
        return
    world["credits"] = 100
    if not GalaxyStrategy.offer_peace(world, 1):
        _fail("Peace negotiation failed")
        return
    if GalaxyStrategy.declare_war(world, 1):
        _fail("Postwar truce was violated")
        return
    world["pending_event"] = "political_crisis"
    world["stability"] = 12
    GalaxySystems.resolve_event(world, 0)
    if int(world["stability"]) != 34 or str(world["pending_event"]) != "":
        _fail("Political crisis resolution failed")
        return
    if not GalaxyModel.save_game(world):
        _fail("AI state could not be saved")
        return
    var loaded := GalaxyModel.load_game()
    if JSON.stringify(loaded) != JSON.stringify(world):
        _fail("AI state not preserved in save")
        return
    print("GALAXY_AI_PASS")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
