extends SceneTree

const UI = preload("res://scripts/galaxy/galaxy_ui.gd")
const Comfort = preload("res://scripts/galaxy/galaxy_comfort.gd")
const ART = preload("res://assets/art/ui_comfort_panel.svg")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    if ART == null:
        _fail("Missing imported original options artwork")
        return
    var ui: Control = UI.new()
    root.add_child(ui)
    await process_frame
    ui._open_options("menu")
    if ui.screen != "options" or ui.root.get_child_count() < 5:
        _fail("Options controls not visible")
        return
    ui._set_comfort("ui_scale", 120)
    ui._set_comfort("volume", 35)
    ui._set_comfort("muted", true)
    var stored := Comfort.load_preferences()
    if int(stored["ui_scale"]) != 120 or int(stored["volume"]) != 35 or not bool(stored["muted"]):
        _fail("Preferences did not survive reload")
        return
    ui._back_from_options()
    if ui.screen != "menu":
        _fail("Options menu back-navigation failed")
        return
    ui._start_tutorial()
    for step in range(4):
        ui.tutorial_step = step
        ui._show_tutorial()
        if ui.screen != "tutorial":
            _fail("Tutorial navigation failed")
            return
    ui._begin_new_game()
    ui.settings["seed"] = 42155
    ui.settings["size"] = 40
    ui.settings["ai_count"] = 2
    ui._show_empire()
    ui._show_review()
    ui._start_game()
    if ui.screen != "galaxy" or not ui.simulation_paused or ui.world.is_empty():
        _fail("First-play must start paused and reachable")
        return
    var hint_found := false
    for node in ui.root.get_children():
        if node.name == "OnboardingHint":
            hint_found = true
    if not hint_found:
        _fail("Contextual first-play guidance missing")
        return
    ui._open_options("galaxy")
    ui._back_from_options()
    if ui.screen != "galaxy":
        _fail("In-game options lost navigation")
        return
    ui._show_save_slots()
    if ui.screen != "save_slots":
        _fail("Save slot view inaccessible")
        return
    ui._show_galaxy()
    ui._toggle_auto_survey()
    if not bool(ui.world["auto_survey"]):
        _fail("Player automation toggle inaccessible")
        return
    ui._set_comfort("ui_scale", 100)
    ui._set_comfort("volume", 80)
    ui._set_comfort("muted", false)
    ui.queue_free()
    print("GALAXY_COMFORT_FLOW_PASS: options persistence, art, tutorial, first play, save slots, automation")
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_COMFORT_FLOW_FAILURE: " + message)
    quit(1)
