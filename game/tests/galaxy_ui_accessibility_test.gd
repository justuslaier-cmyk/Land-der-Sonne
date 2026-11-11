extends SceneTree

const Visual = preload("res://scripts/galaxy/galaxy_visual_theme.gd")

func _initialize() -> void:
    var small: Vector2i = Visual.gutters(Vector2(640, 360))
    var large: Vector2i = Visual.gutters(Vector2(1920, 1080))
    assert(small.x >= 12 and small.y >= 12, "Small viewport must retain safe gutters")
    assert(small.x < large.x and small.y < large.y, "Gutters should scale with viewport")
    assert(large.x <= 48 and large.y <= 30, "Large viewport gutters must remain bounded")
    assert(Visual.contrast_ratio(Visual.TEXT, Visual.BACKGROUND) >= 4.5, "Main text contrast below 4.5:1")
    assert(Visual.contrast_ratio(Visual.GOLD, Visual.BACKGROUND) >= 4.5, "Gold headings contrast below 4.5:1")
    assert(Visual.contrast_ratio(Visual.TEXT, Visual.BUTTON_BG) >= 4.5, "Button text contrast below 4.5:1")
    assert(absf(Visual.contrast_ratio(Visual.TEXT, Visual.TEXT) - 1.0) < 0.001, "Identical colors should have 1:1 contrast")
    print("GALAXY_UI_ACCESSIBILITY_PASS")
    quit(0)
