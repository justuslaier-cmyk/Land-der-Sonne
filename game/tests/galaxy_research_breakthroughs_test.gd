extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 100303
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    world["science"] = 200
    world["artifacts"] = [{"culture": "Die Letzten von Aeth", "discipline": "Sternensegel",
        "origin": "Testsystem", "analyzed": false}]
    if not GalaxyLore.analyze_artifact(world, 0):
        _fail("Valid archaeological analysis rejected")
        return
    if int(world["science"]) != 170 or int(world["research_insights"]["propulsion"]) != 1:
        _fail("Archaeological insight not granted or analysis cost wrong")
        return
    if GalaxyLore.analyze_artifact(world, 0):
        _fail("Artifact could be analysed twice")
        return
    if GalaxySystems.register_archaeological_insight(world, "Sternensegel"):
        _fail("Duplicate discipline granted another insight")
        return
    if int(GalaxySystems.research_preview(world, "propulsion")["cost"]) != 15:
        _fail("One-time insight did not discount research")
        return
    if not GalaxySystems.start_research(world, "propulsion"):
        _fail("Discounted propulsion research rejected")
        return
    if int(world["science"]) != 155 or int(world["research_insights"]["propulsion"]) != 0:
        _fail("Insight discount was not consumed exactly once")
        return
    if not bool(world["research_breakthroughs"][0]["consumed"]):
        _fail("Discovery history not marked consumed")
        return
    if not GalaxyModel.save_game(world):
        _fail("Archaeological research save failed")
        return
    var loaded := GalaxyModel.load_game()
    GalaxyStrategy.prepare(loaded)
    if int(loaded["research_insights"]["propulsion"]) != 0 or loaded["research_breakthroughs"].size() != 1:
        _fail("Breakthrough state not persisted")
        return
    if GalaxySystems.register_archaeological_insight(loaded, "Sternensegel"):
        _fail("Reloading permitted duplicate insight")
        return
    if int(GalaxySystems.research_preview(loaded, "industry")["cost"]) != 25:
        _fail("Insight incorrectly discounted other research field")
        return
    print("GALAXY_RESEARCH_BREAKTHROUGHS_PASS: artifact, one-time insight, cost and persistence")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
