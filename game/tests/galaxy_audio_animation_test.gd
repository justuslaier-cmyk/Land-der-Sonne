extends SceneTree

const Audio = preload("res://scripts/galaxy/galaxy_audio.gd")
const UI = preload("res://scripts/galaxy/galaxy_ui.gd")
const Comfort = preload("res://scripts/galaxy/galaxy_comfort.gd")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var audio := Audio.new()
    root.add_child(audio)
    await process_frame
    for bus in ["Master", "Music", "SFX"]:
        if AudioServer.get_bus_index(bus) < 0:
            _fail("Missing audio bus: " + bus)
            return
    var ambient := Audio.create_ambient()
    if ambient == null or ambient.loop_mode != AudioStreamWAV.LOOP_FORWARD or ambient.data.size() != Audio.SAMPLE_RATE * Audio.MUSIC_SECONDS * 2:
        _fail("Original looping soundtrack invalid")
        return
    for kind in ["click", "select", "event"]:
        var sound := Audio.create_effect(kind)
        if sound == null or sound.data.is_empty() or sound.loop_mode != AudioStreamWAV.LOOP_DISABLED:
            _fail("Original SFX invalid: " + kind)
            return
        audio.play_effect(kind)
    var ui := UI.new()
    root.add_child(ui)
    await process_frame
    if not is_instance_valid(ui.audio_director):
        _fail("Audio director not persistent in game UI")
        return
    ui._show_menu()
    ui._show_empire()
    ui._show_review()
    if not is_instance_valid(ui.audio_director):
        _fail("Navigation destroyed audio director")
        return
    ui._set_comfort("music_volume", 35)
    ui._set_comfort("sfx_volume", 60)
    if absf(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))) - 0.35) > 0.02:
        _fail("Music bus setting not applied")
        return
    if absf(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))) - 0.60) > 0.02:
        _fail("SFX bus setting not applied")
        return
    ui._set_comfort("volume", 25)
    ui._set_comfort("muted", true)
    var master := AudioServer.get_bus_index("Master")
    if not AudioServer.is_bus_mute(master) or absf(db_to_linear(AudioServer.get_bus_volume_db(master)) - 0.25) > 0.02:
        _fail("Master volume/mute setting not applied")
        return
    ui._set_comfort("muted", false)
    if AudioServer.is_bus_mute(master):
        _fail("Unmute setting not applied")
        return
    ui._set_comfort("volume", 80)
    Comfort.save_preferences(Comfort.defaults())
    ui.queue_free()
    audio.queue_free()
    print("GALAXY_AUDIO_ANIMATION_PASS: original soundtrack, SFX, buses, UI persistence and volume/mute")
    quit(0)

func _fail(message: String) -> void:
    push_error("GALAXY_AUDIO_ANIMATION_FAILURE: " + message)
    quit(1)
