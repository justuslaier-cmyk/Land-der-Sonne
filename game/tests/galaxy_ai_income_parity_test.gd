extends SceneTree

# Baseline territorial revenue must be symmetric for players and AI.
func _initialize() -> void:
    var cfg := GalaxyModel.defaults()
    cfg["seed"] = 222019
    cfg["difficulty"] = 1
    var world := GalaxyModel.generate(cfg, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(world)
    if world["ai"].is_empty():
        _fail("Missing rival")
        return
    var rival := int(world["ai"][0]["id"])
    var key := str(rival)
    var rival_count := 0
    var rival_resources := 0
    var player_count := 0
    var player_resources := 0
    for star in world["stars"]:
        if int(star["owner"]) == rival:
            rival_count += 1
            rival_resources += int(star["resource"])
        if int(star["owner"]) == 0:
            player_count += 1
            player_resources += int(star["resource"])
    var rival_before := int(world["ai_treasury"].get(key, 50))
    var player_before := int(world["credits"])
    GalaxySystems.tick(world)
    var expected_rival := rival_count * 2 + int(rival_resources / 3)
    var expected_player := player_count * 2 + int(player_resources / 3)
    if int(world["ai_treasury"][key]) - rival_before != expected_rival:
        _fail("Rival received hidden territorial revenue")
        return
    if int(world["credits"]) - player_before < expected_player:
        _fail("Player territorial revenue below common baseline")
        return
    print("GALAXY_AI_INCOME_PARITY_PASS: identical territorial tax base on normal difficulty")
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_AI_INCOME_PARITY_FAILURE: " + message)
    quit(1)
