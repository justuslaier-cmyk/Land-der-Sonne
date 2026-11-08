extends RefCounted
class_name WorldStorage

const SAVE_PATH: String = "user://world.json"
const MAX_SAVE_BYTES: int = 1048576

static func save_world(world: WorldState, path: String = SAVE_PATH) -> bool:
    if world == null:
        return false
    var json_text := JSON.stringify(world.to_dict())
    if json_text.to_utf8_buffer().size() > MAX_SAVE_BYTES:
        return false
    var temp_path := path + ".tmp"
    var backup_path := path + ".bak"
    var file := FileAccess.open(temp_path, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(json_text)
    file.flush()
    file.close()
    # Validate the staged save before touching the previous good save.
    if _read_valid_world(temp_path) == null:
        return false
    var full_path := ProjectSettings.globalize_path(path)
    var full_temp := ProjectSettings.globalize_path(temp_path)
    var full_backup := ProjectSettings.globalize_path(backup_path)
    if FileAccess.file_exists(backup_path):
        if DirAccess.remove_absolute(full_backup) != OK:
            return false
    if FileAccess.file_exists(path):
        if DirAccess.rename_absolute(full_path, full_backup) != OK:
            return false
    if DirAccess.rename_absolute(full_temp, full_path) != OK:
        # Best-effort rollback of the previous save.
        if FileAccess.file_exists(backup_path):
            DirAccess.rename_absolute(full_backup, full_path)
        return false
    return true

static func load_world(path: String = SAVE_PATH) -> WorldState:
    var primary := _read_valid_world(path)
    if primary != null:
        return primary
    return _read_valid_world(path + ".bak")

static func _read_valid_world(path: String) -> WorldState:
    if not FileAccess.file_exists(path):
        return null
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null or file.get_length() > MAX_SAVE_BYTES:
        return null
    var json := JSON.new()
    if json.parse(file.get_as_text()) != OK:
        return null
    if typeof(json.data) != TYPE_DICTIONARY:
        return null
    return WorldState.from_dict(json.data)
