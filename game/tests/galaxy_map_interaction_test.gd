extends SceneTree

# Interaction regression: real UI handlers, not just model route previews.
const UI = preload("res://scripts/galaxy/galaxy_ui.gd")

func _initialize() -> void:
    call_deferred("_run")

func _fail(reason: String) -> void:
    push_error("GALAXY_MAP_INTERACTION_FAILURE: " + reason)
    quit(1)

func _mouse_button(index: MouseButton, pressed: bool, pos: Vector2) -> InputEventMouseButton:
    var event := InputEventMouseButton.new()
    event.button_index = index
    event.pressed = pressed
    event.position = pos
    return event

func _run() -> void:
    var ui: Control = UI.new()
    root.add_child(ui)
    ui.settings["seed"] = 45102
    ui.settings["size"] = 40
    ui.settings["ai_count"] = 2
    ui._start_game()
    await process_frame
    if ui.screen != "galaxy" or not is_instance_valid(ui.map_area):
        _fail("galaxy map missing")
        return
    var center: Vector2 = ui.map_area.size * 0.5
    if center.x <= 0.0 or center.y <= 0.0:
        _fail("map has no layout size")
        return
    var start_zoom: float = ui.zoom
    ui._map_input(_mouse_button(MOUSE_BUTTON_WHEEL_UP, true, center))
    if ui.zoom <= start_zoom:
        _fail("wheel up did not zoom in")
        return
    ui._map_input(_mouse_button(MOUSE_BUTTON_WHEEL_DOWN, true, center))
    if absf(ui.zoom - start_zoom) > 0.0001:
        _fail("inverse wheel events did not restore zoom")
        return
    for i in range(40):
        ui._map_input(_mouse_button(MOUSE_BUTTON_WHEEL_DOWN, true, center))
    if ui.zoom < 0.25 or ui.zoom > 3.0:
        _fail("minimum zoom limit broken")
        return
    for i in range(50):
        ui._map_input(_mouse_button(MOUSE_BUTTON_WHEEL_UP, true, center))
    if ui.zoom < 0.25 or ui.zoom > 3.0:
        _fail("maximum zoom limit broken")
        return
    ui.zoom = start_zoom
    ui.map_offset = Vector2.ZERO
    var drag_start := center
    ui._map_input(_mouse_button(MOUSE_BUTTON_RIGHT, true, drag_start))
    var move := InputEventMouseMotion.new()
    move.position = drag_start + Vector2(34, -21)
    ui._map_input(move)
    ui._map_input(_mouse_button(MOUSE_BUTTON_RIGHT, false, move.position))
    if ui.map_offset.distance_to(Vector2(34, -21)) > 0.001 or ui.map_dragging:
        _fail("right-drag pan or release failed")
        return
    ui.map_offset = Vector2.ZERO
    var star: Dictionary = ui.world["stars"][0]
    var star_pos: Vector2 = ui._star_pos(star)
    ui.selected = 1
    ui._map_input(_mouse_button(MOUSE_BUTTON_LEFT, true, star_pos))
    if ui.selected != 0 or int(ui.world.get("selected", -1)) != 0:
        _fail("left-click did not select home system")
        return
    ui._research()
    if ui.screen != "research":
        _fail("research navigation failed")
        return
    ui._show_galaxy()
    if ui.screen != "galaxy" or not is_instance_valid(ui.map_area):
        _fail("return from research failed")
        return
    print("GALAXY_MAP_INTERACTION_PASS: zoom bounds, cursor zoom, drag pan, selection, navigation")
    ui.queue_free()
    quit(0)
