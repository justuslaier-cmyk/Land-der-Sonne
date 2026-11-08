extends RefCounted
class_name WorldStorage

const SAVE_PATH: String = "user://world.json"
const MAX_SAVE_BYTES: int = 1048576

static func save_world(world: WorldState, path: String = SAVE_PATH) -> bool:
    if world == null:
        return false
    var json_text := JSON.stringify(world.to_dict())
    var temp_path := path + ".tmp"
    var file := FileAccess.open(temp_path, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(json_text)
    file.flush()
    file.close()
    # Replace only after the temporary save has been written.
    if FileAccess.file_exists(path):
        var remove_error := DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
        if remove_error != OK:
            return false
    return DirAccess.rename_absolute(ProjectSettings.globalize_path(temp_path), ProjectSettings.globalize_path(path)) == OK

static func load_world(path: String = SAVE_PATH) -> WorldState:
    if not FileAccess.file_exists(path):
        return null
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return null
    if file.get_length() > MAX_SAVE_BYTES:
        return null
    var json := JSON.new()
    if json.parse(file.get_as_text()) != OK:
        return null
    if typeof(json.data) != TYPE_DICTIONARY:
        return null
    return WorldState.from_dict(json.data)
