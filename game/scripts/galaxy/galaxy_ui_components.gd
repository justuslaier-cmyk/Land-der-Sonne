extends RefCounted
# Shared interaction components and deterministic, fog-safe navigation queries.
const ICON_ATLAS = preload("res://assets/art/function_icon_atlas.svg")
const DOMAINS := [
    ["FORSCH", "TECHNO"],
    ["FLOTTE", "SCHIFF", "FLUG"],
    ["KOLON", "BAU", "GEBÄUDE"],
    ["DIPLOM", "VERHAND"],
    ["POLIT", "GESELL"],
    ["WIRTSCHAFT", "MARKT", "CREDIT"],
    ["CHRONIK", "EREIGNIS"],
    ["ERKUND", "SYSTEM"]
]

static func action_button(title: String, callback: Callable, compact: bool = false) -> Button:
    var button := Button.new()
    button.text = title
    button.custom_minimum_size = Vector2(0 if compact else 280, 40 if compact else 44)
    button.focus_mode = Control.FOCUS_ALL
    button.add_theme_font_size_override("font_size", 16)
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL if compact else Control.SIZE_SHRINK_BEGIN
    button.clip_text = false
    button.tooltip_text = describe_action(title)
    GalaxyVisualTheme.apply_button(button)
    apply_icon(button)
    button.pressed.connect(callback)
    return button

static func apply_icon(button: Button) -> void:
    var title := button.text.to_upper()
    for domain in range(DOMAINS.size()):
        for word in DOMAINS[domain]:
            if title.contains(word):
                var icon_texture := AtlasTexture.new()
                icon_texture.atlas = ICON_ATLAS
                icon_texture.region = Rect2(domain * 32, 0, 32, 32)
                button.icon = icon_texture
                button.expand_icon = true
                button.add_theme_constant_override("icon_max_width", 24)
                button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
                return

static func describe_action(title: String) -> String:
    var upper := title.to_upper()
    if upper.contains("(-") or upper.contains("("):
        return "Aktion: %s. Angezeigte Voraussetzungen und Kosten vor Bestätigung prüfen." % title
    if upper.contains("ZURÜCK") or upper.contains("GALAXIE"):
        return "Zur Kartenansicht zurückkehren."
    return "Aktion öffnen oder ausführen: %s" % title

static func find_known_system(world: Dictionary, query: String) -> int:
    var needle := query.strip_edges().to_lower()
    if needle.is_empty():
        return -1
    var known: Array = world.get("known", [])
    for star in world.get("stars", []):
        var id := int(star.get("id", -1))
        if known.has(id) and str(star.get("name", "")).to_lower().contains(needle):
            return id
    return -1
