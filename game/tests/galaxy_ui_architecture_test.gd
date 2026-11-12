extends SceneTree

const UI = preload("res://scripts/galaxy/galaxy_ui.gd")
const Components = preload("res://scripts/galaxy/galaxy_ui_components.gd")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var ui: Control = UI.new()
    root.add_child(ui)
    await process_frame
    ui.settings["seed"] = 71821
    ui.settings["size"] = 40
    ui.settings["ai_count"] = 2
    ui._start_game()
    if ui.screen != "galaxy" or not is_instance_valid(ui.system_search):
        _fail("Search/navigation controls not mounted")
        return
    var known_id := int(ui.world["known"][0])
    var name := str(ui.world["stars"][known_id]["name"])
    if Components.find_known_system(ui.world, name.to_lower()) != known_id:
        _fail("Case insensitive known-system lookup failed")
        return
    var previous: int = ui.selected
    ui._search_system("unknown-system-xyz")
    if ui.selected != previous or not ui.notice.contains("Kein bekanntes System"):
        _fail("Missing search result must not change selection")
        return
    ui._search_system(name)
    if ui.selected != known_id or int(ui.world["selected"]) != known_id:
        _fail("Search result did not select system")
        return
    var button := Components.action_button("FORSCHUNG", func(): pass)
    if button.tooltip_text.is_empty() or button.focus_mode != Control.FOCUS_ALL or button.icon == null:
        _fail("Shared action component missing focus, tooltip or icon")
        return
    var ctrl_f := InputEventKey.new()
    ctrl_f.keycode = KEY_F
    ctrl_f.ctrl_pressed = true
    ctrl_f.pressed = true
    ui._unhandled_key_input(ctrl_f)
    if ui.get_viewport().gui_get_focus_owner() != ui.system_search:
        _fail("Ctrl+F did not focus system search")
        return
    ui.system_search.release_focus()
    ui._research()
    var escape := InputEventKey.new()
    escape.keycode = KEY_ESCAPE
    escape.pressed = true
    ui._unhandled_key_input(escape)
    if ui.screen != "galaxy":
        _fail("Escape did not return from report")
        return
    print("GALAXY_UI_ARCHITECTURE_PASS: shared components, search, keyboard, navigation")
    ui.queue_free()
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_UI_ARCHITECTURE_FAILURE: " + message)
    quit(1)
