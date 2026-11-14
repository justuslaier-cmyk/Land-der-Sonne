extends RefCounted
class_name GalaxyNarrativeDirector

# Phase 13 / pass 3: deterministic orchestration with a single unresolved choice.
# The game controller must call advance after the annual simulation tick and
# resolve_choice from the UI. This script does not mutate the scene tree.
const Events = preload("res://scripts/galaxy_event_engine.gd")
const Stories = preload("res://scripts/galaxy_story_chains.gd")

static func advance(world: Dictionary) -> Dictionary:
	var active: Dictionary = world.get("narrative_pending", {})
	if not active.is_empty():
		return active.duplicate(true)
	var stages: Array = Stories.pending(world)
	if not stages.is_empty():
		var stage: Dictionary = stages[0]
		active = {"kind": "story", "id": str(stage["chain_id"]), "stage": str(stage["id"]), "title": str(stage["title"]), "text": str(stage["text"]), "options": stage["options"].duplicate(true)}
	else:
		# Fixed world-derived roll; no global RNG side effects.
		var seed: int = int(world.get("settings", {}).get("seed", world.get("seed", 0)))
		var tick: int = int(world.get("tick", 0))
		var roll: int = (seed * 1103515245 + tick * 12345) & 0x7fffffff
		var event: Dictionary = Events.choose(world, roll)
		if not event.is_empty():
			active = {"kind": "event", "id": str(event["id"]), "title": str(event["title"]), "text": str(event["text"]), "options": event["options"].duplicate(true)}
	if not active.is_empty():
		world["narrative_pending"] = active.duplicate(true)
	return active

static func resolve_choice(world: Dictionary, option_id: String) -> bool:
	var active: Dictionary = world.get("narrative_pending", {})
	if active.is_empty():
		return false
	var success: bool = false
	if str(active.get("kind", "")) == "story":
		success = Stories.resolve(world, str(active.get("id", "")), option_id)
	elif str(active.get("kind", "")) == "event":
		for definition in Events.DEFINITIONS:
			if str(definition["id"]) == str(active.get("id", "")):
				success = Events.apply(world, definition, option_id)
				break
		if success and str(active.get("id", "")) == "ancient_signal" and option_id == "study":
			Stories.begin(world, "first_signal", "ancient_signal", "study")
	if not success:
		return false
	world.erase("narrative_pending")
	return true

static func history(world: Dictionary) -> Array:
	var entries: Array = []
	for entry in world.get("event_journal", []):
		var item: Dictionary = entry.duplicate(true)
		item["kind"] = "event"
		entries.append(item)
	for entry in world.get("story_journal", []):
		var item: Dictionary = entry.duplicate(true)
		item["kind"] = "story"
		entries.append(item)
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.get("tick", 0)) == int(b.get("tick", 0)):
			return str(a.get("kind", "")) < str(b.get("kind", ""))
		return int(a.get("tick", 0)) < int(b.get("tick", 0))
	)
	return entries
