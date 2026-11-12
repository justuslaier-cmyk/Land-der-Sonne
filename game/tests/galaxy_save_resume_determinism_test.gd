extends SceneTree

# Save/resume must not change the deterministic strategic simulation.
func _initialize() -> void:
    var slot := 3
    var path: String = GalaxyModel.slot_path(slot)
    for suffix in ["", ".bak", ".previous", ".tmp"]:
        var target: String = path + str(suffix)
        if FileAccess.file_exists(target):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(target))
    var settings := GalaxyModel.defaults()
    settings["seed"] = 827314
    settings["size"] = 60
    settings["ai_count"] = 4
    var original := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(original)
    var continuous := original.duplicate(true)
    var resumed := original.duplicate(true)
    for i in range(36):
        _advance(continuous)
        if i < 18:
            _advance(resumed)
    if not GalaxyModel.save_game(resumed, slot):
        _fail("Cannot save midway through a live campaign")
        return
    var restored := GalaxyModel.load_game(slot)
    if restored.is_empty() or JSON.stringify(restored) != JSON.stringify(resumed):
        _fail("Campaign state changed across save/load")
        return
    for i in range(18):
        _advance(restored)
    if JSON.stringify(restored) != JSON.stringify(continuous):
        _fail("Save/resume diverged from uninterrupted campaign")
        return
    if int(restored["tick"]) != 36:
        _fail("Campaign did not reach expected year")
        return
    for suffix in ["", ".bak", ".previous", ".tmp"]:
        var target: String = path + str(suffix)
        if FileAccess.file_exists(target):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(target))
    print("GALAXY_SAVE_RESUME_DETERMINISM_PASS: 36-year uninterrupted and 18+18 resumed simulations match")
    quit(0)

func _advance(world: Dictionary) -> void:
    GalaxyStrategy.tick(world)
    if str(world.get("pending_event", "")) != "":
        GalaxySystems.resolve_event(world, 0)

func _fail(message: String) -> void:
    push_error("GALAXY_SAVE_RESUME_DETERMINISM_FAILURE: " + message)
    quit(1)
