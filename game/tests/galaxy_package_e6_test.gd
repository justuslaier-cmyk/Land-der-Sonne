extends SceneTree

func _initialize() -> void:
    var world := GalaxyModel.generate(GalaxyModel.defaults(), GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    GalaxyCivilians.prepare(world)
    var rival := int(world["ai"][0]["id"])
    world["contacts"] = [rival]
    world["trade_pacts"] = [rival]
    world["credits"] = 200
    world["tick"] = 3
    GalaxyStrategy.settle_international_market(world)
    var ledger: Dictionary = world["trade_market_ledger"]
    if int(ledger["ore_purchased"]) != 3 or int(ledger["purchase_cost"]) != 6:
        _fail("Finite foreign ore was not purchased")
        return
    if int(world["foreign_market_stocks"][str(rival)]) != 21:
        _fail("Foreign stock not debited")
        return
    world["tick"] = 5
    GalaxyStrategy.set_trade_embargo(world, rival, true)
    GalaxyStrategy.settle_international_market(world)
    if int(world["trade_market_ledger"]["ore_delivered"]) != 3:
        _fail("Cargo not physically delivered")
        return
    if int(world["trade_market_ledger"]["ore_purchased"]) != 0:
        _fail("Embargo allowed purchases")
        return
    var workforce: Dictionary = GalaxySystems.research_workforce(world)
    if int(workforce["scientists"]) > int(workforce["institutions"]) * 3:
        _fail("Scientific workforce exceeds institutions")
        return
    print("GALAXY_PACKAGE_E6_PASS: finite foreign stock, purchase, delayed delivery, embargo, scientists")
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_PACKAGE_E6_FAILURE: " + message)
    quit(1)
