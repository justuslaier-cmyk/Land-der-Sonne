extends SceneTree

# Tests the actual UI helper without starting a new game.
const UI = preload("res://scripts/galaxy/galaxy_ui.gd")

func _initialize() -> void:
    var ui: Control = UI.new()
    assert(ui._event_category("ancient_signal") == "ARCHÄOLOGIE  •  ANOMALIE")
    assert(ui._event_category("political_crisis") == "INNENPOLITIK  •  KRISE")
    assert(ui._event_category("market") == "WIRTSCHAFT  •  MARKT")
    assert(ui._event_category("unknown") == "ERKUNDUNG  •  UNBEKANNTES")
    ui.free()
    print("GALAXY_EVENT_CARD_PASS")
    quit(0)
