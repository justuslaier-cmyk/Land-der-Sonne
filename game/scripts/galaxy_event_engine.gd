extends RefCounted
class_name GalaxyEventEngine

# Phase 13 / pass 1: data-driven, deterministic event selection.
# Pure functions: caller owns persistence and application of effects.
const DEFINITIONS := [
	{"id": "industrial_shortage", "weight": 5, "cooldown": 8, "min_tick": 2, "condition": "low_alloys", "title": "Die stillen Werften", "text": "In den orbitalen Werften erlöschen Schweißlichter. Eine Knappheit an Legierungen zwingt die Verwaltung zum Handeln.", "options": [
		{"id": "ration", "label": "Vorräte rationieren", "credits": 0, "alloys": 3, "stability": -1},
		{"id": "import", "label": "Notkäufe genehmigen", "credits": -25, "alloys": 10, "stability": 0}
	]},
	{"id": "ancient_signal", "weight": 2, "cooldown": 20, "min_tick": 5, "condition": "explored", "title": "Das Echo der Ersten", "text": "Ein längst verstummter Sender erwacht im interstellaren Staub. Seine Signatur passt zu keiner bekannten Zivilisation.", "options": [
		{"id": "study", "label": "Signal wissenschaftlich untersuchen", "credits": -10, "science": 15},
		{"id": "archive", "label": "Aufzeichnung versiegeln", "credits": 0, "science": 3}
	]},
	{"id": "trade_dispute", "weight": 4, "cooldown": 10, "min_tick": 3, "condition": "trade", "title": "Streit an der Handelsroute", "text": "Frachtkapitäne verweigern die Weiterfahrt. Eine alte Tariffrage spaltet die Händler.", "options": [
		{"id": "subsidize", "label": "Transport subventionieren", "credits": -15, "stability": 2},
		{"id": "mediate", "label": "Schlichtung einberufen", "credits": -5, "stability": 1}
	]}
]

static func eligible(world: Dictionary, record: Dictionary) -> bool:
	var tick: int = int(world.get("tick", 0))
	if tick < int(record.get("min_tick", 0)):
		return false
	var last: Dictionary = world.get("event_last_seen", {})
	var id: String = str(record.get("id", ""))
	if last.has(id) and tick - int(last[id]) < int(record.get("cooldown", 0)):
		return false
	match str(record.get("condition", "")):
		"low_alloys":
			return int(world.get("alloys", 0)) < 20
		"explored":
			return int(world.get("explored_count", 0)) > 0 or world.get("discovered", []).size() > 0
		"trade":
			return world.get("civilian_trade", []).size() > 0
		_:
			return false

static func candidates(world: Dictionary) -> Array:
	var result: Array = []
	for record in DEFINITIONS:
		if eligible(world, record):
			result.append(record.duplicate(true))
	return result

static func choose(world: Dictionary, roll: int) -> Dictionary:
	var options: Array = candidates(world)
	var total: int = 0
	for item in options:
		total += maxi(0, int(item.get("weight", 0)))
	if total <= 0:
		return {}
	var target: int = posmod(roll, total)
	for item in options:
		target -= maxi(0, int(item.get("weight", 0)))
		if target < 0:
			return item
	return {}

static func can_apply(world: Dictionary, event: Dictionary, option_id: String) -> bool:
	for option in event.get("options", []):
		if str(option.get("id", "")) != option_id:
			continue
		for field in ["credits", "alloys", "science"]:
			if int(world.get(field, 0)) + int(option.get(field, 0)) < 0:
				return false
		return true
	return false

static func apply(world: Dictionary, event: Dictionary, option_id: String) -> bool:
	if not can_apply(world, event, option_id):
		return false
	for option in event.get("options", []):
		if str(option.get("id", "")) != option_id:
			continue
		for field in ["credits", "alloys", "science", "stability"]:
			if option.has(field):
				world[field] = int(world.get(field, 0)) + int(option[field])
		var last: Dictionary = world.get("event_last_seen", {}).duplicate(true)
		last[str(event.get("id", ""))] = int(world.get("tick", 0))
		world["event_last_seen"] = last
		var journal: Array = world.get("event_journal", []).duplicate(true)
		journal.append({"tick": int(world.get("tick", 0)), "event_id": str(event.get("id", "")), "option_id": option_id})
		world["event_journal"] = journal
		return true
	return false
