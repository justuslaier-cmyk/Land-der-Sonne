extends SceneTree

func _initialize() -> void:
    var world := GalaxyModel.generate(GalaxyModel.defaults(), GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    GalaxyEndgame.prepare(world)
    world["credits"] = 300
    world["alloys"] = 200
    world["research_level"] = 4
    world["research_fields"]["society"] = 1 # Existing project requires a societal discovery.
    if not GalaxyEndgame.start_project(world, "orbital_archive"):
        _fail("Project rejected with resources")
        return
    if GalaxyEndgame.start_project(world, "stellar_foundry"):
        _fail("Concurrent project accepted")
        return
    for i in range(8):
        GalaxyEndgame.tick(world)
    if not world["megaproject_completed"].has("orbital_archive"):
        _fail("Project never completed")
        return
    var before := int(world["science"])
    GalaxyEndgame.tick(world)
    if int(world["science"]) != before + 5:
        _fail("Permanent yield not applied")
        return
    world["tick"] = 70
    world["wars"] = [1, 2]
    GalaxyEndgame.tick(world)
    if str(world["galactic_crisis"].get("state", "")) != "active":
        _fail("Systemic crisis did not start")
        return
    world["credits"] = 300
    world["alloys"] = 200
    for i in range(5):
        if not GalaxyEndgame.defend_crisis(world):
            _fail("Defense action rejected")
            return
    GalaxyEndgame.tick(world)
    if int(world["galactic_crises_survived"]) != 1:
        _fail("Crisis not resolved exactly once")
        return
    GalaxyEndgame.tick(world)
    if int(world["galactic_crises_survived"]) != 1:
        _fail("Crisis reward repeated")
        return
    GalaxyProgress.tick(world)
    if not world["milestones"].has("megaproject") or not world["milestones"].has("crisis"):
        _fail("Endgame achievements not awarded")
        return
    print("GALAXY_PACKAGE_G2_PASS: megaproject, permanent yield, crisis, defense, once-only milestones")
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_PACKAGE_G2_FAILURE: " + message)
    quit(1)
