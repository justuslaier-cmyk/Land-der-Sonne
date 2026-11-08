extends SceneTree

func _initialize() -> void:
    call_deferred("_capture")

func _capture() -> void:
    var packed: PackedScene = load("res://scenes/main.tscn")
    if packed == null:
        push_error("Could not load scene for screenshot")
        quit(1)
        return
    var instance: Node2D = packed.instantiate()
    root.add_child(instance)
    for i in range(4):
        await process_frame
    await RenderingServer.frame_post_draw
    var image: Image = root.get_viewport().get_texture().get_image()
    if image == null or image.is_empty():
        push_error("Rendering returned empty image")
        quit(1)
        return
    var out_path := "user://render-check.png"
    var result := image.save_png(out_path)
    if result != OK:
        push_error("Could not save render screenshot")
        quit(1)
        return
    print("RENDER_CAPTURE_PASS: ", ProjectSettings.globalize_path(out_path), " size=", image.get_width(), "x", image.get_height())
    quit(0)
