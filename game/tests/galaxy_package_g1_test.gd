extends SceneTree

func _initialize() -> void:
    var world := GalaxyModel.generate(GalaxyModel.defaults(), GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    GalaxyNarrative.prepare(world)
    var event: Dictionary = GalaxyNarrative.EVENTS[1]
    if GalaxyNarrative.apply(world, event):
        _fail("Research event without exchange")
        return
    world["research_exchange_ledger"] = {"science_granted": 3}
    world["tick"] = 5
    var initial := int(world["science"])
    if not GalaxyNarrative.apply(world, event):
        _fail("Eligible event rejected")
        return
    if int(world["science"]) != initial + 10:
        _fail("Event did not change science")
        return
    if GalaxyNarrative.apply(world, event):
        _fail("Cooldown allowed duplicate")
        return
    if world["narrative_chronicle"].size() != 1:
        _fail("Duplicate chronicle entry")
        return
    var replay := world.duplicate(true)
    GalaxyNarrative.tick(world)
    GalaxyNarrative.tick(replay)
    if JSON.stringify(world["narrative_chronicle"]) != JSON.stringify(replay["narrative_chronicle"]):
        _fail("Replay diverged")
        return
    world["tick"] = 20
    if not GalaxyNarrative.apply(world, event):
        _fail("Cooldown did not expire")
        return
    print("GALAXY_PACKAGE_G1_PASS: causal triggers, effects, cooldown, chronicle, replay")
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_PACKAGE_G1_FAILURE: " + message)
    quit(1)
