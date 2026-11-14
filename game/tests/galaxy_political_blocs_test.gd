extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 90202
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    world["tick"] = 10
    world["civilian_approval"] = 95
    world["culture"]["tradition"] = 90
    world["culture"]["openness"] = 5
    world["culture"]["commercialism"] = 5
    var support: Dictionary = GalaxyStrategy.reform_support(world, 2)
    if int(support["support"]) >= 30:
        _fail("Traditionalist opposition did not constrain reform")
        return
    if GalaxyStrategy.propose_rights_reform(world, 2):
        _fail("Reform passed despite insufficient bloc support")
        return
    world["culture"]["tradition"] = 10
    world["culture"]["openness"] = 90
    world["culture"]["commercialism"] = 20
    support = GalaxyStrategy.reform_support(world, 2)
    if int(support["support"]) < 30:
        _fail("Reformist support was not reflected")
        return
    if not GalaxyStrategy.propose_rights_reform(world, 2):
        _fail("Supported reform was rejected")
        return
    var pending: Dictionary = world["governance"]["pending"]
    if int(pending["support"]) != int(support["support"]) or int(pending["opposition"]) != int(support["opposition"]):
        _fail("Bloc votes were not persisted on the proposal")
        return
    var due := int(pending["enact_tick"])
    world["tick"] = due - 1
    GalaxyStrategy.advance_governance(world)
    if int(world["governance"]["rights"]) != 1:
        _fail("Reform enacted before opposition delay")
        return
    world["tick"] = due
    GalaxyStrategy.advance_governance(world)
    if int(world["governance"]["rights"]) != 2:
        _fail("Supported reform was not enacted")
        return
    print("GALAXY_POLITICAL_BLOCS_PASS: opposition veto, reform support and enactment")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
