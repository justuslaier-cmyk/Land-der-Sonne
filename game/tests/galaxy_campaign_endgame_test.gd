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
    ui.world["galactic_crisis"]["threat"] = 0
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
    ui.world["galactic_crisis"]["threat"] = 0
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
