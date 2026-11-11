extends RefCounted
class_name GalaxyAISpatialIndex

# Transient annual summary, not persisted: ownership changes during the tick.
# Build exactly once before AI societal updates, never cache across years.
static func build(world: Dictionary) -> Dictionary:
    var index: Dictionary = {}
    for star in world.get("stars", []):
        var owner: int = int(star.get("owner", -1))
        if owner <= 0:
            continue
        var key: String = str(owner)
        if not index.has(key):
            index[key] = {"count": 0, "resources": 0}
        var summary: Dictionary = index[key]
        summary["count"] = int(summary["count"]) + 1
        summary["resources"] = int(summary["resources"]) + int(star.get("resource", 0))
    return index
