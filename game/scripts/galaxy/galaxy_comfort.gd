extends RefCounted

const PATH := "user://galaxy_preferences.cfg"

static func defaults() -> Dictionary:
    return {"ui_scale": 100, "volume": 80, "muted": false, "fullscreen": false}

static func normalize(source: Dictionary) -> Dictionary:
    var result := defaults()
    result["ui_scale"] = clampi(int(source.get("ui_scale", 100)), 80, 150)
    result["volume"] = clampi(int(source.get("volume", 80)), 0, 100)
    result["muted"] = bool(source.get("muted", false))
    result["fullscreen"] = bool(source.get("fullscreen", false))
    return result

static func save_preferences(source: Dictionary) -> bool:
    var cfg := ConfigFile.new()
    for key in defaults().keys():
        cfg.set_value("display", key, normalize(source)[key])
    return cfg.save(PATH) == OK

static func load_preferences() -> Dictionary:
    var cfg := ConfigFile.new()
    if cfg.load(PATH) != OK:
        return defaults()
    var source := {}
    for key in defaults().keys():
        source[key] = cfg.get_value("display", key, defaults()[key])
    return normalize(source)

static func apply(window: Window, source: Dictionary) -> void:
    var values := normalize(source)
    window.content_scale_factor = float(values["ui_scale"]) / 100.0
    window.mode = Window.MODE_FULLSCREEN if bool(values["fullscreen"]) else Window.MODE_WINDOWED
    var master := AudioServer.get_bus_index("Master")
    if master >= 0:
        AudioServer.set_bus_volume_db(master, linear_to_db(float(values["volume"]) / 100.0))
        AudioServer.set_bus_mute(master, bool(values["muted"]))
