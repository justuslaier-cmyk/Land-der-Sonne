extends RefCounted
class_name GalaxyVisualTheme

# Phase 15/1: consistent Godot UI token system, accessible focus states.
const BACKGROUND := Color("#090f20")
const PANEL := Color("#142239")
const GOLD := Color("#e8c77b")
const TEXT := Color("#e4eaf4")
const MUTED := Color("#a8bad4")
const FOCUS := Color("#ffe3a3")
const BUTTON_BG := Color("#20334f")
const BUTTON_HOVER := Color("#304968")
const BUTTON_PRESSED := Color("#0e1b31")

static func panel_style(background: Color, border: Color, width: int = 1) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = background
    style.border_color = border
    style.set_border_width_all(width)
    style.set_corner_radius_all(5)
    style.content_margin_left = 16
    style.content_margin_right = 16
    style.content_margin_top = 10
    style.content_margin_bottom = 10
    return style

static func apply_button(button: Button) -> void:
    button.focus_mode = Control.FOCUS_ALL
    button.add_theme_color_override("font_color", TEXT)
    button.add_theme_color_override("font_hover_color", FOCUS)
    button.add_theme_color_override("font_focus_color", FOCUS)
    button.add_theme_color_override("font_pressed_color", GOLD)
    button.add_theme_color_override("font_disabled_color", MUTED)
    button.add_theme_stylebox_override("normal", panel_style(BUTTON_BG, Color("#4b6282")))
    button.add_theme_stylebox_override("hover", panel_style(BUTTON_HOVER, GOLD, 2))
    button.add_theme_stylebox_override("pressed", panel_style(BUTTON_PRESSED, GOLD, 2))
    button.add_theme_stylebox_override("focus", panel_style(Color.TRANSPARENT, FOCUS, 3))
    button.add_theme_stylebox_override("disabled", panel_style(PANEL, Color("#34445b")))

# Scales margins down for smaller windows without sacrificing large-screen rhythm.
static func gutters(viewport_size: Vector2) -> Vector2i:
    var horizontal: int = clampi(int(viewport_size.x * 0.035), 12, 48)
    var vertical: int = clampi(int(viewport_size.y * 0.042), 12, 30)
    return Vector2i(horizontal, vertical)

# WCAG-style relative luminance and contrast for opaque sRGB palette colors.
static func relative_luminance(color: Color) -> float:
    var channels := [color.r, color.g, color.b]
    var result := 0.0
    for i in range(3):
        var value: float = float(channels[i])
        var linear: float = value / 12.92 if value <= 0.04045 else pow((value + 0.055) / 1.055, 2.4)
        result += linear * ([0.2126, 0.7152, 0.0722][i])
    return result

static func contrast_ratio(a: Color, b: Color) -> float:
    var light: float = maxf(relative_luminance(a), relative_luminance(b))
    var dark: float = minf(relative_luminance(a), relative_luminance(b))
    return (light + 0.05) / (dark + 0.05)
