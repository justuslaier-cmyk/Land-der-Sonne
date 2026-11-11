extends SceneTree

func _initialize() -> void:
    var world := {"stars": [
        {"owner": 0}, {"owner": 0}, {"owner": 0}, {"owner": 1}
    ], "lanes": [[0, 1], [1, 2], [2, 3]]}
    if GalaxyCivilians.freight_hops(world, 0, 2) != 2:
        _fail("Two-hop owned route not found")
        return
    if GalaxyCivilians.freight_hops(world, 0, 3) != -1:
        _fail("Foreign destination was accessible")
        return
    world["stars"][1]["owner"] = 1
    if GalaxyCivilians.freight_hops(world, 0, 2) != -1:
        _fail("Foreign transit system was traversed")
        return
    if GalaxyCivilians.freight_capacity({"demographics": {"employed": 0}}) != 0:
        _fail("Unemployed world has freight capacity")
        return
    if GalaxyCivilians.freight_capacity({"demographics": {"employed": 6}}) != 3:
        _fail("Freight capacity does not follow workforce")
        return
    var settings := GalaxyModel.defaults()
    settings["seed"] = 80101
    var simulation := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(simulation)
    var lane: Array = simulation["lanes"][0]
    var from_id := int(lane[0])
    var to_id := int(lane[1])
    simulation["stars"][from_id]["owner"] = 0
    simulation["stars"][to_id]["owner"] = 0
    simulation["civilian_worlds"][str(from_id)] = {"population": 10, "capacity": 100,
        "jobs": 30, "satisfaction": 90, "private_capital": 200, "goods": 200, "output": 0, "taxes": 0}
    simulation["civilian_worlds"][str(to_id)] = {"population": 80, "capacity": 100,
        "jobs": 0, "satisfaction": 30, "private_capital": 0, "goods": 0, "output": 0, "taxes": 0}
    simulation["tick"] = 1
    GalaxyCivilians.tick(simulation)
    var ledger: Dictionary = simulation["civilian_goods_ledger"]
    if int(ledger["opening_stock"]) + int(ledger["produced"]) - int(ledger["consumed"]) - int(ledger.get("dispatched", 0)) != int(ledger["ending_stock"]):
        _fail("Goods were created or destroyed by freight")
        return
    var costs := 0
    for shipment in ledger["shipments"]:
        var hops := GalaxyCivilians.freight_hops(simulation, int(shipment["from"]), int(shipment["to"]))
        if hops <= 0 or int(shipment["hops"]) != hops:
            _fail("Shipment used invalid geographic route")
            return
        if int(shipment["goods"]) > int(shipment["capacity"]):
            _fail("Shipment exceeded labor freight capacity")
            return
        if int(shipment["cost"]) != int(shipment["goods"]) * hops:
            _fail("Freight cost does not match distance")
            return
        costs += int(shipment["cost"])
    if costs != int(ledger["freight_cost"]):
        _fail("Freight cost ledger mismatch")
        return
    print("GALAXY_FREIGHT_ROUTES_PASS: owned lane paths, capacity, costs and conserved goods")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
