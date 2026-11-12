extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 74129
    var baseline := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(baseline)
    GalaxyAI.prepare(baseline)
    if baseline["ai"].is_empty():
        _fail("No rival available")
        return
    var id := int(baseline["ai"][0]["id"])
    var key := str(id)
    var fleet_index := -1
    for i in range(baseline["ai_fleets"].size()):
        if int(baseline["ai_fleets"][i]["owner"]) == id:
            fleet_index = i
            break
    if fleet_index < 0:
        _fail("Missing rival fleet")
        return
    baseline["ai_fleets"][fleet_index]["strength"] = 1
    baseline["tick"] = id % 6
    for opening in [28, 29, 45, 46]:
        var world := baseline.duplicate(true)
        world["ai_treasury"][key] = opening
        var strength_before := int(world["ai_fleets"][fleet_index]["strength"])
        GalaxyAI.tick(world)
        var closing := int(world["ai_treasury"][key])
        var paid := int(world["ai_fleet_logistics"][key]["maintenance_paid"])
        if paid != 1:
            _fail("Upkeep not charged")
            return
        if closing < 0 or closing > opening - paid:
            _fail("Treasury created credits or went negative")
            return
        if opening == 28 and closing != 27:
            _fail("Recruitment used pre-upkeep treasury")
            return
        if opening == 29 and closing != 0:
            _fail("Recruitment did not charge both upkeep and construction")
            return
        if opening == 45 and closing != 16:
            _fail("Expansion used stale pre-recruitment balance")
            return
        if opening == 46 and closing != 17:
            _fail("Expansion ignored construction costs")
            return
        if opening == 28 and int(world["ai_fleets"][fleet_index]["strength"]) != strength_before:
            _fail("Unaffordable recruitment increased fleet strength")
            return
    print("GALAXY_AI_TREASURY_REGRESSION_PASS: upkeep, recruitment and expansion share one live balance")
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_AI_TREASURY_REGRESSION_FAILURE: " + message)
    quit(1)
