extends SceneTree

# Prevent reintroducing scrolling walls of text in the four setup screens.
const UI = preload("res://scripts/galaxy/galaxy_ui.gd")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var ui: Control = UI.new()
    root.add_child(ui)
    await process_frame
    for page in ["menu", "settings", "empire", "review"]:
        match page:
            "menu":
                ui._show_menu()
            "settings":
                ui._show_settings()
            "empire":
                for tab in range(4):
                    ui.creation_tab = tab
                    ui._show_empire()
                    await process_frame
                    if ui.screen != "empire":
                        _fail("Empire creation tab failed to render")
                        return
            "review":
                ui._show_review()
        await process_frame
        if ui.screen != page:
            _fail("Screen transition failed: " + page)
            return
        for node in ui.find_children("*", "ScrollContainer", true, false):
            if node.get_parent() == ui.root:
                _fail("Global page scrolling reintroduced in " + page)
                return
        var panels: Array[Node] = ui.find_children("*", "PanelContainer", true, false)
        if panels.is_empty():
            _fail("Missing framed pixel UI panels in " + page)
            return
    print("GALAXY_FIXED_SETUP_UI_PASS")
    ui.queue_free()
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_FIXED_SETUP_UI_FAILURE: " + message)
    quit(1)
