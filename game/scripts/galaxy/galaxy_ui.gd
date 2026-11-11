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

func _ready() -> void:
    get_window().title = "Land der Sonne | Galaktische Chroniken"
    _show_menu()

func _process(delta: float) -> void:
    if world.is_empty() or simulation_paused or screen != "galaxy":
        return
    simulation_elapsed += delta * float(simulation_speed)
    var steps := 0
    while simulation_elapsed >= 4.0 and steps < 8:
        simulation_elapsed -= 4.0
        GalaxyStrategy.tick(world)
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
    label.add_theme_font_size_override("font_size", 17)
    label.add_theme_color_override("font_color", WHITE)
    root.add_child(label)
    return label

func _button(value: String, callback: Callable) -> void:
    var button := Button.new()
    button.text = value
    button.custom_minimum_size = Vector2(320, 43)
    button.add_theme_font_size_override("font_size", 16)
    button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    button.pressed.connect(callback)
    root.add_child(button)

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
    _button("EINSTELLUNGEN", _show_options)
    _button("BEENDEN", func(): get_tree().quit())
    _label("Früher Prototyp • Galaxien können zufällig oder mit festem Seed erzeugt werden.")

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
    var bar := HBoxContainer.new()
    root.add_child(bar)
    for spec in [["PAUSE / WEITER", _toggle_pause], ["1×", func(): _set_speed(1)], ["2×", func(): _set_speed(2)], ["4×", func(): _set_speed(4)], ["8×", func(): _set_speed(8)], ["AUTO-ERKUNDUNG", _toggle_auto_survey], ["FORSCHUNG", _research], ["FLOTTE", _fleet], ["FLOTTENDOKTRIN", _fleet_doctrine], ["SCHIFFSWERFT", _shipyard], ["POLITIK", _politics], ["DIPLOMATIE", _diplomacy], ["CHRONIK", _chronicle], ["ZIELE", _goals_report], ["GESELLSCHAFT", _society_report], ["WIRTSCHAFT", _economy_report], ["SPEICHERN", _save], ["MENÜ", _show_menu]]:
        var button := Button.new()
        button.text = spec[0]
        button.pressed.connect(spec[1])
        bar.add_child(button)
    if notice != "":
        _label(notice)
    var info := _label("Linksklick: System wählen   •   Rechte Maustaste ziehen: Kamera   •   Mausrad: Zoom zum Cursor")
    info.add_theme_font_size_override("font_size", 13)
    map_area = Control.new()
    map_area.custom_minimum_size = Vector2(760, 500)
    map_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    map_area.draw.connect(_draw_map)
    map_area.gui_input.connect(_map_input)
    var workspace := HBoxContainer.new()
    workspace.add_theme_constant_override("separation", 20)
    workspace.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    root.add_child(workspace)
    map_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    workspace.add_child(map_area)
    var side := PanelContainer.new()
    side.custom_minimum_size = Vector2(335, 500)
    workspace.add_child(side)
    galaxy_details = VBoxContainer.new()
    galaxy_details.add_theme_constant_override("separation", 9)
    side.add_child(galaxy_details)
    _show_selection()
    if str(world["pending_event"]) != "":
        simulation_paused = true
        _show_event()

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
            map_area.draw_arc(pos, 19, 0, TAU, 32, Color.WHITE, 1.4)
            map_area.draw_string(ThemeDB.fallback_font, pos + Vector2(12, -15), str(star["name"]) if known else "Unkartiert", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, WHITE)
    for rival_fleet in world.get("ai_fleets", []):
        var rival_loc := int(rival_fleet["location"])
        if rival_loc < 0 or rival_loc >= world["stars"].size() or not world["known"].has(rival_loc):
            continue
        var rp := _star_pos(world["stars"][rival_loc])
        map_area.draw_colored_polygon(PackedVector2Array([rp + Vector2(0, 14), rp + Vector2(-6, 24), rp + Vector2(6, 24)]), Color("#e991b3"))
        map_area.draw_line(rp + Vector2(-3, 20), rp + Vector2(3, 20), Color("#ffd4e0"), 1.0)
    for fleet in world["fleets"]:
        if int(fleet["owner"]) == 0:
            var loc := int(fleet["location"])
            if loc >= 0 and loc < world["stars"].size():
                var p := _star_pos(world["stars"][loc])
                map_area.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -15), p + Vector2(-7, -26), p + Vector2(7, -26)]), Color("#7ce3cc"))

func _draw_pixel_star(pos: Vector2, radius: float, tint: Color, star_id: int) -> void:
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
            _side_button("KOLONISIEREN (50)", _colonize)
        if owner > 0:
            _side_button("DIPLOMATIE", func(): _diplomacy(owner))
    var fleet: Dictionary = world["fleets"][0]
    _side_label("FLOTTE / Stärke %d" % int(fleet["strength"]), true)
    _side_label("Reisezeit: %d" % int(fleet["eta"]))
    _side_label("GALAKTISCHE AKTIVITÄT", true)
    var activity: Array = world.get("ai_activity", [])
    if not activity.is_empty():
        _side_label(str(activity.back()["text"]))
    _side_label("CHRONIK", true)
    _label("GALAKTISCHES PROTOKOLL / LETZTE 35 EINTRÄGE")
    var incidents: Array = world.get("ambient_event_log", [])
    if not incidents.is_empty():
        _label("KLEINE PHÄNOMENE / %d protokolliert" % incidents.size())
        for i in range(maxi(0, incidents.size() - 5), incidents.size()):
            var incident: Dictionary = incidents[i]
            var amount := int(incident["effect"])
            _label("Jahr %d  •  %s  (%s%d %s)" % [int(incident["year"]) + 2200, str(incident["text"]), "+" if amount >= 0 else "", amount, str(incident["resource"])])
    var history: Array = world["history"]
    _side_label(str(history.back()) if not history.is_empty() else "Keine Einträge")

func _side_label(value: String, heading: bool = false) -> void:
    var label := Label.new()
    label.text = value
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size", 19 if heading else 15)
    label.add_theme_color_override("font_color", GOLD if heading else WHITE)
    galaxy_details.add_child(label)

func _side_button(value: String, callback: Callable) -> void:
    var button := Button.new()
    button.text = value
    button.custom_minimum_size.y = 40
    button.pressed.connect(callback)
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
    if int(world["credits"]) < 50:
        return
    if not world["known"].has(selected) or int(world["stars"][selected]["owner"]) != -1 or not bool(world["stars"][selected]["habitable"]):
        return
    world["credits"] = int(world["credits"]) - 50
    world["stars"][selected]["owner"] = 0
    world["history"].append("Kolonie auf %s gegründet" % world["stars"][selected]["name"])
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
    notice = "Forschungsdurchbruch erzielt." if GalaxySystems.start_research(world) else "Nicht genügend Forschungspunkte."
    _show_galaxy()

func _fleet_doctrine() -> void:
    screen = "fleet_doctrine"
    _clear()
    _title("FLOTTENKOMMANDO / DOKTRIN")
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
    _label("BEVÖLKERUNG GESAMT: %d  •  ZIVILE STEUERN: %d  •  WANDERUNGEN: %d" % [population, int(world.get("civilian_taxes", 0)), int(world.get("civilian_migration", 0))])
    _label("HANDELSROUTEN DER PRIVATWIRTSCHAFT")
    var trade: Array = world.get("civilian_trade", [])
    if trade.is_empty():
        _label("Keine aktuellen Warenlieferungen zwischen den Kolonien.")
    for shipment in trade:
        _label("◇ %s → %s  •  %d Gütereinheiten" % [world["stars"][int(shipment["from"])]["name"], world["stars"][int(shipment["to"])]["name"], int(shipment["goods"])])
    _label("FREMDE GESELLSCHAFTEN / BEKANNTE REICHE")
    for rival in world["ai"]:
        var id := int(rival["id"])
        if not world["contacts"].has(id):
            continue
        var society: Dictionary = world.get("ai_societies", {}).get(str(id), {})
        _label("⬡ %s  •  %s" % [rival["name"], GalaxyIdentity.GOVERNMENTS[int(rival.get("government", 0))]])
        _label("    Bevölkerung %d  •  Wohlstand %d  •  Legitimität %d" % [int(society.get("population", 0)), int(society.get("prosperity", 0)), int(society.get("legitimacy", 0))])
    _button("ZURÜCK ZUR GALAXIE", _show_galaxy)

func _economy_report() -> void:
    screen = "economy"
    _clear()
    _title("WIRTSCHAFT / REICHSBILANZ")
    var forecast: Dictionary = GalaxyStrategy.income_forecast(world)
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
    _button("ZURÜCK ZUR GALAXIE", _show_galaxy)

func _chronicle() -> void:
    screen = "chronicle"
    _clear()
    _title("GALAKTISCHE CHRONIK")
    GalaxyLore.prepare(world)
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
    _button("ZURÜCK ZUR GALAXIE", _show_galaxy)

func _diplomacy(rival_id: int = -1) -> void:
    screen = "diplomacy"
    _clear()
    _title("DIPLOMATIE")
    _label("Erkunde fremde Hauptwelten, um diplomatische Kontakte herzustellen.")
    for rival in world["ai"]:
        var id := int(rival["id"])
        if rival_id != -1 and rival_id != id:
            continue
        if not world["contacts"].has(id):
            continue
        _label("%s  •  Beziehung: %d  •  Vertrauen: %d/50  •  Strategie: %s" % [rival["name"], int(world["relations"].get(str(id), 0)), int(world.get("diplomatic_trust", {}).get(str(id), 0)), str(world.get("ai_intentions", {}).get(str(id), {}).get("stance", "unbekannt"))])
        _button("GESCHENK SENDEN (-30 Credits)", func(): _diplomatic_choice(id, "gift"))
        _button("HANDELSABKOMMEN", func(): _diplomatic_choice(id, "trade"))
        _button("ULTIMATUM", func(): _diplomatic_choice(id, "threat"))
        _button("NICHTANGRIFFSPAKT (Beziehung +35)", func():
            notice = "Nichtangriffspakt geschlossen." if GalaxyStrategy.propose_non_aggression(world, id) else "Pakt nicht möglich: Beziehungen oder bestehender Vertrag."
            _diplomacy()
        )
        if world["wars"].has(id):
            _button("FRIEDEN ANBIETEN (gegebenenfalls 70 Credits)", func():
                notice = "Friedensvertrag geschlossen." if GalaxyStrategy.offer_peace(world, id) else "Friedensangebot abgelehnt oder nicht finanzierbar."
                _diplomacy()
            )
        else:
            _button("KRIEG ERKLÄREN", func(): _war(id))
    _button("ZURÜCK ZUR GALAXIE", _show_galaxy)

func _diplomatic_choice(id: int, action: String) -> void:
    notice = "Handelsvertrag geschlossen." if action == "trade" and GalaxyStrategy.sign_trade(world, id) else GalaxySystems.diplomatic_action(world, id, action) if action != "trade" else "Handelsvertrag benötigt +15 Beziehung, Erstkontakt und Frieden."
    _show_galaxy()

func _show_event() -> void:
    screen = "event"
    _clear()
    var kind := str(world["pending_event"])
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
    _label("%s  •  Ressourcen %d  •  Credits %d  •  Legierungen %d" % [planet["type"], int(planet["resources"]), int(world["credits"]), int(world["alloys"])])
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
    else:
        _label("Kolonie • Bevölkerung %d" % int(colony.get("population", 1)))
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
    _label("Stabilität: %d%%  •  Politische Ausrichtung beeinflusst die Jahresproduktion." % int(world["stability"]))
    _label("Schwerpunkt: %s" % ["Handel", "Wissenschaft", "Industrie"][int(world["policies"]["focus"])])
    for i in range(3):
        var index := i
        _button(["HANDEL (+4 Credits)", "WISSENSCHAFT (+4 Forschung)", "INDUSTRIE (+3 Legierungen)"][i], func(): _set_policy(index, int(world["policies"]["tax"])))
    _label("Steuersatz: %s" % ["Niedrig", "Normal", "Hoch"][int(world["policies"]["tax"])])
    for i in range(3):
        var index := i
        _button(["NIEDRIG (Stabilität +1)", "NORMAL", "HOCH (+5 Credits, Stabilität -1)"][i], func(): _set_policy(int(world["policies"]["focus"]), index))
    _button("ZURÜCK", _show_galaxy)

func _set_policy(focus: int, tax: int) -> void:
    GalaxyStrategy.set_policy(world, focus, tax)
    _politics()

func _shipyard() -> void:
    screen = "shipyard"
    _clear()
    GalaxyStrategy.prepare(world)
    _title("SCHIFFSKONSTRUKTION")
    _label("Legierungen: %d  •  Credits: %d" % [int(world["alloys"]), int(world["credits"])])
    if notice != "":
        _label(notice)
    var design: Dictionary = world["ship_design"]
    _label("Rumpf: %s  •  Bewaffnung: %s  •  Antrieb: %s" % [["Leicht", "Mittel", "Schwer"][int(design["hull"])], ["Laser", "Plasma", "Kinetisch"][int(design["weapon"])], ["Impuls", "Ionen", "Warp"][int(design["engine"])]])
    _label("Schiffsstärke: +%d" % GalaxyStrategy.ship_strength(world))
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

func _design(hull: int, weapon: int, engine: int) -> void:
    GalaxyStrategy.configure_ship(world, hull, weapon, engine)
    _shipyard()

func _produce_ships() -> void:
    notice = "Neue Schiffe gebaut." if GalaxyStrategy.build_ships(world) else "Nicht genügend Credits oder Legierungen."
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
        _draw_pixel_planet(canvas, p, radius, colors[int(planet["type_id"])], int(planet["orbit"]) + selected * 11)
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
        button.modulate = GOLD if int(empire["portrait"]) == i else WHITE
        button.pressed.connect(func():
            empire["portrait"] = index
            _show_empire()
        )
        card.add_child(button)

func _draw_species(canvas: Control, index: int) -> void:
    var w := canvas.size.x
    canvas.draw_rect(Rect2(0, 0, w, 170), Color("#13233a"))
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
    _draw_pixel_planet(canvas, center, 65.0, colors[int(target["type_id"])], selected + int(target["orbit"]) * 17)
    canvas.draw_circle(center + Vector2(-22, -20), 17, Color("#dce8e7", 0.15))
    canvas.draw_circle(center + Vector2(17, 24), 25, Color("#182d4a", 0.16))
    canvas.draw_string(ThemeDB.fallback_font, Vector2(w * 0.48, 60), str(target["type"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 23, GOLD)
    canvas.draw_string(ThemeDB.fallback_font, Vector2(w * 0.48, 95), "%d Planeten  /  %d Asteroidengürtel" % [planets.size(), int(system["asteroids"])], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, WHITE)
    canvas.draw_string(ThemeDB.fallback_font, Vector2(w * 0.48, 125), "Sternklasse: " + str(system["star_class"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, WHITE)

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
    var steel := Color("#9cb5ce")
    canvas.draw_rect(Rect2(center + Vector2(-3, -10), Vector2(6, 20)), steel)
    canvas.draw_rect(Rect2(center + Vector2(-17, -4), Vector2(34, 8)), steel.darkened(0.25))
    canvas.draw_rect(Rect2(center + Vector2(-14, -7), Vector2(7, 14)), Color("#477aa3"))
    canvas.draw_rect(Rect2(center + Vector2(7, -7), Vector2(7, 14)), Color("#477aa3"))
    canvas.draw_rect(Rect2(center + Vector2(-2, -2), Vector2(4, 4)), Color("#8af5ed"))
