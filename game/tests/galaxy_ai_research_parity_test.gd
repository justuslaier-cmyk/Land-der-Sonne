extends SceneTree

func _initialize() -> void:
    var cfg := GalaxyModel.defaults()
    cfg["seed"] = 641913
    var world := GalaxyModel.generate(cfg, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    if world["ai"].is_empty():
        _fail("No rival")
        return
    var rival: Dictionary = world["ai"][0]
    var key := str(rival["id"])
    world["ai_science"][key] = 24
    var fields: Dictionary = world["ai_research_fields"][key]
    var field := "propulsion" if int(rival["temperament"]) == 0 else "industry" if int(rival["temperament"]) == 1 else "society"
    world["tick"] = int(rival["id"]) % 5
    GalaxyAI.tick(world)
    if int(fields[field]) != 0 or int(world["ai_science"][key]) != 24:
        _fail("AI researched without 25 science")
        return
    world["ai_science"][key] = 25
    GalaxyAI.tick(world)
    if int(fields[field]) != 1 or int(world["ai_science"][key]) != 0:
        _fail("AI research did not pay same basic science cost")
        return
    if not GalaxyModel.save_game(world, 3):
        _fail("AI research save failed")
        return
    var loaded := GalaxyModel.load_game(3)
    if int(loaded["ai_research_fields"][key][field]) != 1 or int(loaded["ai_science"][key]) != 0:
        _fail("AI research not persistent")
        return
    print("GALAXY_AI_RESEARCH_PARITY_PASS: paid unlock, resource shortage, persistence")
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_AI_RESEARCH_PARITY_FAILURE: " + message)
    quit(1)
