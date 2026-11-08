extends RefCounted
class_name WorldState

const SAVE_VERSION: int = 1
const DEFAULT_SEED: int = 20261108
const LANDMARK_ID: String = "first_landmark"

var seed_value: int = DEFAULT_SEED
var tick: int = 0
var flags: Dictionary = {}

func _init(initial_seed: int = DEFAULT_SEED) -> void:
    seed_value = initial_seed

func advance(steps: int = 1) -> void:
    if steps < 0:
        push_error("World ticks cannot move backwards")
        return
    tick += steps

func set_flag(flag_id: String, enabled: bool) -> void:
    if flag_id.is_empty():
        push_error("World flag identifier cannot be empty")
        return
    flags[flag_id] = enabled

func has_flag(flag_id: String) -> bool:
    return flags.get(flag_id, false) == true

func to_dict() -> Dictionary:
    return {
        "version": SAVE_VERSION,
        "seed": seed_value,
        "tick": tick,
        "flags": flags.duplicate(true)
    }

static func from_dict(data: Dictionary) -> WorldState:
    if typeof(data.get("version")) != TYPE_INT or data["version"] != SAVE_VERSION:
        return null
    if typeof(data.get("seed")) != TYPE_INT or typeof(data.get("tick")) != TYPE_INT:
        return null
    if data["tick"] < 0 or typeof(data.get("flags")) != TYPE_DICTIONARY:
        return null
    var loaded := WorldState.new(data["seed"])
    loaded.tick = data["tick"]
    for key in data["flags"].keys():
        if typeof(key) != TYPE_STRING or typeof(data["flags"][key]) != TYPE_BOOL or key.is_empty():
            return null
        loaded.flags[key] = data["flags"][key]
    return loaded
