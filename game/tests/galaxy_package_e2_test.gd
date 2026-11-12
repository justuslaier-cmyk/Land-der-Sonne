extends SceneTree

func _initialize() -> void:
    var world := GalaxyModel.generate(GalaxyModel.defaults(), GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    GalaxySystems.prepare(world)
    world["buildings"] = {"0": {"lab": 3}}
    GalaxyCivilians.prepare(world)
    world["civilian_worlds"]["0"]["demographics"] = GalaxyCivilians.demographic_defaults(int(world["civilian_worlds"]["0"]["population"]))
    world["civilian_worlds"]["0"]["demographics"]["employed"] = 15
    world["science"] = 10
    world["tick"] = 7
    GalaxySystems.settle_research_exchange(world)
    if int(world["science"]) != 10 or int(world["research_exchange_ledger"]["science_granted"]) != 0:
        _fail("Uncontracted science transfer")
        return
    if world["ai"].is_empty():
        _fail("No diplomatic partner in fixture")
        return
    var partner := int(world["ai"][0]["id"])
    world["contacts"] = [partner]
    world["trade_pacts"] = [partner]
    GalaxySystems.settle_research_exchange(world)
    if int(world["science"]) != 13 or int(world["research_exchange_ledger"]["science_granted"]) != 3:
        _fail("Research exchange did not depend on pact and labs")
        return
    var replay := world.duplicate(true)
    GalaxySystems.settle_research_exchange(world)
    GalaxySystems.settle_research_exchange(replay)
    if JSON.stringify(world["research_exchange_ledger"]) != JSON.stringify(replay["research_exchange_ledger"]) or int(world["science"]) != int(replay["science"]):
        _fail("Exchange replay diverged")
        return
    world["wars"] = [partner]
    GalaxySystems.settle_research_exchange(world)
    if int(world["research_exchange_ledger"]["science_granted"]) != 0:
        _fail("War did not suspend exchange")
        return
    world["wars"] = []
    world["trade_pacts"] = []
    GalaxySystems.settle_research_exchange(world)
    if int(world["research_exchange_ledger"]["science_granted"]) != 0:
        _fail("Revoked trade pact still granted science")
        return
    if not ResourceLoader.exists("res://assets/art/scene_research_exchange.svg"):
        _fail("Missing original research exchange art")
        return
    print("GALAXY_PACKAGE_E2_PASS: academic pact science, war suspension, determinism, art")
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_PACKAGE_E2_FAILURE: " + message)
    quit(1)
