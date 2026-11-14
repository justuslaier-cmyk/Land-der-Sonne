extends SceneTree

# Package 2.1: deterministic demographic accounting, migration, supply shock,
# and full economic ledger under repeated simulated years.
func _initialize() -> void:
    var origin := {"population": 24, "capacity": 80, "jobs": 12, "satisfaction": 65, "goods": 40,
        "demographics": GalaxyCivilians.demographic_defaults(24)}
    var destination := {"population": 6, "capacity": 80, "jobs": 18, "satisfaction": 85, "goods": 25,
        "demographics": GalaxyCivilians.demographic_defaults(6)}
    var total_before := int(origin["population"]) + int(destination["population"])
    if not GalaxyCivilians.transfer_migrant(origin, destination):
        _fail("Valid migration rejected")
        return
    if int(origin["population"]) + int(destination["population"]) != total_before:
        _fail("Migration created or destroyed population")
        return
    for market in [origin, destination]:
        var d: Dictionary = market["demographics"]
        if int(d["children"]) + int(d["working_age"]) + int(d["elders"]) != int(market["population"]):
            _fail("Cohort totals diverge after migration")
            return
        if int(d["employed"]) + int(d["unemployed"]) != int(d["working_age"]):
            _fail("Employment totals diverge after migration")
            return
    destination["capacity"] = int(destination["population"])
    if GalaxyCivilians.transfer_migrant(origin, destination):
        _fail("Migration ignored destination capacity")
        return
    var baseline := {"population": 24, "capacity": 80, "jobs": 12, "satisfaction": 80, "goods": 80,
        "demographics": GalaxyCivilians.demographic_defaults(24)}
    var shortage := baseline.duplicate(true)
    shortage["goods"] = 0
    shortage["satisfaction"] = 20
    GalaxyCivilians.advance_demographics(baseline, 24, 24, 4)
    GalaxyCivilians.advance_demographics(shortage, 24, 24, 4)
    if int(shortage["demographics"]["births"]) > int(baseline["demographics"]["births"]):
        _fail("Supply shortage increased birth rate")
        return
    for market in [baseline, shortage]:
        var d: Dictionary = market["demographics"]
        if int(d["children"]) + int(d["working_age"]) + int(d["elders"]) != int(market["population"]):
            _fail("Cohort totals diverge after demographic advance")
            return
    var settings := GalaxyModel.defaults()
    settings["seed"] = 529771
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    for year in range(24):
        GalaxyStrategy.tick(world)
        if str(world.get("pending_event", "")) != "":
            GalaxySystems.resolve_event(world, 0)
        var audit: Dictionary = GalaxySocietyAudit.inspect(world)
        if not bool(audit["valid"]):
            _fail("Society audit at year %d: %s" % [year, str(audit["errors"])])
            return
        var ledger: Dictionary = world["civilian_goods_ledger"]
        if int(ledger["opening_stock"]) + int(ledger["produced"]) - int(ledger["consumed"]) - int(ledger["dispatched"]) != int(ledger["ending_stock"]):
            _fail("Annual household goods ledger unbalanced at year %d" % year)
            return
        if int(ledger["transit_before"]) + int(ledger["dispatched"]) - int(ledger["arrived"]) - int(ledger["returned"]) != int(ledger["transit_after"]):
            _fail("Freight transit ledger unbalanced at year %d" % year)
            return
        var budget: Dictionary = world["public_budget_ledger"]
        if int(budget["opening"]) + int(budget["tax_receipts"]) - int(budget["welfare_spending"]) != int(budget["closing"]):
            _fail("Annual public budget unbalanced at year %d" % year)
            return
        for key in world["civilian_worlds"].keys():
            var market: Dictionary = world["civilian_worlds"][key]
            if int(market["population"]) < 0 or int(market["goods"]) < 0 or int(market["private_capital"]) < 0:
                _fail("Negative household stock at year %d" % year)
                return
            var d: Dictionary = market["demographics"]
            if int(d["children"]) + int(d["working_age"]) + int(d["elders"]) != int(market["population"]):
                _fail("Population/cohort mismatch at year %d" % year)
                return
    print("GALAXY_SOCIETY_SHOCK_PASS: migration, cohorts, supply shock, 24-year goods/freight/budget ledgers")
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_SOCIETY_SHOCK_FAILURE: " + message)
    quit(1)
