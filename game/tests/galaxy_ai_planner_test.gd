extends SceneTree

const Planner = preload("res://scripts/galaxy/galaxy_ai_planner.gd")

func _initialize() -> void:
	var rival: Dictionary = {"id": 1}
	var fleet: Dictionary = {"strength": 20}
	var world: Dictionary = {
		"tick": 18,
		"ai_treasury": {"1": 65},
		"ai_societies": {"1": {"legitimacy": 12, "factions": {"reform": 80, "security": 20, "commerce": 20}}}
	}
	var first: Dictionary = Planner.evaluate(world, rival, fleet)
	assert(first == Planner.evaluate(world, rival, fleet), "Planning must be deterministic")
	assert(str(first["stance"]) == "reformen", "Low legitimacy and reform pressure must favor reforms")
	assert(first["reasons"].size() > 0, "Planner must provide a reason")
	world["ai_societies"]["1"]["legitimacy"] = 90
	world["ai_societies"]["1"]["factions"] = {"reform": 0, "security": 10, "commerce": 90}
	world["ai_treasury"]["1"] = 120
	var second: Dictionary = Planner.evaluate(world, rival, fleet)
	assert(str(second["stance"]) == "handel", "Strong trade interests must favor trade")
	world["ai_societies"]["1"]["factions"] = {"reform": 0, "security": 95, "commerce": 0}
	var third: Dictionary = Planner.evaluate(world, rival, fleet)
	assert(str(third["stance"]) == "militarisierung", "Security interests must favor militarization")
	print("GALAXY_AI_PLANNER_PASS")
	quit(0)
