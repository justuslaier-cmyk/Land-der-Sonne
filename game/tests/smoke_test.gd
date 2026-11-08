extends SceneTree

func _initialize() -> void:
    var script_resource: Script = load("res://scripts/main.gd")
    if script_resource == null:
        push_error("Main script failed to load")
        quit(1)
        return
    var first: int = script_resource.terrain_at(Vector2i(12, 7), 42)
    var second: int = script_resource.terrain_at(Vector2i(12, 7), 42)
    if first != second:
        push_error("Terrain generation is not deterministic")
        quit(1)
        return
    if first < 0 or first > 2:
        push_error("Invalid terrain value")
        quit(1)
        return
    print("SMOKE_TEST_PASS: deterministic terrain")
    quit(0)
