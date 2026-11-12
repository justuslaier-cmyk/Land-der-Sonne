extends SceneTree

# Long campaign: real UI navigation, project construction, both crisis arcs,
# save/resume and continuation. Crisis prerequisites are injected deliberately.
const UI = preload("res://scripts/galaxy/galaxy_ui.gd")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var ui: Control = UI.new()
    root.add_child(ui)
    await process_frame
    ui._begin_new_game()
    ui.settings["seed"] = 729146
    ui.settings["size"] = 60
    ui.settings["ai_count"] = 3
    ui._show_empire()
    ui._show_review()
    ui._start_game()
    if ui.screen != "galaxy":
        _fail("Campaign could not start")
        return
    # Perform real exploration, movement and colonization before late-game fixtures.
    var expansion_target := -1
    for star in ui.world["stars"]:
        var sid := int(star["id"])
        if sid == 0 or int(star["owner"]) != -1 or not bool(star["habitable"]):
            continue
        if bool(GalaxySystems.survey_preview(ui.world, sid)["allowed"]):
            expansion_target = sid
            break
    if expansion_target < 0:
        _fail("No reachable habitable neutral system for campaign expansion")
        return
    ui.selected = expansion_target
    ui._explore()
    if not ui.world["known"].has(expansion_target):
        _fail("Exploration action did not reveal selected system")
        return
    ui._move_fleet()
    if int(ui.world["fleets"][0]["destination"]) != expansion_target:
        _fail("Fleet order did not reach expansion target")
        return
    for i in range(12):
        if int(ui.world["fleets"][0]["location"]) == expansion_target and int(ui.world["fleets"][0]["destination"]) < 0:
            break
        GalaxyStrategy.tick(ui.world)
        ui.world["pending_event"] = ""
    if int(ui.world["fleets"][0]["location"]) != expansion_target or int(ui.world["fleets"][0]["destination"]) >= 0:
        _fail("Fleet never arrived at expansion target")
        return
    ui.world["credits"] = maxi(100, int(ui.world["credits"]))
    ui._colonize()
    if int(ui.world["stars"][expansion_target]["owner"]) != 0:
        _fail("Player colonization failed")
        return
    var rival_id := int(ui.world["ai"][0]["id"])
    if not ui.world["contacts"].has(rival_id):
        ui.world["contacts"].append(rival_id)
    if not GalaxyStrategy.declare_war(ui.world, rival_id):
        _fail("War declaration failed after first contact")
        return
    if not ui.world["wars"].has(rival_id):
        _fail("War state not recorded")
        return
    ui._economy_report()
    ui._research()
    ui._politics()
    ui._diplomacy()
    ui._fleet_command()
    ui._chronicle()
    if ui.screen != "chronicle":
        _fail("Core campaign screens not reachable")
        return
    ui.world["research_level"] = 4
    ui.world["credits"] = 3000
    ui.world["alloys"] = 2000
    if not GalaxyEndgame.start_project(ui.world, "orbital_archive"):
        _fail("Project could not start")
        return
    for i in range(9):
        GalaxyStrategy.tick(ui.world)
        ui.world["pending_event"] = ""
    if not ui.world["megaproject_completed"].has("orbital_archive"):
        _fail("Project not completed through strategic simulation")
        return
    ui.world["tick"] = 70
    ui.world["wars"] = [1, 2]
    GalaxyEndgame.tick(ui.world)
    if str(ui.world["galactic_crisis"].get("id", "")) != "fracture":
        _fail("First crisis not triggered")
        return
    ui._chronicle()
    if not GalaxyEndgame.defend_crisis(ui.world):
        _fail("Crisis defense action not available")
        return
    for i in range(5):
        if int(ui.world["galactic_crisis"]["threat"]) <= 0:
            break
        if not GalaxyEndgame.defend_crisis(ui.world):
            _fail("Crisis defense failed before first crisis resolved")
            return
    GalaxyEndgame.tick(ui.world)
    if int(ui.world["galactic_crises_survived"]) != 1:
        _fail("First crisis not resolved")
        return
    ui.world["tick"] = 110
    ui.world["ancient_history"]["completed"] = true
    GalaxyEndgame.tick(ui.world)
    if str(ui.world["galactic_crisis"].get("id", "")) != "ancient":
        _fail("Second crisis not triggered")
        return
    for i in range(6):
        if int(ui.world["galactic_crisis"]["threat"]) <= 0:
            break
        if not GalaxyEndgame.defend_crisis(ui.world):
            _fail("Crisis defense failed before second crisis resolved")
            return
    GalaxyEndgame.tick(ui.world)
    if int(ui.world["galactic_crises_survived"]) != 2:
        _fail("Second crisis not resolved")
        return
    ui._show_galaxy()
    ui._save()
    var expected := JSON.stringify(ui.world)
    ui._load_game()
    if JSON.stringify(ui.world) != expected:
        _fail("Endgame progress lost across save/load")
        return
    if not ui.world["megaproject_completed"].has("orbital_archive") or int(ui.world["galactic_crises_survived"]) != 2:
        _fail("Project or crisis progress lost")
        return
    var before := int(ui.world["tick"])
    GalaxyStrategy.tick(ui.world)
    if int(ui.world["tick"]) != before + 1:
        _fail("Post-endgame continuation blocked")
        return
    print("GALAXY_CAMPAIGN_ENDGAME_PASS: UI screens, megaproject, two crises, save/load and continuation")
    ui.queue_free()
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_CAMPAIGN_ENDGAME_FAILURE: " + message)
    quit(1)
