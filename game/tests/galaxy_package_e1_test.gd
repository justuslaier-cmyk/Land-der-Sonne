extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 440221
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    if GalaxyCivilians.freight_hops(world, 0, 0) != 0:
        _fail("Self route is not zero")
        return
    if GalaxyCivilians.freight_hops(world, -1, 0) != -1:
        _fail("Invalid source accepted")
        return
    var markets: Dictionary = world["civilian_worlds"]
    var home: Dictionary = markets["0"]
    home["demographics"] = {"employed": 8}
    if GalaxyCivilians.freight_capacity(home) != 4:
        _fail("Employment capacity not applied")
        return
    home["demographics"]["employed"] = 100
    if GalaxyCivilians.freight_capacity(home) != 10:
        _fail("Capacity ceiling ignored")
        return
    home["demographics"]["employed"] = 0
    if GalaxyCivilians.freight_capacity(home) != 0:
        _fail("Unemployed freight capacity nonzero")
        return
    var replay := world.duplicate(true)
    for year in range(75):
        world["tick"] = year
        replay["tick"] = year
        GalaxyStrategy.tick(world)
        GalaxyStrategy.tick(replay)
        var audit: Dictionary = GalaxySocietyAudit.inspect(world)
        if not bool(audit["valid"]):
            _fail("Year %d freight audit: %s" % [year, str(audit["errors"])])
            return
        if JSON.stringify(world["civilian_goods_ledger"]) != JSON.stringify(replay["civilian_goods_ledger"]):
            _fail("Freight replay diverged")
            return
    var forged := world.duplicate(true)
    forged["civilian_goods_ledger"]["dispatched"] = int(forged["civilian_goods_ledger"]["dispatched"]) + 1
    if GalaxySocietyAudit.inspect(forged)["valid"]:
        _fail("Forged manifest accepted")
        return
    forged = world.duplicate(true)
    forged["civilian_goods_ledger"]["arrived"] = int(forged["civilian_goods_ledger"]["arrived"]) + 1
    if GalaxySocietyAudit.inspect(forged)["valid"]:
        _fail("Forged arrival accepted")
        return
    GalaxySystems.prepare(world)
    if GalaxySystems.research_preview(world, "invalid")["allowed"]:
        _fail("Invalid research field accepted")
        return
    var research_before := int(world["research_fields"]["propulsion"])
    world["science"] = 200
    if not GalaxySystems.start_research(world, "propulsion"):
        _fail("First propulsion research unavailable")
        return
    if int(world["research_fields"]["propulsion"]) != research_before + 1:
        _fail("Research level not persisted in world state")
        return
    print("GALAXY_PACKAGE_E1_PASS: 75-year freight manifests, capacity, replay and research")
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_PACKAGE_E1_FAILURE: " + message)
    quit(1)
