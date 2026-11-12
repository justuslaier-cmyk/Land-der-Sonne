extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 11027
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    if GalaxyStrategy.set_welfare(world, -1) or GalaxyStrategy.set_welfare(world, 3):
        _fail("Invalid welfare level accepted")
        return
    if not GalaxyStrategy.set_welfare(world, 2):
        _fail("Welfare policy rejected")
        return
    var replay := world.duplicate(true)
    for year in range(1, 41):
        GalaxyStrategy.tick(world)
        GalaxyStrategy.tick(replay)
        var ledger: Dictionary = world.get("public_budget_ledger", {})
        if int(ledger["opening"]) + int(ledger["tax_receipts"]) - int(ledger["welfare_spending"]) != int(ledger["closing"]):
            _fail("Public treasury balance failed at year %d" % year)
            return
        if int(ledger["welfare_spending"]) < 0 or int(ledger["welfare_spending"]) > int(ledger["tax_receipts"]) + maxi(0, int(ledger["opening"])):
            _fail("Public spending exceeded treasury")
            return
        if not bool(world["society_audit"]["valid"]):
            _fail("Civilian audit failed: " + str(world["society_audit"]["errors"]))
            return
        if JSON.stringify(ledger) != JSON.stringify(replay["public_budget_ledger"]):
            _fail("Treasury replay diverged")
            return
        if int(world["credits"]) != int(replay["credits"]):
            _fail("Treasury replay diverged in credits")
            return
    var before := world.duplicate(true)
    if not GalaxyStrategy.set_welfare(world, 0):
        _fail("Cannot disable welfare")
        return
    GalaxyStrategy.tick(world)
    if int(world["public_budget_ledger"]["welfare_spending"]) != 0:
        _fail("Welfare still spends when disabled")
        return
    if not GalaxyModel.save_game(before, 4):
        _fail("Save failed")
        return
    var loaded := GalaxyModel.load_game(4)
    if JSON.stringify(loaded.get("public_budget_ledger", {})) != JSON.stringify(before["public_budget_ledger"]):
        _fail("Treasury ledger lost in save")
        return
    if int(loaded["policies"].get("welfare", -1)) != 2:
        _fail("Welfare policy lost in save")
        return
    var image: Texture2D = load("res://assets/art/scene_society.svg")
    if image == null:
        _fail("Original society illustration cannot be imported")
        return
    print("GALAXY_PACKAGE_D2_PASS: 40-year budget, welfare, replay, save and art")
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_PACKAGE_D2_FAILURE: " + message)
    quit(1)
