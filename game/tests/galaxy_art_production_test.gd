extends SceneTree

const UI = preload("res://scripts/galaxy/galaxy_ui.gd")
const PORTRAIT_PATHS := ["res://assets/art/species_portrait_0.svg", "res://assets/art/species_portrait_1.svg", "res://assets/art/species_portrait_2.svg", "res://assets/art/species_portrait_3.svg", "res://assets/art/species_portrait_4.svg"]
const SHIP_PATHS := ["res://assets/art/ship_style_0.svg", "res://assets/art/ship_style_1.svg", "res://assets/art/ship_style_2.svg", "res://assets/art/ship_style_3.svg"]

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    for path in PORTRAIT_PATHS:
        var texture: Texture2D = load(path)
        if texture == null or texture.get_size() != Vector2(64, 96):
            _fail("Portrait texture import: " + path)
            return
    for path in SHIP_PATHS:
        var texture: Texture2D = load(path)
        if texture == null or texture.get_size() != Vector2(64, 64):
            _fail("Ship texture import: " + path)
            return
    var ui: Control = UI.new()
    root.add_child(ui)
    await process_frame
    ui._show_empire()
    for i in range(5):
        var portrait_canvas := Control.new()
        portrait_canvas.size = Vector2(150, 170)
        root.add_child(portrait_canvas)
        portrait_canvas.draw.connect(func(): ui._draw_species(portrait_canvas, i))
        portrait_canvas.queue_redraw()
    ui._show_review()
    for i in range(4):
        var ship_canvas := Control.new()
        ship_canvas.size = Vector2(150, 120)
        root.add_child(ship_canvas)
        ship_canvas.draw.connect(func(): ui._draw_ship(ship_canvas, i, 1))
        ship_canvas.queue_redraw()
    await process_frame
    ui.queue_free()
    print("GALAXY_ART_PRODUCTION_PASS: nine individual imported sprites and gallery draw callbacks")
    quit(0)

func _fail(reason: String) -> void:
    push_error("GALAXY_ART_PRODUCTION_FAILURE: " + reason)
    quit(1)
