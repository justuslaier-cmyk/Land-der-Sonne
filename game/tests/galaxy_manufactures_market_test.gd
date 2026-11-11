extends SceneTree

func _initialize() -> void:
    var market := {"production_stock": {"ore": 4, "components": 2, "manufactures": 9}}
    var sold := GalaxyCivilians.sell_manufactures(market, 3)
    if sold != 3 or int(market["production_stock"]["manufactures"]) != 6:
        _fail("Manufactured sales do not consume actual inventory")
        return
    if GalaxyCivilians.sell_manufactures(market, 0) != 0:
        _fail("Sales occurred without demand")
        return
    if GalaxyCivilians.sell_manufactures(market, 99) != 6 or int(market["production_stock"]["manufactures"]) != 0:
        _fail("Sales exceeded inventory")
        return
    var settings := GalaxyModel.defaults()
    settings["seed"] = 70303
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    var home: Dictionary = world["civilian_worlds"]["0"]
    home["goods"] = 0
    home["population"] = 60
    home["capacity"] = 100
    home["jobs"] = 10
    home["demographics"] = {"children": 10, "working_age": 40, "elders": 10, "employed": 10, "unemployed": 30}
    home["production_stock"] = {"ore": 0, "components": 0, "manufactures": 30}
    world["tick"] = 1
    GalaxyCivilians.tick(world)
    var chain: Dictionary = world["civilian_production_ledger"]["systems"]["0"]
    if int(chain["sold"]) <= 0:
        _fail("Manufactured goods were not sold during consumer shortage")
        return
    if int(chain["manufactures_before"]) + int(chain["assembled"]) - int(chain["sold"]) != int(chain["manufactures_after"]):
        _fail("Manufactured inventory conservation failed")
        return
    var ledger: Dictionary = world["civilian_goods_ledger"]
    if int(ledger["opening_stock"]) + int(ledger["produced"]) - int(ledger["consumed"]) - int(ledger.get("dispatched", 0)) != int(ledger["ending_stock"]):
        _fail("Consumer goods ledger fails after manufacturing sales")
        return
    if not GalaxyModel.save_game(world):
        _fail("Save failed")
        return
    var loaded := GalaxyModel.load_game()
    if JSON.stringify(loaded["civilian_worlds"]["0"]["production_stock"]) != JSON.stringify(home["production_stock"]):
        _fail("Manufacturing inventory not persisted")
        return
    print("GALAXY_MANUFACTURES_MARKET_PASS: sales, scarcity, conservation and persistence")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
