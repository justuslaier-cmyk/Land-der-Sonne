extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 110202
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    if world["ai"].is_empty():
        _fail("No rival empires")
        return
    var rival := int(world["ai"][0]["id"])
    if not world["contacts"].has(rival):
        world["contacts"].append(rival)
    world["relations"][str(rival)] = 90
    world["credits"] = 200
    world["tick"] = 10
    if not GalaxyStrategy.negotiate_treaty(world, rival, "alliance"):
        _fail("Alliance negotiation rejected")
        return
    if int(world["credits"]) != 160:
        _fail("Alliance deposit incorrect")
        return
    world["tick"] = 12
    GalaxyStrategy.advance_diplomacy(world)
    if not world["alliances"].has(rival):
        _fail("Alliance not ratified")
        return
    if GalaxyStrategy.declare_war(world, rival):
        _fail("War declaration bypassed defensive alliance")
        return
    if not GalaxyStrategy.negotiate_treaty(world, rival, "dependency"):
        _fail("Economic dependency negotiation rejected")
        return
    world["tick"] = 14
    GalaxyStrategy.advance_diplomacy(world)
    if GalaxyStrategy.dependency_income(world) != 4:
        _fail("Annual economic tribute missing")
        return
    if not GalaxyModel.save_game(world):
        _fail("Alliance save failed")
        return
    var loaded := GalaxyModel.load_game()
    if loaded.is_empty():
        _fail("Save file rejected during load")
        return
    var alliance_found := false
    for member in loaded.get("alliances", []):
        if int(member) == rival:
            alliance_found = true
    if not alliance_found:
        _fail("Alliance did not persist for rival %d; saved alliances: %s" % [rival, str(loaded.get("alliances", []))])
        return
    var dependency: Dictionary = loaded.get("diplomatic_dependencies", {}).get(str(rival), {})
    if int(dependency.get("tribute", -1)) != 4:
        _fail("Dependency tribute did not persist for rival %d; saved dependency: %s" % [rival, str(dependency)])
        return
    if GalaxyStrategy.negotiate_treaty(loaded, rival, "alliance"):
        _fail("Duplicate alliance accepted")
        return
    print("GALAXY_ALLIANCES_PASS: alliance, war protection, economic dependency and persistence")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
