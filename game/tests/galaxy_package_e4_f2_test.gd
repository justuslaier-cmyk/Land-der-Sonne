extends SceneTree

func _initialize() -> void:
    var world := GalaxyModel.generate(GalaxyModel.defaults(), GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    var rival := int(world["ai"][0]["id"])
    world["contacts"] = [rival]
    world["trade_pacts"] = [rival]
    world["credits"] = 100
    world["tick"] = 3
    GalaxyStrategy.settle_international_market(world)
    if int(world["trade_market_ledger"]["trade_revenue"]) != 6:
        _fail("Trade revenue missing")
        return
    if not GalaxyStrategy.set_trade_tariff(world, rival, 2):
        _fail("Tariff rejected")
        return
    GalaxyStrategy.settle_international_market(world)
    if int(world["trade_market_ledger"]["tariff_revenue"]) != 4:
        _fail("Tariff accounting failed")
        return
    if not GalaxyStrategy.set_trade_embargo(world, rival, true):
        _fail("Embargo rejected")
        return
    GalaxyStrategy.settle_international_market(world)
    if int(world["trade_market_ledger"]["trade_revenue"]) != 0:
        _fail("Embargo leaked income")
        return
    GalaxySystems.settle_research_exchange(world)
    if int(world["research_exchange_ledger"]["eligible_partners"]) != 0:
        _fail("Embargo leaked research exchange")
        return
    if GalaxyStrategy.set_trade_tariff(world, rival, 4):
        _fail("Invalid tariff accepted")
        return
    if not GalaxyStrategy.set_propaganda(world, 2):
        _fail("Information policy rejected")
        return
    GalaxyAI.tick(world)
    var assessment: Dictionary = world["ai_military_assessments"][str(rival)]
    if not assessment.has("doctrine") or not assessment.has("supply_estimate"):
        _fail("F2 defensive AI assessment absent")
        return
    if not ResourceLoader.exists("res://assets/art/scene_trade_policy.svg") or not ResourceLoader.exists("res://assets/art/scene_information_policy.svg"):
        _fail("Missing original art")
        return
    print("GALAXY_PACKAGE_E4_F2_PASS: tariffs, embargo, academic cutoff, propaganda, AI doctrine, art")
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_PACKAGE_E4_F2_FAILURE: " + message)
    quit(1)
