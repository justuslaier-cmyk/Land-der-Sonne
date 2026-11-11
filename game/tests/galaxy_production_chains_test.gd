extends SceneTree

func _initialize() -> void:
    var market := {"demographics": {"employed": 30}}
    var first: Dictionary = GalaxyCivilians.advance_production(market, 5)
    if int(first["extracted"]) <= 0 or int(first["processed"]) <= 0 or int(first["assembled"]) <= 0:
        _fail("Production chain does not process all three stages")
        return
    for year in range(1, 101):
        var ledger: Dictionary = GalaxyCivilians.advance_production(market, 4)
        if int(ledger["ore_before"]) + int(ledger["extracted"]) - int(ledger["ore_used"]) != int(ledger["ore_after"]):
            _fail("Ore conservation failed")
            return
        if int(ledger["components_before"]) + int(ledger["processed"]) - int(ledger["components_used"]) != int(ledger["components_after"]):
            _fail("Components conservation failed")
            return
        if int(ledger["manufactures_before"]) + int(ledger["assembled"]) != int(ledger["manufactures_after"]):
            _fail("Manufactures conservation failed")
            return
        for key in ["ore", "components", "manufactures"]:
            if int(market["production_stock"][key]) < 0:
                _fail("Negative production stock")
                return
    var no_labor := {"demographics": {"employed": 0}, "production_stock": market["production_stock"].duplicate(true)}
    var frozen: Dictionary = no_labor["production_stock"].duplicate(true)
    GalaxyCivilians.advance_production(no_labor, 4)
    if JSON.stringify(frozen) != JSON.stringify(no_labor["production_stock"]):
        _fail("Production occurred without labor")
        return
    var settings := GalaxyModel.defaults()
    settings["seed"] = 70202
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    world["tick"] = 1
    GalaxyCivilians.tick(world)
    if not world.has("civilian_production_ledger") or not world["civilian_worlds"]["0"].has("production_stock"):
        _fail("Production chain not integrated into annual economy")
        return
    if not GalaxyModel.save_game(world):
        _fail("Production stock save failed")
        return
    var loaded := GalaxyModel.load_game()
    if JSON.stringify(loaded["civilian_worlds"]["0"]["production_stock"]) != JSON.stringify(world["civilian_worlds"]["0"]["production_stock"]):
        _fail("Production stock lost during save/load")
        return
    print("GALAXY_PRODUCTION_CHAINS_PASS: 100-year conserved chain, labor limits and persistence")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
