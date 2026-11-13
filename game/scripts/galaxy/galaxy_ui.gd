extends Control

const UiComponents = preload("res://scripts/galaxy/galaxy_ui_components.gd")
const Comfort = preload("res://scripts/galaxy/galaxy_comfort.gd")
const AudioDirector = preload("res://scripts/galaxy/galaxy_audio.gd")
const OPTIONS_ART = preload("res://assets/art/ui_comfort_panel.svg")
# Map resources are immutable and reused across redraws, including 250-star maps.
const MAP_NEBULA = preload("res://assets/art/galaxy_nebula.svg")
const MAP_STAR_STRIP = preload("res://assets/art/star_sprite_strip.svg")
const MAP_PLAYER_SHIP = preload("res://assets/art/ship_style_0.svg")
const MAP_RIVAL_SHIP = preload("res://assets/art/ship_style_3.svg")

const BG := GalaxyVisualTheme.BACKGROUND
const PANEL := GalaxyVisualTheme.PANEL
const GOLD := GalaxyVisualTheme.GOLD
const WHITE := GalaxyVisualTheme.TEXT
var screen := "menu"
var settings: Dictionary = GalaxyModel.defaults()
var empire: Dictionary = GalaxyModel.empire_defaults()
var world: Dictionary = {}
var root: VBoxContainer
var status: Label
var map_area: Control
var selected: int = 0
var notice: String = ""
var panel: String = "system"
var zoom: float = 0.65
var map_offset: Vector2 = Vector2.ZERO
var map_dragging := false
var drag_origin := Vector2.ZERO
var map_offset_origin := Vector2.ZERO
var selected_planet: int = 0
var galaxy_details: VBoxContainer
var simulation_speed: int = 1
var simulation_paused: bool = true
var simulation_elapsed: float = 0.0
var time_status: Label
var forecast_status: Label
var tutorial_step: int = 0
var system_search: LineEdit
var comfort: Dictionary = Comfort.defaults()
var options_return: String = "menu"
var onboarding_dismissed: bool = false
var audio_director: GalaxyAudio

func _ready() -> void:
    get_window().title = "Land der Sonne | Galaktische Chroniken"
    audio_director = AudioDirector.new()
    audio_director.name = "GalaxyAudioDirector"
    add_child(audio_director)
    comfort = Comfort.load_preferences()
    _apply_comfort()
    _show_menu()

# Keyboard shortcuts are ignored while text fields are being edited.
func _unhandled_key_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    if get_viewport().gui_get_focus_owner() is LineEdit or get_viewport().gui_get_focus_owner() is TextEdit:
        return
    if event.keycode == KEY_F1:
        if screen != "help":
            _show_help()
        get_viewport().set_input_as_handled()
    elif event.keycode == KEY_ESCAPE and screen == "help":
        if world.is_empty():
            _show_menu()
        else:
            _show_galaxy()
        get_viewport().set_input_as_handled()
    elif event.keycode == KEY_ESCAPE and screen != "galaxy" and screen != "menu" and not world.is_empty() and screen != "event":
        _show_galaxy()
        get_viewport().set_input_as_handled()
    elif event.keycode == KEY_F and event.ctrl_pressed and screen == "galaxy" and is_instance_valid(system_search):
        system_search.grab_focus()
        get_viewport().set_input_as_handled()
    elif event.keycode == KEY_SPACE and screen == "galaxy" and not world.is_empty():
        _toggle_pause()
        get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
    if world.is_empty() or simulation_paused or screen != "galaxy":
        return
    simulation_elapsed += delta * float(simulation_speed)
    var steps := 0
    while simulation_elapsed >= 4.0 and steps < 8:
        simulation_elapsed -= 4.0
        GalaxyStrategy.tick(world)
        # Autosave every ten completed simulation years, independent of manual slots.
        if int(world.get("tick", 0)) > 0 and int(world["tick"]) % 10 == 0:
            world["selected"] = selected
            if not GalaxyModel.save_game(world, 0):
                notice = "Automatisches Speichern fehlgeschlagen."
        steps += 1
        if str(world.get("pending_event", "")) != "":
            simulation_paused = true
            _show_event()
            return
    if steps > 0:
        _refresh_status()
        _refresh_forecast()
        if is_instance_valid(map_area):
            map_area.queue_redraw()
        _show_selection()
    _refresh_time_status()

func _toggle_pause() -> void:
    simulation_paused = not simulation_paused
    _refresh_time_status()

func _set_speed(speed: int) -> void:
    simulation_speed = speed
    world["simulation_speed"] = speed
    simulation_paused = false
    _refresh_time_status()

func _refresh_time_status() -> void:
    if is_instance_valid(time_status):
        time_status.text = ("PAUSE" if simulation_paused else "ZEIT LÄUFT") + "  •  %dx  •  %.1fs bis nächstes Jahr" % [simulation_speed, maxf(0.0, (4.0 - simulation_elapsed) / float(simulation_speed))]

func _apply_comfort() -> void:
    Comfort.apply(get_window(), comfort)

func _set_comfort(key: String, value: Variant) -> void:
    comfort[key] = value
    _apply_comfort()
    Comfort.save_preferences(comfort)

func _back_from_options() -> void:
    if options_return == "galaxy" and not world.is_empty():
        _show_galaxy()
    else:
        _show_menu()

func _clear() -> void:
    for child in get_children():
        if child == audio_director:
            continue
        remove_child(child)
        child.queue_free()
    var backdrop := ColorRect.new()
    backdrop.color = BG
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(backdrop)
    var margin := MarginContainer.new()
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var gutters: Vector2i = GalaxyVisualTheme.gutters(get_viewport_rect().size)
    margin.add_theme_constant_override("margin_left", gutters.x)
    margin.add_theme_constant_override("margin_right", gutters.x)
    margin.add_theme_constant_override("margin_top", gutters.y)
    margin.add_theme_constant_override("margin_bottom", gutters.y)
    add_child(margin)
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    margin.add_child(scroll)
    root = VBoxContainer.new()
    root.add_theme_constant_override("separation", 14)
    root.size_flags_vertical = Control.SIZE_EXPAND_FILL
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
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size", 17)
    label.add_theme_color_override("font_color", WHITE)
    root.add_child(label)
    return label

# One original 32x32 pixel icon per major gameplay domain.
func _apply_action_icon(button: Button) -> void:
    UiComponents.apply_icon(button)

func _button(value: String, callback: Callable) -> void:
    var button := UiComponents.action_button(value, callback)
    button.pressed.connect(func(): _play_ui_sound("click"))
    root.add_child(button)

func _play_ui_sound(kind: String = "click") -> void:
    if is_instance_valid(audio_director):
        audio_director.play_effect(kind)

func _begin_new_game() -> void:
    # A fresh wizard must not inherit settings or identity from a previous game.
    settings = GalaxyModel.defaults()
    empire = GalaxyModel.empire_defaults()
    notice = ""
    _show_settings()

func _reset_new_game() -> void:
    settings = GalaxyModel.defaults()
    empire = GalaxyModel.empire_defaults()
    _show_settings()

func _cancel_new_game() -> void:
    # Cancel discards the draft; continuing a running game is a separate action.
    settings = GalaxyModel.defaults()
    empire = GalaxyModel.empire_defaults()
    _show_menu()

func _show_menu() -> void:
    screen = "menu"
    _clear()
    _title("LAND DER SONNE", 52)
    _label("GALAKTISCHE CHRONIKEN  •  Ein Universum. Unzählige Geschichten.")
    _illustration("menu")
    _button("NEUES SPIEL", _begin_new_game)
    _button("SPIEL LADEN", _load_game)
    _button("SPIELSTÄNDE 1–4", _show_save_slots)
    _button("SPIELANLEITUNG", _show_help)
    _button("INTERAKTIVER EINSTIEG", _start_tutorial)
    _button("EINSTELLUNGEN", func(): _open_options("menu"))
    _button("BEENDEN", func(): get_tree().quit())
    _label("Früher Prototyp • Galaxien können zufällig oder mit festem Seed erzeugt werden.")

func _show_help() -> void:
    var from_game := not world.is_empty()
    screen = "help"
    _clear()
    _title("SPIELANLEITUNG")
    _illustration("menu")
    _label("1. NEUES SPIEL: Galaxiegröße, Seed und KI-Reiche wählen; danach Reich, Spezies und Heimatwelt bestimmen.")
    _label("2. GALAXIE: Systeme auswählen, erkunden und eigene Kolonien verwalten. Die Kartenansicht zeigt den bekannten Raum.")
    _label("3. ZEIT: Die Simulation startet pausiert. Mit PAUSE / WEITER fortsetzen und mit 1× bis 8× beschleunigen.")
    _label("4. FORSCHUNG UND WIRTSCHAFT: Forschungspunkte in Technologien investieren, Ressourcen und Produktion überwachen.")
    _label("5. DIPLOMATIE UND FLOTTEN: Beziehungen verwalten, Flotten befehligen und ihre Versorgung beachten.")
    _label("6. EREIGNISSE: Offene Entscheidungen unterbrechen die Zeit. Eine Auswahl setzt die Simulation fort.")
    _label("7. SPIELSTÄNDE: Vier manuelle Slots im Menü SPIELSTÄNDE; der automatische Spielstand wird alle zehn Jahre erneuert.")
    _label("8. CHRONIK UND ZIELE: Langfristigen Fortschritt über die Berichte nachvollziehen.")
    _label("Tastatur: F1 = Hilfe, Esc = zurück, Leertaste = Pause, Strg+F = Systemsuche. Im Textfeld werden Kartenkürzel ignoriert.")
    _label("Hinweis: Dies ist eine Anleitung zum experimentellen Prototyp, kein vollständiges interaktives Tutorial.")
    _button("ZUR GALAXIE" if from_game else "ZUM MENÜ", _show_galaxy if from_game else _show_menu)

# A short interactive onboarding that requires user input at each step.
func _start_tutorial() -> void:
    tutorial_step = 0
    _show_tutorial()

func _show_tutorial() -> void:
    screen = "tutorial"
    _clear()
    _title("ERSTE SCHRITTE  %d / 4" % (tutorial_step + 1))
    _illustration("menu")
    var steps := [
        "Eine Galaxie entsteht aus Sternenzahl, Form und Seed. Derselbe Seed erzeugt denselben Ausgangspunkt.",
        "Dein Reich erhält einen Namen, eine Spezies und eine Heimatwelt. Die Vorlagen sind veränderbar.",
        "Im Galaxiebildschirm wählst du Sterne und Verwaltungsbereiche. Die Simulation startet pausiert.",
        "Forschung, Wirtschaft, Diplomatie und Flotten wirken über mehrere Jahre zusammen. F1 öffnet jederzeit die Hilfe."
    ]
    _label(steps[tutorial_step])
    if tutorial_step > 0:
        _button("ZURÜCK", func():
            tutorial_step -= 1
            _show_tutorial()
        )
    if tutorial_step < steps.size() - 1:
        _button("NÄCHSTER SCHRITT", func():
            tutorial_step += 1
            _show_tutorial()
        )
    else:
        _button("JETZT SPIEL STARTEN", _begin_new_game)
    _button("TUTORIAL BEENDEN", _show_menu)

func _open_options(return_screen: String = "menu") -> void:
    options_return = return_screen
    _show_options()

func _show_options() -> void:
    screen = "options"
    _clear()
    _title("EINSTELLUNGEN")
    var art := TextureRect.new()
    art.texture = OPTIONS_ART
    art.custom_minimum_size = Vector2(0, 96)
    art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    art.mouse_filter = Control.MOUSE_FILTER_IGNORE
    root.add_child(art)
    _label("Darstellung, Ton und Bedienung werden unabhängig von Spielständen gespeichert.")
    _label("UI-Skalierung")
    var scale_slider := HSlider.new()
    scale_slider.min_value = 80
    scale_slider.max_value = 150
    scale_slider.step = 10
    scale_slider.value = int(comfort["ui_scale"])
    scale_slider.custom_minimum_size = Vector2(260, 38)
    scale_slider.tooltip_text = "Bedienelemente auf 80 bis 150 Prozent vergrößern."
    scale_slider.value_changed.connect(func(value: float): _set_comfort("ui_scale", int(value)))
    root.add_child(scale_slider)
    _label("Master-Lautstärke")
    var volume_slider := HSlider.new()
    volume_slider.min_value = 0
    volume_slider.max_value = 100
    volume_slider.step = 5
    volume_slider.value = int(comfort["volume"])
    volume_slider.custom_minimum_size = Vector2(260, 38)
    volume_slider.tooltip_text = "Gesamtlautstärke des Spiels in Prozent."
    volume_slider.value_changed.connect(func(value: float): _set_comfort("volume", int(value)))
    root.add_child(volume_slider)
    var mute_button := CheckBox.new()
    mute_button.text = "Ton stummschalten"
    mute_button.button_pressed = bool(comfort["muted"])
    mute_button.toggled.connect(func(value: bool): _set_comfort("muted", value))
    root.add_child(mute_button)
    for audio_spec in [["Musik-Lautstärke", "music_volume", "Music"], ["Effekt-Lautstärke", "sfx_volume", "SFX"]]:
        _label(str(audio_spec[0]))
        var channel_slider := HSlider.new()
        channel_slider.min_value = 0
        channel_slider.max_value = 100
        channel_slider.step = 5
        channel_slider.value = int(comfort[audio_spec[1]])
        channel_slider.custom_minimum_size = Vector2(260, 38)
        channel_slider.tooltip_text = "Lautstärke des Audiokanals " + str(audio_spec[2])
        var setting_key: String = str(audio_spec[1])
        channel_slider.value_changed.connect(func(value: float): _set_comfort(setting_key, int(value)))
        root.add_child(channel_slider)
    _button("Fenster / Vollbild umschalten", func():
        var fullscreen := get_window().mode != Window.MODE_FULLSCREEN
        _set_comfort("fullscreen", fullscreen)
    )
    _button("STANDARDWERTE WIEDERHERSTELLEN", func():
        comfort = Comfort.defaults()
        _apply_comfort()
        Comfort.save_preferences(comfort)
        _show_options()
    )
    _button("ZURÜCK", _back_from_options)

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
    spin.value_changed.connect(func(value: float):
        settings[key] = int(value)
        if key == "size":
            settings["ai_count"] = mini(int(settings["ai_count"]), mini(20, int(value) / 5))
            _show_settings()
    )
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

func _seed_input() -> void:
    var row := HBoxContainer.new()
    root.add_child(row)
    var label := Label.new()
    label.text = "Galaxie-Seed (0 = zufällig)"
    label.custom_minimum_size.x = 280
    row.add_child(label)
    var spin := SpinBox.new()
    spin.min_value = 0
    spin.max_value = 2147483647
    spin.step = 1
    spin.rounded = true
    spin.value = int(settings["seed"])
    spin.custom_minimum_size.x = 200
    spin.value_changed.connect(func(value: float): settings["seed"] = int(value))
    row.add_child(spin)

func _show_settings() -> void:
    screen = "settings"
    _clear()
    _title("01 / GALAXIE KONFIGURIEREN")
    _label("Seed 0 erzeugt eine Zufallsgalaxie; ein fester Seed erlaubt denselben Start.")
    _spin("Sternensysteme", "size", 20, 250, 10)
    _seed_input()
    _spin("KI-Reiche", "ai_count", 0, mini(20, int(settings["size"]) / 5))
    _choice("Galaxieform", ["Spiralgalaxie", "Elliptisch", "Ring"], settings, "shape")
    _spin("Bewohnbare Welten (%)", "habitable", 1, 90)
    _spin("Rohstoffhäufigkeit (%)", "resources", 1, 100)
    _spin("Ereignishäufigkeit (%)", "events", 1, 100)
    _choice("Schwierigkeit", ["Entspannt", "Normal", "Herausfordernd"], settings, "difficulty")
    _label("Schwierigkeit steuert die Häufigkeit bezahlter KI-Expansion und Flottenverstärkung; keine Gratisressourcen oder versteckten Kampfboni.")
    _button("WEITER: REICH ERSTELLEN", func():
        var error := GalaxyModel.validate(settings, empire)
        if error != "":
            notice = error
            _show_settings()
        else:
            notice = ""
            _show_empire()
    )
    if notice != "":
        _label("Eingabe prüfen: " + notice)
    _button("STANDARDWERTE WIEDERHERSTELLEN", _reset_new_game)
    _button("ABBRECHEN", _cancel_new_game)

func _apply_empire_template(index: int) -> void:
    empire = GalaxyModel.empire_defaults()
    if index == 1:
        empire["name"] = "Sternenkonklave"
        empire["species"] = "Asteri"
        empire["homeworld"] = "Observatorium"
        empire["government"] = 2
        empire["civics"] = ["archives", "guilds"]
        empire["ethic"] = "mercantile"
    elif index == 2:
        empire["name"] = "Grenzbund"
        empire["species"] = "Pioniere"
        empire["homeworld"] = "Neuland"
        empire["government"] = 3
        empire["civics"] = ["frontier", "commons"]
        empire["ethic"] = "collectivist"
    notice = ""
    _show_empire()

func _show_empire() -> void:
    screen = "empire"
    _clear()
    _title("02 / ZIVILISATION ERSCHAFFEN")
    _label("VORLAGEN  •  Ausgangspunkt auswählen und anschließend anpassen")
    _button("SOLARE UNION / REPUBLIK", func(): _apply_empire_template(0))
    _button("STERNENKONKLAVE / TECHNOKRATIE", func(): _apply_empire_template(1))
    _button("GRENZBUND / KOLLEKTIV", func(): _apply_empire_template(2))
    _entry("Reichsname", "name")
    _entry("Speziesname", "species")
    _entry("Heimatwelt", "homeworld")
    _label("Speziesdesign – wähle ein Porträt")
    _species_gallery()
    _label("Ausgewählt: " + ["Humanoid", "Insektoid", "Aquatisch", "Kristallin", "Synthetisch"][int(empire["portrait"])])
    _choice("Herrschaftsform", ["Republik", "Monarchie", "Technokratie", "Kollektiv"], empire, "government")
    _label("GESELLSCHAFTLICHE GRUNDHALTUNG")
    var ethics: Array = []
    for item in GalaxyIdentity.ETHICS:
        ethics.append(str(item["icon"]) + " " + str(item["name"]))
    var ethic_index := 0
    for i in range(GalaxyIdentity.ETHICS.size()):
        if str(GalaxyIdentity.ETHICS[i]["id"]) == str(empire.get("ethic", "pluralist")):
            ethic_index = i
    var ethic_option := OptionButton.new()
    for value in ethics:
        ethic_option.add_item(str(value))
    ethic_option.selected = ethic_index
    ethic_option.item_selected.connect(func(index: int):
        empire["ethic"] = str(GalaxyIdentity.ETHICS[index]["id"])
        _show_empire()
    )
    root.add_child(ethic_option)
    _label("STAATSPRINZIPIEN  •  Genau zwei auswählen")
    for item in GalaxyIdentity.CIVICS:
        var civic_id := str(item["id"])
        var selected_civic: bool = empire.get("civics", ["archives", "commons"]).has(civic_id)
        var civic_button := Button.new()
        civic_button.text = ("● " if selected_civic else "○ ") + str(item["icon"]) + " " + str(item["name"]) + "  —  " + str(item["description"])
        civic_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
        civic_button.pressed.connect(func():
            var chosen: Array = empire.get("civics", ["archives", "commons"]).duplicate()
            if chosen.has(civic_id):
                chosen.erase(civic_id)
            elif chosen.size() < 2:
                chosen.append(civic_id)
            else:
                chosen.pop_front()
                chosen.append(civic_id)
            empire["civics"] = chosen
            _show_empire()
        )
        root.add_child(civic_button)
    _label("BIOLOGISCHE SPEZIESMERKMALE  •  Budget: höchstens 3 Punkte, maximal 4 Merkmale")
    var trait_points := 0
    for trait_id in empire.get("traits", ["curious"]):
        trait_points += int(GalaxyIdentity.trait_info(str(trait_id)).get("cost", 0))
    _label("Verwendete Punkte: %d / 3  •  Nachteile geben Punkte zurück." % trait_points)
    for item in GalaxyIdentity.TRAITS:
        var trait_id := str(item["id"])
        var selected_trait: bool = empire.get("traits", ["curious"]).has(trait_id)
        var trait_button := Button.new()
        trait_button.text = ("● " if selected_trait else "○ ") + str(item["icon"]) + " " + str(item["name"]) + " (%+d)  —  " % int(item["cost"]) + str(item["description"])
        trait_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
        trait_button.pressed.connect(func():
            var chosen: Array = empire.get("traits", ["curious"]).duplicate()
            if chosen.has(trait_id):
                chosen.erase(trait_id)
            else:
                chosen.append(trait_id)
            var candidate: Dictionary = empire.duplicate(true)
            candidate["traits"] = chosen
            if GalaxyIdentity.validate(candidate) == "":
                empire["traits"] = chosen
            _show_empire()
        )
        root.add_child(trait_button)
    _label("Schiffsarchitektur – Vorschau")
    _ship_gallery()
    _button("WEITER: ZUSAMMENFASSUNG", func():
        var error := GalaxyModel.validate(settings, empire)
        if error != "":
            notice = error
            _show_empire()
        else:
            notice = ""
            _show_review()
    )
    if notice != "":
        _label("Eingabe prüfen: " + notice)
    _button("ZURÜCK ZU GALAXIEEINSTELLUNGEN", _show_settings)
    _button("ABBRECHEN", _cancel_new_game)

func _show_review() -> void:
    screen = "review"
    _clear()
    _title("03 / DEIN UNIVERSUM")
    _label("Reich: %s  |  Spezies: %s" % [empire["name"], empire["species"]])
    _label("Heimat: %s  |  Systeme: %s  |  KI-Reiche: %s" % [empire["homeworld"], settings["size"], settings["ai_count"]])
    _label("Staatsprinzipien: " + ", ".join(empire.get("civics", [])))
    _label("Speziesmerkmale: " + ", ".join(empire.get("traits", [])))
    _label("Galaxie-Seed: " + ("zufällig" if int(settings["seed"]) == 0 else str(settings["seed"])))
    _species_gallery(true)
    _ship_gallery(true)
    var error := GalaxyModel.validate(settings, empire)
    if error != "":
        _label("Konfiguration ungültig: " + error)
    else:
        _button("GALAXIE ERSCHAFFEN", _start_game)
    _button("ZURÜCK ZUR REICHSERSTELLUNG", _show_empire)
    _button("ABBRECHEN", _cancel_new_game)

func _start_game() -> void:
    if GalaxyModel.validate(settings, empire) != "":
        return
    # Use the selected seed if supplied; 0 requests a new random galaxy.
    world = GalaxyModel.generate(settings, empire)
    selected = 0
    GalaxyStrategy.prepare(world)
    _ensure_home_colony()
    simulation_elapsed = 0.0
    simulation_speed = 1
    world["simulation_speed"] = 1
    simulation_paused = false
    onboarding_dismissed = false
    _show_galaxy()

func _show_save_slots() -> void:
    screen = "save_slots"
    _clear()
    _title("SPIELSTÄNDE")
    for slot in range(1, 5):
        var index: int = slot
        var stored := GalaxyModel.load_game(index)
        var description := "LEER" if stored.is_empty() else "%s | Jahr %d | Seed %d" % [str(stored.get("empire", {}).get("name", "Reich")), int(stored.get("tick", 0)) + 2200, int(stored.get("settings", {}).get("seed", 0))]
        if stored.is_empty():
            _label("SLOT %d — LEER (kein gültiger Spielstand)" % index)
        else:
            _button("SLOT %d — %s — LADEN" % [index, description], func(): _load_slot(index))
        if not world.is_empty():
            _button("SLOT %d — SPEICHERN" % index, func(): _save_slot(index))
    _button("ZURÜCK", _show_galaxy if not world.is_empty() else _show_menu)

func _load_slot(slot: int) -> void:
    var loaded := GalaxyModel.load_game(slot)
    if loaded.is_empty():
        _label("Slot %d enthält keinen gültigen Spielstand." % slot)
        return
    world = loaded
    GalaxyStrategy.prepare(world)
    _ensure_home_colony()
    settings = world["settings"].duplicate(true)
    empire = world["empire"].duplicate(true)
    selected = clampi(int(world.get("selected", 0)), 0, world["stars"].size() - 1)
    simulation_elapsed = 0.0
    simulation_speed = clampi(int(world.get("simulation_speed", 1)), 1, 8)
    simulation_paused = true
    _show_galaxy()

func _save_slot(slot: int) -> void:
    world["selected"] = selected
    var ok := GalaxyModel.save_game(world, slot)
    _label("Slot %d gespeichert." % slot if ok else "Speichern in Slot %d fehlgeschlagen." % slot)

func _load_game() -> void:
    var loaded := GalaxyModel.load_game()
    if loaded.is_empty():
        _clear()
        _title("SPIEL LADEN")
        _label("Kein gültiger galaktischer Spielstand vorhanden.")
        _button("ZURÜCK", _show_menu)
        return
    world = loaded
    GalaxyStrategy.prepare(world)
    _ensure_home_colony()
    settings = world["settings"].duplicate(true)
    empire = world["empire"].duplicate(true)
    selected = clampi(int(world.get("selected", 0)), 0, world["stars"].size() - 1)
    simulation_elapsed = 0.0
    simulation_speed = clampi(int(world.get("simulation_speed", 1)), 1, 8)
    simulation_paused = true
    _show_galaxy()

func _ensure_home_colony() -> void:
    GalaxyStrategy.prepare(world)
    var star: Dictionary = world["stars"][0]
    var system := GalaxyCelestials.generate(int(world["settings"]["seed"]), star)
    var index := 0
    for i in range(system["planets"].size()):
        if bool(system["planets"][i]["habitable"]):
            index = i
            break
    var key := GalaxyStrategy.planet_key(0, index)
    if not world["planet_colonies"].has(key):
        world["planet_colonies"][key] = {"population": 2, "buildings": {}}

func _show_galaxy() -> void:
    screen = "galaxy"
    GalaxySystems.prepare(world)
    _clear()
    _title("GALAXIE / %s" % world["empire"]["name"], 29)
    status = _label("")
    _refresh_status()
    forecast_status = _label("")
    forecast_status.add_theme_font_size_override("font_size", 14)
    _refresh_forecast()
    time_status = _label("")
    _refresh_time_status()
    # Stable command groups replace the overflowing horizontal action strip.
    var commands := HFlowContainer.new()
    commands.add_theme_constant_override("h_separation", 8)
    commands.add_theme_constant_override("v_separation", 6)
    root.add_child(commands)
    var pause_button := UiComponents.action_button("PAUSE / WEITER", _toggle_pause, true)
    commands.add_child(pause_button)
    var speed_choice := OptionButton.new()
    speed_choice.tooltip_text = "Simulationsgeschwindigkeit. Das Spiel beginnt pausiert."
    for rate in [1, 2, 4, 8]:
        speed_choice.add_item("%d×" % rate, rate)
    speed_choice.select([1, 2, 4, 8].find(simulation_speed))
    speed_choice.item_selected.connect(func(index: int): _set_speed(speed_choice.get_item_id(index)))
    commands.add_child(speed_choice)
    _navigation_menu("ERKUNDUNG", [["Auto-Erkundung", _toggle_auto_survey], ["Flotte", _fleet], ["Flottenkommando", _fleet_command], ["Flottendoktrin", _fleet_doctrine]], commands)
    _navigation_menu("REICH", [["Wirtschaft", _economy_report], ["Gesellschaft", _society_report], ["Politik", _politics], ["Forschung", _research], ["Schiffswerft", _shipyard]], commands)
    _navigation_menu("AUSSENPOLITIK", [["Diplomatie", _diplomacy], ["Ziele", _goals_report]], commands)
    _navigation_menu("CHRONIK", [["Chronik öffnen", _chronicle], ["Spielanleitung", _show_help]], commands)
    _navigation_menu("SPIEL", [["Speichern", _save], ["Spielstände", _show_save_slots], ["Einstellungen", func(): _open_options("galaxy")], ["Hauptmenü", _show_menu]], commands)
    var search_row := HBoxContainer.new()
    root.add_child(search_row)
    var search_caption := Label.new()
    search_caption.text = "BEKANNTE SYSTEME"
    search_row.add_child(search_caption)
    system_search = LineEdit.new()
    system_search.placeholder_text = "System suchen (Strg+F, Enter)"
    system_search.custom_minimum_size.x = 280
    system_search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    system_search.tooltip_text = "Nur bereits kartografierte Systeme werden gefunden. Enter wählt das erste passende System."
    system_search.text_submitted.connect(_search_system)
    search_row.add_child(system_search)
    if notice != "":
        _label(notice)
    var info := _label("Linksklick: System wählen   •   Rechte Maustaste ziehen: Kamera   •   Mausrad: Zoom zum Cursor")
    info.add_theme_font_size_override("font_size", 13)
    map_area = Control.new()
    map_area.custom_minimum_size = Vector2(380, 450)
    map_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    map_area.draw.connect(_draw_map)
    map_area.gui_input.connect(_map_input)
    var map_animation := Timer.new()
    map_animation.wait_time = 0.12
    map_animation.autostart = true
    map_animation.timeout.connect(func():
        if is_instance_valid(map_area) and screen == "galaxy":
            map_area.queue_redraw()
    )
    map_area.add_child(map_animation)
    var workspace := HBoxContainer.new()
    workspace.add_theme_constant_override("separation", 12)
    workspace.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    root.add_child(workspace)
    map_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    workspace.add_child(map_area)
    var side := PanelContainer.new()
    side.add_theme_stylebox_override("panel", GalaxyVisualTheme.panel_style(PANEL, GalaxyVisualTheme.FOCUS, 2))
    side.custom_minimum_size = Vector2(275, 450)
    workspace.add_child(side)
    var details_scroll := ScrollContainer.new()
    details_scroll.custom_minimum_size = Vector2(275, 450)
    details_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    side.add_child(details_scroll)
    galaxy_details = VBoxContainer.new()
    galaxy_details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    galaxy_details.add_theme_constant_override("separation", 9)
    details_scroll.add_child(galaxy_details)
    _show_selection()
    if not onboarding_dismissed:
        var tip := _label("ERSTER SCHRITT: Wähle ein bekanntes System, erkunde erreichbare Sterne und pausiere mit Leertaste. F1 öffnet die Anleitung.")
        tip.name = "OnboardingHint"
        _button("EINSTIEGSHINWEIS AUSBLENDEN", func():
            onboarding_dismissed = true
            tip.visible = false
        )
    if str(world["pending_event"]) != "":
        simulation_paused = true
        _show_event()

func _navigation_menu(title_text: String, entries: Array, parent: Control) -> void:
    var menu := MenuButton.new()
    menu.text = title_text
    menu.tooltip_text = "Öffnet die verfügbaren Aktionen für " + title_text.to_lower()
    GalaxyVisualTheme.apply_button(menu)
    var popup := menu.get_popup()
    for index in range(entries.size()):
        popup.add_item(str(entries[index][0]), index)
    popup.id_pressed.connect(func(id: int):
        if id >= 0 and id < entries.size():
            _play_ui_sound("click")
            var action: Callable = entries[id][1]
            action.call()
    )
    parent.add_child(menu)

func _search_system(query: String) -> void:
    var match_id: int = UiComponents.find_known_system(world, query)
    if match_id < 0:
        notice = "Kein bekanntes System gefunden: " + query.strip_edges()
        if is_instance_valid(system_search):
            system_search.tooltip_text = notice
        return
    selected = match_id
    world["selected"] = selected
    notice = "System ausgewählt: " + str(world["stars"][selected]["name"])
    _show_selection()
    if is_instance_valid(map_area):
        map_area.queue_redraw()

func _refresh_status() -> void:
    status.text = "◷ Jahr %d  •  ◆ Credits %d  •  ✧ Forschung %d  •  ⬡ Legierungen %d  •  ❖ Stabilität %d%%  •  %d Systeme  •  %d KI-Reiche" % [int(world["tick"]) + 2200, int(world["credits"]), int(world["science"]), int(world["alloys"]), int(world["stability"]), world["stars"].size(), world["ai"].size()]

func _refresh_forecast() -> void:
    if not is_instance_valid(forecast_status):
        return
    var forecast: Dictionary = GalaxyStrategy.income_forecast(world)
    forecast_status.text = "JÄHRLICHE PLANUNG  •  Credits %+d  •  Forschung %+d  •  Legierungen %+d" % [int(forecast["credits"]), int(forecast["science"]), int(forecast["alloys"])]

func _star_pos(star: Dictionary) -> Vector2:
    return map_area.size * 0.5 + map_offset + Vector2(float(star["x"]), float(star["y"])) * zoom

func _draw_map() -> void:
    var palette := [Color("#f3d59a"), Color("#8dd0ff"), Color("#f19b80"), Color("#c7a8f2")]
    var width := map_area.size.x
    var height := map_area.size.y
    map_area.draw_rect(Rect2(Vector2.ZERO, Vector2(width, height)), Color("#080e20"))
    # Illustrated nebula backdrop, behind all interactive map objects.
    var nebula: Texture2D = MAP_NEBULA
    if nebula != null:
        map_area.draw_texture_rect(nebula, Rect2(0, 0, width, height), false, Color(1, 1, 1, 0.28))
    var seed := int(world["settings"]["seed"])
    for i in range(140):
        var x := float(posmod(i * 7919 + seed, 1009)) / 1009.0 * width
        var y := float(posmod(i * 4861 + seed, 997)) / 997.0 * height
        map_area.draw_circle(Vector2(x, y), 0.65 + float(i % 3) * 0.35, Color("#405575"))
    for cloud in range(12):
        var center := Vector2(float(posmod(seed + cloud * 373, 997)) / 997.0 * width, float(posmod(seed / 3 + cloud * 659, 991)) / 991.0 * height)
        var tint := Color("#34447c") if cloud % 2 == 0 else Color("#31596d")
        map_area.draw_circle(center, 38.0 + float(cloud % 4) * 16.0, Color(tint, 0.055))
    # Draw only surveyed lane endpoints to preserve fog of war.
    for lane in world.get("lanes", []):
        var a := int(lane[0])
        var b := int(lane[1])
        if not world["known"].has(a) or not world["known"].has(b):
            continue
        map_area.draw_line(_star_pos(world["stars"][a]), _star_pos(world["stars"][b]), Color("#4c829d", 0.48), 1.4)
    for star in world["stars"]:
        var pos := _star_pos(star)
        if pos.x < -35.0 or pos.y < -35.0 or pos.x > width + 35.0 or pos.y > height + 35.0:
            continue
        var id := int(star["id"])
        var known: bool = world["known"].has(id)
        var owner := int(star["owner"])
        var radius := 7.0 if id == selected else (4.0 + float(int(star["kind"]) % 4) * 1.0) * sqrt(zoom / 0.65)
        map_area.draw_circle(pos, radius + 5.0, Color("#182943", 0.75))
        if known and int(star["kind"]) == 1:
            map_area.draw_circle(pos, radius + 8.0, Color("#5a9bd1", 0.13))
        if known and int(star["kind"]) == 2:
            map_area.draw_circle(pos, radius + 7.0, Color("#dd735d", 0.14))
        _draw_pixel_star(pos, radius, palette[int(star["kind"]) % palette.size()] if known else Color("#63738c"), id)
        if owner == 0:
            map_area.draw_arc(pos, 13, 0, TAU, 24, GOLD, 2.0)
        elif known and owner > 0:
            map_area.draw_arc(pos, 11, 0, TAU, 24, Color("#d4748b"), 1.5)
        # Discovered archaeological sites remain visible on the strategic map.
        if known:
            var lore: Dictionary = world.get("ancient_history", {})
            if lore.get("discovered", []).has(id):
                map_area.draw_arc(pos, 24.0, 0.0, TAU, 24, Color("#e4c18a", 0.9), 2.0)
                map_area.draw_line(pos + Vector2(-5, -21), pos + Vector2(0, -28), Color("#e4c18a"), 1.5)
                map_area.draw_line(pos + Vector2(0, -28), pos + Vector2(5, -21), Color("#e4c18a"), 1.5)
            for site in world.get("ancient_sites", []):
                if int(site["star_id"]) == id and bool(site["discovered"]):
                    map_area.draw_arc(pos, 20.0, 0.0, TAU, 20, Color("#7bd2c9", 0.9), 1.5)
                    break
        if id == selected:
            var pulse_radius := 19.0 + 2.0 * sin(float(Time.get_ticks_msec()) * 0.004)
            map_area.draw_arc(pos, pulse_radius, 0, TAU, 32, Color.WHITE, 1.4)
            map_area.draw_string(ThemeDB.fallback_font, pos + Vector2(12, -15), str(star["name"]) if known else "Unkartiert", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, WHITE)
    for rival_fleet in world.get("ai_fleets", []):
        var rival_loc := int(rival_fleet["location"])
        if rival_loc < 0 or rival_loc >= world["stars"].size() or not world["known"].has(rival_loc):
            continue
        var rp := _star_pos(world["stars"][rival_loc])
        var hostile_icon: Texture2D = MAP_RIVAL_SHIP
        if hostile_icon != null:
            map_area.draw_texture_rect(hostile_icon, Rect2(rp + Vector2(-12, 10), Vector2(24, 24)), false, Color("#e991b3"))
        else:
            map_area.draw_colored_polygon(PackedVector2Array([rp + Vector2(0, 14), rp + Vector2(-6, 24), rp + Vector2(6, 24)]), Color("#e991b3"))
        map_area.draw_line(rp + Vector2(-3, 20), rp + Vector2(3, 20), Color("#ffd4e0"), 1.0)
    for fleet in world["fleets"]:
        if int(fleet["owner"]) == 0:
            var loc := int(fleet["location"])
            if loc >= 0 and loc < world["stars"].size():
                var p := _star_pos(world["stars"][loc])
                var friendly_icon: Texture2D = MAP_PLAYER_SHIP
                if friendly_icon != null:
                    map_area.draw_texture_rect(friendly_icon, Rect2(p + Vector2(-12, -33), Vector2(24, 24)), false, Color("#7ce3cc"))
                else:
                    map_area.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -15), p + Vector2(-7, -26), p + Vector2(7, -26)]), Color("#7ce3cc"))

func _draw_pixel_star(pos: Vector2, radius: float, tint: Color, star_id: int) -> void:
    var star_strip: Texture2D = MAP_STAR_STRIP
    if star_strip != null:
        var diameter: float = maxf(15.0, radius * 3.5)
        var kind: int = int(world["stars"][star_id]["kind"]) if world.has("stars") and star_id >= 0 and star_id < world["stars"].size() else 0
        var source := Rect2(float(posmod(kind, 4)) * 32.0, 0.0, 32.0, 32.0)
        map_area.draw_texture_rect_region(star_strip, Rect2(pos - Vector2.ONE * diameter * 0.5, Vector2.ONE * diameter), source, tint if world["known"].has(star_id) else Color("#63738c"))
        return
    var pixel := maxf(1.5, radius / 3.5)
    var grid := 5
    for yy in range(-grid, grid + 1):
        for xx in range(-grid, grid + 1):
            var d := Vector2(float(xx), float(yy)).length()
            if d > 4.4:
                continue
            var variation := float(posmod(xx * 13 + yy * 29 + star_id * 7, 9)) / 30.0
            var light := 1.15 - d * 0.12 + variation
            var color := tint.lightened(clampf(light - 1.0, 0.0, 0.55)) if light >= 1.0 else tint.darkened(clampf(1.0 - light, 0.0, 0.65))
            map_area.draw_rect(Rect2(pos + Vector2(float(xx), float(yy)) * pixel - Vector2.ONE * pixel * 0.5, Vector2.ONE * pixel), color)

func _map_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and map_dragging:
        map_offset = map_offset_origin + event.position - drag_origin
        map_area.queue_redraw()
        return
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_RIGHT:
            map_dragging = event.pressed
            if event.pressed:
                drag_origin = event.position
                map_offset_origin = map_offset
            return
        if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            if event.pressed:
                var previous := zoom
                zoom = clampf(zoom * (1.13 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / 1.13), 0.25, 3.0)
                var center := map_area.size * 0.5
                map_offset = event.position - center - (event.position - center - map_offset) * (zoom / previous)
                map_area.queue_redraw()
            return
        if not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
            return
        var best := 22.0
        var found := -1
        for star in world["stars"]:
            var distance := _star_pos(star).distance_to(event.position)
            if distance < best:
                best = distance
                found = int(star["id"])
        if found >= 0:
            selected = found
            _play_ui_sound("select")
            world["selected"] = selected
            notice = ""
            _show_galaxy()

func _show_selection() -> void:
    if not is_instance_valid(galaxy_details):
        return
    for child in galaxy_details.get_children():
        galaxy_details.remove_child(child)
        child.queue_free()
    var star: Dictionary = world["stars"][selected]
    var known: bool = world["known"].has(selected)
    var owner := int(star["owner"])
    _side_label("SYSTEM / " + (str(star["name"]) if known else "Unkartiert"), true)
    _side_label(GalaxySystems.empire_name(world, owner) if known and owner >= 0 else "Unbeansprucht / Unbekannt")
    if not known:
        _side_label("Noch keine Kartografiedaten vorhanden.")
        var survey: Dictionary = GalaxySystems.survey_preview(world, selected)
        _side_label("Erkundung: " + ("in Reichweite" if bool(survey["allowed"]) else str(survey["reason"])))
        if bool(survey["allowed"]):
            _side_button("SYSTEM ERKUNDEN", _explore)
    else:
        var system := GalaxyCelestials.generate(int(world["settings"]["seed"]), star)
        _side_label("%s  •  %d Planeten" % [system["star_class"], system["planets"].size()])
        _side_label("Rohstoffe %d  •  %s" % [int(star["resource"]), "Bewohnbar" if bool(star["habitable"]) else "Unbewohnbar"])
        _side_button("SYSTEMANSICHT", _show_star_system)
        var route: Dictionary = GalaxySystems.route_preview(world, selected)
        if bool(route["allowed"]):
            _side_label("Flugstrecke: %.1f  •  Reisezeit: %d Jahre" % [float(route["distance"]), int(route["eta"])])
            _side_button("FLOTTE ENTSENDEN", _move_fleet)
        else:
            _side_label("Flottenroute: " + str(route["reason"]))
        if owner == 0:
            _side_button("PLANETENVERWALTUNG", _construction)
        if owner > 0 and world["wars"].has(owner):
            _side_button("ANGREIFEN", _attack)
        if owner == -1 and bool(star["habitable"]):
            var stationed := false
            for fleet in world["fleets"]:
                if int(fleet.get("owner", -1)) == 0 and int(fleet.get("location", -1)) == selected and int(fleet.get("destination", -1)) < 0:
                    stationed = true
                    break
            if stationed and int(world["credits"]) >= 50:
                _side_button("KOLONISIEREN (50)", _colonize)
            else:
                _side_label("Kolonie: eigene Flotte vor Ort und 50 Credits erforderlich.")
        if owner > 0:
            _side_button("DIPLOMATIE", func(): _diplomacy(owner))
    var fleet: Dictionary = world["fleets"][0]
    _side_label("FLOTTE / Stärke %d" % int(fleet["strength"]), true)
    _side_label("Reisezeit: %d" % int(fleet["eta"]))
    _side_label("GALAKTISCHE AKTIVITÄT", true)
    var activity: Array = world.get("ai_activity", [])
    if not activity.is_empty():
        _side_label(str(activity.back()["text"]))
    # Chronicle entries belong to the dedicated chronicle screen, not the
    # galactic map root. The sidebar stays focused on the selected system.
    var history: Array = world["history"]
    if not history.is_empty():
        _side_label("LETZTES EREIGNIS", true)
        _side_label(str(history.back()))
    _side_button("CHRONIK ÖFFNEN", _chronicle)

func _side_label(value: String, heading: bool = false) -> void:
    var label := Label.new()
    label.text = value
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size", 19 if heading else 15)
    label.add_theme_color_override("font_color", GOLD if heading else WHITE)
    galaxy_details.add_child(label)

func _side_button(value: String, callback: Callable) -> void:
    var button := UiComponents.action_button(value, callback, true)
    button.pressed.connect(func(): _play_ui_sound("click"))
    galaxy_details.add_child(button)

func _move_fleet() -> void:
    var preview: Dictionary = GalaxySystems.route_preview(world, selected)
    notice = "Flottenroute festgelegt (%d Jahre)." % int(preview["eta"]) if GalaxySystems.move_fleet(world, selected) else "Route nicht möglich: " + str(preview["reason"])
    _show_galaxy()

func _explore() -> void:
    var preview: Dictionary = GalaxySystems.survey_preview(world, selected)
    notice = "System kartografiert (+4 Forschung)." if GalaxySystems.explore(world, selected) else "Erkundung nicht möglich: " + str(preview["reason"])
    _show_galaxy()

func _colonize() -> void:
    var reason := GalaxyStrategy.colonize_system(world, selected)
    notice = "Sternensystem kolonisiert." if reason.is_empty() else "Kolonisierung nicht möglich: " + reason
    _show_galaxy()

func _advance() -> void:
    GalaxyStrategy.tick(world)
    notice = ""
    _show_galaxy()

func _save() -> void:
    world["selected"] = selected
    var ok := GalaxyModel.save_game(world)
    _label("Spielstand gespeichert." if ok else "Speichern fehlgeschlagen.")

func _toggle_auto_survey() -> void:
    world["auto_survey"] = not bool(world.get("auto_survey", false))
    notice = "Automatische Erkundung AKTIV: Alle zwei Jahre wird ein erreichbares System kartografiert." if bool(world["auto_survey"]) else "Automatische Erkundung DEAKTIVIERT."
    _show_galaxy()

func _research() -> void:
    screen = "research"
    _clear()
    _title("FORSCHUNG / SPEZIALISIERUNGEN")
    _illustration("research")
    _label("Verfügbare Forschungspunkte: %d  •  Gesamtfortschritt: %d" % [int(world["science"]), int(world["research_level"])])
    var technology: Dictionary = GalaxySystems.technology_bonuses(world)
    _label("Forschungslabore in eigenen Systemen: %d" % GalaxySystems.research_labs(world))
    var workforce: Dictionary = GalaxySystems.research_workforce(world)
    _label("Forschungspersonal: %d Wissenschaftler  •  %d Institutionen  •  %d Beschäftigte" % [int(workforce["scientists"]), int(workforce["institutions"]), int(workforce["workforce"])])
    var exchange: Dictionary = world.get("research_exchange_ledger", {})
    _label("Wissenschaftlicher Austausch: +%d Forschung/Jahr  •  %d Partner  •  %d Labore" % [int(exchange.get("science_granted", 0)), int(exchange.get("eligible_partners", 0)), int(exchange.get("laboratories", 0))])
    _label("Wissenschaftsnetz: Handelsabkommen und Labore erforderlich; Krieg unterbricht den Austausch.")
    _label("Technologiediffusion: %d wissenschaftliche Impulse, letzter Austausch Jahr %d" % [int(world.get("technology_diffusion", {}).get("insights", 0)), int(world.get("technology_diffusion", {}).get("last_year", -1))])
    _illustration("research_exchange")
    var insights: Dictionary = world.get("research_insights", {})
    _label("Archäologische Erkenntnisse: Antrieb %d  •  Industrie %d  •  Gesellschaft %d" % [int(insights.get("propulsion", 0)), int(insights.get("industry", 0)), int(insights.get("society", 0))])
    _label("Entschlüsselte wissenschaftliche Durchbrüche: %d" % world.get("research_breakthroughs", []).size())
    _label("Technologieeffekte: Flottenreichweite +%d  •  Legierungen/Jahr +%d  •  Stabilität/Jahr +%d" % [int(technology["fleet_range"]), int(technology["industry_alloys"]), int(technology["society_stability"])])
    for field in ["propulsion", "industry", "society"]:
        var field_id: String = str(field)
        var preview: Dictionary = GalaxySystems.research_preview(world, field)
        var label_name: String = str({"propulsion": "Antrieb", "industry": "Industrie", "society": "Gesellschaft"}[field])
        _label("%s  •  Stufe %d  •  Kosten %d  •  %s" % [label_name, int(preview["level"]), int(preview["cost"]), "Forschbar" if bool(preview["allowed"]) else str(preview["reason"])])
        _button("ERFORSCHEN: " + label_name.to_upper(), func(): _research_field(field_id))
    _button("ZURÜCK ZUR GALAXIE", _show_galaxy)

func _research_field(field: String) -> void:
    var preview: Dictionary = GalaxySystems.research_preview(world, field)
    notice = "Forschungsdurchbruch erzielt." if GalaxySystems.start_research(world, field) else str(preview["reason"])
    _research()

func _fleet_command() -> void:
    screen = "fleet_command"
    _clear()
    GalaxyStrategy.prepare(world)
    _title("FLOTTENKOMMANDO / ADMIRÄLE UND BEFEHLE")
    _illustration("fleet")
    var command: Dictionary = world["fleet_command"]
    var bonuses: Dictionary = GalaxyStrategy.fleet_command_bonuses(world)
    _label("Aktuelle Flotte: Stärke %d  •  Standort %s" % [int(world["fleets"][0]["strength"]), str(world["stars"][int(world["fleets"][0]["location"])]["name"])])
    _label("Befehl: %s  •  Admiral: %s" % [str(command["order"]), str(command["admiral"])])
    _label("Effekte: Angriff +%d  •  Schiffbau -%d Credits  •  Reichweite +%d  •  Reisezeit -%d" % [int(bonuses["attack"]), int(bonuses["shipyard_discount"]), int(bonuses["range"]), int(bonuses["travel_reduction"])])
    _label("Versorgung: %d/100  •  Unterhalt: %d Credits/Jahr" % [int(world["fleet_logistics"]["supply"]), GalaxyStrategy.fleet_upkeep(world)])
    _label("Unter 50 Versorgung sinkt die Kampfkraft; bei 0 drohen Verluste.")
    _button("FLOTTE VERSORGEN / REPARIEREN (-10 Credits, -4 Legierungen)", _service_fleet)
    _label("Gefechtsberichte: %d" % world["battle_reports"].size())
    for i in range(maxi(0, world["battle_reports"].size() - 3), world["battle_reports"].size()):
        var report: Dictionary = world["battle_reports"][i]
        _label("Jahr %d • %s • Angriff %d / Verteidigung %d • Verluste %d" % [int(report["year"]), "Sieg" if bool(report["victory"]) else "Niederlage", int(report["attack"]), int(report["defense"]), int(report["losses"])])
    _label("Die bestehende Simulation verwaltet weiterhin eine gemeinsame Spielerflotte.")
    for order in ["hold", "patrol", "assault"]:
        var selected_order: String = str(order)
        _button("BEFEHL: " + order.to_upper(), func(): _set_fleet_order(selected_order))
    for admiral in ["none", "tactician", "navigator", "quartermaster"]:
        var selected_admiral: String = str(admiral)
        _button("ADMIRAL: " + admiral.to_upper(), func(): _set_admiral(selected_admiral))
    _label("Bisherige Kommandowechsel: %d" % world["fleet_command_history"].size())
    _button("ZURÜCK ZUR GALAXIE", _show_galaxy)

func _service_fleet() -> void:
    notice = "Flotte versorgt und repariert." if GalaxyStrategy.service_fleet(world) else "Service nur in eigenen Systemen mit ausreichenden Ressourcen und Bedarf möglich."
    _fleet_command()

func _set_fleet_order(order: String) -> void:
    notice = "Flottenbefehl übernommen." if GalaxyStrategy.set_fleet_order(world, order) else "Befehl unverändert oder ungültig."
    _fleet_command()

func _set_admiral(admiral: String) -> void:
    notice = "Admiralsposten neu besetzt." if GalaxyStrategy.assign_admiral(world, admiral) else "Admiral unverändert oder ungültig."
    _fleet_command()

func _fleet_doctrine() -> void:
    screen = "fleet_doctrine"
    _clear()
    _title("FLOTTENKOMMANDO / DOKTRIN")
    _illustration("fleet")
    _label("Aktuelle Doktrin: %s   •   Erfahrung: %d/60" % [str(world.get("fleet_doctrine", "balanced")), int(world.get("fleet_experience", 0))])
    _label("Angriffskraft: %d  •  Grundstärke: %d" % [GalaxyStrategy.fleet_attack_power(world), int(world["fleets"][0]["strength"])])
    for entry in [["balanced", "AUSGEWOGEN / keine Modifikatoren"], ["assault", "ANGRIFF / +6 Angriffskraft"], ["defense", "VERTEIDIGUNG / +6 bei Verteidigung eigener Systeme"], ["exploration", "ERKUNDUNG / +35 Reichweite"]]:
        var key: String = entry[0]
        var label: String = entry[1]
        _button(label, func():
            notice = "Flottendoktrin aktiviert." if GalaxyStrategy.set_fleet_doctrine(world, key) else "Diese Doktrin ist bereits aktiv."
            _fleet_doctrine()
        )
    _button("ZURÜCK ZUR GALAXIE", _show_galaxy)

func _fleet() -> void:
    notice = "Flotte verstärkt (+5)." if GalaxySystems.build_fleet(world) else "65 Credits für den Flottenausbau benötigt."
    _show_galaxy()

func _goals_report() -> void:
    screen = "goals"
    _clear()
    GalaxyProgress.prepare(world)
    _title("GALAKTISCHE ZIELE / DEIN VERMÄCHTNIS")
    _label("Deine Zivilisation schreibt ihre eigene Geschichte. Alle Wege bleiben offen.")
    var current: Dictionary = GalaxyProgress.measures(world)
    var required: Dictionary = GalaxyProgress.targets()
    for milestone in GalaxyProgress.MILESTONES:
        var id := str(milestone["id"])
        var completed: bool = world["milestones"].has(id)
        _label(("%s  " % ("✓" if completed else "○")) + str(milestone["icon"]) + "  " + str(milestone["name"]))
        _label("    " + str(milestone["description"]) + "  •  %d / %d" % [mini(int(current[id]), int(required[id])), int(required[id])])
    _label("Erreicht: %d / %d  •  Die Simulation läuft auch nach allen Meilensteinen weiter." % [world["milestones"].size(), GalaxyProgress.MILESTONES.size()])
    _button("ZURÜCK ZUR GALAXIE", _show_galaxy)

func _society_report() -> void:
    screen = "society"
    _clear()
    GalaxyStrategy.prepare(world)
    _title("GESELLSCHAFT / LEBEN IN DER GALAXIE")
    var identity: Dictionary = world["empire"]
    _label("REGIERUNG / " + str(GalaxyIdentity.GOVERNMENTS[int(identity.get("government", 0))]))
    for item in GalaxyIdentity.ETHICS:
        if str(item["id"]) == str(identity.get("ethic", "pluralist")):
            _label(str(item["icon"]) + "  " + str(item["name"]))
    _label("STAATSPRINZIPIEN")
    for civic_id in identity.get("civics", ["archives", "commons"]):
        var civic: Dictionary = GalaxyIdentity.civic(str(civic_id))
        _label(str(civic["icon"]) + "  " + str(civic["name"]) + "  •  " + str(civic["description"]))
    _label("SPEZIES / " + str(identity["species"]))
    for trait_id in identity.get("traits", ["curious"]):
        var trait_data: Dictionary = GalaxyIdentity.trait_info(str(trait_id))
        _label(str(trait_data["icon"]) + "  " + str(trait_data["name"]) + "  •  " + str(trait_data["description"]))
    _illustration("society")
    _label("ÖFFENTLICHE ZUSTIMMUNG  •  %d%%" % int(world.get("civilian_approval", 65)))
    for petition in world.get("civilian_petitions", []):
        _label("⚑ Anliegen aus %s: %s" % [world["stars"][int(petition["system"])]["name"], petition["demand"]])
    _label("ZIVILE LEBENSWELTEN")
    var population := 0
    var markets: Dictionary = world.get("civilian_worlds", {})
    for key in markets.keys():
        var sid := int(key)
        if sid < 0 or sid >= world["stars"].size() or int(world["stars"][sid]["owner"]) != 0:
            continue
        var market: Dictionary = markets[key]
        population += int(market["population"])
        _label("◉ %s  •  Bevölkerung %d  •  Zufriedenheit %d%%" % [world["stars"][sid]["name"], int(market["population"]), int(market["satisfaction"])])
        _label("    ⚒ Arbeitsplätze %d  •  ◈ Waren %d  •  ◆ Privatkapital %d" % [int(market["jobs"]), int(market["goods"]), int(market["private_capital"])])
        var stock: Dictionary = market.get("production_stock", GalaxyCivilians.production_defaults())
        _label("    Produktionslager: Erz %d  •  Bauteile %d  •  Fertigwaren %d" % [int(stock["ore"]), int(stock["components"]), int(stock["manufactures"])])
        var chains: Dictionary = world.get("civilian_production_ledger", {}).get("systems", {})
        if chains.has(str(sid)):
            _label("    Fertigwarenabsatz: %d  •  Montage: %d" % [int(chains[str(sid)].get("sold", 0)), int(chains[str(sid)].get("assembled", 0))])
        var cohorts: Dictionary = market.get("demographics", GalaxyCivilians.demographic_defaults(int(market["population"])))
        _label("    Altersgruppen: Kinder %d  •  Erwerbsalter %d  •  Ältere %d" % [int(cohorts["children"]), int(cohorts["working_age"]), int(cohorts["elders"])])
        _label("    Beschäftigte %d  •  Erwerbslose %d  •  Geburten %d  •  Todesfälle %d" % [int(cohorts["employed"]), int(cohorts["unemployed"]), int(cohorts["births"]), int(cohorts["deaths"])])
        _label("    Gesundheitsindex: %d/100  •  Geburten und Sterbefälle beeinflussen die Einwohnerzahl" % int(cohorts.get("health", 50)))
    _label("BEVÖLKERUNG GESAMT: %d  •  ZIVILE STEUERN: %d  •  WANDERUNGEN: %d" % [population, int(world.get("civilian_taxes", 0)), int(world.get("civilian_migration", 0))])
    var audit: Dictionary = world.get("society_audit", {})
    if not audit.is_empty():
        _label("JAHRESPRÜFUNG: %s  •  %d Befunde  •  %d Jahre archiviert" % ["OK" if bool(audit.get("valid", false)) else "FEHLER", audit.get("errors", []).size(), world.get("society_audit_history", []).size()])
        for issue in audit.get("errors", []).slice(0, 4):
            _label("    ! " + str(issue))
    var public_budget: Dictionary = world.get("public_budget_ledger", {})
    if not public_budget.is_empty():
        _label("ÖFFENTLICHER HAUSHALT: Steuereingang %d  •  Sozialausgaben %d  •  Begünstigte Kolonien %d" % [int(public_budget["tax_receipts"]), int(public_budget["welfare_spending"]), public_budget["recipients"].size()])
    _label("HANDELSROUTEN DER PRIVATWIRTSCHAFT")
    var ledger: Dictionary = world.get("civilian_goods_ledger", {})
    if not ledger.is_empty():
        _label("Güterbilanz: Anfang %d  + Produktion %d  − Verbrauch %d  = Bestand %d" % [int(ledger["opening_stock"]), int(ledger["produced"]), int(ledger["consumed"]), int(ledger["ending_stock"])])
    if not ledger.is_empty():
        _label("Transportkosten gesamt: %d Privatkapital" % int(ledger.get("freight_cost", 0)))
    _label("Unterwegs: %d Güter in %d Lieferungen" % [GalaxyCivilians.transit_goods(world), world.get("civilian_freight_transit", []).size()])
    if not ledger.is_empty():
        _label("Lokale Reserveziele gesamt: %d Güter" % int(ledger.get("reserve_target", 0)))
    var trade: Array = world.get("civilian_trade", [])
    if trade.is_empty():
        _label("Keine aktuellen Warenlieferungen zwischen den Kolonien.")
    for shipment in trade:
        _label("◇ %s → %s  •  %d Güter  •  %d Sprünge  •  Ankunft Jahr %d  •  Kosten %d" % [world["stars"][int(shipment["from"])]["name"], world["stars"][int(shipment["to"])]["name"], int(shipment["goods"]), int(shipment.get("hops", 0)), int(shipment.get("arrival_tick", 0)), int(shipment.get("cost", 0))])
    _label("FREMDE GESELLSCHAFTEN / BEKANNTE REICHE")
    for rival in world["ai"]:
        var id := int(rival["id"])
        if not world["contacts"].has(id):
            continue
        var society: Dictionary = world.get("ai_societies", {}).get(str(id), {})
        _label("⬡ %s  •  %s" % [rival["name"], GalaxyIdentity.GOVERNMENTS[int(rival.get("government", 0))]])
        _label("    Bevölkerung %d  •  Wohlstand %d  •  Legitimität %d" % [int(society.get("population", 0)), int(society.get("prosperity", 0)), int(society.get("legitimacy", 0))])
    UiComponents.install_report_filter(root)
    _button("ZURÜCK ZUR GALAXIE", _show_galaxy)

func _economy_report() -> void:
    screen = "economy"
    _clear()
    _title("WIRTSCHAFT / REICHSBILANZ")
    _illustration("economy")
    var forecast: Dictionary = GalaxyStrategy.income_forecast(world)
    var public_budget: Dictionary = world.get("public_budget_ledger", {})
    if not public_budget.is_empty():
        _label("STAATSHAUSHALT LETZTES JAHR: Anfang %d + Steuern %d − Sozialausgaben %d = %d" % [int(public_budget["opening"]), int(public_budget["tax_receipts"]), int(public_budget["welfare_spending"]), int(public_budget["closing"])])
    _label("ZIVILE HANDELSAUTOMATISIERUNG")
    var automation: Dictionary = world.get("market_automation", {"enabled": true, "reserve": 20})
    _label("Autonomer Markt: %s  •  Strategische Reserve: %d" % ["aktiv" if bool(automation.get("enabled", true)) else "pausiert", int(automation.get("reserve", 20))])
    _button("AUTOMATISIERUNG UMSCHALTEN", func():
        GalaxyStrategy.set_market_automation(world, not bool(world["market_automation"]["enabled"]), int(world["market_automation"]["reserve"]))
        _economy_report()
    )
    _button("RESERVE ERHÖHEN", func():
        GalaxyStrategy.set_market_automation(world, bool(world["market_automation"]["enabled"]), mini(100, int(world["market_automation"]["reserve"]) + 10))
        _economy_report()
    )
    _button("RESERVE SENKEN", func():
        GalaxyStrategy.set_market_automation(world, bool(world["market_automation"]["enabled"]), maxi(0, int(world["market_automation"]["reserve"]) - 10))
        _economy_report()
    )
    _label("INTERNATIONALER HANDEL / ZOLL UND ABHÄNGIGKEIT")
    _illustration("trade_policy")
    var market: Dictionary = world.get("trade_market_ledger", {})
    _label("Aktive Partner: %d  •  Handelsumsatz: %d Credits  •  Zollertrag: %d Credits  •  Abhängigkeit: %d" % [int(market.get("partners", 0)), int(market.get("trade_revenue", 0)), int(market.get("tariff_revenue", 0)), int(market.get("dependency", 0))])
    _label("Importierte Erze: %d bestellt, %d geliefert  •  Einkauf: %d Credits  •  Konvois unterwegs: %d" % [int(market.get("ore_purchased", 0)), int(market.get("ore_delivered", 0)), int(market.get("purchase_cost", 0)), int(market.get("ore_in_transit", 0))])
    _label("HANDELSWEGE / SICHERHEIT")
    _illustration("freight_security")
    _label("Konvoischutz: Stufe %d/3  •  Blockierte Zielsysteme: %d" % [int(world.get("trade_security", 0)), world.get("freight_blockades", []).size()])
    var cargo_ledger: Dictionary = world.get("civilian_goods_ledger", {})
    _label("Letztes Jahr: %d Frachteinheiten versandt  •  %d Transportkosten durch Piraterierisiko vermieden" % [int(cargo_ledger.get("dispatched", 0)), int(cargo_ledger.get("piracy_avoided_cost", 0))])
    _button("KONVOISICHERHEIT VERBESSERN", func():
        notice = "Handelswege gesichert." if GalaxyStrategy.improve_trade_security(world) else "Nicht genug Credits oder maximale Sicherheitsstufe."
        _economy_report()
    )
    _label("ERWARTETE REGULÄRE JAHRESPRODUKTION")
    _label("Credits: %+d   Forschung: %+d   Legierungen: %+d" % [int(forecast["credits"]), int(forecast["science"]), int(forecast["alloys"])])
    _label("Prognose ohne Zufallsereignisse, Kriege und einmalige Entscheidungen.")
    var entries: Array = world.get("economy_history", [])
    if entries.is_empty():
        _label("Noch keine abgeschlossenen Simulationsjahre vorhanden.")
    else:
        _label("JAHRESABSCHLÜSSE / %d gespeichert (maximal 60)" % entries.size())
        for i in range(entries.size() - 1, maxi(-1, entries.size() - 16), -1):
            var entry: Dictionary = entries[i]
            var delta: Dictionary = entry["delta"]
            var balance: Dictionary = entry["balance"]
            _label("%d  •  Credits %+d  •  Forschung %+d  •  Legierungen %+d  •  Stabilität %+d" % [int(entry["year"]), int(delta["credits"]), int(delta["science"]), int(delta["alloys"]), int(delta["stability"])])
            _label("    Bestand: %d Credits  /  %d Forschung  /  %d Legierungen  /  %d%% Stabilität" % [int(balance["credits"]), int(balance["science"]), int(balance["alloys"]), int(balance["stability"])])
    UiComponents.install_report_filter(root)
    _button("ZURÜCK ZUR GALAXIE", _show_galaxy)

func _chronicle() -> void:
    screen = "chronicle"
    _clear()
    _title("GALAKTISCHE CHRONIK")
    _illustration("chronicle")
    GalaxyLore.prepare(world)
    GalaxyEndgame.prepare(world)
    _label("GALAKTISCHE LANGZEITPROJEKTE")
    for project in GalaxyEndgame.PROJECTS:
        var project_id := str(project["id"])
        if world["megaproject_completed"].has(project_id):
            _label("✓ %s  •  VOLLENDET" % str(project["title"]))
            continue
        var active: Dictionary = world.get("megaproject_active", {})
        if str(active.get("id", "")) == project_id:
            _label("◉ %s  •  Baufortschritt %d/%d" % [str(project["title"]), int(active.get("progress", 0)), int(project["duration"])])
        else:
            _button("BAUEN: %s  (%d Credits / %d Legierungen)" % [str(project["title"]), int(project["credits"]), int(project["alloys"])], func():
                notice = "Großprojekt begonnen." if GalaxyEndgame.start_project(world, project_id) else "Nicht möglich: Ressourcen, Forschung oder laufendes Projekt."
                _chronicle()
            )
    GalaxyNarrative.prepare(world)
    var followups: Array = GalaxyNarrative.pending_followups(world)
    if not followups.is_empty():
        _label("EREIGNISFOLGEN / ENTSCHEIDUNGEN")
        var aftermath_icon := TextureRect.new()
        aftermath_icon.texture = load("res://assets/art/chronicle_aftermath.svg")
        aftermath_icon.custom_minimum_size = Vector2(48, 48)
        aftermath_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        aftermath_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        root.add_child(aftermath_icon)
        for incident_id in followups:
            var key := str(incident_id)
            _label("Nachwirkung: %s — seit Jahr %d" % [key, int(world["narrative_chains"][key]["origin"])])
            _button("WIEDERAUFBAU / INVESTITION (-20 Credits)", func():
                notice = "Folgeentscheidung umgesetzt." if GalaxyNarrative.resolve_followup(world, key, "invest") else "Nicht genügend Credits."
                _chronicle()
            )
            _button("ANPASSUNG / RISIKO (kostenlos)", func():
                notice = "Folgeentscheidung umgesetzt." if GalaxyNarrative.resolve_followup(world, key, "adapt") else "Entscheidung nicht möglich."
                _chronicle()
            )
    _label("LANGZEITZIELE / SANDBOX")
    GalaxyProgress.evaluate_victories(world)
    for route in ["exploration", "prosperity", "resilience"]:
        _label("%s  %s" % ["✓" if world["victory_paths"].has(route) else "○", route])
    _label("Erreichte Ziele erlauben unbegrenztes Weiterspielen.")
    var crisis: Dictionary = world.get("galactic_crisis", {})
    if not crisis.is_empty():
        _label("GALAKTISCHE KRISE: %s  •  Bedrohung %d  •  Status %s" % [str(crisis.get("title", "")), int(crisis.get("threat", 0)), str(crisis.get("state", ""))])
        if str(crisis.get("state", "")) == "active":
            _button("KRISENABWEHR FINANZIEREN (25 Credits, 10 Legierungen)", func():
                notice = "Abwehrmaßnahmen finanziert." if GalaxyEndgame.defend_crisis(world) else "Nicht genug Ressourcen."
                _chronicle()
            )
            _button("KRISENFORSCHUNG (35 Forschung, 10 Credits; Stufe 3)", func():
                notice = "Wissenschaftliche Gegenmaßnahme erfolgreich." if GalaxyEndgame.research_crisis(world) else "Forschung, Credits oder Technologie fehlen."
                _chronicle()
            )
    var lore: Dictionary = world["ancient_history"]
    if not lore["discovered"].is_empty():
        _label("ARCHÄOLOGISCHES ARCHIV / " + str(lore["civilization"]))
        _label("Geschätztes Alter: %d Jahre  •  Fundorte: %d" % [int(lore["age"]), lore["discovered"].size()])
        _label("Die Vergangenheit wird aus tatsächlichen Funden und Entscheidungen rekonstruiert.")
    var artifacts: Array = world.get("artifacts", [])
    if not artifacts.is_empty():
        _label("RELIKTE VERGESSENER ZIVILISATIONEN")
        for i in range(artifacts.size()):
            var artifact: Dictionary = artifacts[i]
            _label("• %s  |  %s  |  Fundort: %s" % [artifact["culture"], artifact["discipline"], artifact["origin"]])
            if bool(artifact.get("analyzed", false)):
                _label("Technologie entschlüsselt: dauerhafter Produktionsbonus")
            else:
                var artifact_index := i
                _button("RELIKT ERFORSCHEN (30 Forschung)", func():
                    notice = "Relikt entschlüsselt." if GalaxyLore.analyze_artifact(world, artifact_index) else "Nicht genügend Forschung oder bereits entschlüsselt."
                    _chronicle()
                )
    var history: Array = world["history"]
    for i in range(maxi(0, history.size() - 35), history.size()):
        _label("• " + str(history[i]))
    UiComponents.install_report_filter(root)
    _button("ZURÜCK ZUR GALAXIE", _show_galaxy)

func _diplomacy(rival_id: int = -1) -> void:
    screen = "diplomacy"
    _clear()
    _title("DIPLOMATIE")
    _illustration("diplomacy")
    _label("Erkunde fremde Hauptwelten, um diplomatische Kontakte herzustellen.")
    _label("Gegenspionage: Stufe %d/3" % int(world.get("counterintelligence", 0)))
    _label("Informationspolitik: Stufe %d/3; Kosten %d Credits/Jahr" % [int(world.get("propaganda_level", 0)), int(world.get("propaganda_level", 0)) * 3])
    _illustration("information_policy")
    _button("INFORMATIONSPOLITIK ERHÖHEN", func():
        GalaxyStrategy.set_propaganda(world, mini(3, int(world.get("propaganda_level", 0)) + 1))
        _diplomacy()
    )
    _button("INFORMATIONSPOLITIK REDUZIEREN", func():
        GalaxyStrategy.set_propaganda(world, maxi(0, int(world.get("propaganda_level", 0)) - 1))
        _diplomacy()
    )
    _button("GEGENSPIONAGE AUSBAUEN (-25 Credits)", _counterintelligence)
    for rival in world["ai"]:
        var id := int(rival["id"])
        if rival_id != -1 and rival_id != id:
            continue
        if not world["contacts"].has(id):
            continue
        var intel := GalaxyStrategy.intelligence_level(world, id)
        var stance := str(world.get("ai_intentions", {}).get(str(id), {}).get("stance", "unbekannt")) if intel >= 2 else "unbekannt"
        _label("%s  •  Beziehung: %d  •  Vertrauen: %d/50  •  Strategie: %s" % [rival["name"], int(world["relations"].get(str(id), 0)), int(world.get("diplomatic_trust", {}).get(str(id), 0)), stance])
        _label("Geheimdienstinformationen: Stufe %d/3" % intel)
        var messages: int = 0
        for message in world.get("communications", []):
            if int(message["rival"]) == id:
                messages += 1
        _label("Interstellare Nachrichten unterwegs: %d" % messages)
        _button("NACHRICHT SENDEN", func():
            notice = "Nachricht unterwegs." if GalaxyStrategy.send_communication(world, id, "news") else "Nachricht nicht möglich."
            _diplomacy(id)
        )
        var tariff := int(world.get("trade_tariffs", {}).get(str(id), 0))
        _label("Zollstufe %d/3  •  Embargo %s" % [tariff, "aktiv" if world.get("trade_embargoes", []).has(id) else "inaktiv"])
        _button("ZOLL ERHÖHEN", func():
            GalaxyStrategy.set_trade_tariff(world, id, mini(3, tariff + 1))
            _diplomacy(id)
        )
        _button("ZOLL SENKEN", func():
            GalaxyStrategy.set_trade_tariff(world, id, maxi(0, tariff - 1))
            _diplomacy(id)
        )
        _button("EMBARGO UMSCHALTEN", func():
            GalaxyStrategy.set_trade_embargo(world, id, not world.get("trade_embargoes", []).has(id))
            _diplomacy(id)
        )
        if intel >= 3:
            _label("Wirtschaftsspionage: gegnerische Staatskasse %d Credits" % int(world.get("ai_treasury", {}).get(str(id), 0)))
        for mission in world.get("spy_missions", []):
            if int(mission["rival"]) == id:
                _label("Aktive Geheimdienstoperation: %s  •  Bericht Jahr %d" % [str(mission["kind"]), int(mission["due"])])
        _button("AUFKLÄRUNG (-20 Credits)", func(): _spy(id, "recon"))
        _button("INFILTRATION (-35 Credits)", func(): _spy(id, "infiltrate"))
        for negotiation in world.get("diplomatic_negotiations", []):
            if int(negotiation["rival"]) == id:
                _label("Verhandlung: %s  •  Abschlussprüfung Jahr %d" % [str(negotiation["kind"]), int(negotiation["due"])])
        for treaty in world.get("diplomatic_treaties", []):
            if int(treaty["rival"]) == id:
                _label("Ratifizierter Vertrag: %s  •  Seit Jahr %d" % [str(treaty["kind"]), int(treaty["signed"])])
        _button("GESCHENK SENDEN (-30 Credits)", func(): _diplomatic_choice(id, "gift"))
        _button("HANDELSVERTRAG VERHANDELN (-15 Credits)", func(): _negotiate(id, "trade"))
        _button("ULTIMATUM", func(): _diplomatic_choice(id, "threat"))
        _button("NICHTANGRIFFSPAKT VERHANDELN (-20 Credits)", func(): _negotiate(id, "non_aggression"))
        _button("VERTEIDIGUNGSBÜNDNIS VERHANDELN (-40 Credits)", func(): _negotiate(id, "alliance"))
        _button("WIRTSCHAFTLICHE ABHÄNGIGKEIT VERHANDELN (-30 Credits)", func(): _negotiate(id, "dependency"))
        if world.get("alliances", []).has(id):
            _label("Status: Verteidigungsbündnis aktiv")
        if world.get("diplomatic_dependencies", {}).has(str(id)):
            _label("Wirtschaftliches Abkommen: +%d Credits pro Jahr" % int(world["diplomatic_dependencies"][str(id)]["tribute"]))
        if world["wars"].has(id):
            var war_goal: Dictionary = world.get("war_goals", {}).get(str(id), {})
            var target_id := int(war_goal.get("target", -1))
            var goal_met: bool = bool(war_goal.get("achieved", false)) or (target_id >= 0 and target_id < world["stars"].size() and int(world["stars"][target_id]["owner"]) == 0)
            if target_id >= 0 and target_id < world["stars"].size():
                var objective_icon := TextureRect.new()
                objective_icon.texture = load("res://assets/art/war_objective.svg")
                objective_icon.custom_minimum_size = Vector2(48, 48)
                objective_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
                objective_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
                root.add_child(objective_icon)
                _label("Kriegsziel: %s — %s" % [str(world["stars"][target_id]["name"]), "erreicht" if goal_met else "offen"])
            var relation := int(world["relations"].get(str(id), -100))
            var peace_cost := (35 if goal_met else 70) if relation < -80 else 0
            _button("FRIEDEN ANBIETEN (-%d Credits)" % peace_cost, func():
                notice = "Friedensvertrag geschlossen." if GalaxyStrategy.offer_peace(world, id) else "Friedensangebot abgelehnt oder nicht finanzierbar."
                _diplomacy()
            )
        else:
            _button("KRIEG ERKLÄREN", func(): _war(id))
    _button("ZURÜCK ZUR GALAXIE", _show_galaxy)

func _spy(id: int, kind: String) -> void:
    notice = "Geheimdienstoperation gestartet." if GalaxyStrategy.launch_spy_mission(world, id, kind) else "Operation nicht möglich."
    _diplomacy()

func _counterintelligence() -> void:
    notice = "Gegenspionage ausgebaut." if GalaxyStrategy.reinforce_counterintelligence(world) else "Gegenspionage nicht finanzierbar oder bereits maximal."
    _diplomacy()

func _negotiate(id: int, kind: String) -> void:
    notice = "Verhandlungen eröffnet." if GalaxyStrategy.negotiate_treaty(world, id, kind) else "Verhandlung nicht möglich: Beziehung, Credits oder bestehender Vertrag."
    _diplomacy()

func _diplomatic_choice(id: int, action: String) -> void:
    notice = "Handelsvertrag geschlossen." if action == "trade" and GalaxyStrategy.sign_trade(world, id) else GalaxySystems.diplomatic_action(world, id, action) if action != "trade" else "Handelsvertrag benötigt +15 Beziehung, Erstkontakt und Frieden."
    _show_galaxy()

func _event_card_header(kind: String) -> void:
    # Event visual hierarchy; all illustration artwork remains procedural.
    var banner := PanelContainer.new()
    banner.add_theme_stylebox_override("panel", GalaxyVisualTheme.panel_style(PANEL, GOLD, 2))
    banner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    root.add_child(banner)
    var content := VBoxContainer.new()
    content.add_theme_constant_override("separation", 5)
    banner.add_child(content)
    var kicker := Label.new()
    kicker.text = "GALAKTISCHE CHRONIK  /  JAHR %d" % int(world.get("tick", 0))
    kicker.add_theme_font_size_override("font_size", 13)
    kicker.add_theme_color_override("font_color", GOLD)
    content.add_child(kicker)
    var heading := Label.new()
    heading.text = _event_category(kind)
    heading.add_theme_font_size_override("font_size", 22)
    heading.add_theme_color_override("font_color", WHITE)
    content.add_child(heading)
    var hint := Label.new()
    hint.text = "Wähle eine Antwort. Die Entscheidung beeinflusst den Verlauf deines Reiches."
    hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    hint.add_theme_font_size_override("font_size", 14)
    hint.add_theme_color_override("font_color", GalaxyVisualTheme.MUTED)
    content.add_child(hint)

func _event_category(kind: String) -> String:
    if kind in ["ancient_signal", "ancient_echo", "ancient_awakening"]:
        return "ARCHÄOLOGIE  •  ANOMALIE"
    if kind == "political_crisis":
        return "INNENPOLITIK  •  KRISE"
    if kind == "colonies":
        return "KOLONIEN  •  VERWALTUNG"
    if kind == "market":
        return "WIRTSCHAFT  •  MARKT"
    return "ERKUNDUNG  •  UNBEKANNTES"

func _show_event() -> void:
    screen = "event"
    _play_ui_sound("event")
    _clear()
    var kind := str(world["pending_event"])
    _event_card_header(kind)
    _illustration(kind)
    if kind in ["ancient_signal", "ancient_echo", "ancient_awakening"]:
        _title("EREIGNIS / " + GalaxyLore.event_title(kind))
        _label(GalaxyLore.event_text(world, kind))
        if kind == "ancient_signal":
            _button("FUNDORT SICHERN UND ERFORSCHEN (+12 Forschung)", func(): _resolve_system_event(0))
            _button("RELIKTE BERGEN (+20 Credits, -3 Stabilität)", func(): _resolve_system_event(1))
        elif kind == "ancient_echo":
            _button("VERGESSENE STERNKARTEN ENTSCHLÜSSELN (+Forschung)", func(): _resolve_system_event(0))
            _button("ARCHIV VERKAUFEN (+55 Credits, -8 Stabilität)", func(): _resolve_system_event(1))
        else:
            _button("DAS ARCHIV BEWAHREN (+65 Forschung, +8 Stabilität)", func(): _resolve_system_event(0))
            _button("DIE MASCHINEN AUSSCHLACHTEN (+35 Legierungen, +60 Credits, -12 Stabilität)", func(): _resolve_system_event(1))
    elif kind == "political_crisis":
        _title("EREIGNIS / AUFSTAND IN DEN KOLONIEN")
        _label("Die Stabilität des Reiches ist eingebrochen. Demonstrationen und Versorgungsengpässe bedrohen den Zusammenhalt. Der Rat verlangt eine Entscheidung.")
        _button("SOZIALPROGRAMM (-45 Credits, +22 Stabilität)", func(): _resolve_system_event(0))
        _button("PROTESTE UNTERDRÜCKEN (+20 Credits, -12 Stabilität)", func(): _resolve_system_event(1))
    elif kind == "colonies":
        _title("EREIGNIS / DER KOLONIALRAT")
        _label("Die jüngsten Kolonien fordern eine neue politische und wirtschaftliche Ausrichtung.")
        _label("Die Entscheidung wird langfristig in der Chronik vermerkt.")
        _button("FORSCHUNG FÖRDERN (-20 Credits, +35 Forschung)", func(): _resolve_system_event(0))
        _button("EXPORTE STÄRKEN (+30 Credits)", func(): _resolve_system_event(1))
    elif kind == "market":
        _title("EREIGNIS / SCHWANKUNGEN AM MARKT")
        _label("Steigende Reserven lösen eine Debatte über die Zukunft des Reichshaushalts aus.")
        _button("TECHNOLOGIEFONDS (-40 Credits, +45 Forschung)", func(): _resolve_system_event(0))
        _button("RESERVEN VERKAUFEN (+20 Credits)", func(): _resolve_system_event(1))
    else:
        _title("EREIGNIS / DAS VERLASSENE SIGNAL")
        _label("Ein Forschungsschiff entdeckt ein uraltes Notsignal in einem benachbarten Sektor.")
        _button("SIGNAL UNTERSUCHEN (+20 Forschung)", func(): _resolve_system_event(0))
        _button("TECHNOLOGIE BERGEN (+30 Credits)", func(): _resolve_system_event(1))

func _resolve_system_event(option: int) -> void:
    GalaxySystems.resolve_event(world, option)
    simulation_paused = false
    _show_galaxy()

func _illustration(kind: String) -> void:
    var asset := "res://assets/art/event_ruins.svg"
    match kind:
        "menu":
            asset = "res://assets/art/menu_city.svg"
        "ancient_signal", "ancient_echo", "ancient_awakening":
            asset = "res://assets/art/event_reactor.svg"
        "political_crisis", "politics":
            asset = "res://assets/art/event_political.svg"
        "colonies", "construction":
            asset = "res://assets/art/event_colonies.svg"
        "society":
            asset = "res://assets/art/scene_society.svg"
        "market", "economy":
            asset = "res://assets/art/event_market.svg"
        "research":
            asset = "res://assets/art/scene_research.svg"
        "research_exchange":
            asset = "res://assets/art/scene_research_exchange.svg"
        "freight_security":
            asset = "res://assets/art/scene_freight_security.svg"
        "trade_policy":
            asset = "res://assets/art/scene_trade_policy.svg"
        "information_policy":
            asset = "res://assets/art/scene_information_policy.svg"
        "fleet", "shipyard":
            asset = "res://assets/art/scene_fleet.svg"
        "diplomacy":
            asset = "res://assets/art/scene_diplomacy.svg"
        "chronicle":
            asset = "res://assets/art/galaxy_nebula.svg"
    var texture: Texture2D = load(asset)
    if texture != null:
        var image := TextureRect.new()
        image.texture = texture
        image.custom_minimum_size = Vector2(0, 200)
        image.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
        image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        root.add_child(image)
        image.modulate.a = 0.0
        var reveal := create_tween()
        reveal.tween_property(image, "modulate:a", 1.0, 0.28).set_trans(Tween.TRANS_SINE)
        return
    # Preserve a functional fallback if an art resource fails to import.
    var canvas := Control.new()
    canvas.custom_minimum_size = Vector2(850, 200)
    canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    canvas.draw.connect(func(): _draw_illustration(canvas, kind))
    root.add_child(canvas)

func _draw_illustration(canvas: Control, kind: String) -> void:
    var width := canvas.size.x
    canvas.draw_rect(Rect2(0, 0, width, 200), Color("#0c1930"))
    for i in range(90):
        var x := float(posmod(i * 1237 + 61, 997)) / 997.0 * width
        var y := float(posmod(i * 439 + 17, 191))
        canvas.draw_circle(Vector2(x, y), 0.8 + float(i % 3) * 0.5, Color("#8eafcd", 0.4 + float(i % 4) * 0.13))
    if kind == "menu":
        canvas.draw_circle(Vector2(width * 0.76, 115), 92, Color("#1e3559"))
        canvas.draw_circle(Vector2(width * 0.76 - 11, 102), 77, Color("#487e94"))
        canvas.draw_arc(Vector2(width * 0.76, 110), 112, -0.6, 2.4, 90, Color("#d3b47c", 0.8), 4.0)
        canvas.draw_circle(Vector2(width * 0.21, 80), 16, Color("#e9c780"))
    elif kind in ["ancient_signal", "ancient_echo", "ancient_awakening"]:
        var glow := Color("#58b3c1") if kind == "ancient_signal" else Color("#edbd7b") if kind == "ancient_awakening" else Color("#ba78d8")
        canvas.draw_circle(Vector2(width * 0.73, 100), 100, Color(glow, 0.08))
        canvas.draw_circle(Vector2(width * 0.73, 100), 72, Color("#26334c"))
        for i in range(8):
            var x := width * 0.6 + float(i) * 24.0
            var height := float(35 + posmod(i * 31, 62))
            canvas.draw_rect(Rect2(x, 165 - height, 13, height), Color("#37485f"))
            canvas.draw_rect(Rect2(x + 3, 165 - height + 6, 7, 3), glow)
        canvas.draw_arc(Vector2(width * 0.73, 96), 92, 0.0, TAU, 80, Color(glow, 0.6), 2.0)
        if kind in ["ancient_echo", "ancient_awakening"]:
            for i in range(5):
                canvas.draw_arc(Vector2(width * 0.73, 96), 22 + float(i) * 19, -0.9, 1.4, 36, Color(glow, 0.2 + float(i) * 0.1), 2.0)
        else:
            canvas.draw_colored_polygon(PackedVector2Array([Vector2(width * 0.23, 125), Vector2(width * 0.3, 99), Vector2(width * 0.39, 125), Vector2(width * 0.3, 145)]), Color("#92a9bc"))
            canvas.draw_circle(Vector2(width * 0.3, 125), 7, glow)
    elif kind == "political_crisis":
        canvas.draw_circle(Vector2(width * 0.75, 98), 85, Color("#713b50"))
        for i in range(11):
            var x := width * 0.45 + float(i) * 24.0
            canvas.draw_rect(Rect2(x, 135.0 - float(i % 4) * 18.0, 18, 65 + float(i % 4) * 18.0), Color("#282d4d"))
            canvas.draw_line(Vector2(x + 8, 145), Vector2(x + 8, 105 - float(i % 3) * 16), Color("#e5a57b"), 2.0)
    elif kind == "colonies":
        canvas.draw_circle(Vector2(width * 0.7, 110), 90, Color("#486a72"))
        canvas.draw_circle(Vector2(width * 0.68, 90), 72, Color("#719f88"))
        canvas.draw_rect(Rect2(width * 0.1, 132, 190, 55), Color("#243c59"))
        for i in range(8):
            canvas.draw_rect(Rect2(width * 0.12 + i * 21, 110 - i % 3 * 12, 13, 50), Color("#7aa9b6"))
    elif kind == "market":
        canvas.draw_circle(Vector2(width * 0.78, 90), 75, Color("#4d567b"))
        for i in range(9):
            canvas.draw_line(Vector2(width * 0.13 + i * 29, 150), Vector2(width * 0.13 + i * 29, 150 - (i * 31 % 95)), Color("#e0b976"), 7.0)
    else:
        canvas.draw_circle(Vector2(width * 0.75, 95), 69, Color("#263e5e"))
        canvas.draw_arc(Vector2(width * 0.75, 95), 84, 0, TAU, 64, Color("#7ccad3"), 3.0)
        canvas.draw_line(Vector2(width * 0.2, 115), Vector2(width * 0.38, 115), Color("#e5c47e"), 5.0)
        canvas.draw_colored_polygon(PackedVector2Array([Vector2(width * 0.3, 92), Vector2(width * 0.37, 115), Vector2(width * 0.3, 138)]), Color("#a1b7cc"))

func _construction() -> void:
    screen = "construction"
    _clear()
    GalaxyStrategy.prepare(world)
    var star: Dictionary = world["stars"][selected]
    var system := GalaxyCelestials.generate(int(world["settings"]["seed"]), star)
    selected_planet = clampi(selected_planet, 0, system["planets"].size() - 1)
    var planet: Dictionary = system["planets"][selected_planet]
    _title("PLANETENVERWALTUNG / " + str(planet["name"]))
    _illustration("construction")
    _label("%s  •  Ressourcen %d  •  Credits %d  •  Legierungen %d" % [planet["type"], int(planet["resources"]), int(world["credits"]), int(world["alloys"])])
    _label("Klima: %s  •  Ökosystem: %s  •  Umweltbelastung: %d/100" % [planet["climate"], planet["ecology"], int(planet["environmental_pressure"])])
    _planet_preview()
    var navigation := HBoxContainer.new()
    root.add_child(navigation)
    for i in range(system["planets"].size()):
        var index := i
        var button := Button.new()
        button.text = str(i + 1) + (" ◆" if selected_planet == i else "")
        button.pressed.connect(func():
            selected_planet = index
            notice = ""
            _construction()
        )
        navigation.add_child(button)
    if notice != "":
        _label(notice)
    var colony := GalaxyStrategy.planet_colony(world, selected, selected_planet)
    if colony.is_empty():
        if bool(planet["habitable"]):
            _label("Besiedelbare Welt • Noch keine Kolonie")
            _button("KOLONIE GRÜNDEN (50 Credits)", func():
                notice = "Kolonie gegründet." if GalaxyStrategy.settle_planet(world, selected, selected_planet) else "Kolonisierung nicht möglich."
                _construction()
            )
        else:
            _label("Unbewohnbare Welt • Eine Kolonie ist derzeit nicht möglich.")
            _label("Terraforming-Potenzial vorhanden (noch keine Terraforming-Technologie)." if bool(planet["terraformable"]) else "Derzeit nicht terraformierbar.")
    else:
        _label("Kolonie • Bevölkerung %d" % int(colony.get("population", 1)))
        _label("Tragfähigkeit: %d  •  Umweltbelastung: %d/100" % [int(colony.get("capacity", int(planet["size"]))), int(colony.get("environmental_pressure", planet["environmental_pressure"]))])
        var built: Dictionary = colony.get("buildings", {})
        for spec in [["mine", "MINE"], ["lab", "FORSCHUNGSLABOR"], ["factory", "WERFT"], ["fort", "VERTEIDIGUNG"]]:
            var kind: String = spec[0]
            _label("%s  •  Stufe %d / 3" % [spec[1], int(built.get(kind, 0))])
            _button("%s BAUEN (%d Credits)" % [spec[1], GalaxyStrategy.building_cost(kind)], func():
                notice = "Gebäude errichtet: " + kind if GalaxyStrategy.construct_planet(world, selected, selected_planet, kind) else "Bau nicht möglich: Credits oder Baulimit."
                _construction()
            )
    _button("ZURÜCK ZUM STERNSYSTEM", _show_star_system)


func _politics() -> void:
    screen = "politics"
    _clear()
    GalaxyStrategy.prepare(world)
    _title("REICHSPOLITIK")
    _illustration("politics")
    var culture: Dictionary = world["culture"]
    _label("Kulturentwicklung • Generation %d" % int(culture.get("generation", 0)))
    _label("Tradition %d  •  Offenheit %d  •  Zusammenhalt %d  •  Handelsorientierung %d" % [int(culture["tradition"]), int(culture["openness"]), int(culture["solidarity"]), int(culture["commercialism"])])
    var groups: Dictionary = GalaxyIdentity.social_groups(culture)
    _label("Gesellschaftliche Strömungen: Tradition %d%%  •  Reform %d%%  •  Handel %d%%" % [int(groups["traditionalists"]), int(groups["reformers"]), int(groups["merchants"])])
    var effects: Dictionary = GalaxyIdentity.culture_modifiers(culture)
    _label("Kulturelle Effekte/Jahr: Zufriedenheit %+d  •  Privatkapital %+d  •  Forschung %+d  •  Legitimität %+d" % [int(effects["satisfaction"]), int(effects["capital"]), int(effects["science"]), int(effects["legitimacy"])])
    _label("Kulturelle Entwicklung ist gesellschaftlich bedingt und nicht direkt steuerbar.")
    _label("Stabilität: %d%%  •  Politische Ausrichtung beeinflusst die Jahresproduktion." % int(world["stability"]))
    var governance: Dictionary = world["governance"]
    _label("Legitimität: %d%%  •  Mandat: %s  •  Nächster Machtwechsel Jahr %d" % [int(governance.get("legitimacy", 60)), ["Traditionalisten", "Reformisten", "Handelsblock"][clampi(int(governance.get("mandate", 0)), 0, 2)], int(governance.get("next_transition", 0))])
    if int(governance.get("crisis_years", 0)) > 0:
        _label("Politische Legitimitaetskrise seit %d Jahren" % int(governance["crisis_years"]))
    _label("Regierungsform: %s  •  Bürgerrechte: %s" % [GalaxyIdentity.GOVERNMENTS[int(world["empire"].get("government", 0))], ["Eingeschränkt", "Standard", "Erweitert"][int(governance["rights"])]])
    var reform_votes: Dictionary = GalaxyStrategy.reform_support(world, 2 if int(governance["rights"]) < 2 else 0)
    _label("Politische Blöcke • Reformunterstützung %d%%  •  Widerstand %d%%" % [int(reform_votes["support"]), int(reform_votes["opposition"])])
    var pending: Dictionary = governance.get("pending", {})
    if not pending.is_empty():
        _label("Reform in Beratung: Stufe %d  •  Inkrafttreten Jahr %d" % [int(pending["rights"]), int(pending["enact_tick"])])
        _label("Beschlusslage: Zustimmung %d%%  •  Opposition %d%%" % [int(pending.get("support", 100)), int(pending.get("opposition", 0))])
    else:
        for level in range(3):
            var reform_level := level
            _button(["BÜRGERRECHTE EINSCHRÄNKEN", "BÜRGERRECHTE BEIBEHALTEN", "BÜRGERRECHTE ERWEITERN"][level], func(): _propose_rights(reform_level))
    _label("Schwerpunkt: %s" % ["Handel", "Wissenschaft", "Industrie"][int(world["policies"]["focus"])])
    for i in range(3):
        var index := i
        _button(["HANDEL (+4 Credits)", "WISSENSCHAFT (+4 Forschung)", "INDUSTRIE (+3 Legierungen)"][i], func(): _set_policy(index, int(world["policies"]["tax"])))
    _label("Sozialhaushalt: %s" % ["Keiner", "Grundversorgung", "Ausgebaut"][clampi(int(world["policies"].get("welfare", 0)), 0, 2)])
    for level in range(3):
        var welfare_level := level
        _button(["SOZIALHAUSHALT AUS", "GRUNDVERSORGUNG (3/KOLONIE)", "AUSGEBAUT (6/KOLONIE)"][level], func(): _set_welfare(welfare_level))
    _label("Steuersatz: %s" % ["Niedrig", "Normal", "Hoch"][int(world["policies"]["tax"])])
    for i in range(3):
        var index := i
        _button(["NIEDRIG (Stabilität +1)", "NORMAL", "HOCH (+5 Credits, Stabilität -1)"][i], func(): _set_policy(int(world["policies"]["focus"]), index))
    _button("ZURÜCK", _show_galaxy)

func _propose_rights(level: int) -> void:
    GalaxyStrategy.propose_rights_reform(world, level)
    _politics()

func _set_policy(focus: int, tax: int) -> void:
    GalaxyStrategy.set_policy(world, focus, tax)
    _politics()

func _set_welfare(level: int) -> void:
    GalaxyStrategy.set_welfare(world, level)
    _politics()

func _shipyard() -> void:
    screen = "shipyard"
    _clear()
    GalaxyStrategy.prepare(world)
    _title("SCHIFFSKONSTRUKTION")
    _illustration("shipyard")
    _label("Legierungen: %d  •  Credits: %d" % [int(world["alloys"]), int(world["credits"])])
    if notice != "":
        _label(notice)
    var design: Dictionary = world["ship_design"]
    _label("Rumpf: %s  •  Bewaffnung: %s  •  Antrieb: %s" % [["Leicht", "Mittel", "Schwer"][int(design["hull"])], ["Laser", "Plasma", "Kinetisch"][int(design["weapon"])], ["Impuls", "Ionen", "Warp"][int(design["engine"])]])
    var blueprint: Dictionary = GalaxyStrategy.ship_blueprint(world)
    _label("Schiffsrolle: %s  •  Schiffsstärke: +%d" % [str(blueprint["role"]), int(blueprint["strength"])])
    _label("Baukosten: %d Credits / %d Legierungen  •  Antriebsforschung %d erforderlich" % [int(blueprint["credits"]), int(blueprint["alloys"]), int(blueprint["required_propulsion"])])
    _label("Baufreigabe: %s  •  Registrierte Schiffe: %d" % ["Ja" if bool(blueprint["allowed"]) else "Antrieb noch nicht erforscht", world["ship_registry"].size()])
    for role in ["escort", "interceptor", "artillery"]:
        var chosen_role: String = str(role)
        _button("ROLLE: " + role.to_upper(), func(): _set_ship_role(chosen_role))
    _ship_preview()
    for i in range(3):
        var index := i
        _button("RUMPF: " + ["LEICHT", "MITTEL", "SCHWER"][i], func(): _design(index, int(design["weapon"]), int(design["engine"])))
    for i in range(3):
        var index := i
        _button("WAFFE: " + ["LASER", "PLASMA", "KINETISCH"][i], func(): _design(int(design["hull"]), index, int(design["engine"])))
    for i in range(3):
        var index := i
        _button("ANTRIEB: " + ["IMPULS", "IONEN", "WARP"][i], func(): _design(int(design["hull"]), int(design["weapon"]), index))
    _button("SCHIFFE PRODUZIEREN", _produce_ships)
    _button("ZURÜCK", _show_galaxy)

func _set_ship_role(role: String) -> void:
    GalaxyStrategy.set_ship_role(world, role)
    _shipyard()

func _design(hull: int, weapon: int, engine: int) -> void:
    GalaxyStrategy.configure_ship(world, hull, weapon, engine)
    _shipyard()

func _produce_ships() -> void:
    notice = "Neue Schiffe gebaut." if GalaxyStrategy.build_ships(world) else "Bau nicht möglich: Forschung, Credits oder Legierungen fehlen."
    _shipyard()

func _war(id: int) -> void:
    notice = "Krieg erklärt." if GalaxyStrategy.declare_war(world, id) else "Kriegserklärung nicht möglich."
    _show_galaxy()

func _attack() -> void:
    notice = GalaxyStrategy.attack(world, selected)
    _show_galaxy()

func _show_star_system() -> void:
    screen = "star_system"
    _clear()
    var star: Dictionary = world["stars"][selected]
    var system := GalaxyCelestials.generate(int(world["settings"]["seed"]), star)
    selected_planet = clampi(selected_planet, 0, system["planets"].size() - 1)
    _title("STERNSYSTEM / " + str(star["name"]))
    _label("%s  •  %d K  •  %d Planeten  •  %d Asteroidengürtel  •  %d Kometen" % [system["star_class"], int(system["temperature"]), system["planets"].size(), int(system["asteroids"]), int(system["comets"])])
    var canvas := Control.new()
    canvas.custom_minimum_size = Vector2(950, 300)
    canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    canvas.draw.connect(func(): _draw_star_system(canvas, system))
    canvas.gui_input.connect(func(event: InputEvent):
        if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
            var count: int = system["planets"].size()
            var step := (canvas.size.x - 180.0) / float(maxi(1, count))
            var nearest := -1
            var distance := 30.0
            for i in range(count):
                var pos := Vector2(150.0 + float(i) * step, canvas.size.y * 0.5 + sin(float(i) * 2.4) * 55.0)
                var d := pos.distance_to(event.position)
                if d < distance:
                    nearest = i
                    distance = d
            if nearest >= 0:
                selected_planet = nearest
                _show_star_system()
    )
    root.add_child(canvas)
    var chosen: Dictionary = system["planets"][selected_planet]
    var section := HBoxContainer.new()
    section.add_theme_constant_override("separation", 24)
    root.add_child(section)
    var info := VBoxContainer.new()
    section.add_child(info)
    var title := Label.new()
    title.text = "%s / %s" % [chosen["name"], chosen["type"]]
    title.add_theme_font_size_override("font_size", 25)
    title.add_theme_color_override("font_color", GOLD)
    info.add_child(title)
    for detail in ["Ressourcen: %d" % int(chosen["resources"]), "Monde: %d" % chosen["moons"].size(), "Orbit: %d" % int(chosen["orbit"]), "Besiedelbar: %s" % ("Ja" if bool(chosen["habitable"]) else "Nein")]:
        var item := Label.new()
        item.text = detail
        info.add_child(item)
    var navigation := VBoxContainer.new()
    section.add_child(navigation)
    for i in range(system["planets"].size()):
        var index := i
        var button := Button.new()
        button.text = str(system["planets"][i]["name"]) + ("  ◀" if selected_planet == i else "")
        button.pressed.connect(func():
            selected_planet = index
            _show_star_system()
        )
        navigation.add_child(button)
    if int(star["owner"]) == 0:
        _button("AUSGEWÄHLTEN PLANETEN VERWALTEN", _construction)
    _button("ZURÜCK ZUR GALAXIE", _show_galaxy)

func _draw_star_system(canvas: Control, system: Dictionary) -> void:
    var w := canvas.size.x
    var h := canvas.size.y
    canvas.draw_rect(Rect2(0, 0, w, h), Color("#081324"))
    var seed := int(world["settings"]["seed"]) + selected * 77
    for i in range(100):
        var p := Vector2(float(posmod(seed + i * 1823, 997)) / 997.0 * w, float(posmod(seed + i * 1193, 313)) / 313.0 * h)
        canvas.draw_rect(Rect2(p, Vector2.ONE * (1 if i % 3 else 2)), Color("#7088a7", 0.45))
    var star_colors := [Color("#e9c57d"), Color("#7acaff"), Color("#e36e59"), Color("#e4eaf2")]
    var origin := Vector2(76, h * 0.5)
    var star_strip: Texture2D = load("res://assets/art/star_sprite_strip.svg")
    if star_strip != null:
        canvas.draw_texture_rect_region(star_strip, Rect2(origin - Vector2(42, 42), Vector2(84, 84)), Rect2(float(posmod(int(world["stars"][selected]["kind"]), 4)) * 32.0, 0, 32, 32))
    else:
        canvas.draw_circle(origin, 36, star_colors[int(world["stars"][selected]["kind"]) % 4])
    canvas.draw_circle(origin, 44, Color(star_colors[int(world["stars"][selected]["kind"]) % 4], 0.13))
    var planets: Array = system["planets"]
    var step := (w - 180.0) / float(maxi(1, planets.size()))
    var colors := [Color("#ad9e86"), Color("#c89e69"), Color("#a8d7ec"), Color("#2b9bb4"), Color("#c8a267"), Color("#e57948"), Color("#4aab75"), Color("#b4c5d6")]
    for i in range(planets.size()):
        var planet: Dictionary = planets[i]
        var x := 150.0 + float(i) * step
        var y := h * 0.5 + sin(float(i) * 2.4) * 55.0
        var p := Vector2(x, y)
        var radius := float(planet["size"]) + (7.0 if int(planet["type_id"]) == 1 else 0.0)
        canvas.draw_line(Vector2(x, 45), Vector2(x, h - 40), Color("#31465d", 0.24), 1.0)
        if bool(planet["rings"]):
            canvas.draw_arc(p, radius + 9.0, -0.5, PI + 0.5, 28, Color("#c9bb9a"), 3.0)
        if int(planet["type_id"]) in [2, 3, 6]:
            canvas.draw_arc(p, radius + 4.0, PI * 0.1, PI * 1.85, 38, Color("#5bc9e9", 0.35), 3.0)
        _draw_planet_sprite(canvas, p, radius * 2.0, int(planet["type_id"]), colors[int(planet["type_id"])], int(planet["orbit"]) + selected * 11)
        if i == selected_planet:
            canvas.draw_arc(p, radius + 14.0, 0.0, TAU, 40, GOLD, 2.0)
        canvas.draw_arc(p, radius, -PI * 0.4, PI * 0.65, 24, Color("#e2e5f2", 0.3), 2.0)
        if GalaxyStrategy.planet_colony(world, selected, i).size() > 0:
            _draw_orbital_station(canvas, p + Vector2(radius + 17.0, -radius - 11.0))
        for j in range(planet["moons"].size()):
            canvas.draw_circle(p + Vector2(radius + 11 + j * 8, -radius - 8 + j * 8), 3.0, Color("#a6a9b8"))
        canvas.draw_string(ThemeDB.fallback_font, p + Vector2(-10, radius + 25), str(i + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, WHITE)

func _species_gallery(readonly: bool = false) -> void:
    var gallery := HBoxContainer.new()
    gallery.add_theme_constant_override("separation", 12)
    root.add_child(gallery)
    for i in range(5):
        var index := i
        var card := VBoxContainer.new()
        gallery.add_child(card)
        var canvas := Control.new()
        canvas.custom_minimum_size = Vector2(150, 170)
        canvas.draw.connect(func(): _draw_species(canvas, index))
        card.add_child(canvas)
        var button := Button.new()
        button.text = ["Humanoid", "Insektoid", "Aquatisch", "Kristallin", "Synthetisch"][i]
        button.disabled = readonly
        GalaxyVisualTheme.apply_button(button)
        button.modulate = GOLD if int(empire["portrait"]) == i else WHITE
        button.pressed.connect(func():
            empire["portrait"] = index
            _show_empire()
        )
        card.add_child(button)

func _draw_species(canvas: Control, index: int) -> void:
    var w := canvas.size.x
    canvas.draw_rect(Rect2(0, 0, w, 170), Color("#13233a"))
    # Procedural portrait is guaranteed to render in Godot even when an SVG
    # import is blank on a particular Windows graphics driver.
    var colors := [Color("#c9a17b"), Color("#91b97b"), Color("#6dc6c8"), Color("#ad8ed8"), Color("#9fb6c8")]
    var c: Color = colors[index]
    var center := Vector2(w * 0.5, 76)
    canvas.draw_circle(center + Vector2(0, 8), 52, Color(c, 0.08))
    canvas.draw_colored_polygon(PackedVector2Array([Vector2(26, 165), Vector2(44, 116), Vector2(64, 107), Vector2(86, 107), Vector2(106, 116), Vector2(124, 165)]), c.darkened(0.48))
    if index == 1:
        for side in [-1, 1]:
            canvas.draw_line(center + Vector2(side * 24, -28), center + Vector2(side * 39, -61), c, 4)
            canvas.draw_circle(center + Vector2(side * 39, -61), 6, c)
    if index == 2:
        for side in [-1, 1]:
            canvas.draw_colored_polygon(PackedVector2Array([center + Vector2(side * 31, -10), center + Vector2(side * 52, 12), center + Vector2(side * 30, 26)]), c)
    if index == 3:
        canvas.draw_colored_polygon(PackedVector2Array([center + Vector2(0, -64), center + Vector2(-34, -21), center + Vector2(0, 34), center + Vector2(34, -21)]), c)
    else:
        canvas.draw_circle(center + Vector2(0, -9), 37, c)
    if index == 4:
        canvas.draw_rect(Rect2(center + Vector2(-26, -23), Vector2(52, 19)), Color("#263e5a"))
        canvas.draw_rect(Rect2(center + Vector2(-18, -18), Vector2(36, 8)), Color("#77e6df"))
    else:
        for side in [-1, 1]:
            canvas.draw_circle(center + Vector2(side * 15, -13), 6 if index == 1 else 4, Color("#182d47"))
            canvas.draw_circle(center + Vector2(side * 15, -14), 2, Color("#e4eaf4"))
    if index == int(empire["portrait"]):
        canvas.draw_rect(Rect2(2, 2, w - 4, 166), GOLD, false, 2)

func _ship_gallery(readonly: bool = false) -> void:
    var gallery := HBoxContainer.new()
    gallery.add_theme_constant_override("separation", 12)
    root.add_child(gallery)
    for i in range(4):
        var index := i
        var card := VBoxContainer.new()
        gallery.add_child(card)
        var canvas := Control.new()
        canvas.custom_minimum_size = Vector2(178, 100)
        canvas.draw.connect(func(): _draw_ship(canvas, index, 1))
        card.add_child(canvas)
        var button := Button.new()
        button.text = ["Solar", "Organisch", "Geometrisch", "Industriell"][i]
        button.disabled = readonly
        GalaxyVisualTheme.apply_button(button)
        button.modulate = GOLD if int(empire["ship_style"]) == i else WHITE
        button.pressed.connect(func():
            empire["ship_style"] = index
            _show_empire()
        )
        card.add_child(button)

func _draw_ship(canvas: Control, style: int, hull: int) -> void:
    var w := canvas.size.x
    var h := canvas.size.y
    canvas.draw_rect(Rect2(0, 0, w, h), Color("#102039"))
    # Individual imported sprites avoid the Godot 4.3 SVG atlas-region white-tile bug.
    var ship_strip: Texture2D = load("res://assets/art/ship_style_%d.svg" % posmod(style, 4))
    if ship_strip != null:
        var diameter: float = minf(w * 0.76, h * 0.9)
        var dest := Rect2(Vector2((w - diameter) * 0.5, (h - diameter) * 0.5), Vector2.ONE * diameter)
        canvas.draw_texture_rect(ship_strip, dest, false)
        if style == int(empire["ship_style"]):
            canvas.draw_rect(Rect2(2, 2, w - 4, h - 4), GOLD, false, 2)
        return
    var center := Vector2(w * 0.5, h * 0.5)
    var scale_factor := 0.8 + float(hull) * 0.2
    var hull_colors := [Color("#e1bf7e"), Color("#7ed2b2"), Color("#a9c5e8"), Color("#c1a4d8")]
    var color: Color = hull_colors[style]
    var points := PackedVector2Array()
    if style == 0:
        points = PackedVector2Array([Vector2(40, 0), Vector2(5, -12), Vector2(-18, -31), Vector2(-35, -20), Vector2(-24, 0), Vector2(-35, 20), Vector2(-18, 31), Vector2(5, 12)])
    elif style == 1:
        points = PackedVector2Array([Vector2(40, 0), Vector2(8, -20), Vector2(-15, -25), Vector2(-35, -8), Vector2(-25, 0), Vector2(-35, 8), Vector2(-15, 25), Vector2(8, 20)])
    elif style == 2:
        points = PackedVector2Array([Vector2(40, 0), Vector2(0, -22), Vector2(-30, -22), Vector2(-17, 0), Vector2(-30, 22), Vector2(0, 22)])
    else:
        points = PackedVector2Array([Vector2(38, -10), Vector2(4, -10), Vector2(-10, -28), Vector2(-35, -28), Vector2(-25, 0), Vector2(-35, 28), Vector2(-10, 28), Vector2(4, 10), Vector2(38, 10)])
    var transformed := PackedVector2Array()
    for p in points:
        transformed.append(center + p * scale_factor)
    canvas.draw_colored_polygon(transformed, color.darkened(0.35))
    canvas.draw_polyline(transformed, color, 2.0, true)
    canvas.draw_circle(center + Vector2(5, 0), 6, Color("#78e4ef"))
    for offset in [-15, 15]:
        canvas.draw_circle(center + Vector2(-32 * scale_factor, offset * scale_factor), 4, Color("#63c9ff"))
    if style == int(empire["ship_style"]):
        canvas.draw_rect(Rect2(2, 2, w - 4, h - 4), GOLD, false, 2)

func _ship_preview() -> void:
    var canvas := Control.new()
    canvas.custom_minimum_size = Vector2(600, 150)
    canvas.draw.connect(func(): _draw_ship(canvas, int(empire["ship_style"]), int(world["ship_design"]["hull"])))
    root.add_child(canvas)

func _planet_preview() -> void:
    var canvas := Control.new()
    canvas.custom_minimum_size = Vector2(850, 175)
    canvas.draw.connect(func(): _draw_planet_preview(canvas))
    root.add_child(canvas)

func _draw_planet_preview(canvas: Control) -> void:
    var w := canvas.size.x
    canvas.draw_rect(Rect2(0, 0, w, 175), Color("#0e1d35"))
    var star: Dictionary = world["stars"][selected]
    var system := GalaxyCelestials.generate(int(world["settings"]["seed"]), star)
    var planets: Array = system["planets"]
    var target: Dictionary = planets[clampi(selected_planet, 0, planets.size() - 1)]
    var colors := [Color("#ae9981"), Color("#cba676"), Color("#9bc7df"), Color("#3c91b5"), Color("#c9a36d"), Color("#d87e5e"), Color("#69a980"), Color("#afc4d4")]
    var center := Vector2(w * 0.28, 90)
    canvas.draw_circle(center + Vector2(9, 0), 72, Color("#213853"))
    _draw_planet_sprite(canvas, center, 130.0, int(target["type_id"]), colors[int(target["type_id"])], selected + int(target["orbit"]) * 17)
    canvas.draw_circle(center + Vector2(-22, -20), 17, Color("#dce8e7", 0.15))
    canvas.draw_circle(center + Vector2(17, 24), 25, Color("#182d4a", 0.16))
    canvas.draw_string(ThemeDB.fallback_font, Vector2(w * 0.48, 60), str(target["type"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 23, GOLD)
    canvas.draw_string(ThemeDB.fallback_font, Vector2(w * 0.48, 95), "%d Planeten  /  %d Asteroidengürtel" % [planets.size(), int(system["asteroids"])], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, WHITE)
    canvas.draw_string(ThemeDB.fallback_font, Vector2(w * 0.48, 125), "Sternklasse: " + str(system["star_class"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, WHITE)

func _draw_planet_sprite(canvas: Control, center: Vector2, diameter: float, type_id: int, tint: Color, variation_seed: int) -> void:
    var strip: Texture2D = load("res://assets/art/planet_sprite_strip.svg")
    if strip == null:
        _draw_pixel_planet(canvas, center, diameter * 0.5, tint, variation_seed)
        return
    var source := Rect2(float(posmod(type_id, 8)) * 64.0, 0.0, 64.0, 64.0)
    canvas.draw_texture_rect_region(strip, Rect2(center - Vector2.ONE * diameter * 0.5, Vector2.ONE * diameter), source)

func _draw_pixel_planet(canvas: Control, center: Vector2, radius: float, tint: Color, variation_seed: int) -> void:
    var cell := maxf(2.0, radius / 13.0)
    var cells := int(ceil(radius / cell))
    for yy in range(-cells, cells + 1):
        for xx in range(-cells, cells + 1):
            var delta := Vector2(float(xx), float(yy)) * cell
            if delta.length_squared() > radius * radius:
                continue
            var stripe := float(posmod(xx * 17 + yy * 31 + variation_seed * 13, 19)) / 19.0
            var shade := clampf(0.55 + (float(-xx) / float(maxi(1, cells))) * 0.3 + stripe * 0.25, 0.15, 1.0)
            var color := tint.darkened(1.0 - shade)
            if posmod(xx * 7 + yy * 11 + variation_seed, 13) < 3:
                color = color.lightened(0.17)
            canvas.draw_rect(Rect2(center + delta - Vector2.ONE * cell * 0.5, Vector2.ONE * cell), color)

func _draw_orbital_station(canvas: Control, center: Vector2) -> void:
    var station: Texture2D = load("res://assets/art/orbital_station.svg")
    if station != null:
        canvas.draw_texture_rect(station, Rect2(center - Vector2(20, 20), Vector2(40, 40)), false)
        return
    var steel := Color("#9cb5ce")
    canvas.draw_rect(Rect2(center + Vector2(-3, -10), Vector2(6, 20)), steel)
    canvas.draw_rect(Rect2(center + Vector2(-17, -4), Vector2(34, 8)), steel.darkened(0.25))
    canvas.draw_rect(Rect2(center + Vector2(-14, -7), Vector2(7, 14)), Color("#477aa3"))
    canvas.draw_rect(Rect2(center + Vector2(7, -7), Vector2(7, 14)), Color("#477aa3"))
    canvas.draw_rect(Rect2(center + Vector2(-2, -2), Vector2(4, 4)), Color("#8af5ed"))
