extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 100101
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    var owned_id := -1
    for star in world["stars"]:
        if int(star["owner"]) == 0:
            owned_id = int(star["id"])
            break
    if owned_id < 0:
        _fail("No owned system available for laboratory")
        return
    world["buildings"][str(owned_id)] = {"lab": 2}
    world["science"] = 300
    if GalaxySystems.start_research(world, "unknown"):
        _fail("Invalid research field accepted")
        return
    if not GalaxySystems.start_research(world, "propulsion"):
        _fail("First propulsion discovery rejected")
        return
    if int(world["science"]) != 275 or int(world["research_fields"]["propulsion"]) != 1:
        _fail("Science cost or propulsion level incorrect")
        return
    if GalaxySystems.start_research(world, "propulsion"):
        _fail("Missing industrial prerequisite was ignored")
        return
    if not GalaxySystems.start_research(world, "industry"):
        _fail("First industry discovery rejected")
        return
    if not GalaxySystems.start_research(world, "propulsion"):
        _fail("Propulsion prerequisite was not unlocked")
        return
    if GalaxySystems.start_research(world, "industry"):
        _fail("Missing society prerequisite was ignored")
        return
    if not GalaxySystems.start_research(world, "society"):
        _fail("First society discovery rejected")
        return
    if not GalaxySystems.start_research(world, "industry"):
        _fail("Industry prerequisite was not unlocked")
        return
    if int(world["research_level"]) != 5 or world["research_history"].size() != 5:
        _fail("Research levels and discovery history diverged")
        return
    if not GalaxyModel.save_game(world):
        _fail("Research save failed")
        return
    var loaded := GalaxyModel.load_game()
    if JSON.stringify(loaded["research_fields"]) != JSON.stringify(world["research_fields"]) or loaded["research_history"].size() != 5:
        _fail("Research branches were not persisted")
        return
    world["science"] = 0
    if GalaxySystems.start_research(world, "society"):
        _fail("Research allowed without science resources")
        return
    print("GALAXY_RESEARCH_BRANCHES_PASS: prerequisites, costs, fields and save persistence")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
