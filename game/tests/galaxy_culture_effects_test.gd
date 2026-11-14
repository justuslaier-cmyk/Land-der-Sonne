extends SceneTree

func _initialize() -> void:
    var empire := GalaxyModel.empire_defaults()
    var low := GalaxyIdentity.culture_defaults(empire)
    var high := low.duplicate(true)
    low["solidarity"] = 10
    low["commercialism"] = 10
    low["openness"] = 10
    low["tradition"] = 10
    high["solidarity"] = 90
    high["commercialism"] = 90
    high["openness"] = 90
    high["tradition"] = 90
    var low_mod: Dictionary = GalaxyIdentity.culture_modifiers(low)
    var high_mod: Dictionary = GalaxyIdentity.culture_modifiers(high)
    for key in ["satisfaction", "capital", "science", "legitimacy"]:
        if int(high_mod[key]) <= int(low_mod[key]):
            _fail("Culture has no distinct effect: " + key)
            return
    for culture in [low, high]:
        var groups: Dictionary = GalaxyIdentity.social_groups(culture)
        if int(groups["traditionalists"]) + int(groups["reformers"]) + int(groups["merchants"]) != 100:
            _fail("Social group percentages do not total 100")
            return
        for key in groups.keys():
            if int(groups[key]) < 0 or int(groups[key]) > 100:
                _fail("Invalid group share")
                return
    var settings := GalaxyModel.defaults()
    settings["seed"] = 202611
    settings["ai_count"] = 2
    var world := GalaxyModel.generate(settings, empire)
    GalaxyStrategy.prepare(world)
    var base: Dictionary = world.duplicate(true)
    var changed: Dictionary = world.duplicate(true)
    base["culture"] = low.duplicate(true)
    changed["culture"] = high.duplicate(true)
    GalaxyCivilians.tick(base)
    GalaxyCivilians.tick(changed)
    if int(changed["civilian_worlds"]["0"]["satisfaction"]) <= int(base["civilian_worlds"]["0"]["satisfaction"]):
        _fail("Solidarity does not affect civilian satisfaction")
        return
    if int(changed["civilian_worlds"]["0"]["private_capital"]) <= int(base["civilian_worlds"]["0"]["private_capital"]):
        _fail("Commercialism does not affect civilian investment")
        return
    var forecast_low: Dictionary = GalaxyStrategy.income_forecast(base)
    var forecast_high: Dictionary = GalaxyStrategy.income_forecast(changed)
    if int(forecast_high["science"]) <= int(forecast_low["science"]):
        _fail("Openness does not affect science forecast")
        return
    print("GALAXY_CULTURE_EFFECTS_PASS: social groups, civilian economy, science forecast")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
