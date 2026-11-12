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
        "res://assets/art/war_objective.svg",
        "res://assets/art/scene_research.svg",
        "res://assets/art/galaxy_nebula.svg",
        "res://assets/art/planet_sprite_strip.svg",
        "res://assets/art/ship_sprite_strip.svg",
        "res://assets/art/species_portrait_strip.svg",
        "res://assets/art/star_sprite_strip.svg",
        "res://assets/art/orbital_station.svg",
        "res://assets/art/function_icon_atlas.svg"
    ]
    for path in paths:
        assert(ResourceLoader.exists(path), "Missing art resource: " + path)
        var texture: Texture2D = load(path)
        assert(texture != null, "Unimportable art resource: " + path)
    var objective: Texture2D = load("res://assets/art/war_objective.svg")
    assert(objective.get_size() == Vector2(48, 48), "War objective icon size incorrect")
    var planets: Texture2D = load("res://assets/art/planet_sprite_strip.svg")
    var ships: Texture2D = load("res://assets/art/ship_sprite_strip.svg")
    assert(planets.get_width() == 512 and planets.get_height() == 64, "Planet strip must contain 8 cells of 64x64")
    assert(ships.get_width() == 256 and ships.get_height() == 64, "Ship strip must contain 4 cells of 64x64")
    var portraits: Texture2D = load("res://assets/art/species_portrait_strip.svg")
    var stars: Texture2D = load("res://assets/art/star_sprite_strip.svg")
    var station: Texture2D = load("res://assets/art/orbital_station.svg")
    assert(portraits.get_size() == Vector2(320, 96), "Portrait strip must contain five 64x96 portraits")
    assert(stars.get_size() == Vector2(128, 32), "Star strip must contain four 32x32 icons")
    assert(station.get_size() == Vector2(64, 64), "Orbital station must be 64x64")
    var icons: Texture2D = load("res://assets/art/function_icon_atlas.svg")
    assert(icons.get_size() == Vector2(256, 64), "Function icon atlas must contain eight 32x32 pairs")
    print("GALAXY_ART_RESOURCES_PASS")
    quit(0)
