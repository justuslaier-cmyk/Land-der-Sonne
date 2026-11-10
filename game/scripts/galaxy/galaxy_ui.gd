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
    _illustration("menu")
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
    GalaxyStrategy.prepare(world)
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
    GalaxySystems.prepare(world)
    settings = world["settings"].duplicate(true)
    empire = world["empire"].duplicate(true)
    selected = clampi(int(world.get("selected", 0)), 0, world["stars"].size() - 1)
    _show_galaxy()

func _show_galaxy() -> void:
    screen = "galaxy"
    GalaxySystems.prepare(world)
    _clear()
    _title("GALAXIE / %s" % world["empire"]["name"], 29)
    status = _label("")
    _refresh_status()
    var bar := HBoxContainer.new()
    root.add_child(bar)
    for spec in [["ZEIT +1", _advance], ["FORSCHUNG", _research], ["FLOTTE", _fleet], ["SCHIFFSWERFT", _shipyard], ["POLITIK", _politics], ["DIPLOMATIE", _diplomacy], ["CHRONIK", _chronicle], ["SPEICHERN", _save], ["MENÜ", _show_menu]]:
        var button := Button.new()
        button.text = spec[0]
        button.pressed.connect(spec[1])
        bar.add_child(button)
    if notice != "":
        _label(notice)
    var info := _label("Linksklick: Stern auswählen   •   Mausrad: Zoom   •   Erkundung deckt Systeme auf")
    info.add_theme_font_size_override("font_size", 13)
    map_area = Control.new()
    map_area.custom_minimum_size = Vector2(850, 510)
    map_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    map_area.draw.connect(_draw_map)
    map_area.gui_input.connect(_map_input)
    root.add_child(map_area)
    _show_selection()
    if str(world["pending_event"]) != "":
        _show_event()

func _refresh_status() -> void:
    status.text = "Jahr %d  •  Credits %d  •  Forschung %d  •  Legierungen %d  •  Stabilität %d%%  •  %d Systeme  •  %d KI-Reiche" % [int(world["tick"]) + 2200, int(world["credits"]), int(world["science"]), int(world["alloys"]), int(world["stability"]), world["stars"].size(), world["ai"].size()]

func _star_pos(star: Dictionary) -> Vector2:
    return Vector2(430, 245) + map_offset + Vector2(float(star["x"]), float(star["y"])) * zoom

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
    for star in world["stars"]:
        var pos := _star_pos(star)
        var id := int(star["id"])
        var known: bool = world["known"].has(id)
        var owner := int(star["owner"])
        var radius := 7.0 if id == selected else 3.0 + float(star["resource"]) * 0.5
        map_area.draw_circle(pos, radius + 5.0, Color("#182943", 0.75))
        map_area.draw_circle(pos, radius, palette[int(star["kind"]) % palette.size()] if known else Color("#63738c"))
        if owner == 0:
            map_area.draw_arc(pos, 13, 0, TAU, 24, GOLD, 2.0)
        elif known and owner > 0:
            map_area.draw_arc(pos, 11, 0, TAU, 24, Color("#d4748b"), 1.5)
        if id == selected:
            map_area.draw_arc(pos, 19, 0, TAU, 32, Color.WHITE, 1.4)
            map_area.draw_string(ThemeDB.fallback_font, pos + Vector2(12, -15), str(star["name"]) if known else "Unkartiert", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, WHITE)
    for fleet in world["fleets"]:
        if int(fleet["owner"]) == 0:
            var loc := int(fleet["location"])
            if loc >= 0 and loc < world["stars"].size():
                var p := _star_pos(world["stars"][loc])
                map_area.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -15), p + Vector2(-7, -26), p + Vector2(7, -26)]), Color("#7ce3cc"))

func _map_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
            zoom = minf(1.6, zoom * 1.15)
            map_area.queue_redraw()
            return
        if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
            zoom = maxf(0.3, zoom / 1.15)
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
    var star: Dictionary = world["stars"][selected]
    var known: bool = world["known"].has(selected)
    var owner := int(star["owner"])
    _label("SYSTEM: %s  •  %s" % [str(star["name"]) if known else "Unkartiert", GalaxySystems.empire_name(world, owner) if known and owner >= 0 else "Unbeansprucht / Unbekannt"])
    if not known:
        _label("Unbekannte Systeme müssen vor der Kolonisierung kartografiert werden.")
        _button("ERKUNDEN", _explore)
    else:
        _label("Rohstoffstufe %d  •  %s" % [int(star["resource"]), "Bewohnbar" if bool(star["habitable"]) else "Unbewohnbar"])
        if int(world["fleets"][0]["location"]) != selected:
            _button("FLOTTE HIERHER SCHICKEN", _move_fleet)
        if owner == 0:
            _button("PLANETARE BAUPROJEKTE", _construction)
        if owner > 0 and world["wars"].has(owner):
            _button("ANGREIFEN", _attack)
        if owner == -1 and bool(star["habitable"]):
            _button("KOLONISIEREN (50 Credits)", _colonize)
        if owner > 0:
            _button("DIPLOMATIE MIT DIESEM REICH", func(): _diplomacy(owner))
    var fleet: Dictionary = world["fleets"][0]
    _label("Flotte: Stärke %d  •  Standort %s  •  Reisezeit %d" % [int(fleet["strength"]), world["stars"][int(fleet["location"])]["name"], int(fleet["eta"])])
    _label("Letzter Chronikeintrag: " + str(world["history"].back()))

func _move_fleet() -> void:
    notice = "Flottenroute festgelegt." if GalaxySystems.move_fleet(world, selected) else "Route nicht möglich: Ziel zu weit entfernt oder Flotte unterwegs."
    _show_galaxy()

func _explore() -> void:
    notice = "System kartografiert (+4 Forschung)." if GalaxySystems.explore(world, selected) else "Keine freie Flotte innerhalb von 170 Karteneinheiten."
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
    var ok := GalaxyModel.save_game(world)
    _label("Spielstand gespeichert." if ok else "Speichern fehlgeschlagen.")

func _research() -> void:
    notice = "Forschungsdurchbruch erzielt." if GalaxySystems.start_research(world) else "Nicht genügend Forschungspunkte."
    _show_galaxy()

func _fleet() -> void:
    notice = "Flotte verstärkt (+5)." if GalaxySystems.build_fleet(world) else "65 Credits für den Flottenausbau benötigt."
    _show_galaxy()

func _chronicle() -> void:
    screen = "chronicle"
    _clear()
    _title("GALAKTISCHE CHRONIK")
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
        _label("%s  •  Beziehung: %d" % [rival["name"], int(world["relations"].get(str(id), 0))])
        _button("GESCHENK SENDEN (-30 Credits)", func(): _diplomatic_choice(id, "gift"))
        _button("HANDELSABKOMMEN", func(): _diplomatic_choice(id, "trade"))
        _button("ULTIMATUM", func(): _diplomatic_choice(id, "threat"))
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
    if kind == "colonies":
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
    _title("PLANETENVERWALTUNG / " + str(star["name"]))
    _label("Rohstoffstufe %d  •  Credits %d  •  Legierungen %d" % [int(star["resource"]), int(world["credits"]), int(world["alloys"])])
    if notice != "":
        _label(notice)
    var built: Dictionary = world["buildings"].get(str(selected), {})
    for spec in [["mine", "MINE", "Credits"], ["lab", "FORSCHUNGSLABOR", "Forschung"], ["factory", "WERFT", "Legierungen"], ["fort", "VERTEIDIGUNG", "Befestigung"]]:
        var kind: String = spec[0]
        _label("%s  •  Stufe %d / 3" % [spec[1], int(built.get(kind, 0))])
        _button("%s BAUEN (%d Credits)" % [spec[1], GalaxyStrategy.building_cost(kind)], func(): _build(kind))
    _button("ZURÜCK", _show_galaxy)

func _build(kind: String) -> void:
    notice = "Bauprojekt abgeschlossen: " + kind if GalaxyStrategy.construct(world, selected, kind) else "Bau nicht möglich: Credits, Eigentum oder Baulimit."
    _construction()

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
