extends RefCounted
class_name GalaxyIdentity

# Distinct identity axes: government, two civic institutions, cultural ethics
# and biological traits. IDs and icon glyphs are stable save-game data.
const CIVICS := [
    {"id": "guilds", "name": "Freie Sternengilden", "icon": "◆", "description": "Private Betriebe investieren schneller; ungleiche Einkommen belasten den Zusammenhalt."},
    {"id": "commons", "name": "Gemeinschaftliche Versorgung", "icon": "✚", "description": "Öffentliche Versorgung stärkt Zufriedenheit, benötigt aber Ressourcen."},
    {"id": "archives", "name": "Offene Wissensarchive", "icon": "✧", "description": "Forschung und Bildung stehen im Mittelpunkt."},
    {"id": "frontier", "name": "Grenzland-Charta", "icon": "⬡", "description": "Neue Kolonien wachsen schneller, ihre Versorgung bleibt anspruchsvoll."},
    {"id": "guardians", "name": "Hüter der Ordnung", "icon": "⛨", "description": "Stabile Institutionen stärken die Regierung, begrenzen jedoch individuelle Freiheit."},
    {"id": "ecology", "name": "Symbiotische Ökologie", "icon": "❀", "description": "Genügsame Lebensweise reduziert Verbrauch und Ressourcenverschwendung."}
]
const TRAITS := [
    {"id": "strong", "name": "Kraftvoll", "icon": "✦", "cost": 1, "description": "Mehr körperliche Produktion."},
    {"id": "curious", "name": "Wissbegierig", "icon": "✧", "cost": 2, "description": "Mehr wissenschaftliche Erträge."},
    {"id": "fertile", "name": "Fruchtbar", "icon": "❋", "cost": 2, "description": "Höhere natürliche Geburtenrate."},
    {"id": "solitary", "name": "Einzelgänger", "icon": "◈", "cost": -1, "description": "Weniger soziale Nähe, geringere Bevölkerungsdichte."},
    {"id": "resilient", "name": "Widerstandsfähig", "icon": "⬢", "cost": 1, "description": "Robust gegenüber Versorgungskrisen."},
    {"id": "voracious", "name": "Unersättlich", "icon": "◉", "cost": -1, "description": "Erhöhter Verbrauch von Konsumgütern."},
    {"id": "cooperative", "name": "Kooperativ", "icon": "❖", "cost": 1, "description": "Stärkere soziale Zufriedenheit."},
    {"id": "slow_breeding", "name": "Langsame Generationen", "icon": "☾", "cost": -1, "description": "Langsameres Bevölkerungswachstum."}
]
const ETHICS := [
    {"id": "pluralist", "name": "Pluralismus", "icon": "◈"},
    {"id": "collectivist", "name": "Gemeinsinn", "icon": "❖"},
    {"id": "mercantile", "name": "Handelsfreiheit", "icon": "◆"},
    {"id": "traditionalist", "name": "Traditionsbewusstsein", "icon": "⬡"}
]
const GOVERNMENTS := ["Republik", "Monarchie", "Technokratie", "Kollektiv"]

static func civic(id: String) -> Dictionary:
    for item in CIVICS:
        if item["id"] == id:
            return item
    return {}

static func trait_info(id: String) -> Dictionary:
    for item in TRAITS:
        if item["id"] == id:
            return item
    return {}

static func validate(empire: Dictionary) -> String:
    var civics: Array = empire.get("civics", ["archives", "commons"])
    var traits: Array = empire.get("traits", ["curious"])
    if civics.size() != 2 or civics[0] == civics[1]:
        return "Wähle zwei unterschiedliche Staatsprinzipien."
    for id in civics:
        if civic(str(id)).is_empty():
            return "Unbekanntes Staatsprinzip."
    if traits.size() > 4:
        return "Höchstens vier Speziesmerkmale möglich."
    var points := 0
    var seen: Array = []
    for id in traits:
        if seen.has(id) or trait_info(str(id)).is_empty():
            return "Ungültige oder doppelte Speziesmerkmale."
        seen.append(id)
        points += int(trait_info(str(id))["cost"])
    if points > 3 or points < -3:
        return "Speziesmerkmale überschreiten das Genetikbudget."
    if traits.has("fertile") and traits.has("slow_breeding"):
        return "Fruchtbar und langsame Generationen schließen sich aus."
    if int(empire.get("government", 0)) < 0 or int(empire.get("government", 0)) >= GOVERNMENTS.size():
        return "Ungültige Regierungsform."
    var ethic := str(empire.get("ethic", "pluralist"))
    var found := false
    for item in ETHICS:
        if item["id"] == ethic:
            found = true
    if not found:
        return "Unbekannte gesellschaftliche Grundhaltung."
    return ""

static func has_civic(empire: Dictionary, id: String) -> bool:
    return empire.get("civics", ["archives", "commons"]).has(id)

static func has_trait(empire: Dictionary, id: String) -> bool:
    return empire.get("traits", ["curious"]).has(id)

static func modifiers(empire: Dictionary) -> Dictionary:
    var result := {"production": 0, "science": 0, "growth": 0, "needs": 0, "satisfaction": 0, "capital": 0, "legitimacy": 0}
    if has_trait(empire, "strong"):
        result["production"] += 2
    if has_trait(empire, "curious"):
        result["science"] += 2
    if has_trait(empire, "fertile"):
        result["growth"] += 1
    if has_trait(empire, "slow_breeding"):
        result["growth"] -= 1
    if has_trait(empire, "solitary"):
        result["satisfaction"] -= 2
    if has_trait(empire, "cooperative"):
        result["satisfaction"] += 3
    if has_trait(empire, "resilient"):
        result["satisfaction"] += 2
    if has_trait(empire, "voracious"):
        result["needs"] += 2
    if has_civic(empire, "guilds"):
        result["capital"] += 3
        result["satisfaction"] -= 1
    if has_civic(empire, "commons"):
        result["satisfaction"] += 3
        result["needs"] -= 1
    if has_civic(empire, "archives"):
        result["science"] += 2
    if has_civic(empire, "frontier"):
        result["growth"] += 1
        result["needs"] += 1
    if has_civic(empire, "guardians"):
        result["legitimacy"] += 2
        result["satisfaction"] -= 1
    if has_civic(empire, "ecology"):
        result["needs"] -= 2
    match int(empire.get("government", 0)):
        0:
            result["satisfaction"] += 1
        1:
            result["legitimacy"] += 2
        2:
            result["science"] += 2
            result["satisfaction"] -= 1
        3:
            result["needs"] -= 1
            result["capital"] -= 1
    match str(empire.get("ethic", "pluralist")):
        "pluralist":
            result["satisfaction"] += 1
        "collectivist":
            result["needs"] -= 1
        "mercantile":
            result["capital"] += 2
        "traditionalist":
            result["legitimacy"] += 1
    return result

# Persistent culture tracks are distinct from immutable biological traits.
# A slow-moving cohort of traditions changes through lived conditions.
static func culture_defaults(empire: Dictionary) -> Dictionary:
    var ethic := str(empire.get("ethic", "pluralist"))
    return {"tradition": 55 if ethic == "traditionalist" else 35,
        "openness": 60 if ethic == "pluralist" else 45,
        "solidarity": 60 if ethic == "collectivist" else 45,
        "commercialism": 60 if ethic == "mercantile" else 40,
        "generation": 0, "history": []}

static func culture_tick(culture: Dictionary, empire: Dictionary, prosperity: int, satisfaction: int, year: int) -> void:
    var ethic := str(empire.get("ethic", "pluralist"))
    var change := 1 if satisfaction >= 65 else -1 if satisfaction < 35 else 0
    culture["solidarity"] = clampi(int(culture.get("solidarity", 45)) + change, 0, 100)
    culture["commercialism"] = clampi(int(culture.get("commercialism", 40)) + (1 if prosperity >= 65 else -1 if prosperity < 30 else 0), 0, 100)
    culture["openness"] = clampi(int(culture.get("openness", 45)) + (1 if ethic == "pluralist" and satisfaction >= 50 else -1 if satisfaction < 30 else 0), 0, 100)
    culture["tradition"] = clampi(int(culture.get("tradition", 35)) + (1 if ethic == "traditionalist" else -1 if int(culture.get("openness", 45)) >= 75 else 0), 0, 100)
    if year > 0 and year % 20 == 0:
        culture["generation"] = int(culture.get("generation", 0)) + 1
        var memory: Array = culture.get("history", [])
        memory.append({"year": year, "generation": int(culture["generation"]), "tradition": int(culture["tradition"]), "openness": int(culture["openness"]), "solidarity": int(culture["solidarity"]), "commercialism": int(culture["commercialism"])})
        if memory.size() > 8:
            memory.pop_front()
        culture["history"] = memory

static func assign_rival_identities(world: Dictionary) -> void:
    for rival in world["ai"]:
        if rival.has("civics") and rival.has("traits") and rival.has("ethic") and rival.has("government"):
            continue
        var id := int(rival["id"])
        rival["government"] = id % GOVERNMENTS.size()
        rival["ethic"] = str(ETHICS[id % ETHICS.size()]["id"])
        rival["civics"] = [str(CIVICS[id % CIVICS.size()]["id"]), str(CIVICS[(id + 2) % CIVICS.size()]["id"])]
        rival["traits"] = [str(TRAITS[id % TRAITS.size()]["id"])]
