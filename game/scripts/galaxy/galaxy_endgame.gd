extends RefCounted
class_name GalaxyEndgame

# Long projects compete for scarce resources and permanently change yields.
const PROJECTS := [
    {"id": "orbital_archive", "title": "Orbitalarchiv", "credits": 110, "alloys": 70, "duration": 8, "science": 3, "bonus": "science", "yield": 5},
    {"id": "stellar_foundry", "title": "Sternenschmiede", "credits": 140, "alloys": 90, "duration": 10, "science": 2, "bonus": "alloys", "yield": 4},
    {"id": "unity_beacon", "title": "Einheitsleuchtfeuer", "credits": 120, "alloys": 75, "duration": 9, "science": 2, "bonus": "stability", "yield": 2}
]

static func prepare(world: Dictionary) -> void:
    if not world.has("megaproject_active"):
        world["megaproject_active"] = {}
    if not world.has("megaproject_completed"):
        world["megaproject_completed"] = []
    if not world.has("galactic_crisis"):
        world["galactic_crisis"] = {}
    if not world.has("galactic_crises_survived"):
        world["galactic_crises_survived"] = 0
    if not world.has("galactic_crisis_resolved_ids"):
        world["galactic_crisis_resolved_ids"] = []

static func start_project(world: Dictionary, id: String) -> bool:
    prepare(world)
    if not world["megaproject_active"].is_empty() or world["megaproject_completed"].has(id):
        return false
    for project in PROJECTS:
        if str(project["id"]) != id:
            continue
        if int(world.get("research_level", 0)) < int(project["science"]):
            return false
        if int(world.get("credits", 0)) < int(project["credits"]) or int(world.get("alloys", 0)) < int(project["alloys"]):
            return false
        world["credits"] = int(world["credits"]) - int(project["credits"])
        world["alloys"] = int(world["alloys"]) - int(project["alloys"])
        world["megaproject_active"] = {"id": id, "progress": 0, "started": int(world["tick"])}
        world["history"].append("Großprojekt begonnen: %s." % str(project["title"]))
        return true
    return false

static func defend_crisis(world: Dictionary) -> bool:
    prepare(world)
    var crisis: Dictionary = world["galactic_crisis"]
    if str(crisis.get("state", "")) != "active" or int(world.get("credits", 0)) < 25 or int(world.get("alloys", 0)) < 10:
        return false
    world["credits"] = int(world["credits"]) - 25
    world["alloys"] = int(world["alloys"]) - 10
    crisis["threat"] = maxi(0, int(crisis["threat"]) - 22)
    world["history"].append("Galaktische Krisenabwehr: Bedrohung um 22 gesenkt.")
    return true

static func tick(world: Dictionary) -> void:
    prepare(world)
    var active: Dictionary = world["megaproject_active"]
    if not active.is_empty():
        active["progress"] = int(active["progress"]) + 1
        for project in PROJECTS:
            if str(project["id"]) != str(active["id"]):
                continue
            if int(active["progress"]) >= int(project["duration"]):
                world["megaproject_completed"].append(str(active["id"]))
                world["megaproject_active"] = {}
                world["history"].append("Großprojekt vollendet: %s." % str(project["title"]))
            break
    for project in PROJECTS:
        if not world["megaproject_completed"].has(str(project["id"])):
            continue
        var field := str(project["bonus"])
        world[field] = int(world.get(field, 0)) + int(project["yield"])
        if field == "stability":
            world[field] = mini(100, int(world[field]))
    var crisis: Dictionary = world["galactic_crisis"]
    var year := int(world["tick"])
    if str(crisis.get("state", "")) == "survived":
        world["galactic_crisis"] = {}
        crisis = world["galactic_crisis"]
    if crisis.is_empty() and year >= 70 and not world["galactic_crisis_resolved_ids"].has("fracture") and (world.get("wars", []).size() >= 2 or int(world.get("stability", 100)) < 35):
        world["galactic_crisis"] = {"id": "fracture", "title": "Die galaktische Spaltung", "state": "active", "threat": 75, "started": year}
        world["history"].append("Galaktische Krise: Krieg und Instabilität zerreißen die Sternenordnung.")
        return
    if crisis.is_empty() and year >= 110 and not world["galactic_crisis_resolved_ids"].has("ancient") and world.get("ancient_history", {}).get("completed", false):
        world["galactic_crisis"] = {"id": "ancient", "title": "Die Rückkehr der Alten", "state": "active", "threat": 90, "started": year}
        world["history"].append("Galaktische Krise: Die alten Archive aktivieren vergessene Maschinen.")
        return
    if str(crisis.get("state", "")) != "active":
        return
    if int(crisis["threat"]) <= 0:
        crisis["state"] = "survived"
        world["galactic_crises_survived"] = int(world["galactic_crises_survived"]) + 1
        world["galactic_crisis_resolved_ids"].append(str(crisis["id"]))
        world["history"].append("Galaktische Krise überwunden: %s." % str(crisis["title"]))
        return
    crisis["threat"] = mini(100, int(crisis["threat"]) + 2)
    world["credits"] = maxi(0, int(world["credits"]) - 4)
    world["stability"] = maxi(0, int(world["stability"]) - 1)
