extends RefCounted
class_name GalaxyLore

# Seed-bound archaeological strata: fixed history, discoverable sites, persistent choices.
static func prepare(world: Dictionary) -> void:
    if world.has("ancient_history"):
        if not world.has("ancient_sites"):
            _generate_sites(world)
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
    _generate_sites(world)

static func inspect(world: Dictionary, star_id: int) -> bool:
    prepare(world)
    var lore: Dictionary = world["ancient_history"]
    if not lore["ruins"].has(star_id) or lore["discovered"].has(star_id):
        return _discover_site(world, star_id)
    lore["discovered"].append(star_id)
    _discover_site(world, star_id)
    world["history"].append("Archäologische Anomalie in %s: Spuren von %s." % [world["stars"][star_id]["name"], lore["civilization"]])
    if int(lore["stage"]) == 0 and str(world.get("pending_event", "")) == "":
        world["pending_event"] = "ancient_signal"
        lore["stage"] = 1
    return true

static func tick(world: Dictionary) -> void:
    prepare(world)
    var lore: Dictionary = world["ancient_history"]
    if not [2, 5].has(int(lore["stage"])) or str(world.get("pending_event", "")) != "":
        return
    lore["timer"] = int(lore["timer"]) - 1
    if int(lore["timer"]) <= 0:
        if int(lore["stage"]) == 2:
            lore["stage"] = 3
            world["pending_event"] = "ancient_echo"
        else:
            lore["stage"] = 6
            world["pending_event"] = "ancient_awakening"

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
        lore["stage"] = 5
        lore["timer"] = 3
        if option == 0:
            world["science"] = int(world["science"]) + (48 if int(lore["choice"]) == 0 else 24)
            world["history"].append("Das Echo der Alten entschlüsselt: vergessene Sternkarten gesichert.")
        else:
            world["credits"] = int(world["credits"]) + 55
            world["stability"] = maxi(0, int(world["stability"]) - 8)
            world["history"].append("Das Echo verkauft. Unruhen wegen des verlorenen Erbes.")
    elif kind == "ancient_awakening" and int(lore["stage"]) == 6:
        lore["stage"] = 7
        lore["completed"] = true
        lore["final_choice"] = option
        if option == 0:
            world["science"] = int(world["science"]) + 65
            world["stability"] = mini(100, int(world["stability"]) + 8)
            world["history"].append("Das erwachte Archiv wird unter Aufsicht erforscht. Die Sternenreiche erfahren von den Ersten.")
        else:
            world["alloys"] = int(world.get("alloys", 0)) + 35
            world["credits"] = int(world["credits"]) + 60
            world["stability"] = maxi(0, int(world["stability"]) - 12)
            world["history"].append("Das erwachte Archiv wurde zerlegt. Antike Maschinen treiben die Industrie an; Unruhen folgen.")
    world["pending_event"] = ""

static func event_title(kind: String) -> String:
    if kind == "ancient_signal":
        return "DIE STIMMEN DER ERSTEN"
    if kind == "ancient_echo":
        return "DAS ECHO UNTER DEM STAUB"
    return "DAS ERWACHEN DES ARCHIVS"

static func event_text(world: Dictionary, kind: String) -> String:
    var lore: Dictionary = world["ancient_history"]
    if kind == "ancient_signal":
        return "Auf einer verlassenen Welt ruhen Bauwerke von %s, einer Zivilisation, die vor etwa %d Jahren verschwand. Aus den Tiefen antwortet ein Signal, das kein heutiges Reich versteht." % [lore["civilization"], int(lore["age"])]
    if kind == "ancient_echo":
        return "Zwei Jahre nach der Entdeckung erwachen die Ruinen. Die geborgenen Daten tragen dieselbe Signatur wie das Signal. Was zunächst wie ein Fund wirkte, könnte eine Warnung sein."
    return "Drei Jahre nach dem Echo entfaltet sich über den Ruinen ein Netzwerk uralter Maschinen. Das Archiv bietet Wissen, das eine ganze Epoche verändern könnte. Doch die Kolonien fürchten die Macht seiner Erbauer. Soll das Netzwerk bewahrt oder ausgeschlachtet werden?"

# Independent lost cultures coexist with the primary story arc. Discoveries are
# tied to actual exploration, not random menu prompts.
static func _generate_sites(world: Dictionary) -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = int(world["settings"]["seed"]) * 271 + 7919
    var cultures := [
        ["Die Architekten von Ilyr", "Gravitationsarchitektur", "Versunkene Orbitale"],
        ["Das Thren-Konsortium", "Biotechnologie", "Organische Archive"],
        ["Die Aschefürsten", "Sternenmetallurgie", "Verlassene Schmiedewelten"],
        ["Der Meridian-Chor", "Quantenkommunikation", "Stille Relais"]
    ]
    var sites: Array = []
    var occupied: Array = world["ancient_history"]["ruins"].duplicate()
    var count: int = world["stars"].size()
    for i in range(mini(4, count - 4)):
        var id := rng.randi_range(1, count - 1)
        while occupied.has(id):
            id = 1 + (id % (count - 1))
        occupied.append(id)
        var culture: Array = cultures[i]
        sites.append({"star_id": id, "culture": culture[0], "discipline": culture[1], "site": culture[2], "age": rng.randi_range(10000, 125000), "discovered": false, "artifact": false})
    world["ancient_sites"] = sites
    if not world.has("artifacts"):
        world["artifacts"] = []

static func _discover_site(world: Dictionary, star_id: int) -> bool:
    var sites: Array = world.get("ancient_sites", [])
    for site in sites:
        if int(site["star_id"]) != star_id or bool(site["discovered"]):
            continue
        site["discovered"] = true
        site["artifact"] = true
        var artifact := {"culture": site["culture"], "discipline": site["discipline"], "origin": world["stars"][star_id]["name"], "analyzed": false}
        world["artifacts"].append(artifact)
        world["science"] = int(world["science"]) + 8
        world["history"].append("Relikt der %s in %s entdeckt: %s (+8 Forschung)." % [site["culture"], artifact["origin"], site["discipline"]])
        return true
    return false

static func analyze_artifact(world: Dictionary, index: int) -> bool:
    prepare(world)
    if index < 0 or index >= world["artifacts"].size() or int(world.get("science", 0)) < 30:
        return false
    var artifact: Dictionary = world["artifacts"][index]
    if bool(artifact.get("analyzed", false)):
        return false
    world["science"] = int(world["science"]) - 30
    artifact["analyzed"] = true
    if not world.has("ancient_technology"):
        world["ancient_technology"] = []
    var discipline := str(artifact["discipline"])
    if not world["ancient_technology"].has(discipline):
        world["ancient_technology"].append(discipline)
    world["history"].append("Antikes Relikt entschlüsselt: %s. Neue Technologie: %s." % [artifact["culture"], discipline])
    return true

static func artifact_bonus(world: Dictionary, field: String) -> int:
    var technology: Array = world.get("ancient_technology", [])
    if field == "science":
        return (3 if technology.has("Quantenkommunikation") else 0) + (2 if technology.has("Biotechnologie") else 0)
    if field == "alloys":
        return 3 if technology.has("Sternenmetallurgie") else 0
    if field == "credits":
        return 4 if technology.has("Gravitationsarchitektur") else 0
    return 0
