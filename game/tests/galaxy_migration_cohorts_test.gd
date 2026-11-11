extends SceneTree

func _initialize() -> void:
    var source := {"population": 20, "capacity": 50, "jobs": 10, "satisfaction": 20,
        "demographics": {"children": 4, "working_age": 14, "elders": 2, "employed": 10, "unemployed": 4}}
    var destination := {"population": 10, "capacity": 12, "jobs": 20, "satisfaction": 90,
        "demographics": {"children": 2, "working_age": 7, "elders": 1, "employed": 7, "unemployed": 0}}
    var before := int(source["population"]) + int(destination["population"])
    for index in range(2):
        if not GalaxyCivilians.transfer_migrant(source, destination):
            _fail("Migration failed despite free capacity")
            return
    if GalaxyCivilians.transfer_migrant(source, destination):
        _fail("Migration exceeded destination capacity")
        return
    if int(source["population"]) + int(destination["population"]) != before:
        _fail("Migration created or destroyed citizens")
        return
    if int(source["demographics"]["working_age"]) != 12 or int(destination["demographics"]["working_age"]) != 9:
        _fail("Migrants were not moved between real age cohorts")
        return
    for market in [source, destination]:
        var d: Dictionary = market["demographics"]
        if int(d["children"]) + int(d["working_age"]) + int(d["elders"]) != int(market["population"]):
            _fail("Migration cohort sum mismatch")
            return
        if int(d["employed"]) + int(d["unemployed"]) != int(d["working_age"]):
            _fail("Post-migration employment mismatch")
            return
    var settings := GalaxyModel.defaults()
    settings["seed"] = 60103
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    var other := 1
    world["stars"][other]["owner"] = 0
    world["civilian_worlds"]["1"] = {"population": 30, "capacity": 90, "jobs": 10, "satisfaction": 20,
        "private_capital": 0, "goods": 0, "output": 0, "taxes": 0}
    for year in range(1, 121):
        world["tick"] = year
        GalaxyCivilians.tick(world)
        var weighted := 0
        var total := 0
        for key in world["civilian_worlds"].keys():
            if int(world["stars"][int(key)]["owner"]) != 0:
                continue
            var market: Dictionary = world["civilian_worlds"][key]
            var d: Dictionary = market["demographics"]
            if int(d["children"]) + int(d["working_age"]) + int(d["elders"]) != int(market["population"]):
                _fail("Long-run population accounting failed in year %d" % year)
                return
            if int(d["employed"]) + int(d["unemployed"]) != int(d["working_age"]):
                _fail("Long-run labor accounting failed in year %d" % year)
                return
            weighted += int(market["satisfaction"]) * int(market["population"])
            total += int(market["population"])
        if int(world["civilian_approval"]) != weighted / maxi(1, total):
            _fail("Approval uses outdated population weights")
            return
    print("GALAXY_MIGRATION_COHORTS_PASS: transfers, capacity, 120-year accounting and approval")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
