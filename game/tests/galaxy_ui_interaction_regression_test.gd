extends SceneTree

# Interactive map and simulation controls, including boundary clamping.
const UI = preload("res://scripts/galaxy/galaxy_ui.gd")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var ui: Control = UI.new()
    root.add_child(ui)
    await process_frame
    ui.settings["seed"] = 21999
    ui.settings["size"] = 40
    ui.settings["ai_count"] = 2
    ui._start_game()
    if ui.screen != "galaxy" or not is_instance_valid(ui.map_area):
        _fail("Map did not initialize")
        return
    # A3 cockpit regression: fixed canvas, independently scrollable navigation
    # and real inspector, rather than the old global scroll surface.
    var global_scroll := false
    var nav_scroll := false
    var inspector_scroll := false
    var command_emblem := false
    for node in ui.find_children("*", "ScrollContainer", true, false):
        if node.get_parent() == ui.root:
            global_scroll = true
        if node.get_parent() is HBoxContainer:
            nav_scroll = true
        if node.get_parent() is PanelContainer:
            inspector_scroll = true
    for node in ui.find_children("*", "TextureRect", true, false):
        if node.texture != null and str(node.texture.resource_path).contains("command_emblem"):
            command_emblem = true
    if global_scroll or not nav_scroll or not inspector_scroll or not command_emblem:
        _fail("A3 fixed cockpit, independent scroll surfaces or pixel crest missing")
        return
    ui.simulation_paused = true
    var wheel := InputEventMouseButton.new()
    wheel.button_index = MOUSE_BUTTON_WHEEL_UP
    wheel.pressed = true
    wheel.position = Vector2(200, 180)
    var previous_zoom: float = ui.zoom
    ui._map_input(wheel)
    if ui.zoom <= previous_zoom:
        _fail("Wheel-up did not zoom in")
        return
    wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
    ui._map_input(wheel)
    if absf(ui.zoom - previous_zoom) > 0.001:
        _fail("Zoom in/out did not restore scale")
        return
    var right := InputEventMouseButton.new()
    right.button_index = MOUSE_BUTTON_RIGHT
    right.pressed = true
    right.position = Vector2(100, 100)
    ui._map_input(right)
    if not ui.map_dragging:
        _fail("Right drag did not begin")
        return
    var motion := InputEventMouseMotion.new()
    motion.position = Vector2(130, 125)
    ui._map_input(motion)
    if ui.map_offset.distance_to(Vector2(30, 25)) > 0.001:
        _fail("Map drag offset incorrect")
        return
    right.pressed = false
    ui._map_input(right)
    if ui.map_dragging:
        _fail("Right drag did not stop")
        return
    ui._toggle_pause()
    if ui.simulation_paused:
        _fail("Pause toggle did not resume")
        return
    ui._set_speed(4)
    if ui.simulation_speed != 4 or int(ui.world.get("simulation_speed", 0)) != 4:
        _fail("Simulation speed not persisted to world")
        return
    ui._toggle_pause()
    if not ui.simulation_paused:
        _fail("Pause toggle did not stop")
        return
    print("GALAXY_UI_INTERACTION_PASS: zoom, pan, pause and speed")
    ui.queue_free()
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_UI_INTERACTION_FAILURE: " + message)
    quit(1)
