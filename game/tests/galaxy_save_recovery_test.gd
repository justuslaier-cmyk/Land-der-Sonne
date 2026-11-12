extends SceneTree

# A1: Save rotation and interrupted-write recovery, isolated to the
# runner's user:// profile. This test intentionally manipulates save files.
func _initialize() -> void:
    var primary := GalaxyModel.SAVE_PATH
    var backup := primary + ".bak"
    var previous := primary + ".previous"
    var temp := primary + ".tmp"
    for path in [primary, backup, previous, temp]:
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    var settings := GalaxyModel.defaults()
    settings["seed"] = 194011
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    if not GalaxyModel.save_game(world):
        _fail("initial save failed")
        return
    var first_tick := int(world["tick"])
    GalaxyStrategy.tick(world)
    if not GalaxyModel.save_game(world):
        _fail("second save failed")
        return
    if not FileAccess.file_exists(backup):
        _fail("backup not created on second save")
        return
    var prior := GalaxyModel._read(backup)
    if prior.is_empty() or int(prior["tick"]) != first_tick:
        _fail("backup does not contain previous save")
        return
    var saved_tick := int(world["tick"])
    # Simulate corrupted primary and confirm backup recovery.
    var damaged := FileAccess.open(primary, FileAccess.WRITE)
    if damaged == null:
        _fail("cannot create corrupt primary")
        return
    damaged.store_string("{invalid json")
    damaged.close()
    var restored := GalaxyModel.load_game()
    if restored.is_empty() or int(restored["tick"]) != first_tick:
        _fail("corrupt primary did not recover from backup")
        return
    # Simulate an interrupted promotion: only .previous survives.
    DirAccess.remove_absolute(ProjectSettings.globalize_path(primary))
    DirAccess.remove_absolute(ProjectSettings.globalize_path(backup))
    var displaced := FileAccess.open(previous, FileAccess.WRITE)
    if displaced == null:
        _fail("cannot create displaced save")
        return
    displaced.store_string(JSON.stringify(world))
    displaced.close()
    restored = GalaxyModel.load_game()
    if restored.is_empty() or int(restored["tick"]) != saved_tick:
        _fail("interrupted rotation did not recover from .previous")
        return
    GalaxyStrategy.tick(world)
    if not GalaxyModel.save_game(world):
        _fail("save could not recover interrupted rotation")
        return
    if int(GalaxyModel.load_game().get("tick", -1)) != int(world["tick"]):
        _fail("recovered save roundtrip failed")
        return
    if not FileAccess.file_exists(backup):
        _fail("recovered rotation did not create backup")
        return
    for path in [primary, backup, previous, temp]:
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    # Independent manual slots must not overwrite the autosave.
    for slot in range(1, 5):
        if not GalaxyModel.save_game(world, slot):
            _fail("manual slot %d failed" % slot)
            return
        if int(GalaxyModel.load_game(slot).get("tick", -1)) != int(world["tick"]):
            _fail("manual slot %d roundtrip failed" % slot)
            return
    if GalaxyModel.save_game(world, 5) or not GalaxyModel.load_game(5).is_empty():
        _fail("invalid slot accepted")
        return
    for slot in range(1, 5):
        for suffix in ["", ".bak", ".previous", ".tmp"]:
            var slot_file: String = GalaxyModel.slot_path(slot) + str(suffix)
            if FileAccess.file_exists(slot_file):
                DirAccess.remove_absolute(ProjectSettings.globalize_path(slot_file))
    print("GALAXY_SAVE_RECOVERY_PASS: backup rotation, corrupt primary, interrupted promotion")
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_SAVE_RECOVERY_FAILURE: " + message)
    quit(1)
