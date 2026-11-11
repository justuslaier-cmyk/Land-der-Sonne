extends SceneTree

const UI = preload("res://scripts/galaxy/galaxy_ui.gd")

func _initialize() -> void:
    var paths := [
        "res://assets/art/menu_city.svg",
        "res://assets/art/event_reactor.svg",
        "res://assets/art/event_ruins.svg",
        "res://assets/art/event_political.svg",
        "res://assets/art/event_colonies.svg",
        "res://assets/art/event_market.svg",
        "res://assets/art/scene_fleet.svg",
        "res://assets/art/scene_diplomacy.svg",
        "res://assets/art/scene_research.svg",
        "res://assets/art/galaxy_nebula.svg"
    ]
    for path in paths:
        assert(ResourceLoader.exists(path), "Missing art resource: " + path)
        var texture: Texture2D = load(path)
        assert(texture != null, "Unimportable art resource: " + path)
    print("GALAXY_ART_RESOURCES_PASS")
    quit(0)
