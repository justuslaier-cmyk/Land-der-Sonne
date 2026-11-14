extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 70101
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    world["stars"][1]["owner"] = 0
    world["civilian_worlds"]["1"] = {"population": 28, "capacity": 90, "jobs": 6,
        "satisfaction": 45, "private_capital": 20, "goods": 0, "output": 0, "taxes": 0}
    for year in range(1, 81):
        world["tick"] = year
        GalaxyCivilians.tick(world)
        var ledger: Dictionary = world["civilian_goods_ledger"]
        if int(ledger["opening_stock"]) + int(ledger["produced"]) - int(ledger["consumed"]) - int(ledger.get("dispatched", 0)) != int(ledger["ending_stock"]):
            _fail("Goods balance violated in year %d" % year)
            return
        var actual := 0
        for key in world["civilian_worlds"].keys():
            if int(world["stars"][int(key)]["owner"]) != 0:
                continue
            var market: Dictionary = world["civilian_worlds"][key]
            if int(market["goods"]) < 0:
                _fail("Negative market inventory")
                return
            actual += int(market["goods"])
        if actual != int(ledger["ending_stock"]):
            _fail("Ledger differs from physical inventory")
            return
        for shipment in ledger["shipments"]:
            if int(shipment["goods"]) <= 0:
                _fail("Invalid shipment amount")
                return
    var replay := world.duplicate(true)
    world["tick"] = 81
    replay["tick"] = 81
    GalaxyCivilians.tick(world)
    GalaxyCivilians.tick(replay)
    if JSON.stringify(world["civilian_goods_ledger"]) != JSON.stringify(replay["civilian_goods_ledger"]):
        _fail("Goods simulation is not deterministic")
        return
    print("GALAXY_GOODS_LEDGER_PASS: 80-year goods conservation, trade and deterministic replay")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
