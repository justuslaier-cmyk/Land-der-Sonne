extends SceneTree

func _initialize() -> void:
    var slot := 4
    var path: String = GalaxyModel.slot_path(slot)
    for suffix in ["", ".bak", ".previous", ".tmp"]:
        var target: String = path + str(suffix)
        if FileAccess.file_exists(target):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(target))
    var settings := GalaxyModel.defaults()
    settings["seed"] = 938172
    var world := GalaxyModel.generate(settings, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    if not GalaxyModel.save_game(world, slot):
        _fail("Cannot create valid baseline")
        return
    GalaxyStrategy.tick(world)
    if not GalaxyModel.save_game(world, slot):
        _fail("Cannot create recovery backup")
        return
    var expected := GalaxyModel._read(path + ".bak")
    if expected.is_empty():
        _fail("Valid recovery backup missing")
        return
    for corruption in ["unknown_owner", "duplicate_empire", "negative_tick"]:
        var invalid := world.duplicate(true)
        match corruption:
            "unknown_owner":
                invalid["stars"][0]["owner"] = 9999
            "duplicate_empire":
                if invalid["ai"].size() > 1:
                    invalid["ai"][1]["id"] = int(invalid["ai"][0]["id"])
            "negative_tick":
                invalid["tick"] = -1
        var file := FileAccess.open(path, FileAccess.WRITE)
        if file == null:
            _fail("Cannot write malformed fixture")
            return
        file.store_string(JSON.stringify(invalid))
        file.close()
        if not GalaxyModel._read(path).is_empty():
            _fail("Accepted structurally corrupt save: " + corruption)
            return
        var recovered := GalaxyModel.load_game(slot)
        if recovered.is_empty() or JSON.stringify(recovered) != JSON.stringify(expected):
            _fail("Recovery did not use valid backup: " + corruption)
            return
    for suffix in ["", ".bak", ".previous", ".tmp"]:
        var target: String = path + str(suffix)
        if FileAccess.file_exists(target):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(target))
    print("GALAXY_SAVE_INTEGRITY_PASS: corrupt ownership, empire IDs and tick rejected with backup recovery")
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_SAVE_INTEGRITY_FAILURE: " + message)
    quit(1)
