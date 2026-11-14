extends SceneTree

const Chains = preload("res://scripts/galaxy_story_chains.gd")
const Events = preload("res://scripts/galaxy_event_engine.gd")

func _initialize() -> void:
	var world := {"tick": 5, "credits": 100, "science": 0, "alloys": 10, "explored_count": 1}
	var signal_event: Dictionary = {}
	for event in Events.candidates(world):
		if str(event["id"]) == "ancient_signal":
			signal_event = event
	assert(not signal_event.is_empty(), "Ancient signal must be eligible after exploration")
	assert(Events.apply(world, signal_event, "study"), "Study must succeed")
	assert(Chains.begin(world, "first_signal", "ancient_signal", "study"), "Chain must start")
	assert(not Chains.begin(world, "first_signal", "ancient_signal", "study"), "Duplicate chain must fail")
	assert(Chains.pending(world).is_empty(), "Stage must respect delay")
	world["tick"] = 7
	assert(Chains.pending(world).size() == 1, "First stage should unlock")
	assert(not Chains.resolve(world, "first_signal", "unknown"), "Invalid option must not mutate state")
	assert(Chains.resolve(world, "first_signal", "follow"), "Follow should succeed")
	assert(world["credits"] == 75, "Costs must be charged exactly once")
	world["tick"] = 10
	assert(Chains.pending(world).size() == 1, "Vault stage should unlock")
	assert(Chains.resolve(world, "first_signal", "restore"), "Vault resolution should succeed")
	assert(Chains.pending(world).is_empty(), "Completed chain must not recur")
	assert(world["story_journal"].size() == 3, "Journal must contain beginning and two resolutions")
	var saved: String = JSON.stringify(world)
	var loaded: Variant = JSON.parse_string(saved)
	assert(typeof(loaded) == TYPE_DICTIONARY, "World must serialize as dictionary")
	assert(loaded["story_chains"]["first_signal"]["completed"], "Completion must persist")
	assert(loaded["story_journal"].size() == 3, "History must persist")
	print("GALAXY_STORY_CHAINS_PASS")
	quit()
