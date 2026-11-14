extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 123456
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    var before := JSON.stringify(world)
    var home: Dictionary = GalaxySystems.route_preview(world, 0)
    if bool(home["allowed"]) or str(home["reason"]) != "Bereits vor Ort":
        _fail("Fleet at capital should not travel to itself")
        return
    var invalid: Dictionary = GalaxySystems.route_preview(world, -1)
    if bool(invalid["allowed"]):
        _fail("Invalid target accepted")
        return
    var unknown: Dictionary = GalaxySystems.route_preview(world, 1)
    if bool(unknown["allowed"]):
        _fail("Unknown system accepted")
        return
    if JSON.stringify(world) != before:
        _fail("Read-only route preview changed world")
        return
    var reachable := -1
    for star in world["stars"]:
        var id := int(star["id"])
        if id != 0 and GalaxySystems.distance(world["stars"][0], star) <= 170.0:
            reachable = id
            break
    if reachable < 0:
        _fail("Fixed-seed galaxy has no survey target")
        return
    var survey: Dictionary = GalaxySystems.survey_preview(world, reachable)
    if not bool(survey["allowed"]):
        _fail("Nearby system should be surveyable")
        return
    if not GalaxySystems.explore(world, reachable):
        _fail("Survey command rejected a valid preview")
        return
    if bool(GalaxySystems.survey_preview(world, reachable)["allowed"]):
        _fail("Already surveyed system should not be surveyed again")
        return
    var route: Dictionary = GalaxySystems.route_preview(world, reachable)
    if not bool(route["allowed"]) or int(route["eta"]) < 1:
        _fail("Known nearby system should be reachable by fleet")
        return
    if not GalaxySystems.move_fleet(world, reachable):
        _fail("Valid preview not accepted by move command")
        return
    if bool(GalaxySystems.route_preview(world, 0)["allowed"]):
        _fail("Fleet in transit should not accept a second route")
        return
    print("GALAXY_NAVIGATION_PASS: previews, fog, exploration, fleet orders")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
