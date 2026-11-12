extends RefCounted
class_name GalaxyProgress

# Persistent, non-linear milestones; none ends the sandbox automatically.
# Progress is derived from world state rather than mutable counters.
const MILESTONES := [
    {"id": "cartographer", "icon": "✧", "name": "Sternenkartografen", "description": "Erkunde 10 Sternensysteme."},
    {"id": "first_contact", "icon": "◈", "name": "Stimmen im All", "description": "Stelle Kontakt zu 3 fremden Reichen her."},
    {"id": "colonies", "icon": "⬡", "name": "Neue Horizonte", "description": "Beherrsche 4 Sternensysteme."},
    {"id": "research", "icon": "✦", "name": "Zeitalter der Entdeckungen", "description": "Erreiche Forschungsstufe 4."},
    {"id": "culture", "icon": "❖", "name": "Bewahrer der Vergangenheit", "description": "Analysiere 2 archäologische Relikte."},
    {"id": "prosperity", "icon": "◆", "name": "Blühende Zivilgesellschaft", "description": "Erreiche 100 zivile Bevölkerungseinheiten bei mindestens 60 % Zustimmung."},
    {"id": "megaproject", "icon": "✺", "name": "Architekten der Sterne", "description": "Vollende ein galaktisches Großprojekt."},
    {"id": "crisis", "icon": "⚑", "name": "Durch die Dunkelheit", "description": "Überstehe eine galaktische Krise."}
]

static func prepare(world: Dictionary) -> void:
    if not world.has("milestones"):
        world["milestones"] = []

static func measures(world: Dictionary) -> Dictionary:
    var owned := 0
    var population := 0
    for star in world["stars"]:
        if int(star["owner"]) == 0:
            owned += 1
    for key in world.get("civilian_worlds", {}).keys():
        var id := int(key)
        if id >= 0 and id < world["stars"].size() and int(world["stars"][id]["owner"]) == 0:
            population += int(world["civilian_worlds"][key]["population"])
    var artifacts := 0
    for artifact in world.get("artifacts", []):
        if bool(artifact.get("analyzed", false)):
            artifacts += 1
    return {"cartographer": world.get("known", []).size(), "first_contact": world.get("contacts", []).size(), "colonies": owned, "research": int(world.get("research_level", 0)), "culture": artifacts, "prosperity": population if int(world.get("civilian_approval", 0)) >= 60 else 0, "megaproject": world.get("megaproject_completed", []).size(), "crisis": int(world.get("galactic_crises_survived", 0))}

static func targets() -> Dictionary:
    return {"cartographer": 10, "first_contact": 3, "colonies": 4, "research": 4, "culture": 2, "prosperity": 100, "megaproject": 1, "crisis": 1}

static func tick(world: Dictionary) -> void:
    prepare(world)
    var current: Dictionary = measures(world)
    var required: Dictionary = targets()
    for milestone in MILESTONES:
        var id := str(milestone["id"])
        if world["milestones"].has(id) or int(current[id]) < int(required[id]):
            continue
        world["milestones"].append(id)
        world["history"].append("Meilenstein erreicht: " + str(milestone["name"]) + ".")
