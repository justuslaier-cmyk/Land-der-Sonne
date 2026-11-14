extends SceneTree

const UI = preload("res://scripts/galaxy/galaxy_ui.gd")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var ui: Control = UI.new()
    root.add_child(ui)
    await process_frame
    ui._show_help()
    if ui.screen != "help":
        _fail("menu help screen missing")
        return
    var labels: Array = []
    for node in ui.root.get_children():
        if node is Label:
            labels.append(node.text)
    if labels.size() < 8 or not str(labels).contains("SPIELSTÄNDE"):
        _fail("quick-start content incomplete")
        return
    ui._begin_new_game()
    ui.settings["seed"] = 71821
    ui.settings["size"] = 40
    ui.settings["ai_count"] = 2
    ui._show_empire()
    ui._show_review()
    ui._start_game()
    ui._show_help()
    if ui.screen != "help" or ui.world.is_empty():
        _fail("in-game help discarded world")
        return
    ui._show_galaxy()
    if ui.screen != "galaxy":
        _fail("return from help did not restore galaxy")
        return
    # Keyboard navigation: Space toggles time, F1 opens help, Esc returns.
    var was_paused: bool = ui.simulation_paused
    var space := InputEventKey.new()
    space.keycode = KEY_SPACE
    space.pressed = true
    ui._unhandled_key_input(space)
    if ui.simulation_paused == was_paused:
        _fail("space shortcut did not toggle pause")
        return
    var f1 := InputEventKey.new()
    f1.keycode = KEY_F1
    f1.pressed = true
    ui._unhandled_key_input(f1)
    if ui.screen != "help":
        _fail("F1 shortcut did not open help")
        return
    var escape := InputEventKey.new()
    escape.keycode = KEY_ESCAPE
    escape.pressed = true
    ui._unhandled_key_input(escape)
    if ui.screen != "galaxy":
        _fail("Escape shortcut did not return to galaxy")
        return
    print("GALAXY_HELP_PASS: menu, content, in-game navigation and world preservation")
    ui.queue_free()
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_HELP_FAILURE: " + message)
    quit(1)
