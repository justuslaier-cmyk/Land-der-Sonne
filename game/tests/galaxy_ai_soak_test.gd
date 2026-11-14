extends SceneTree

# Phase 14 pass 3: long-run deterministic AI replay and bounded explanation log.
# Run with: godot --headless --path game --script res://tests/galaxy_ai_soak_test.gd
const YEARS := 120

func _initialize() -> void:
    var config: Dictionary = GalaxyModel.defaults()
    config["seed"] = 14629
    config["size"] = 80
    config["ai_count"] = 3
    var left: Dictionary = GalaxyModel.generate(config, GalaxyModel.empire_defaults())
    var right: Dictionary = GalaxyModel.generate(config, GalaxyModel.empire_defaults())
    GalaxyStrategy.prepare(left)
    GalaxyStrategy.prepare(right)
    var last_year: int = int(left["tick"])
    for i in range(YEARS):
        GalaxyStrategy.tick(left)
        GalaxyStrategy.tick(right)
        if str(left.get("pending_event", "")) != "":
            GalaxySystems.resolve_event(left, 0)
        if str(right.get("pending_event", "")) != "":
            GalaxySystems.resolve_event(right, 0)
        if int(left["tick"]) != last_year + 1:
            _fail("Simulation year did not advance at step %d" % i)
            return
        last_year = int(left["tick"])
        # Save/resume the right-hand simulation at regular intervals.
        # A deterministic replay must survive JSON serialization mid-campaign.
        if (i + 1) % 30 == 0:
            var restored: Variant = JSON.parse_string(JSON.stringify(right))
            if typeof(restored) != TYPE_DICTIONARY:
                _fail("Checkpoint is not a dictionary at year %d" % i)
                return
            right = restored
            GalaxyStrategy.prepare(right)
        if JSON.stringify(left) != JSON.stringify(right):
            _fail("Replay diverged at year %d" % i)
            return
        for rival in left["ai"]:
            var key: String = str(rival["id"])
            var society: Dictionary = left["ai_societies"][key]
            if int(society["population"]) < 5:
                _fail("Invalid rival population at year %d" % i)
                return
            if int(society["legitimacy"]) < 0 or int(society["legitimacy"]) > 100:
                _fail("Invalid rival legitimacy at year %d" % i)
                return
        if left.get("ai_decision_log", []).size() > 240:
            _fail("Unbounded AI decision log")
            return
    if left.get("ai_decision_log", []).is_empty():
        _fail("No AI strategy decisions recorded")
        return
    var first: Dictionary = left["ai_decision_log"][0]
    if not first.has("scores") or not first.has("reasons") or not first.has("empire_id"):
        _fail("Incomplete explanation trace")
        return
    print("GALAXY_AI_SOAK_PASS years=%d decisions=%d" % [YEARS, left["ai_decision_log"].size()])
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
