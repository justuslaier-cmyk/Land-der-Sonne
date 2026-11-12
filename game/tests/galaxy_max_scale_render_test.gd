extends SceneTree

# Real engine, real viewport; benchmark map redraw + navigation at target resolutions.
# Software/Xvfb renderer is NOT a Windows target GPU or an FPS certification.
const UI = preload("res://scripts/galaxy/galaxy_ui.gd")
const SIZES := [Vector2i(1280, 720), Vector2i(1920, 1080)]
const FRAMES := 90

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var ui: Control = UI.new()
    root.add_child(ui)
    await process_frame
    ui._begin_new_game()
    ui.settings["seed"] = 20261112
    ui.settings["size"] = 250
    ui.settings["ai_count"] = 20
    ui._start_game()
    ui.simulation_paused = true
    if ui.screen != "galaxy" or ui.map_area == null:
        _fail("Large galaxy screen missing")
        return
    var results: Array = []
    for size in SIZES:
        root.get_window().size = size
        await process_frame
        await RenderingServer.frame_post_draw
        var timings: Array = []
        var before_memory := OS.get_static_memory_usage()
        for i in range(FRAMES):
            var started := Time.get_ticks_usec()
            if i % 9 == 0:
                ui.zoom = clampf(ui.zoom * 1.08, 0.3, 2.0)
                ui.map_offset = Vector2(float(i * 3), float(-i))
                ui.selected = posmod(i * 13, ui.world["stars"].size())
                ui._show_selection()
            ui.map_area.queue_redraw()
            await process_frame
            await RenderingServer.frame_post_draw
            timings.append(Time.get_ticks_usec() - started)
        timings.sort()
        var total_us := 0
        for elapsed in timings:
            total_us += int(elapsed)
        results.append({"width": size.x, "height": size.y, "frames": FRAMES,
            "mean_frame_ms": float(total_us) / float(FRAMES) / 1000.0,
            "p95_frame_ms": float(timings[int(ceil(float(FRAMES) * 0.95)) - 1]) / 1000.0,
            "max_frame_ms": float(timings[FRAMES - 1]) / 1000.0,
            "memory_before_bytes": before_memory,
            "memory_after_bytes": OS.get_static_memory_usage()})
    print("GALAXY_MAX_SCALE_RENDER_PASS: " + JSON.stringify(results))
    ui.queue_free()
    quit(0)

func _fail(reason: String) -> void:
    push_error("GALAXY_MAX_SCALE_RENDER_FAILURE: " + reason)
    quit(1)
