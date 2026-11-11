extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var scene: PackedScene = load("res://scenes/galaxy.tscn")
    if scene == null:
        _fail("Missing galaxy scene")
        return
    var ui: Control = scene.instantiate()
    root.add_child(ui)
    await process_frame
    if ui.screen != "menu":
        _fail("Menu not visible at launch")
        return
    ui._begin_new_game()
    if ui.screen != "settings":
        _fail("New game did not open galaxy settings")
        return
    ui.settings["size"] = 100
    ui.settings["seed"] = 314159
    ui._show_empire()
    ui.empire["name"] = "Test Republic"
    ui._show_review()
    if ui.screen != "review" or int(ui.settings["size"]) != 100:
        _fail("Back/forward wizard lost the draft")
        return
    ui._show_empire()
    if str(ui.empire["name"]) != "Test Republic":
        _fail("Review back-navigation discarded empire")
        return
    ui._show_settings()
    if int(ui.settings["seed"]) != 314159:
        _fail("Back-navigation discarded seed")
        return
    ui._reset_new_game()
    if ui.settings != GalaxyModel.defaults() or ui.empire != GalaxyModel.empire_defaults():
        _fail("Reset did not restore complete defaults")
        return
    ui.settings["size"] = 100
    ui.empire["name"] = "Discard this"
    ui._cancel_new_game()
    if ui.screen != "menu" or ui.settings != GalaxyModel.defaults() or ui.empire != GalaxyModel.empire_defaults():
        _fail("Cancel did not discard wizard draft")
        return
    ui._begin_new_game()
    for template_id in range(3):
        ui._apply_empire_template(template_id)
        if GalaxyModel.validate(ui.settings, ui.empire) != "":
            _fail("Preset " + str(template_id) + " is invalid")
            return
    ui._apply_empire_template(1)
    if str(ui.empire["name"]) != "Sternenkonklave" or int(ui.empire["government"]) != 2:
        _fail("Technocracy preset did not apply")
        return
    ui.settings["shape"] = 99
    if GalaxyModel.validate(ui.settings, ui.empire) == "":
        _fail("Invalid galaxy shape accepted")
        return
    ui.settings["shape"] = 0
    ui.settings["habitable"] = 101
    if GalaxyModel.validate(ui.settings, ui.empire) == "":
        _fail("Invalid habitability accepted")
        return
    ui.settings["habitable"] = 30
    ui.empire["homeworld"] = ""
    if GalaxyModel.validate(ui.settings, ui.empire) == "":
        _fail("Missing homeworld accepted")
        return
    ui._apply_empire_template(0)
    ui._begin_new_game()
    ui.settings["seed"] = 314159
    ui.empire["name"] = ""
    ui._show_review()
    if GalaxyModel.validate(ui.settings, ui.empire) == "":
        _fail("Invalid empire was accepted")
        return
    ui._start_game()
    if ui.screen == "galaxy":
        _fail("Invalid empire started game")
        return
    ui.empire["name"] = "Seeded Empire"
    ui._start_game()
    if ui.screen != "galaxy" or int(ui.world["settings"]["seed"]) != 314159:
        _fail("Valid game did not start with selected seed")
        return
    print("GALAXY_WIZARD_PASS: start, navigation, reset, cancel, validation and seed")
    ui.queue_free()
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
