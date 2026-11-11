extends SceneTree

const Index = preload("res://scripts/galaxy/galaxy_ai_spatial_index.gd")
const Planner = preload("res://scripts/galaxy/galaxy_ai_planner.gd")

func _initialize() -> void:
    var world: Dictionary = {"tick": 4, "stars": [
        {"owner": 1, "resource": 3}, {"owner": 2, "resource": 4},
        {"owner": 1, "resource": 2}, {"owner": 0, "resource": 9},
        {"owner": -1, "resource": 7}
    ], "ai_treasury": {"1": 30},
    "ai_societies": {"1": {"legitimacy": 18, "factions": {"reform": 75, "security": 20, "commerce": 15}}}}
    var summary: Dictionary = Index.build(world)
    assert(int(summary["1"]["count"]) == 2, "Owned count incorrect")
    assert(int(summary["1"]["resources"]) == 5, "Resource sum incorrect")
    assert(int(summary["2"]["count"]) == 1, "Second owner incorrect")
    assert(not summary.has("0"), "Player must not appear in rival index")
    assert(summary == Index.build(world), "Index must be deterministic")
    world["stars"][2]["owner"] = 2
    var changed: Dictionary = Index.build(world)
    assert(int(changed["1"]["count"]) == 1, "Index must not persist stale ownership")
    assert(int(changed["2"]["resources"]) == 6, "New owner resource sum incorrect")
    var plan: Dictionary = Planner.evaluate(world, {"id": 1}, {"strength": 12})
    assert(str(plan["stance"]) == "reformen", "Planner must use own legitimacy")
    assert(plan == Planner.evaluate(world, {"id": 1}, {"strength": 12}), "Planning must replay deterministically")
    print("GALAXY_AI_SCALING_PASS")
    quit(0)
