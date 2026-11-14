extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 732119
    settings["events"] = 0
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    var rival_id := int(world["ai"][0]["id"])
    var key := str(rival_id)
    world["contacts"].append(rival_id)
    world["relations"][key] = 20
    if not GalaxyStrategy.sign_trade(world, rival_id):
        _fail("Trade treaty was rejected despite adequate relations")
        return
    for year in range(6):
        GalaxyStrategy.tick(world)
        if str(world.get("pending_event", "")) != "":
            GalaxySystems.resolve_event(world, 0)
    if int(world["diplomatic_trust"].get(key, 0)) != 12:
        _fail("Treaty trust failed to grow by two per year")
        return
    world["trade_pacts"].erase(rival_id)
    GalaxyStrategy.tick(world)
    if int(world["diplomatic_trust"].get(key, 0)) != 11:
        _fail("Trust did not decay after treaty cancellation")
        return
    world["wars"].append(rival_id)
    GalaxyStrategy.tick(world)
    if int(world["diplomatic_trust"].get(key, 0)) != 7:
        _fail("War did not erode diplomatic trust")
        return
    print("GALAXY_DIPLOMACY_TRUST_PASS")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
