extends SceneTree

const UI = preload("res://scripts/galaxy/galaxy_ui.gd")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var ui: Control = UI.new()
    root.add_child(ui)
    await process_frame
    ui._start_tutorial()
    if ui.screen != "tutorial" or ui.tutorial_step != 0:
        _fail("tutorial start")
        return
    for i in range(1, 4):
        ui.tutorial_step = i
        ui._show_tutorial()
        if ui.screen != "tutorial" or ui.tutorial_step != i:
            _fail("tutorial step %d" % i)
            return
    ui._begin_new_game()
    if ui.screen != "settings":
        _fail("tutorial new-game transition")
        return
    ui._show_menu()
    if ui.screen != "menu":
        _fail("tutorial exit")
        return
    print("GALAXY_TUTORIAL_PASS: onboarding steps, new-game transition, exit")
    ui.queue_free()
    quit(0)

func _fail(reason: String) -> void:
    push_error("GALAXY_TUTORIAL_FAILURE: " + reason)
    quit(1)
