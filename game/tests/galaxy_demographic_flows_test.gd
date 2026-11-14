extends SceneTree

func _initialize() -> void:
    var healthy := {"population": 40, "capacity": 100, "jobs": 30, "satisfaction": 90, "goods": 80}
    var stressed := healthy.duplicate(true)
    stressed["satisfaction"] = 20
    stressed["goods"] = 0
    for year in range(1, 31):
        GalaxyCivilians.advance_demographics(healthy, int(healthy["population"]), int(healthy["population"]), year)
        GalaxyCivilians.advance_demographics(stressed, int(stressed["population"]), int(stressed["population"]), year)
        for market in [healthy, stressed]:
            var d: Dictionary = market["demographics"]
            if int(d["children"]) + int(d["working_age"]) + int(d["elders"]) != int(market["population"]):
                _fail("Age cohorts do not sum to total population")
                return
            if int(d["employed"]) + int(d["unemployed"]) != int(d["working_age"]):
                _fail("Employment does not reconcile with working-age cohort")
                return
            if int(market["population"]) > int(market["capacity"]):
                _fail("Births exceeded settlement capacity")
                return
    if int(healthy["population"]) <= int(stressed["population"]):
        _fail("Material conditions do not affect demographic outcomes")
        return
    var aged := {"population": 40, "capacity": 100, "jobs": 10, "satisfaction": 10, "goods": 0,
        "demographics": {"children": 0, "working_age": 0, "elders": 40}}
    GalaxyCivilians.advance_demographics(aged, 40, 40, 4)
    if int(aged["demographics"]["deaths"]) <= 0 or int(aged["population"]) >= 40:
        _fail("Mortality does not reduce total population")
        return
    var replay := healthy.duplicate(true)
    var same := healthy.duplicate(true)
    GalaxyCivilians.advance_demographics(replay, int(replay["population"]), int(replay["population"]), 31)
    GalaxyCivilians.advance_demographics(same, int(same["population"]), int(same["population"]), 31)
    if JSON.stringify(replay) != JSON.stringify(same):
        _fail("Demographic simulation is not deterministic")
        return
    print("GALAXY_DEMOGRAPHIC_FLOWS_PASS: births, mortality, ageing, employment and conservation")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
