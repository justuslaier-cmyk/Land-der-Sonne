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
    print("GALAXY_FORECAST_PASS")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
