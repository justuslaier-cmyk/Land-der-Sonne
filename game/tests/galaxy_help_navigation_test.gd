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
    print("GALAXY_HELP_PASS: menu, content, in-game navigation and world preservation")
    ui.queue_free()
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_HELP_FAILURE: " + message)
    quit(1)
