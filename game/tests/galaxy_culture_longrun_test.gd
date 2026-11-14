extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 55021
    settings["size"] = 20
    settings["ai_count"] = 3
    var original := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(original)
    var replay: Dictionary = original.duplicate(true)
    for year in range(1, 181):
        for world in [original, replay]:
            world["tick"] = year
            GalaxyIdentity.culture_tick(world["culture"], world["empire"], 70, 70, year)
            GalaxyAI.tick(world)
    if JSON.stringify(original["culture"]) != JSON.stringify(replay["culture"]):
        _fail("Player culture diverged between deterministic replays")
        return
    if JSON.stringify(original["ai_cultures"]) != JSON.stringify(replay["ai_cultures"]):
        _fail("AI cultures diverged between deterministic replays")
        return
    var culture: Dictionary = original["culture"]
    if int(culture["generation"]) != 9 or culture["history"].size() != 8:
        _fail("Expected nine generations with eight bounded snapshots")
        return
    var before := JSON.stringify(culture["history"])
    GalaxyIdentity.culture_tick(culture, original["empire"], 70, 70, 180)
    if JSON.stringify(culture["history"]) != before or int(culture["generation"]) != 9:
        _fail("Same-year culture update duplicated generation")
        return
    for field in ["tradition", "openness", "solidarity", "commercialism"]:
        if int(culture[field]) < 0 or int(culture[field]) > 100:
            _fail("Culture escaped its numerical bounds")
            return
    var groups: Dictionary = GalaxyIdentity.social_groups(culture)
    if int(groups["traditionalists"]) + int(groups["reformers"]) + int(groups["merchants"]) != 100:
        _fail("Social group proportions do not sum to 100")
        return
    if not GalaxyModel.save_game(original):
        _fail("Save after long-run simulation failed")
        return
    var loaded := GalaxyModel.load_game()
    if JSON.stringify(loaded.get("culture", {})) != JSON.stringify(original["culture"]):
        _fail("Long-run cultural history lost during save/load")
        return
    if JSON.stringify(loaded.get("ai_cultures", {})) != JSON.stringify(original["ai_cultures"]):
        _fail("Long-run AI cultures lost during save/load")
        return
    print("GALAXY_CULTURE_LONGRUN_PASS: 180 years, 9 generations, bounded history, AI replay, persistence")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
