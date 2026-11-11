extends SceneTree

func _initialize() -> void:
    if GalaxyCivilians.freight_reserve({"population": 12}) != 15:
        _fail("Small colony lost minimum reserve")
        return
    if GalaxyCivilians.freight_reserve({"population": 80}) != 40:
        _fail("Reserve does not reflect household demand")
        return
    var world := {"civilian_freight_transit": [
        {"to": 2, "goods": 8}, {"to": 2, "goods": 5}, {"to": 1, "goods": 4}]}
    if GalaxyCivilians.incoming_freight(world, 2) != 13:
        _fail("Committed inbound cargo not aggregated")
        return
    var settings := GalaxyModel.defaults()
    settings["seed"] = 80303
    var simulation := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(simulation)
    var route: Array = simulation["lanes"][0]
    var origin := int(route[0])
    var target := int(route[1])
    simulation["stars"][origin]["owner"] = 0
    simulation["stars"][target]["owner"] = 0
    simulation["civilian_worlds"][str(origin)] = {"population": 20, "capacity": 100,
        "jobs": 30, "satisfaction": 80, "private_capital": 500, "goods": 100, "output": 0, "taxes": 0}
    simulation["civilian_worlds"][str(target)] = {"population": 80, "capacity": 100,
        "jobs": 0, "satisfaction": 20, "private_capital": 0, "goods": 0, "output": 0, "taxes": 0}
    simulation["civilian_freight_transit"] = [{"from": origin, "to": target, "goods": 100,
        "departure_tick": 0, "arrival_tick": 99}]
    simulation["tick"] = 1
    GalaxyCivilians.tick(simulation)
    for shipment in simulation["civilian_trade"]:
        if int(shipment["to"]) == target:
            _fail("Merchants overbooked a destination already supplied in transit")
            return
    var ledger: Dictionary = simulation["civilian_goods_ledger"]
    if int(ledger["opening_stock"]) + int(ledger["produced"]) - int(ledger["consumed"]) - int(ledger["dispatched"]) != int(ledger["ending_stock"]):
        _fail("Stock conservation failed with existing transit commitments")
        return
    if int(ledger["transit_after"]) != 100 + int(ledger["dispatched"]):
        _fail("In-transit cargo balance failed")
        return
    print("GALAXY_FREIGHT_RESERVES_PASS: local reserves, inbound commitments and transit accounting")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
