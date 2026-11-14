extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 62501
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    var market: Dictionary = world["civilian_worlds"]["0"]
    var starting_population := int(market["population"])
    for year in range(1, 61):
        world["tick"] = year
        GalaxyCivilians.tick(world)
        market = world["civilian_worlds"]["0"]
        var cohorts: Dictionary = market["demographics"]
        if int(cohorts["children"]) < 0 or int(cohorts["working_age"]) < 0 or int(cohorts["elders"]) < 0:
            _fail("Negative demographic cohort")
            return
        if int(cohorts["children"]) + int(cohorts["working_age"]) + int(cohorts["elders"]) != int(market["population"]):
            _fail("Cohorts do not reconcile with population at year %d" % year)
            return
        if int(cohorts["employed"]) + int(cohorts["unemployed"]) != int(cohorts["working_age"]):
            _fail("Employment accounting mismatch")
            return
        if int(cohorts["employed"]) > int(market["jobs"]):
            _fail("Employment exceeds jobs")
            return
    if int(market["population"]) <= starting_population:
        _fail("No demographic growth")
        return
    var snapshot := JSON.stringify(world["civilian_worlds"])
    if not GalaxyModel.save_game(world):
        _fail("Save failed")
        return
    var loaded := GalaxyModel.load_game()
    if JSON.stringify(loaded["civilian_worlds"]) != snapshot:
        _fail("Demographics not preserved in save")
        return
    var legacy := {"population": 17, "jobs": 8}
    GalaxyCivilians.advance_demographics(legacy, 17, 17, 1)
    var cohort: Dictionary = legacy["demographics"]
    if int(cohort["children"]) + int(cohort["working_age"]) + int(cohort["elders"]) != 17:
        _fail("Legacy migration broke cohort accounting")
        return
    print("GALAXY_DEMOGRAPHICS_PASS: 60 years, employment accounting, save and legacy migration")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
