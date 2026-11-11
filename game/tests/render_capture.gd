extends SceneTree

# Capture real Godot-rendered evidence for every principal game flow.
const VIEWPORTS := [Vector2i(1280, 720), Vector2i(1920, 1080)]
const SCREENS := ["menu", "settings", "empire", "review", "galaxy", "research", "economy", "diplomacy", "fleet_command"]

func _initialize() -> void:
    call_deferred("_capture")

func _capture() -> void:
    var packed: PackedScene = load("res://scenes/galaxy.tscn")
    if packed == null:
        _fail("Could not load galaxy scene")
        return
    var instance: Control = packed.instantiate()
    root.add_child(instance)
    for resolution in VIEWPORTS:
        root.get_window().size = resolution
        for screen_name in SCREENS:
            match screen_name:
                "menu":
                    instance._show_menu()
                "settings":
                    instance._show_settings()
                "empire":
                    instance._show_empire()
                "review":
                    instance._show_review()
                "galaxy":
                    if instance.world.is_empty():
                        instance.settings["seed"] = 21015
                        instance.settings["size"] = 40
                        instance.settings["ai_count"] = 2
                        instance._start_game()
                    else:
                        instance._show_galaxy()
                    instance.simulation_paused = true
                "research":
                    instance._research()
                "economy":
                    instance._economy_report()
                "diplomacy":
                    instance._diplomacy()
                "fleet_command":
                    instance._fleet_command()
            for frame in range(5):
                await process_frame
            await RenderingServer.frame_post_draw
            var image: Image = root.get_viewport().get_texture().get_image()
            if image == null or image.is_empty():
                _fail("Empty render: " + screen_name)
                return
            var out_path := "user://render-%s-%dx%d.png" % [screen_name, resolution.x, resolution.y]
            if image.save_png(out_path) != OK:
                _fail("Could not save: " + out_path)
                return
            print("RENDER_CAPTURE_PASS: ", ProjectSettings.globalize_path(out_path), " size=", image.get_width(), "x", image.get_height())
    instance.queue_free()
    quit(0)

func _fail(message: String) -> void:
    push_error("RENDER_CAPTURE_FAILURE: " + message)
    quit(1)
