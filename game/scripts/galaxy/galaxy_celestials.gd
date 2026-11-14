extends RefCounted
class_name GalaxyCelestials

# Stable on-demand generation: identical seed + star id always yields identical bodies.
static func generate(seed: int, star: Dictionary) -> Dictionary:
    var rng := RandomNumberGenerator.new()
    rng.seed = int(seed) * 131071 + int(star["id"]) * 1000003 + 17
    var classes := ["Gelber Zwerg", "Blauer Riese", "Roter Zwerg", "Weißer Stern", "Orangefarbener Zwerg", "Roter Überriese", "Doppelstern"]
    var kind := clampi(int(star["kind"]), 0, classes.size() - 1)
    var system := {"star_class": classes[kind % classes.size()], "temperature": 2500 + kind * 1150 + rng.randi_range(0, 1500), "planets": [], "asteroids": rng.randi_range(0, 3), "comets": rng.randi_range(0, 2), "binary": kind == 6}
    var types := ["Gesteinswelt", "Gasriese", "Eiswelt", "Ozeanwelt", "Wüstenwelt", "Lavawelt", "Dschungelwelt", "Tundrawelt"]
    var count := rng.randi_range(2, 9)
    for i in range(count):
        var ptype := rng.randi_range(0, types.size() - 1)
        if i == 1 and bool(star["habitable"]):
            ptype = 3
        var moons: Array = []
        for j in range(rng.randi_range(0, 4 if ptype == 1 else 2)):
            moons.append({"name": "%s %s-%d" % [star["name"], char(97 + i), j + 1], "size": rng.randi_range(2, 7)})
        (system["planets"] as Array).append({"name": "%s %s" % [star["name"], _roman(i + 1)], "type": types[ptype], "type_id": ptype, "size": rng.randi_range(5, 15), "orbit": i + 1, "moons": moons, "rings": ptype == 1 and rng.randf() < 0.7, "resources": rng.randi_range(1, 5), "habitable": (i == 1 and bool(star["habitable"])) or (ptype in [0, 3, 6] and (bool(star["habitable"]) or rng.randf() < 0.12))})
    # Derived descriptors deliberately consume no additional random numbers:
    # existing orbital layouts and colony keys remain stable across saves.
    for planet in system["planets"]:
        var type_id := int(planet["type_id"])
        var climate: String = ["Gemäßigt", "Gasatmosphäre", "Polar", "Maritim", "Arid", "Vulkanisch", "Tropisch", "Subpolar"][type_id]
        var ecology: String = ["Spärlich", "Keine Oberfläche", "Karg", "Ozeanisch", "Trocken", "Steril", "Artenreich", "Tundra"][type_id]
        var pressure := clampi(int(planet["resources"]) * 8 + (20 if type_id in [4, 5] else 0), 0, 100)
        planet["climate"] = climate
        planet["ecology"] = ecology
        planet["environmental_pressure"] = pressure
        planet["terraformable"] = type_id in [0, 2, 3, 4, 6, 7] and not bool(planet["habitable"])
    return system

static func _roman(n: int) -> String:
    return ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX"][clampi(n - 1, 0, 8)]
