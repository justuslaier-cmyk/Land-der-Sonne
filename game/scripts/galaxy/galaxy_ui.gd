extends Control

const BG := Color("#090f20")
const PANEL := Color("#142239")
const GOLD := Color("#e8c77b")
const WHITE := Color("#e4eaf4")
var screen := "menu"
var settings: Dictionary = GalaxyModel.defaults()
var empire: Dictionary = GalaxyModel.empire_defaults()
var world: Dictionary = {}
var root: VBoxContainer
var status: Label
var map_area: Control
var selected: int = 0

func _ready() -> void:
    get_window().title = "Land der Sonne | Galaktische Chroniken"
    _show_menu()

func _clear() -> void:
    for child in get_children():
        remove_child(child)
        child.queue_free()
    var backdrop := ColorRect.new()
    backdrop.color = BG
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(backdrop)
    var margin := MarginContainer.new()
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    margin.add_theme_constant_override("margin_left", 48)
    margin.add_theme_constant_override("margin_right", 48)
    margin.add_theme_constant_override("margin_top", 30)
    margin.add_theme_constant_override("margin_bottom", 30)
    add_child(margin)
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    margin.add_child(scroll)
    root = VBoxContainer.new()
    root.add_theme_constant_override("separation", 14)
    root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(root)

func _title(value: String, size: int = 36) -> void:
    var label := Label.new()
    label.text = value
    label.add_theme_font_size_override("font_size", size)
    label.add_theme_color_override("font_color", GOLD)
    root.add_child(label)

func _label(value: String) -> Label:
    var label := Label.new()
    label.text = value
    label.add_theme_font_size_override("font_size", 17)
    label.add_theme_color_override("font_color", WHITE)
    root.add_child(label)
    return label

func _button(value: String, callback: Callable) -> void:
    var button := Button.new()
    button.text = value
    button.custom_minimum_size = Vector2(320, 43)
    button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    button.pressed.connect(callback)
    root.add_child(button)

func _show_menu() -> void:
    screen = "menu"
    _clear()
    _title("LAND DER SONNE", 52)
    _label("GALAKTISCHE CHRONIKEN  •  Ein Universum. Unzählige Geschichten.")
    root.add_spacer(false)
    _button("NEUES SPIEL", _show_settings)
    _button("SPIEL LADEN", _load_game)
    _button("EINSTELLUNGEN", _show_options)
    _button("BEENDEN", func(): get_tree().quit())
    _label("Früher Prototyp • Galaxie und Reiche werden aus einem Seed erzeugt")

func _show_options() -> void:
    screen = "options"
    _clear()
    _title("EINSTELLUNGEN")
    _label("Fenstermodus")
    _button("Fenster / Vollbild umschalten", func():
        var mode := get_window().mode
        get_window().mode = Window.MODE_WINDOWED if mode == Window.MODE_FULLSCREEN else Window.MODE_FULLSCREEN
    )
    _button("ZURÜCK", _show_menu)

func _spin(label_text: String, key: String, minimum: int, maximum: int, step: int = 1) -> void:
    var row := HBoxContainer.new()
    root.add_child(row)
    var label := Label.new()
    label.text = label_text
    label.custom_minimum_size.x = 280
    row.add_child(label)
    var spin := SpinBox.new()
    spin.min_value = minimum
    spin.max_value = maximum
    spin.step = step
    spin.value = int(settings[key])
    spin.custom_minimum_size.x = 150
    spin.value_changed.connect(func(value: float): settings[key] = int(value))
    row.add_child(spin)

func _choice(label_text: String, values: Array, dict: Dictionary, key: String) -> void:
    var row := HBoxContainer.new()
    root.add_child(row)
    var label := Label.new()
    label.text = label_text
    label.custom_minimum_size.x = 280
    row.add_child(label)
    var option := OptionButton.new()
    for value in values:
        option.add_item(str(value))
    option.selected = int(dict[key])
    option.item_selected.connect(func(index: int): dict[key] = index)
    option.custom_minimum_size.x = 220
    row.add_child(option)

func _entry(label_text: String, key: String) -> void:
    var row := HBoxContainer.new()
    root.add_child(row)
    var label := Label.new()
    label.text = label_text
    label.custom_minimum_size.x = 280
    row.add_child(label)
    var field := LineEdit.new()
    field.text = str(empire[key])
    field.custom_minimum_size.x = 280
    field.text_changed.connect(func(value: String): empire[key] = value)
    row.add_child(field)

func _show_settings() -> void:
    screen = "settings"
    _clear()
    _title("01 / GALAXIE KONFIGURIEREN")
    _label("Jeder Seed erzeugt eine reproduzierbare Galaxie.")
    _spin("Galaxie-Seed", "seed", 1, 2147483647)
    _spin("Sternensysteme", "size", 20, 250, 10)
    _spin("KI-Reiche", "ai_count", 0, 20)
    _choice("Galaxieform", ["Spiralgalaxie", "Elliptisch", "Ring"], settings, "shape")
    _spin("Bewohnbare Welten (%)", "habitable", 1, 90)
    _spin("Rohstoffhäufigkeit (%)", "resources", 1, 100)
    _spin("Ereignishäufigkeit (%)", "events", 1, 100)
    _choice("Schwierigkeit", ["Entspannt", "Normal", "Herausfordernd"], settings, "difficulty")
    _button("WEITER: REICH ERSTELLEN", _show_empire)
    _button("ZURÜCK ZUM MENÜ", _show_menu)

func _show_empire() -> void:
    screen = "empire"
    _clear()
    _title("02 / ZIVILISATION ERSCHAFFEN")
    _entry("Reichsname", "name")
    _entry("Speziesname", "species")
    _entry("Heimatwelt", "homeworld")
    _choice("Speziesdesign", ["Humanoid", "Insektoid", "Aquatisch", "Kristallin", "Synthetisch"], empire, "portrait")
    _choice("Herrschaftsform", ["Republik", "Monarchie", "Technokratie", "Kollektiv"], empire, "government")
    _choice("Speziesmerkmal", ["Analytisch: +Forschung", "Handelsbegabt: +Credits", "Anpassungsfähig"], empire, "trait")
    _choice("Schiffsstil", ["Solar", "Organisch", "Geometrisch", "Industriell"], empire, "ship_style")
    _button("WEITER: ZUSAMMENFASSUNG", _show_review)
    _button("ZURÜCK ZUR GALAXIE", _show_settings)

func _show_review() -> void:
    screen = "review"
    _clear()
    _title("03 / DEIN UNIVERSUM")
    _label("Reich: %s  |  Spezies: %s" % [empire["name"], empire["species"]])
    _label("Heimat: %s  |  Systeme: %s  |  KI-Reiche: %s" % [empire["homeworld"], settings["size"], settings["ai_count"]])
    _label("Seed: %s" % settings["seed"])
    var error := GalaxyModel.validate(settings, empire)
    if error != "":
        _label("Konfiguration ungültig: " + error)
    else:
        _button("GALAXIE ERSCHAFFEN", _start_game)
    _button("ZURÜCK ZUR REICHSERSTELLUNG", _show_empire)

func _start_game() -> void:
    if GalaxyModel.validate(settings, empire) != "":
        return
    world = GalaxyModel.generate(settings, empire)
    selected = 0
    _show_galaxy()

func _load_game() -> void:
    var loaded := GalaxyModel.load_game()
    if loaded.is_empty():
        _clear()
        _title("SPIEL LADEN")
        _label("Kein gültiger galaktischer Spielstand vorhanden.")
        _button("ZURÜCK", _show_menu)
        return
    world = loaded
    settings = world["settings"].duplicate(true)
    empire = world["empire"].duplicate(true)
    selected = clampi(int(world.get("selected", 0)), 0, world["stars"].size() - 1)
    _show_galaxy()

func _show_galaxy() -> void:
    screen = "galaxy"
    _clear()
    _title("GALAXIE / %s" % world["empire"]["name"], 29)
    status = _label("")
    _refresh_status()
    var buttons := HBoxContainer.new()
    root.add_child(buttons)
    for spec in [["ZEIT +1", _advance], ["SPEICHERN", _save], ["MENÜ", _show_menu]]:
        var button := Button.new()
        button.text = spec[0]
        button.pressed.connect(spec[1])
        buttons.add_child(button)
    map_area = Control.new()
    map_area.custom_minimum_size = Vector2(850, 490)
    map_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    map_area.draw.connect(_draw_map)
    map_area.gui_input.connect(_map_input)
    root.add_child(map_area)
    _show_selection()
    if not bool(world["event_done"]) and int(world["tick"]) >= 3:
        _show_event()

func _refresh_status() -> void:
    status.text = "Jahr %d  •  Credits %d  •  Forschung %d  •  %d Sternensysteme  •  %d KI-Reiche" % [int(world["tick"]) + 2200, int(world["credits"]), int(world["science"]), world["stars"].size(), world["ai"].size()]

func _draw_map() -> void:
    var center := Vector2(430, 245)
    var scale_factor := 0.65
    var palette := [Color("#f3d59a"), Color("#8dd0ff"), Color("#f19b80"), Color("#c7a8f2")]
    for star in world["stars"]:
        var pos := center + Vector2(float(star["x"]), float(star["y"])) * scale_factor
        var radius := 7.0 if int(star["id"]) == selected else 3.0 + float(star["resource"]) * 0.5
        map_area.draw_circle(pos, radius + 3.0, Color("#3a4768"))
        map_area.draw_circle(pos, radius, palette[int(star["kind"]) % palette.size()])
        if int(star["owner"]) == 0:
            map_area.draw_arc(pos, 12, 0, TAU, 24, GOLD, 2.0)
        elif int(star["owner"]) > 0:
            map_area.draw_arc(pos, 10, 0, TAU, 24, Color("#d4748b"), 1.5)
        if int(star["id"]) == selected:
            map_area.draw_arc(pos, 17, 0, TAU, 28, Color.WHITE, 1.0)

func _map_input(event: InputEvent) -> void:
    if not (event is InputEventMouseButton) or not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
        return
    var center := Vector2(430, 245)
    var best := 22.0
    var found := -1
    for star in world["stars"]:
        var pos := center + Vector2(float(star["x"]), float(star["y"])) * 0.65
        var distance := pos.distance_to(event.position)
        if distance < best:
            best = distance
            found = int(star["id"])
    if found >= 0:
        selected = found
        world["selected"] = selected
        _show_galaxy()

func _show_selection() -> void:
    var star: Dictionary = world["stars"][selected]
    _label("Ausgewählt: %s  •  Ressourcenstufe %s  •  %s" % [star["name"], star["resource"], "Bewohnbar" if star["habitable"] else "Unbewohnbar"])
    if int(star["owner"]) == -1 and bool(star["habitable"]):
        _button("KOLONISIEREN (50 Credits)", _colonize)
    _label("Chronik: " + str(world["history"].back()))

func _colonize() -> void:
    if int(world["credits"]) < 50:
        return
    if int(world["stars"][selected]["owner"]) != -1 or not bool(world["stars"][selected]["habitable"]):
        return
    world["credits"] = int(world["credits"]) - 50
    world["stars"][selected]["owner"] = 0
    world["history"].append("Kolonie auf %s gegründet" % world["stars"][selected]["name"])
    _show_galaxy()

func _advance() -> void:
    GalaxyModel.advance(world)
    _show_galaxy()

func _save() -> void:
    var ok := GalaxyModel.save_game(world)
    _label("Spielstand gespeichert." if ok else "Speichern fehlgeschlagen.")

func _show_event() -> void:
    screen = "event"
    _clear()
    _title("EREIGNIS / DAS VERLASSENE SIGNAL")
    _label("Ein Forschungsschiff entdeckt ein uraltes Notsignal in einem benachbarten Sektor.")
    _label("Deine Berater empfehlen, die Quelle sorgfältig zu untersuchen.")
    _button("SIGNAL UNTERSUCHEN (+20 Forschung)", func(): _resolve_event(true))
    _button("TECHNOLOGIE BERGEN (+30 Credits)", func(): _resolve_event(false))

func _resolve_event(research: bool) -> void:
    if research:
        world["science"] = int(world["science"]) + 20
        world["history"].append("Das Signal wurde wissenschaftlich untersucht.")
    else:
        world["credits"] = int(world["credits"]) + 30
        world["history"].append("Die Technologie des Signals wurde verkauft.")
    world["event_done"] = true
    _show_galaxy()
