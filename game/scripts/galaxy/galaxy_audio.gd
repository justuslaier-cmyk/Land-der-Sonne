extends Node
class_name GalaxyAudio

# Original procedural soundtrack and effects; no external audio samples or licenses.
const SAMPLE_RATE := 22050
const MUSIC_SECONDS := 8
var music_player: AudioStreamPlayer
var effects_player: AudioStreamPlayer
var enabled := true

func _ready() -> void:
    _ensure_buses()
    music_player = AudioStreamPlayer.new()
    music_player.bus = "Music"
    add_child(music_player)
    effects_player = AudioStreamPlayer.new()
    effects_player.bus = "SFX"
    add_child(effects_player)
    music_player.stream = create_ambient()
    music_player.volume_db = -17.0
    effects_player.volume_db = -9.0
    if not Engine.is_editor_hint():
        music_player.play()

static func _ensure_buses() -> void:
    for name in ["Music", "SFX"]:
        if AudioServer.get_bus_index(name) < 0:
            AudioServer.add_bus()
            AudioServer.set_bus_name(AudioServer.bus_count - 1, name)
        AudioServer.set_bus_send(AudioServer.get_bus_index(name), "Master")

static func _wave(samples: PackedFloat32Array, looping: bool) -> AudioStreamWAV:
    var bytes := PackedByteArray()
    bytes.resize(samples.size() * 2)
    for i in range(samples.size()):
        var value: int = clampi(int(round(samples[i] * 32767.0)), -32768, 32767)
        bytes.encode_s16(i * 2, value)
    var stream := AudioStreamWAV.new()
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate = SAMPLE_RATE
    stream.stereo = false
    stream.data = bytes
    if looping:
        stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
        stream.loop_begin = 0
        stream.loop_end = samples.size()
    return stream

static func create_ambient() -> AudioStreamWAV:
    # Eight-second seamlessly repeating minor-pentatonic pad with soft harmonics.
    var samples := PackedFloat32Array()
    samples.resize(SAMPLE_RATE * MUSIC_SECONDS)
    var notes := [110.0, 130.8128, 164.8138, 196.0]
    for i in range(samples.size()):
        var t := float(i) / float(SAMPLE_RATE)
        var phase := t / float(MUSIC_SECONDS)
        var value := 0.0
        for n in range(notes.size()):
            var f: float = notes[n]
            var pulse := 0.7 + 0.3 * sin(TAU * (phase + float(n) / 4.0))
            value += (sin(TAU * f * t) + 0.19 * sin(TAU * f * 2.0 * t)) * pulse * 0.047
        # Match loop endpoints with a short crossfade envelope.
        var fade := minf(1.0, minf(t, float(MUSIC_SECONDS) - t) / 0.16)
        samples[i] = value * fade
    return _wave(samples, true)

static func create_effect(kind: String) -> AudioStreamWAV:
    var duration := 0.30 if kind == "event" else 0.12 if kind == "click" else 0.20
    var samples := PackedFloat32Array()
    samples.resize(int(SAMPLE_RATE * duration))
    for i in range(samples.size()):
        var t := float(i) / float(SAMPLE_RATE)
        var progress := t / duration
        var freq := (310.0 + 190.0 * progress) if kind == "select" else (280.0 - 90.0 * progress) if kind == "event" else (540.0 - 180.0 * progress)
        var envelope := pow(1.0 - progress, 2.0) * minf(1.0, t * 140.0)
        samples[i] = sin(TAU * freq * t) * envelope * 0.24
    return _wave(samples, false)

func play_effect(kind: String = "click") -> void:
    if enabled and is_instance_valid(effects_player):
        effects_player.stream = create_effect(kind)
        effects_player.play()

func set_music_enabled(value: bool) -> void:
    enabled = value
    if is_instance_valid(music_player):
        if value and not music_player.playing:
            music_player.play()
        elif not value:
            music_player.stop()
