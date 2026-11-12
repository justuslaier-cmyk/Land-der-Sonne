extends SceneTree

# Persistent objectives, funded peace and historical consequences.
func _initialize() -> void:
    var cfg := GalaxyModel.defaults()
    cfg["seed"] = 988012
    var world := GalaxyModel.generate(cfg, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    if world["ai"].is_empty():
        _fail("Missing rival")
        return
    var rival := int(world["ai"][0]["id"])
    world["contacts"].append(rival)
    world["credits"] = 100
    if not GalaxyStrategy.declare_war(world, rival):
        _fail("Cannot declare eligible war")
        return
    var goal: Dictionary = world["war_goals"][str(rival)]
    var target := int(goal["target"])
    if target < 0 or int(world["stars"][target]["owner"]) != rival:
        _fail("War goal not a rival-held system")
        return
    if not GalaxyModel.save_game(world, 3):
        _fail("Cannot save active objective")
        return
    var loaded := GalaxyModel.load_game(3)
    if int(loaded["war_goals"][str(rival)]["target"]) != target:
        _fail("War goal lost on load")
        return
    world["stars"][target]["owner"] = 0
    world["credits"] = 34
    if GalaxyStrategy.offer_peace(world, rival):
        _fail("Underfunded objective peace accepted")
        return
    world["credits"] = 35
    if not GalaxyStrategy.offer_peace(world, rival):
        _fail("Achieved objective not recognized")
        return
    if int(world["credits"]) != 0 or not bool(world["peace_history"][-1]["achieved"]) or int(world["peace_history"][-1]["cost"]) != 35:
        _fail("Peace objective and cost not recorded")
        return
    if world["war_goals"].has(str(rival)) or world["wars"].has(rival):
        _fail("Ended war retained active goal")
        return
    if not GalaxyModel.save_game(world, 3):
        _fail("Cannot save settlement")
        return
    loaded = GalaxyModel.load_game(3)
    if loaded["peace_history"].size() != 1 or int(loaded["peace_history"][0]["goal"]) != target:
        _fail("Peace settlement lost on load")
        return
    print("GALAXY_WAR_GOAL_PEACE_PASS: territorial objective, funded concession and persistence")
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_WAR_GOAL_PEACE_FAILURE: " + message)
    quit(1)
