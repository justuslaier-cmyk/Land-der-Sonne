extends SceneTree

const Visual = preload("res://scripts/galaxy/galaxy_visual_theme.gd")

func _initialize() -> void:
    var button := Button.new()
    Visual.apply_button(button)
    assert(button.focus_mode == Control.FOCUS_ALL, "Buttons must be keyboard focusable")
    for state in ["normal", "hover", "pressed", "focus", "disabled"]:
        assert(button.has_theme_stylebox_override(state), "Missing style: " + state)
    assert(Visual.BACKGROUND != Visual.TEXT, "Background and foreground must differ")
    assert(Visual.FOCUS != Visual.BUTTON_BG, "Focus must be visually distinct")
    print("GALAXY_VISUAL_THEME_PASS")
    quit(0)
