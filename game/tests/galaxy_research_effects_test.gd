extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 100202
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    world["science"] = 400
    var owned := -1
    var foreign := -1
    for star in world["stars"]:
        if int(star["owner"]) == 0 and owned < 0:
            owned = int(star["id"])
        elif int(star["owner"]) != 0 and foreign < 0:
            foreign = int(star["id"])
    if owned < 0 or foreign < 0:
        _fail("Expected owned and foreign systems")
        return
    world["buildings"][str(foreign)] = {"lab": 9}
    if GalaxySystems.research_labs(world) != 0:
        _fail("Foreign laboratories counted as owned")
        return
    if not GalaxySystems.start_research(world, "propulsion"):
        _fail("Basic propulsion research failed")
        return
    if not GalaxySystems.start_research(world, "industry"):
        _fail("Basic industrial research failed")
        return
    if GalaxySystems.start_research(world, "propulsion"):
        _fail("Advanced propulsion research ignored laboratory requirement")
        return
    world["buildings"][str(owned)] = {"lab": 2}
    if GalaxySystems.research_labs(world) != 2:
        _fail("Owned laboratories were not counted")
        return
    if not GalaxySystems.start_research(world, "propulsion"):
        _fail("Advanced propulsion research blocked with laboratories")
        return
    if not GalaxySystems.start_research(world, "society"):
        _fail("Basic society research failed")
        return
    var bonuses: Dictionary = GalaxySystems.technology_bonuses(world)
    if int(bonuses["fleet_range"]) != 24 or int(bonuses["industry_alloys"]) != 2 or int(bonuses["society_stability"]) != 1:
        _fail("Research bonuses did not match actual levels and laboratories")
        return
    var forecast: Dictionary = GalaxyStrategy.income_forecast(world)
    world["research_fields"]["industry"] = 0
    var baseline: Dictionary = GalaxyStrategy.income_forecast(world)
    if int(forecast["alloys"]) - int(baseline["alloys"]) != 2:
        _fail("Industry research not reflected in income forecast")
        return
    world["research_fields"]["industry"] = 1
    if not GalaxyModel.save_game(world):
        _fail("Technology save failed")
        return
    var loaded := GalaxyModel.load_game()
    if int(GalaxySystems.technology_bonuses(loaded)["fleet_range"]) != 24:
        _fail("Research technology effects not restored")
        return
    print("GALAXY_RESEARCH_EFFECTS_PASS: owned laboratories, fleet range, industry and persistence")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
