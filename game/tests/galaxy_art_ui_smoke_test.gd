extends SceneTree

const UI = preload("res://scripts/galaxy/galaxy_ui.gd")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var ui: Control = UI.new()
    root.add_child(ui)
    ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    ui._show_menu()
    assert(ui.screen == "menu")
    ui._show_settings()
    assert(ui.screen == "settings")
    ui._show_empire()
    assert(ui.screen == "empire")
    ui._show_review()
    assert(ui.screen == "review")
    # All creation-flow art screens must construct without missing texture failures.
    print("GALAXY_ART_UI_SMOKE_PASS")
    ui.queue_free()
    quit(0)
