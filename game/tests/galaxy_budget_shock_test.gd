extends SceneTree

# Package 2.1: public spending must conserve credits, obey shortages,
# and distribute real satisfaction gains without creating money.
func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 284710
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    GalaxyCivilians.prepare(world)
    world["policies"]["welfare"] = 2
    world["civilian_taxes"] = 7
    world["credits"] = 2
    var key := "0"
    if not world["civilian_worlds"].has(key):
        _fail("Home civilian market missing")
        return
    var market: Dictionary = world["civilian_worlds"][key]
    market["satisfaction"] = 50
    GalaxyStrategy.settle_public_budget(world)
    var ledger: Dictionary = world["public_budget_ledger"]
    if int(ledger["opening"]) != 2 or int(ledger["tax_receipts"]) != 7:
        _fail("Tax receipts not accounted for")
        return
    if int(ledger["welfare_spending"]) != 6 or int(world["credits"]) != 3:
        _fail("Public spending not balanced against available credits")
        return
    if int(market["satisfaction"]) != 52:
        _fail("Welfare transfer did not improve satisfaction")
        return
    world["credits"] = 0
    world["civilian_taxes"] = 1
    GalaxyStrategy.settle_public_budget(world)
    ledger = world["public_budget_ledger"]
    if int(ledger["welfare_spending"]) != 1 or int(world["credits"]) != 0:
        _fail("Treasury shortage was not enforced")
        return
    if int(ledger["closing"]) != int(ledger["opening"]) + int(ledger["tax_receipts"]) - int(ledger["welfare_spending"]):
        _fail("Budget ledger violates conservation")
        return
    print("GALAXY_BUDGET_SHOCK_PASS: receipts, welfare effects and shortage conservation")
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_BUDGET_SHOCK_FAILURE: " + message)
    quit(1)
