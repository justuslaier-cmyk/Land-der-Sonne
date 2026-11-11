extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 777
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    if world["milestones"].size() != 0:
        _fail("Milestones awarded before play")
        return
    var targets := GalaxyProgress.targets()
    if targets.size() != GalaxyProgress.MILESTONES.size():
        _fail("Goal definitions inconsistent")
        return
    world["known"] = range(12)
    world["contacts"] = [1, 2, 3]
    world["research_level"] = 4
    GalaxyProgress.tick(world)
    for id in ["cartographer", "first_contact", "research"]:
        if not world["milestones"].has(id):
            _fail("Missing earned goal " + id)
            return
    var achieved: int = world["milestones"].size()
    GalaxyProgress.tick(world)
    if world["milestones"].size() != achieved:
        _fail("Milestone awarded twice")
        return
    if not GalaxyModel.save_game(world):
        _fail("Goal persistence save failed")
        return
    if JSON.stringify(GalaxyModel.load_game()) != JSON.stringify(world):
        _fail("Goal persistence roundtrip failed")
        return
    print("GALAXY_PROGRESS_PASS")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
