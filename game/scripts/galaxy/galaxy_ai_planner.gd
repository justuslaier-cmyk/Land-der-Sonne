extends RefCounted
class_name GalaxyAIPlanner

# Phase 14/1: explainable, deterministic strategic prioritization.
# Read-only planning: existing GalaxyAI remains the executor.
static func evaluate(world: Dictionary, rival: Dictionary, fleet: Dictionary) -> Dictionary:
	var key: String = str(rival.get("id", -1))
	var society: Dictionary = world.get("ai_societies", {}).get(key, {})
	var factions: Dictionary = society.get("factions", {})
	var treasury: int = int(world.get("ai_treasury", {}).get(key, 0))
	var legitimacy: int = int(society.get("legitimacy", 50))
	var security: int = int(factions.get("security", 20))
	var reform: int = int(factions.get("reform", 20))
	var commerce: int = int(factions.get("commerce", 20))
	var strength: int = int(fleet.get("strength", 0))
	var scores := {
		"expansion": 30 + (12 if treasury >= 45 else -30),
		"reformen": 10 + maxi(0, 50 - legitimacy) * 2 + reform / 2,
		"militarisierung": 8 + security + (10 if strength >= 18 else -12),
		"handel": 12 + commerce + (12 if treasury >= 100 else 0)
	}
	var priority: String = "expansion"
	# Stable tie break by explicit order, not dictionary iteration order.
	for stance in ["reformen", "militarisierung", "handel"]:
		if int(scores[stance]) > int(scores[priority]):
			priority = stance
	var reasons: Array = []
	match priority:
		"reformen":
			reasons.append("Legitimitaet %d, Reformdruck %d" % [legitimacy, reform])
		"militarisierung":
			reasons.append("Sicherheitsinteresse %d, Flottenstaerke %d" % [security, strength])
		"handel":
			reasons.append("Handelsinteresse %d, Staatskasse %d" % [commerce, treasury])
		_:
			reasons.append("Expansion bei Staatskasse %d" % treasury)
	return {"stance": priority, "scores": scores, "reasons": reasons, "year": int(world.get("tick", 0))}
