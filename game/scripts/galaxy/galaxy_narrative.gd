extends RefCounted
class_name GalaxyNarrative

# Deterministic, data-driven event definitions. Only actual world-state
# predicates can trigger an incident. Effects are applied exactly once.
const EVENTS := [
    {"id": "trade_relay", "title": "Handelsrelais ausgefallen", "condition": "freight", "cooldown": 12, "chance": 5,
        "effect": "credits", "delta": -8, "cause": "Überlastete interstellare Frachtwege"},
    {"id": "academic_breakthrough", "title": "Wissenschaftliches Symposium", "condition": "research", "cooldown": 15, "chance": 6,
        "effect": "science", "delta": 10, "cause": "Aktive wissenschaftliche Austauschprogramme"},
    {"id": "civilian_reform", "title": "Bürgerinitiative", "condition": "society", "cooldown": 10, "chance": 7,
        "effect": "stability", "delta": 4, "cause": "Gesellschaftlicher Reformdruck"},
    {"id": "border_incident", "title": "Grenzkonflikt", "condition": "war", "cooldown": 9, "chance": 8,
        "effect": "credits", "delta": -6, "cause": "Andauernde interstellare Kriegshandlungen"}
]

static func prepare(world: Dictionary) -> void:
    if not world.has("narrative_cooldowns"):
        world["narrative_cooldowns"] = {}
    if not world.has("narrative_chronicle"):
        world["narrative_chronicle"] = []
    if not world.has("narrative_chains"):
        world["narrative_chains"] = {}
    if not world.has("narrative_decisions"):
        world["narrative_decisions"] = []

static func eligible(world: Dictionary, event: Dictionary) -> bool:
    match str(event["condition"]):
        "freight":
            return world.get("civilian_freight_transit", []).size() > 0
        "research":
            return int(world.get("research_exchange_ledger", {}).get("science_granted", 0)) > 0
        "society":
            return int(world.get("civilian_approval", 65)) < 45
        "war":
            return world.get("wars", []).size() > 0
    return false

static func apply(world: Dictionary, event: Dictionary) -> bool:
    prepare(world)
    var key := str(event["id"])
    var year := int(world["tick"])
    if not eligible(world, event):
        return false
    if year < int(world["narrative_cooldowns"].get(key, -10000)):
        return false
    var field := str(event["effect"])
    var before := int(world.get(field, 0))
    var after := maxi(0, before + int(event["delta"]))
    if field == "stability":
        after = mini(100, after)
    world[field] = after
    world["narrative_cooldowns"][key] = year + int(event["cooldown"])
    var entry := {"year": year, "id": key, "title": str(event["title"]),
        "cause": str(event["cause"]), "effect": "%s %d → %d" % [field, before, after]}
    world["narrative_chronicle"].append(entry)
    if world["narrative_chronicle"].size() > 100:
        world["narrative_chronicle"].pop_front()
    world["history"].append("%s: %s (%s)." % [entry["title"], entry["cause"], entry["effect"]])
    # Follow-up chains are persistent and can influence subsequent incidents.
    world["narrative_chains"][key] = {"origin": year, "last_effect": after, "stage": "awaiting", "ready": year + 2, "resolved": false}
    return true

static func tick(world: Dictionary) -> void:
    prepare(world)
    var year := int(world["tick"])
    var seed := int(world.get("settings", {}).get("seed", 1))
    for event in EVENTS:
        if not eligible(world, event):
            continue
        var key := str(event["id"])
        if year < int(world["narrative_cooldowns"].get(key, -10000)):
            continue
        var roll := posmod(seed * 31 + year * 73 + int(key.hash()), 100)
        if roll < int(event["chance"]):
            apply(world, event)

# Two-year delayed decisions for the four existing incident families.
static func pending_followups(world: Dictionary) -> Array:
    prepare(world)
    var result: Array = []
    for key in world["narrative_chains"].keys():
        var chain: Dictionary = world["narrative_chains"][key]
        if bool(chain.get("resolved", false)) or str(chain.get("stage", "")) != "awaiting":
            continue
        if int(world.get("tick", 0)) >= int(chain.get("ready", 999999)):
            result.append(str(key))
    result.sort()
    return result

static func resolve_followup(world: Dictionary, key: String, option: String) -> bool:
    prepare(world)
    if not pending_followups(world).has(key) or not ["invest", "adapt"].has(option):
        return false
    var chain: Dictionary = world["narrative_chains"][key]
    var cost := 20 if option == "invest" else 0
    if int(world.get("credits", 0)) < cost:
        return false
    world["credits"] = int(world["credits"]) - cost
    var field := "science" if key == "academic_breakthrough" else "stability"
    var change := 8 if option == "invest" else -3
    if key == "trade_relay" or key == "border_incident":
        field = "credits"
        change = 12 if option == "invest" else -5
    world[field] = maxi(0, int(world.get(field, 0)) + change)
    if field == "stability":
        world[field] = mini(100, int(world[field]))
    chain["resolved"] = true
    chain["stage"] = option
    world["narrative_decisions"].append({"id": key, "year": int(world["tick"]), "choice": option, "cost": cost, "field": field, "delta": change})
    world["history"].append("Nachwirkung %s: %s; %s %+d." % [key, option, field, change])
    return true
