extends RefCounted
class_name GalaxyStoryChains

# Phase 13 / pass 2: persistent, causal story-chain state.
# This module is independent of the scene tree; the caller must integrate
# trigger/choice calls with the authoritative simulation and save system.
const CHAINS := {
	"first_signal": {
		"start_event": "ancient_signal",
		"start_option": "study",
		"stages": [
			{"id": "decode", "delay": 2, "title": "Die Sprache ohne Sprecher",
			 "text": "Die Übertragung enthält eine Sternenkarte, deren Koordinaten sich langsam verändern.",
			 "options": [
				{"id": "follow", "label": "Den Koordinaten folgen", "credits": -15, "science": 12, "next": "vault"},
				{"id": "suppress", "label": "Die Daten versiegeln", "credits": 0, "science": 4, "next": ""}
			 ]},
			{"id": "vault", "delay": 3, "title": "Das Archiv der Vergessenen",
			 "text": "Eine Sonde entdeckt ein verlassenes Archiv. Seine Maschinen erwarten eine Entscheidung.",
			 "options": [
				{"id": "restore", "label": "Das Archiv sichern", "credits": -20, "science": 30, "next": ""},
				{"id": "leave", "label": "Den Ort unberührt lassen", "credits": 0, "science": 5, "next": ""}
			 ]}
		]
	}
}

static func begin(world: Dictionary, chain_id: String, source_event: String, source_option: String) -> bool:
	if not CHAINS.has(chain_id):
		return false
	var chain: Dictionary = CHAINS[chain_id]
	if str(chain["start_event"]) != source_event or str(chain["start_option"]) != source_option:
		return false
	var states: Dictionary = world.get("story_chains", {}).duplicate(true)
	if states.has(chain_id):
		return false
	var stage: Dictionary = chain["stages"][0]
	states[chain_id] = {"stage": str(stage["id"]), "ready_tick": int(world.get("tick", 0)) + int(stage["delay"]), "completed": false}
	world["story_chains"] = states
	_append_history(world, chain_id, "begun", source_option)
	return true

static func pending(world: Dictionary) -> Array:
	var result: Array = []
	var states: Dictionary = world.get("story_chains", {})
	for chain_id in states.keys():
		if not CHAINS.has(chain_id):
			continue
		var state: Dictionary = states[chain_id]
		if bool(state.get("completed", false)) or int(world.get("tick", 0)) < int(state.get("ready_tick", 0)):
			continue
		for stage in CHAINS[chain_id]["stages"]:
			if str(stage["id"]) == str(state.get("stage", "")):
				var item: Dictionary = stage.duplicate(true)
				item["chain_id"] = chain_id
				result.append(item)
				break
	return result

static func resolve(world: Dictionary, chain_id: String, option_id: String) -> bool:
	var active: Dictionary = {}
	for item in pending(world):
		if str(item["chain_id"]) == chain_id:
			active = item
			break
	if active.is_empty():
		return false
	for option in active["options"]:
		if str(option["id"]) != option_id:
			continue
		for resource in ["credits", "science", "alloys"]:
			if int(world.get(resource, 0)) + int(option.get(resource, 0)) < 0:
				return false
		for resource in ["credits", "science", "alloys"]:
			if option.has(resource):
				world[resource] = int(world.get(resource, 0)) + int(option[resource])
		var states: Dictionary = world.get("story_chains", {}).duplicate(true)
		var next_id: String = str(option.get("next", ""))
		var next_stage: Dictionary = {}
		for stage in CHAINS[chain_id]["stages"]:
			if str(stage["id"]) == next_id:
				next_stage = stage
				break
		if next_stage.is_empty():
			states[chain_id] = {"stage": str(active["id"]), "ready_tick": int(world.get("tick", 0)), "completed": true}
		else:
			states[chain_id] = {"stage": next_id, "ready_tick": int(world.get("tick", 0)) + int(next_stage["delay"]), "completed": false}
		world["story_chains"] = states
		_append_history(world, chain_id, str(active["id"]), option_id)
		return true
	return false

static func _append_history(world: Dictionary, chain_id: String, stage_id: String, option_id: String) -> void:
	var journal: Array = world.get("story_journal", []).duplicate(true)
	journal.append({"tick": int(world.get("tick", 0)), "chain_id": chain_id, "stage_id": stage_id, "option_id": option_id})
	world["story_journal"] = journal
