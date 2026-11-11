extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 90101
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    world["tick"] = 10
    world["civilian_approval"] = 90
    var gov := int(world["empire"].get("government", 0))
    var delay: int = [3, 2, 4, 3][gov]
    if not GalaxyStrategy.propose_rights_reform(world, 2):
        _fail("Valid rights reform was rejected")
        return
    if GalaxyStrategy.propose_rights_reform(world, 0):
        _fail("Parallel reform was accepted")
        return
    if int(world["governance"]["rights"]) != 1:
        _fail("Reform took effect without delay")
        return
    world["tick"] = 10 + delay - 1
    GalaxyStrategy.advance_governance(world)
    if int(world["governance"]["rights"]) != 1:
        _fail("Reform enacted before deadline")
        return
    if not GalaxyModel.save_game(world):
        _fail("Governance save failed")
        return
    var loaded := GalaxyModel.load_game()
    if int(loaded["governance"]["pending"]["enact_tick"]) != 10 + delay:
        _fail("Pending reform was not persisted")
        return
    world["tick"] = 10 + delay
    GalaxyStrategy.advance_governance(world)
    if int(world["governance"]["rights"]) != 2 or not world["governance"]["pending"].is_empty():
        _fail("Reform did not enact at deadline")
        return
    if GalaxyStrategy.propose_rights_reform(world, 0):
        _fail("Reform cooldown was bypassed")
        return
    world["tick"] += 4
    world["civilian_approval"] = 0
    if GalaxyStrategy.propose_rights_reform(world, 0):
        _fail("Reform passed without necessary public approval")
        return
    world["civilian_approval"] = 90
    if not GalaxyStrategy.propose_rights_reform(world, 0):
        _fail("Reform was blocked after cooldown and restored approval")
        return
    print("GALAXY_GOVERNANCE_REFORMS_PASS: approval, delay, persistence, enactment and cooldown")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
