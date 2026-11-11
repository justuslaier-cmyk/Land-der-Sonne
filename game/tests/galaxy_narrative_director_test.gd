extends SceneTree

const Director = preload("res://scripts/galaxy_narrative_director.gd")

func _initialize() -> void:
	var world: Dictionary = {"tick": 5, "settings": {"seed": 12}, "credits": 100, "science": 0, "alloys": 30, "explored_count": 1, "civilian_trade": []}
	var first: Dictionary = Director.advance(world)
	assert(not first.is_empty(), "Exploration must enable ancient signal")
	assert(str(first["id"]) == "ancient_signal", "Only eligible event must be selected")
	var same: Dictionary = Director.advance(world)
	assert(first == same, "Pending event must remain stable")
	assert(not Director.resolve_choice(world, "invalid"), "Unknown choice must fail")
	assert(Director.resolve_choice(world, "study"), "Valid choice must succeed")
	assert(world["story_chains"].has("first_signal"), "Study must start story chain")
	assert(world["narrative_pending"].is_empty() if world.has("narrative_pending") else true, "Choice must clear pending event")
	world["tick"] = 7
	var stage: Dictionary = Director.advance(world)
	assert(str(stage.get("kind", "")) == "story", "Story takes precedence over ambient events")
	assert(str(stage.get("stage", "")) == "decode", "First story stage must be presented")
	assert(Director.resolve_choice(world, "follow"), "Follow option must succeed")
	world["tick"] = 10
	var vault: Dictionary = Director.advance(world)
	assert(str(vault.get("stage", "")) == "vault", "Second stage must be presented")
	assert(Director.resolve_choice(world, "restore"), "Archive must resolve")
	assert(world["story_chains"]["first_signal"]["completed"], "Chain must complete")
	var chronicle: Array = Director.history(world)
	assert(chronicle.size() == 4, "Event and story journal entries must merge")
	var saved: String = JSON.stringify(world)
	var restored: Variant = JSON.parse_string(saved)
	assert(typeof(restored) == TYPE_DICTIONARY, "JSON save roundtrip must succeed")
	assert(restored["story_chains"]["first_signal"]["completed"], "Completion must survive JSON roundtrip")
	print("GALAXY_NARRATIVE_DIRECTOR_PASS")
	quit()
