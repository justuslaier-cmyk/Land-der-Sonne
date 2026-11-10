extends RefCounted
class_name GalaxyLore

# Seed-bound archaeological strata: fixed history, discoverable sites, persistent choices.
static func prepare(world: Dictionary) -> void:
    if world.has("ancient_history"):
        return
    var seed := int(world["settings"]["seed"])
    var names := ["Die Ersten Wanderer", "Das Vael-Archiv", "Die Stille Dynastie", "Der Chor der Neun"]
    var rng := RandomNumberGenerator.new()
    rng.seed = seed * 9176 + 403
    var name: String = names[rng.randi_range(0, names.size() - 1)]
    var ruins: Array = []
    var count: int = world["stars"].size()
    for i in range(3):
        var id := 1 + int(rng.randi_range(0, count - 2))
        while ruins.has(id):
            id = 1 + (id % (count - 1))
        ruins.append(id)
    world["ancient_history"] = {"civilization": name, "age": rng.randi_range(18000, 90000), "ruins": ruins, "discovered": [], "stage": 0, "choice": -1, "timer": 0, "completed": false}

static func inspect(world: Dictionary, star_id: int) -> bool:
    prepare(world)
    var lore: Dictionary = world["ancient_history"]
    if not lore["ruins"].has(star_id) or lore["discovered"].has(star_id):
        return false
    lore["discovered"].append(star_id)
    world["history"].append("Archäologische Anomalie in %s: Spuren von %s." % [world["stars"][star_id]["name"], lore["civilization"]])
    if int(lore["stage"]) == 0 and str(world.get("pending_event", "")) == "":
        world["pending_event"] = "ancient_signal"
        lore["stage"] = 1
    return true

static func tick(world: Dictionary) -> void:
    prepare(world)
    var lore: Dictionary = world["ancient_history"]
    if int(lore["stage"]) != 2 or str(world.get("pending_event", "")) != "":
        return
    lore["timer"] = int(lore["timer"]) - 1
    if int(lore["timer"]) <= 0:
        lore["stage"] = 3
        world["pending_event"] = "ancient_echo"

static func resolve(world: Dictionary, kind: String, option: int) -> void:
    prepare(world)
    var lore: Dictionary = world["ancient_history"]
    if kind == "ancient_signal" and int(lore["stage"]) == 1:
        lore["choice"] = option
        lore["stage"] = 2
        lore["timer"] = 2
        if option == 0:
            world["science"] = int(world["science"]) + 12
            world["history"].append("Die Ruinen wurden unter Quarantäne gestellt und untersucht.")
        else:
            world["credits"] = int(world["credits"]) + 20
            world["stability"] = maxi(0, int(world["stability"]) - 3)
            world["history"].append("Antike Relikte wurden geborgen; die Kolonien sind beunruhigt.")
    elif kind == "ancient_echo" and int(lore["stage"]) == 3:
        lore["stage"] = 4
        lore["completed"] = true
        if option == 0:
            world["science"] = int(world["science"]) + (48 if int(lore["choice"]) == 0 else 24)
            world["history"].append("Das Echo der Alten entschlüsselt: vergessene Sternkarten gesichert.")
        else:
            world["credits"] = int(world["credits"]) + 55
            world["stability"] = maxi(0, int(world["stability"]) - 8)
            world["history"].append("Das Echo verkauft. Unruhen wegen des verlorenen Erbes.")
    world["pending_event"] = ""

static func event_title(kind: String) -> String:
    return "DIE STIMMEN DER ERSTEN" if kind == "ancient_signal" else "DAS ECHO UNTER DEM STAUB"

static func event_text(world: Dictionary, kind: String) -> String:
    var lore: Dictionary = world["ancient_history"]
    if kind == "ancient_signal":
        return "Auf einer verlassenen Welt ruhen Bauwerke von %s, einer Zivilisation, die vor etwa %d Jahren verschwand. Aus den Tiefen antwortet ein Signal, das kein heutiges Reich versteht." % [lore["civilization"], int(lore["age"])]
    return "Zwei Jahre nach der Entdeckung erwachen die Ruinen. Die geborgenen Daten tragen dieselbe Signatur wie das Signal. Was zunächst wie ein Fund wirkte, könnte eine Warnung sein."
