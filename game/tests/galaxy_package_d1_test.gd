extends SceneTree

# D1: core population, employment, fiscal and household-goods diagnostics.
func _initialize() -> void:
    var config := GalaxyModel.defaults()
    config["seed"] = 11026
    config["size"] = 60
    var world := GalaxyModel.generate(config, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    var mirror := world.duplicate(true)
    for year in range(1, 81):
        GalaxyStrategy.tick(world)
        GalaxyStrategy.tick(mirror)
        var audit: Dictionary = world.get("society_audit", {})
        if not bool(audit.get("valid", false)):
            _fail("Annual accounting violation in year %d: %s" % [year, str(audit.get("errors", []))])
            return
        if JSON.stringify(audit) != JSON.stringify(mirror.get("society_audit", {})):
            _fail("Deterministic audit replay diverged")
            return
        if int(audit["employed"]) > int(audit["working_age"]):
            _fail("Employment exceeds working-age population")
            return
        if world["society_audit_history"].size() > 60:
            _fail("Audit history unbounded")
            return
    var damaged := world.duplicate(true)
    var home: Dictionary = damaged["civilian_worlds"]["0"]
    home["demographics"]["children"] = int(home["demographics"]["children"]) + 3
    if bool(GalaxySocietyAudit.inspect(damaged)["valid"]):
        _fail("Corrupted cohort balance was not detected")
        return
    damaged = world.duplicate(true)
    damaged["civilian_goods_ledger"]["ending_stock"] = int(damaged["civilian_goods_ledger"]["ending_stock"]) + 2
    if bool(GalaxySocietyAudit.inspect(damaged)["valid"]):
        _fail("Corrupted goods ledger was not detected")
        return
    damaged = world.duplicate(true)
    damaged["civilian_taxes"] = int(damaged["civilian_taxes"]) + 1
    if bool(GalaxySocietyAudit.inspect(damaged)["valid"]):
        _fail("Corrupted tax assessment was not detected")
        return
    if not GalaxyModel.save_game(world, 4):
        _fail("Save failed")
        return
    var loaded := GalaxyModel.load_game(4)
    if JSON.stringify(loaded.get("society_audit", {})) != JSON.stringify(world["society_audit"]):
        _fail("Audit snapshot lost in save/load")
        return
    if JSON.stringify(loaded.get("society_audit_history", [])) != JSON.stringify(world["society_audit_history"]):
        _fail("Audit history lost in save/load")
        return
    print("GALAXY_PACKAGE_D1_PASS: 80-year replay, cohorts, goods, taxes, corrupt-state detection, save")
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_PACKAGE_D1_FAILURE: " + message)
    quit(1)
