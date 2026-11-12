extends SceneTree

func _initialize() -> void:
    var world := GalaxyModel.generate(GalaxyModel.defaults(), GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    GalaxyAI.prepare(world)
    if world["ai"].is_empty():
        _fail("No rivals")
        return
    var rival := int(world["ai"][0]["id"])
    var key := str(rival)
    world["tick"] = 1
    world["ai_treasury"][key] = 100
    GalaxyAI.tick(world)
    if not world["ai_fleet_logistics"].has(key):
        _fail("Missing fleet supply ledger")
        return
    var ledger: Dictionary = world["ai_fleet_logistics"][key]
    if int(ledger["maintenance_paid"]) <= 0:
        _fail("Fleet maintenance not paid")
        return
    if int(world["ai_treasury"][key]) >= 100:
        _fail("Maintenance did not debit treasury")
        return
    world["wars"] = [rival]
    world["tick"] = 2
    GalaxyAI.tick(world)
    if int(world["ai_war_exhaustion"][key]) <= 0:
        _fail("War exhaustion did not rise")
        return
    var assessment: Dictionary = world["ai_military_assessments"][key]
    if not assessment.has("war_exhaustion") or not assessment.has("upkeep_paid"):
        _fail("AI assessment missing causal logistics")
        return
    print("GALAXY_PACKAGE_F3_PASS: paid upkeep, fleet supply, exhaustion, explainable assessment")
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_PACKAGE_F3_FAILURE: " + message)
    quit(1)
