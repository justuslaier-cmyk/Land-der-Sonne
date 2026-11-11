extends SceneTree

# End-to-end integration: generation -> initialization -> research -> economy ->
# AI simulation -> persistence -> restore -> UI navigation -> event resolution.
const UI = preload("res://scripts/galaxy/galaxy_ui.gd")

func _initialize() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("GALAXY_INTEGRATION_FAILURE: " + message)
    quit(1)

func _run() -> void:
    var ui: Control = UI.new()
    root.add_child(ui)
    await process_frame
    ui._begin_new_game()
    if ui.screen != "settings":
        _fail("new game wizard did not open")
        return
    ui.settings["seed"] = 173129
    ui.settings["size"] = 40
    ui.settings["ai_count"] = 2
    ui._show_empire()
    ui._show_review()
    if ui.screen != "review":
        _fail("empire review did not open")
        return
    ui._start_game()
    if ui.screen != "galaxy" or ui.world.is_empty():
        _fail("galaxy was not created")
        return
    if ui.world["stars"].size() != 40 or ui.world["ai"].size() != 2:
        _fail("galaxy generation parameters were not applied")
        return
    if not ui.world.has("planet_colonies") or ui.world["planet_colonies"].is_empty():
        _fail("home colony not initialized")
        return
    var initial_tick := int(ui.world.get("tick", 0))
    for i in range(3):
        GalaxyStrategy.tick(ui.world)
        if str(ui.world.get("pending_event", "")) != "":
            ui.world["pending_event"] = ""
    if int(ui.world.get("tick", 0)) <= initial_tick:
        _fail("simulation did not advance")
        return
    if not ui.world.has("ai") or ui.world["ai"].size() != 2:
        _fail("AI empires disappeared during simulation")
        return
    ui._research()
    if ui.screen != "research":
        _fail("research screen not integrated")
        return
    ui._show_galaxy()
    ui._economy_report()
    if ui.screen != "economy":
        _fail("economy report not integrated")
        return
    ui._show_galaxy()
    ui._diplomacy()
    if ui.screen != "diplomacy":
        _fail("diplomacy not integrated")
        return
    ui._show_galaxy()
    ui._fleet()
    if ui.screen != "fleet":
        _fail("fleet screen not integrated")
        return
    ui._show_galaxy()
    ui.world["pending_event"] = "market"
    ui._show_event()
    if ui.screen != "event":
        _fail("event screen not integrated")
        return
    ui._resolve_system_event(1)
    if str(ui.world.get("pending_event", "")) != "":
        _fail("event resolution did not clear pending event")
        return
    ui._show_galaxy()
    ui.selected = 1
    ui._save()
    var before := JSON.stringify(ui.world)
    ui._load_game()
    if ui.screen != "galaxy":
        _fail("load did not restore galaxy UI")
        return
    if JSON.stringify(ui.world) != before:
        _fail("save/load altered strategic world")
        return
    if ui.selected != 1:
        _fail("selected system not restored")
        return
    print("GALAXY_INTEGRATION_PASS: new game, AI ticks, research, economy, diplomacy, fleet, events, persistence")
    ui.queue_free()
    quit(0)
