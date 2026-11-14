extends RefCounted
class_name GalaxyContracts

# Read-only structural validation. Never mutate or silently repair a save.
# A validated world is not yet proof of balanced gameplay or resource conservation.
static func errors(world: Dictionary) -> Array:
    var problems: Array = []
    for key in ["version", "settings", "empire", "stars", "ai", "tick", "credits", "science", "history"]:
        if not world.has(key):
            problems.append("Missing world field: " + key)
    if not problems.is_empty():
        return problems
    if int(world["version"]) != GalaxyModel.VERSION:
        problems.append("Unsupported world version")
    if int(world["tick"]) < 0:
        problems.append("Negative simulation tick")
    if typeof(world["stars"]) != TYPE_ARRAY or world["stars"].is_empty():
        problems.append("Missing star systems")
        return problems
    var owners: Array = [0]
    for rival in world["ai"]:
        var id := int(rival.get("id", -1))
        if id <= 0 or owners.has(id):
            problems.append("Invalid or duplicate empire ID")
        else:
            owners.append(id)
    for i in range(world["stars"].size()):
        var star: Dictionary = world["stars"][i]
        if int(star.get("id", -1)) != i:
            problems.append("Unstable star ID at index " + str(i))
        var owner := int(star.get("owner", -2))
        if owner != -1 and not owners.has(owner):
            problems.append("Unknown star owner at " + str(i))
    for key in world.get("civilian_worlds", {}).keys():
        var id := int(key)
        if id < 0 or id >= world["stars"].size() or str(id) != str(key):
            problems.append("Invalid civilian market key: " + str(key))
            continue
        var market: Dictionary = world["civilian_worlds"][key]
        for field in ["population", "capacity", "jobs", "goods", "private_capital", "taxes"]:
            if int(market.get(field, -1)) < 0:
                problems.append("Negative or missing civilian field: " + str(key) + "." + field)
        if int(market.get("population", 0)) > int(market.get("capacity", 0)):
            problems.append("Civilian population exceeds capacity: " + str(key))
    for shipment in world.get("civilian_trade", []):
        var source := int(shipment.get("from", -1))
        var target := int(shipment.get("to", -1))
        if source < 0 or source >= world["stars"].size() or target < 0 or target >= world["stars"].size() or int(shipment.get("goods", 0)) <= 0:
            problems.append("Invalid civilian freight movement")
    return problems
