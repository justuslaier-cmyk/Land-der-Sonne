extends RefCounted
class_name GalaxyModel

const VERSION: int = 1
const SAVE_PATH: String = "user://galaxy_v1.json"
const MAX_BYTES: int = 4194304

static func defaults() -> Dictionary:
    return {"seed": 0, "size": 60, "ai_count": 5, "shape": 0, "habitable": 30, "resources": 50, "events": 50, "difficulty": 1}

static func empire_defaults() -> Dictionary:
    return {"name": "Solare Union", "species": "Solari", "portrait": 0, "government": 0, "trait": 0, "ship_style": 0, "homeworld": "Aurora", "civics": ["archives", "commons"], "traits": ["curious"], "ethic": "pluralist"}

static func validate(settings: Dictionary, empire: Dictionary) -> String:
    if int(settings.get("size", 0)) < 20 or int(settings.get("size", 0)) > 250:
        return "Sternenzahl muss zwischen 20 und 250 liegen."
    if int(settings.get("ai_count", -1)) < 0 or int(settings.get("ai_count", -1)) > mini(20, int(settings["size"]) / 5):
        return "Zu viele KI-Reiche für diese Galaxie."
    if int(settings.get("seed", -1)) < 0 or int(settings.get("seed", -1)) > 2147483647:
        return "Seed muss zwischen 0 und 2147483647 liegen."
    if int(settings.get("shape", -1)) < 0 or int(settings.get("shape", -1)) > 2:
        return "Unbekannte Galaxieform."
    if int(settings.get("difficulty", -1)) < 0 or int(settings.get("difficulty", -1)) > 2:
        return "Unbekannter Schwierigkeitsgrad."
    for field in ["habitable", "resources", "events"]:
        var amount := int(settings.get(field, -1))
        if amount < 1 or amount > (90 if field == "habitable" else 100):
            return "Galaxieparameter außerhalb des gültigen Bereichs: " + field
    if str(empire.get("homeworld", "")).strip_edges().is_empty():
        return "Die Heimatwelt benötigt einen Namen."
    if str(empire.get("name", "")).strip_edges().is_empty() or str(empire.get("species", "")).strip_edges().is_empty():
        return "Reich und Spezies benötigen Namen."
    return GalaxyIdentity.validate(empire)

static func generate(settings: Dictionary, empire: Dictionary) -> Dictionary:
    var rng := RandomNumberGenerator.new()
    rng.seed = int(settings["seed"])
    if rng.seed == 0:
        rng.randomize()
        rng.seed = rng.randi_range(1, 2147483647)
    var actual_settings := settings.duplicate(true)
    actual_settings["seed"] = int(rng.seed)
    var stars: Array = []
    var prefixes := ["Astra", "Nery", "Vela", "Khar", "Orion", "Ely", "Thal", "Cyr", "Oph", "Zora", "Mer", "Sola", "Vey", "Iona", "Xen", "Arka"]
    var suffixes := ["ion", "is", "ara", "os", "eth", "ora", " Prime", " VII", "aris", "ea", "on", "yx"]
    var count := int(settings["size"])
    for i in range(count):
        var angle := TAU * float(i) / float(count) * 3.0 + rng.randf_range(-0.4, 0.4)
        var distance := sqrt(rng.randf()) * 340.0
        var p := Vector2(cos(angle), sin(angle)) * distance
        if int(settings["shape"]) == 1:
            p = Vector2(rng.randf_range(-330.0, 330.0), rng.randf_range(-235.0, 235.0))
        elif int(settings["shape"]) == 2:
            distance = rng.randf_range(150.0, 330.0)
            p = Vector2(cos(angle), sin(angle)) * distance
        var kind := rng.randi_range(0, 6)
        var star_name := "%s%s-%02d" % [prefixes[rng.randi_range(0, prefixes.size() - 1)], suffixes[rng.randi_range(0, suffixes.size() - 1)], i + 1]
        var resource_roll := rng.randi_range(0, 99) + int(settings["resources"]) / 5
        var resource_level := clampi(1 + resource_roll / 24, 1, 5)
        stars.append({"id": i, "name": star_name, "x": snappedf(p.x, 0.1), "y": snappedf(p.y, 0.1), "kind": kind, "resource": resource_level, "habitable": rng.randi_range(0, 99) < int(settings["habitable"]), "owner": -1})
    # The old MST guaranteed a connected drawing but could contain legs
    # too long to survey. Uniform deterministic scaling preserves relative
    # distances and seed identity while guaranteeing <=170-unit MST legs.
    var geography_lanes: Array = GalaxyRoutes.build(stars)
    var longest := 0.0
    for lane in geography_lanes:
        var first: Dictionary = stars[int(lane[0])]
        var second: Dictionary = stars[int(lane[1])]
        longest = maxf(longest, Vector2(float(first["x"]), float(first["y"])).distance_to(Vector2(float(second["x"]), float(second["y"]))))
    if longest > 169.0:
        var scale := 169.0 / longest
        for star in stars:
            star["x"] = snappedf(float(star["x"]) * scale, 0.1)
            star["y"] = snappedf(float(star["y"]) * scale, 0.1)
    stars[0]["name"] = str(empire["homeworld"])
    stars[0]["habitable"] = true
    stars[0]["owner"] = 0
    var ai: Array = []
    var names := ["Veyr-Konsortium", "Nexari-Synode", "Orionische Liga", "Khar-Dynastie", "Thalische Föderation", "Ophir-Kollektiv", "Astra-Orden", "Zirax-Kommune", "Eidolon-Reich", "Meridian-Pakt"]
    var capitals: Array = [0]
    for j in range(int(settings["ai_count"])):
        # Farthest-first placement maximizes the nearest capital distance.
        # This is a spatial heuristic, not a guarantee of balanced resources.
        var index := -1
        var best_distance := -1.0
        for candidate in range(1, count):
            if capitals.has(candidate):
                continue
            var nearest := INF
            var point := Vector2(float(stars[candidate]["x"]), float(stars[candidate]["y"]))
            for capital in capitals:
                var other := Vector2(float(stars[int(capital)]["x"]), float(stars[int(capital)]["y"]))
                nearest = minf(nearest, point.distance_squared_to(other))
            if nearest > best_distance:
                best_distance = nearest
                index = candidate
        if index < 0:
            break
        capitals.append(index)
        stars[index]["owner"] = j + 1
        stars[index]["habitable"] = true
        ai.append({"id": j + 1, "name": names[j % names.size()] if j < names.size() else "Imperium %d" % (j + 1), "capital": index, "temperament": rng.randi_range(0, 3)})
    return {"version": VERSION, "settings": actual_settings, "empire": empire.duplicate(true), "stars": stars, "lanes": GalaxyRoutes.build(stars), "ai": ai, "tick": 0, "credits": 100, "science": 0, "selected": 0, "event_done": false, "history": ["Gründung des Reiches " + str(empire["name"])]}

static func advance(world: Dictionary) -> void:
    world["tick"] = int(world["tick"]) + 1
    world["credits"] = int(world["credits"]) + 3 + int(world["empire"]["trait"] == 1) * 2
    world["science"] = int(world["science"]) + 2 + int(world["empire"]["trait"] == 0) * 2

# Explicit slots preserve the legacy default save path for existing users.
# Save files remain schema version 1; no destructive migration is attempted.
static func slot_path(slot: int = 0) -> String:
    if slot < 0 or slot > 4:
        return ""
    return SAVE_PATH if slot == 0 else "user://galaxy_slot_%d_v1.json" % slot

static func save_game(world: Dictionary, slot: int = 0) -> bool:
    var path := slot_path(slot)
    if path.is_empty():
        return false
    var payload := JSON.stringify(world)
    if payload.to_utf8_buffer().size() > MAX_BYTES:
        return false
    var temp := path + ".tmp"
    var file := FileAccess.open(temp, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(payload)
    file.flush()
    file.close()
    if _read(temp).is_empty():
        return false
    var full := ProjectSettings.globalize_path(path)
    var stage := ProjectSettings.globalize_path(temp)
    var backup := ProjectSettings.globalize_path(path + ".bak")
    var previous := ProjectSettings.globalize_path(path + ".previous")
    # First repair a rotation interrupted before the new primary was installed.
    if FileAccess.file_exists(path + ".previous"):
        if _read(path + ".previous").is_empty():
            return false
        if not FileAccess.file_exists(path):
            if DirAccess.rename_absolute(previous, full) != OK:
                return false
        else:
            # Primary exists: the old .previous is still the safest backup.
            # Retain it until a new primary has been committed.
            pass
    var had_current := FileAccess.file_exists(path)
    # A damaged primary must never replace the last valid backup.
    if had_current and _read(path).is_empty():
        if _read(path + ".bak").is_empty():
            return false
        if DirAccess.remove_absolute(full) != OK:
            return false
        if DirAccess.rename_absolute(backup, full) != OK:
            return false
    had_current = FileAccess.file_exists(path)
    if had_current:
        # Keep a second recovery copy while moving the current primary.
        # Never delete an existing valid .previous before promotion.
        if FileAccess.file_exists(path + ".previous"):
            if not FileAccess.file_exists(path + ".bak"):
                if DirAccess.rename_absolute(previous, backup) != OK:
                    return false
            else:
                # A stale .previous must not be discarded during a new write.
                return false
        if DirAccess.rename_absolute(full, previous) != OK:
            return false
    if DirAccess.rename_absolute(stage, full) != OK:
        if had_current:
            DirAccess.rename_absolute(previous, full)
        return false
    if had_current:
        # .previous contains the immediately preceding valid primary.
        # If backup replacement fails, both primary and .previous remain.
        if FileAccess.file_exists(path + ".bak"):
            if DirAccess.remove_absolute(backup) != OK:
                return true
        DirAccess.rename_absolute(previous, backup)
    return true

static func load_game(slot: int = 0) -> Dictionary:
    var path := slot_path(slot)
    if path.is_empty():
        return {}
    var world := _read(path)
    if not world.is_empty():
        return world
    var backup := _read(path + ".bak")
    if not backup.is_empty():
        return backup
    return _read(path + ".previous")

static func _read(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null or file.get_length() > MAX_BYTES:
        return {}
    var json := JSON.new()
    if json.parse(file.get_as_text()) != OK or typeof(json.data) != TYPE_DICTIONARY:
        return {}
    var data: Dictionary = json.data
    if int(data.get("version", -1)) != VERSION or typeof(data.get("stars")) != TYPE_ARRAY or typeof(data.get("settings")) != TYPE_DICTIONARY or typeof(data.get("empire")) != TYPE_DICTIONARY:
        return {}
    if data["stars"].is_empty() or validate(data["settings"], data["empire"]) != "":
        return {}
    # Reject structurally corrupt but parseable saves before they can crash
    # strategic simulation or silently propagate impossible ownership.
    if not GalaxyContracts.errors(data).is_empty():
        return {}
    return data
