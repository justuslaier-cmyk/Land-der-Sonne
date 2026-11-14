extends SceneTree

func _initialize() -> void:
    var base := GalaxyModel.empire_defaults()
    if GalaxyIdentity.validate(base) != "":
        _fail("Default civilization identity invalid")
        return
    var customized := base.duplicate(true)
    customized["civics"] = ["guilds", "frontier"]
    customized["traits"] = ["strong", "fertile", "solitary"]
    customized["ethic"] = "mercantile"
    customized["government"] = 1
    if GalaxyIdentity.validate(customized) != "":
        _fail("Valid multi-trait civilization rejected")
        return
    var modifiers := GalaxyIdentity.modifiers(customized)
    if int(modifiers["growth"]) <= 0 or int(modifiers["production"]) <= 0:
        _fail("Civics and biology do not modify simulation")
        return
    customized["traits"] = ["fertile", "slow_breeding"]
    if GalaxyIdentity.validate(customized) == "":
        _fail("Contradictory reproductive traits accepted")
        return
    customized["traits"] = ["strong", "fertile", "solitary"]
    var settings := GalaxyModel.defaults()
    settings["seed"] = 919191
    settings["ai_count"] = 3
    var world := GalaxyModel.generate(settings, customized)
    GalaxyStrategy.prepare(world)
    for rival in world["ai"]:
        if not rival.has("civics") or not rival.has("ethic") or not rival.has("traits"):
            _fail("AI empire has no cultural identity")
            return
    var before := int(world["civilian_worlds"]["0"]["population"])
    for i in range(3):
        GalaxyStrategy.tick(world)
    if int(world["civilian_worlds"]["0"]["population"]) <= before:
        _fail("Autonomous species population did not grow")
        return
    if not GalaxyModel.save_game(world):
        _fail("Identity save failed")
        return
    var loaded := GalaxyModel.load_game()
    if JSON.stringify(loaded) != JSON.stringify(world):
        _fail("Civilization identity persistence failed")
        return
    print("GALAXY_IDENTITY_PASS")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
