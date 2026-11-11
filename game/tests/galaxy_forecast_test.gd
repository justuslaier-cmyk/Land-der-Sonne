extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 812741
    settings["events"] = 0
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    world["buildings"]["0"] = {"mine": 1, "lab": 1, "factory": 1}
    world["policies"]["focus"] = 1
    var expected := GalaxyStrategy.income_forecast(world)
    var before_credits := int(world["credits"])
    var before_science := int(world["science"])
    var before_alloys := int(world["alloys"])
    GalaxyStrategy.tick(world)
    if int(world["credits"]) - before_credits != int(expected["credits"]):
        _fail("Forecast credits diverge from annual production")
        return
    if int(world["science"]) - before_science != int(expected["science"]):
        _fail("Forecast science diverges from annual production")
        return
    if int(world["alloys"]) - before_alloys != int(expected["alloys"]):
        _fail("Forecast alloys diverge from annual production")
        return
    if world.get("economy_history", []).size() != 1:
        _fail("Annual economy ledger did not record the first year")
        return
    var entry: Dictionary = world["economy_history"][0]
    if int(entry["delta"]["credits"]) != int(world["credits"]) - before_credits:
        _fail("Annual economy ledger credit delta is incorrect")
        return
    if int(entry["balance"]["science"]) != int(world["science"]):
        _fail("Annual economy ledger science balance is incorrect")
        return
    for year in range(65):
        GalaxyStrategy.tick(world)
        if str(world.get("pending_event", "")) != "":
            GalaxySystems.resolve_event(world, 0)
    if world["economy_history"].size() != 60:
        _fail("Annual economy ledger did not enforce the retention limit")
        return
    if int(world["economy_history"][-1]["year"]) != int(world["tick"]) + 2200:
        _fail("Annual economy ledger year does not match the simulation")
        return
    print("GALAXY_FORECAST_PASS")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
