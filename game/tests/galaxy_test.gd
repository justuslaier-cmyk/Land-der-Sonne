extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    print("GALAXY_STAGE: load scripts")
    var model: Script = load("res://scripts/galaxy/galaxy_model.gd")
    var scene: PackedScene = load("res://scenes/galaxy.tscn")
    if model == null or scene == null:
        _fail("Galactic scripts or scene could not load")
        return
    var settings: Dictionary = model.defaults()
    settings["seed"] = 314159
    var empire: Dictionary = model.empire_defaults()
    if model.validate(settings, empire) != "":
        _fail("Default setup invalid")
        return
    print("GALAXY_STAGE: generate")
    var a: Dictionary = model.generate(settings, empire)
    var b: Dictionary = model.generate(settings, empire)
    if JSON.stringify(a) != JSON.stringify(b):
        _fail("Seeded galaxy differs between runs")
        return
    if a["stars"].size() != int(settings["size"]) or a["ai"].size() != int(settings["ai_count"]):
        _fail("Incorrect star or AI count")
        return
    model.advance(a)
    if int(a["tick"]) != 1:
        _fail("Tick did not advance")
        return
    print("GALAXY_STAGE: save")
    if not model.save_game(a):
        _fail("Galaxy save failed")
        return
    var restored: Dictionary = model.load_game()
    if restored.is_empty() or JSON.stringify(restored) != JSON.stringify(a):
        _fail("Galaxy save/load mismatch")
        return
    print("GALAXY_STAGE: instantiate UI")
    var ui: Control = scene.instantiate()
    if ui.get_script() == null:
        _fail("Galactic UI script failed to compile")
        return
    root.add_child(ui)
    await process_frame
    if ui.screen != "menu":
        _fail("Main menu did not initialize")
        return
    print("GALAXY_STAGE: wizard")
    ui._show_settings()
    ui._show_empire()
    ui._show_review()
    print("GALAXY_STAGE: start")
    ui._start_game()
    if ui.screen != "galaxy":
        _fail("New game flow did not reach map")
        return
    print("GALAXY_STAGE: finished")
    ui.queue_free()
    print("GALAXY_TEST_PASS: deterministic galaxy, AI, tick, save/load, menu and new game")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
