extends SceneTree

func _initialize() -> void:
    var world := {"tick": 5, "stars": [{"owner": 0}, {"owner": 0}],
        "lanes": [[0, 1]], "civilian_worlds": {
            "0": {"goods": 10}, "1": {"goods": 2}},
        "civilian_freight_transit": [{"from": 0, "to": 1, "goods": 4,
            "departure_tick": 4, "arrival_tick": 6}]}
    if GalaxyCivilians.transit_goods(world) != 4:
        _fail("Freight not counted in transit")
        return
    if not GalaxyCivilians.settle_freight(world).is_empty() or int(world["civilian_worlds"]["1"]["goods"]) != 2:
        _fail("Freight arrived before scheduled tick")
        return
    world["tick"] = 6
    if GalaxyCivilians.settle_freight(world).size() != 1 or int(world["civilian_worlds"]["1"]["goods"]) != 6:
        _fail("Freight did not arrive on schedule")
        return
    if GalaxyCivilians.transit_goods(world) != 0:
        _fail("Delivered cargo remains in transit")
        return
    world["civilian_freight_transit"] = [{"from": 0, "to": 1, "goods": 3,
        "departure_tick": 6, "arrival_tick": 7}]
    world["stars"][1]["owner"] = 1
    world["tick"] = 7
    GalaxyCivilians.settle_freight(world)
    if int(world["civilian_worlds"]["0"]["goods"]) != 13 or GalaxyCivilians.transit_goods(world) != 0:
        _fail("Blocked freight was not returned to origin")
        return
    var settings := GalaxyModel.defaults()
    settings["seed"] = 80202
    var simulation := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(simulation)
    simulation["tick"] = 1
    GalaxyCivilians.tick(simulation)
    if not simulation.has("civilian_freight_transit"):
        _fail("Freight queue missing from annual economy")
        return
    if not GalaxyModel.save_game(simulation):
        _fail("Save failed")
        return
    var loaded := GalaxyModel.load_game()
    if JSON.stringify(loaded["civilian_freight_transit"]) != JSON.stringify(simulation["civilian_freight_transit"]):
        _fail("Transit queue was not saved")
        return
    print("GALAXY_FREIGHT_TRANSIT_PASS: delayed delivery, route blocking, conservation and save")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
