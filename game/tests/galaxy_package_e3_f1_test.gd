extends SceneTree

func _initialize() -> void:
    var world := GalaxyModel.generate(GalaxyModel.defaults(), GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    if not GalaxyStrategy.improve_trade_security(world):
        _fail("Patrol investment rejected")
        return
    if int(world["trade_security"]) != 1:
        _fail("Patrol upgrade not stored")
        return
    world["credits"] = 0
    if GalaxyStrategy.improve_trade_security(world):
        _fail("Free patrol upgrade")
        return
    var first := world.duplicate(true)
    GalaxyCivilians.tick(world)
    GalaxyCivilians.tick(first)
    if JSON.stringify(world["civilian_goods_ledger"]) != JSON.stringify(first["civilian_goods_ledger"]):
        _fail("Freight simulation diverged")
        return
    if not GalaxySocietyAudit.inspect(world)["valid"]:
        _fail("Freight accounting audit failed")
        return
    var target := 0
    var market: Dictionary = world["civilian_worlds"]["0"]
    var before := int(market["goods"])
    world["civilian_freight_transit"] = [{"from": 0, "to": target, "goods": 5, "arrival_tick": int(world["tick"]), "departure_tick": 0, "hops": 1, "cost": 5}]
    world["freight_blockades"] = [target]
    GalaxyCivilians.settle_freight(world)
    if int(market["goods"]) != before + 5 or not world["civilian_freight_transit"].is_empty():
        _fail("Blockaded cargo was lost")
        return
    GalaxyAI.prepare(world)
    if world["ai"].is_empty():
        _fail("AI fixture empty")
        return
    GalaxyAI.tick(world)
    var rival := str(world["ai"][0]["id"])
    if not world["ai_military_assessments"].has(rival):
        _fail("Missing military intent trace")
        return
    if not ResourceLoader.exists("res://assets/art/scene_freight_security.svg"):
        _fail("Missing freight security art")
        return
    print("GALAXY_PACKAGE_E3_F1_PASS: patrol, blockade, deterministic freight, AI intent, art")
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_PACKAGE_E3_F1_FAILURE: " + message)
    quit(1)
