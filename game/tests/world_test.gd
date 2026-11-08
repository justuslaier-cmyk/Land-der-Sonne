extends SceneTree

func _initialize() -> void:
    var terrain_script: Script = load("res://scripts/world/terrain.gd")
    var state_script: Script = load("res://scripts/world/world_state.gd")
    var storage_script: Script = load("res://scripts/world/world_storage.gd")
    if terrain_script == null or state_script == null or storage_script == null:
        _fail("World scripts failed to load")
        return
    for x in range(-130, 131, 13):
        for y in range(-130, 131, 13):
            var cell := Vector2i(x, y)
            var chunk: Vector2i = terrain_script.chunk_for_cell(cell)
            var local: Vector2i = terrain_script.local_cell(cell)
            if local.x < 0 or local.y < 0 or local.x >= 64 or local.y >= 64:
                _fail("Local chunk coordinate out of bounds")
                return
            if chunk * 64 + local != cell:
                _fail("Chunk coordinate roundtrip failed")
                return
            if terrain_script.terrain_at(cell, 17) != terrain_script.terrain_at(cell, 17):
                _fail("Terrain is nondeterministic")
                return
    var world: WorldState = state_script.new(17)
    world.advance(12)
    world.set_flag("first_landmark", true)
    var path := "user://world_test.json"
    if not storage_script.save_world(world, path):
        _fail("World save failed")
        return
    var restored: WorldState = storage_script.load_world(path)
    if restored == null or restored.seed_value != 17 or restored.tick != 12 or not restored.has_flag("first_landmark"):
        _fail("Save/load roundtrip failed")
        return
    DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    if state_script.from_dict({"version": 999, "seed": 17, "tick": 0, "flags": {}}) != null:
        _fail("Unsupported save version accepted")
        return
    print("WORLD_TEST_PASS: chunk boundaries, terrain, persistence and version rejection")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
