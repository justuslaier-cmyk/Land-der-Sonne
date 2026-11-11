extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 90303
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    var governance: Dictionary = world["governance"]
    if int(governance["legitimacy"]) != 60 or int(governance["crisis_years"]) != 0:
        _fail("Governance defaults missing")
        return
    world["tick"] = int(governance["next_transition"]) - 1
    var original := int(governance["mandate"])
    GalaxyStrategy.advance_institutions(world)
    if int(governance["mandate"]) != original:
        _fail("Institutional transition happened too early")
        return
    world["tick"] += 1
    world["civilian_approval"] = 85
    world["culture"]["tradition"] = 5
    world["culture"]["openness"] = 90
    world["culture"]["commercialism"] = 5
    GalaxyStrategy.advance_institutions(world)
    var government := int(world["empire"].get("government", 0))
    var cadence: int = [8, 12, 10, 6][government]
    if int(governance["next_transition"]) != int(world["tick"]) + cadence:
        _fail("Government-specific transition cadence was ignored")
        return
    if government == 0 and int(governance["mandate"]) != 1:
        _fail("Republic did not follow dominant reformist bloc")
        return
    var expected_mandate := int(governance["mandate"])
    if not GalaxyModel.save_game(world):
        _fail("Political save failed")
        return
    var loaded := GalaxyModel.load_game()
    if int(loaded["governance"]["mandate"]) != expected_mandate or int(loaded["governance"]["next_transition"]) != int(governance["next_transition"]):
        _fail("Institutional transition was not persisted")
        return
    governance["legitimacy"] = 26
    governance["crisis_years"] = 0
    world["civilian_approval"] = 0
    world["stability"] = 20
    for i in range(3):
        world["tick"] += 1
        GalaxyStrategy.advance_institutions(world)
    if int(governance["crisis_years"]) != 3 or int(world["stability"]) >= 20:
        _fail("Sustained legitimacy crisis did not penalize stability")
        return
    governance["legitimacy"] = 55
    GalaxyStrategy.advance_institutions(world)
    if int(governance["crisis_years"]) != 0:
        _fail("Recovered legitimacy did not end crisis")
        return
    print("GALAXY_INSTITUTIONS_PASS: transition schedule, political mandate, save and legitimacy crisis")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
