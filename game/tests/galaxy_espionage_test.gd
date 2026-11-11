extends SceneTree

func _initialize() -> void:
    var settings := GalaxyModel.defaults()
    settings["seed"] = 110303
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    if world["ai"].is_empty():
        _fail("No rivals generated")
        return
    var rival := int(world["ai"][0]["id"])
    if GalaxyStrategy.intelligence_level(world, rival) != 0:
        _fail("Uncontacted rival information leaked")
        return
    if GalaxyStrategy.launch_spy_mission(world, rival, "recon"):
        _fail("Spying on uncontacted rival allowed")
        return
    if not world["contacts"].has(rival):
        world["contacts"].append(rival)
    world["credits"] = 200
    world["tick"] = 10
    if GalaxyStrategy.intelligence_level(world, rival) != 1:
        _fail("First-contact intelligence incorrect")
        return
    if not GalaxyStrategy.launch_spy_mission(world, rival, "recon"):
        _fail("Recon mission rejected")
        return
    if int(world["credits"]) != 180 or GalaxyStrategy.launch_spy_mission(world, rival, "recon"):
        _fail("Recon cost or duplicate mission wrong")
        return
    if not GalaxyModel.save_game(world):
        _fail("Intelligence save failed")
        return
    var loaded := GalaxyModel.load_game()
    if loaded["spy_missions"].size() != 1:
        _fail("Active spy mission not persisted")
        return
    GalaxyStrategy.advance_intelligence(world)
    if GalaxyStrategy.intelligence_level(world, rival) != 1:
        _fail("Mission resolved prematurely")
        return
    world["tick"] = 12
    world["ai_societies"][str(rival)]["factions"]["security"] = 0
    GalaxyStrategy.advance_intelligence(world)
    if GalaxyStrategy.intelligence_level(world, rival) != 2 or not world["spy_missions"].is_empty():
        _fail("Successful reconnaissance not resolved")
        return
    if not GalaxyStrategy.reinforce_counterintelligence(world):
        _fail("Counterintelligence upgrade rejected")
        return
    world["credits"] = 100
    world["tick"] = 14
    GalaxyStrategy.advance_intelligence(world)
    if int(world["credits"]) != 100:
        _fail("Counterintelligence failed to block hostile probe")
        return
    world["counterintelligence"] = 0
    world["tick"] = 21
    GalaxyStrategy.advance_intelligence(world)
    if int(world["credits"]) != 97:
        _fail("Undefended hostile probe had no consequence")
        return
    print("GALAXY_ESPIONAGE_PASS: contact gating, missions, persistence, recon and counterintelligence")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
