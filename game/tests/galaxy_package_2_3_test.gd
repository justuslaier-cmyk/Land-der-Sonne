extends SceneTree

func _initialize() -> void:
    var world := GalaxyModel.generate(GalaxyModel.defaults(), GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    world["tick"] = 10
    world["wars"] = [1, 2]
    world["credits"] = 500
    world["science"] = 500
    world["alloys"] = 500
    world["research_level"] = 4
    var event: Dictionary = GalaxyNarrative.EVENTS[3]
    if not GalaxyNarrative.apply(world, event):
        _fail("Incident did not start")
        return
    world["tick"] = 12
    if not GalaxyNarrative.pending_followups(world).has("border_incident"):
        _fail("Delayed followup missing")
        return
    var credits_before := int(world["credits"])
    if not GalaxyNarrative.resolve_followup(world, "border_incident", "invest"):
        _fail("Investment option failed")
        return
    if int(world["credits"]) != credits_before - 8 or GalaxyNarrative.resolve_followup(world, "border_incident", "invest"):
        _fail("Followup charged incorrectly or repeated")
        return
    if not GalaxyModel.save_game(world, 3):
        _fail("Save failed")
        return
    var loaded := GalaxyModel.load_game(3)
    if not GalaxyNarrative.pending_followups(loaded).is_empty() or loaded["narrative_decisions"].size() != 1:
        _fail("Followup did not persist")
        return
    loaded["tick"] = 70
    GalaxyEndgame.tick(loaded)
    if str(loaded["galactic_crisis"].get("id", "")) != "fracture":
        _fail("Fracture crisis absent")
        return
    for i in range(3):
        if not GalaxyEndgame.research_crisis(loaded):
            _fail("Research response unavailable")
            return
    GalaxyEndgame.tick(loaded)
    if int(loaded["galactic_crises_survived"]) != 1:
        _fail("Scientific fracture response failed")
        return
    loaded["tick"] = 110
    loaded["ancient_history"] = {"completed": true}
    GalaxyEndgame.tick(loaded)
    if str(loaded["galactic_crisis"].get("id", "")) != "ancient":
        _fail("Ancient crisis absent")
        return
    for i in range(5):
        if not GalaxyEndgame.defend_crisis(loaded):
            _fail("Fleet response unavailable")
            return
    GalaxyEndgame.tick(loaded)
    if int(loaded["galactic_crises_survived"]) != 2:
        _fail("Military ancient response failed")
        return
    loaded["megaproject_completed"] = ["unity_beacon"]
    GalaxyProgress.evaluate_victories(loaded)
    if not loaded["victory_paths"].has("resilience"):
        _fail("Resilience endgame not recognized")
        return
    if not GalaxyModel.save_game(loaded, 3):
        _fail("Endgame save failed")
        return
    var resumed := GalaxyModel.load_game(3)
    if resumed["victory_paths"] != loaded["victory_paths"] or resumed["crisis_response_history"].size() != loaded["crisis_response_history"].size():
        _fail("Endgame history not persisted")
        return
    var count := resumed["victory_paths"].size()
    GalaxyProgress.evaluate_victories(resumed)
    if resumed["victory_paths"].size() != count:
        _fail("Victory duplicated")
        return
    print("GALAXY_PACKAGE_2_3_PASS: delayed followup, distinct crisis solutions, persistent sandbox victory")
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_PACKAGE_2_3_FAILURE: " + message)
    quit(1)
