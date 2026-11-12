extends SceneTree

# Package 2.1: ore/component/manufacture conversion and physical freight.
func _initialize() -> void:
    var market := {"demographics": {"employed": 25}, "production_stock": {"ore": 8, "components": 6, "manufactures": 2}}
    var ledger: Dictionary = GalaxyCivilians.advance_production(market, 4)
    if int(ledger["ore_before"]) + int(ledger["extracted"]) != int(ledger["ore_used"]) + int(ledger["ore_after"]):
        _fail("Ore created or destroyed in production")
        return
    if int(ledger["components_before"]) + int(ledger["processed"]) != int(ledger["components_used"]) + int(ledger["components_after"]):
        _fail("Components created or destroyed in production")
        return
    if int(ledger["manufactures_before"]) + int(ledger["assembled"]) != int(ledger["manufactures_after"]):
        _fail("Manufactures created or destroyed in production")
        return
    var before := int(market["production_stock"]["manufactures"])
    var sold := GalaxyCivilians.sell_manufactures(market, 3)
    if sold != 3 or int(market["production_stock"]["manufactures"]) != before - sold:
        _fail("Finished goods sale violates stock conservation")
        return
    var world := {"stars": [{"owner": 0}, {"owner": 0}, {"owner": 0}],
        "lanes": [[0, 1], [1, 2]], "tick": 4, "freight_blockades": [],
        "civilian_worlds": {
            "0": {"goods": 30}, "1": {"goods": 5}, "2": {"goods": 0}},
        "civilian_freight_transit": [{"from": 0, "to": 2, "goods": 7, "arrival_tick": 4}]}
    if GalaxyCivilians.freight_hops(world, 0, 2) != 2:
        _fail("Owned-lane freight route not found")
        return
    GalaxyCivilians.settle_freight(world)
    if int(world["civilian_worlds"]["2"]["goods"]) != 7 or GalaxyCivilians.transit_goods(world) != 0:
        _fail("Arrived cargo not conserved")
        return
    world["civilian_freight_transit"] = [{"from": 0, "to": 2, "goods": 4, "arrival_tick": 4}]
    world["freight_blockades"] = [2]
    GalaxyCivilians.settle_freight(world)
    if int(world["civilian_worlds"]["0"]["goods"]) != 34 or GalaxyCivilians.transit_goods(world) != 0:
        _fail("Blockaded cargo was not returned intact")
        return
    world["freight_blockades"] = []
    world["stars"][1]["owner"] = 1
    if GalaxyCivilians.freight_hops(world, 0, 2) != -1:
        _fail("Freight crosses foreign territory")
        return
    print("GALAXY_PRODUCTION_FREIGHT_PASS: material chain, finished sales, freight arrival, blockade return and border rules")
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_PRODUCTION_FREIGHT_FAILURE: " + message)
    quit(1)
