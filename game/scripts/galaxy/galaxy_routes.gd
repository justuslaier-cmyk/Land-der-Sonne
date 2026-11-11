extends RefCounted
class_name GalaxyRoutes

# Deterministic Prim minimum spanning tree. Lanes describe geographic
# connectivity only; fleet movement still uses its existing direct range.
static func build(stars: Array) -> Array:
    var count := stars.size()
    var lanes: Array = []
    if count < 2:
        return lanes
    var visited: Array = []
    var nearest: Array = []
    var parent: Array = []
    for i in range(count):
        visited.append(false)
        nearest.append(INF)
        parent.append(-1)
    nearest[0] = 0.0
    for step in range(count):
        var current := -1
        var best := INF
        for i in range(count):
            if not bool(visited[i]) and float(nearest[i]) < best:
                best = float(nearest[i])
                current = i
        if current < 0:
            break
        visited[current] = true
        if int(parent[current]) >= 0:
            lanes.append([int(parent[current]), current])
        var origin := Vector2(float(stars[current]["x"]), float(stars[current]["y"]))
        for candidate in range(count):
            if bool(visited[candidate]):
                continue
            var destination := Vector2(float(stars[candidate]["x"]), float(stars[candidate]["y"]))
            var separation := origin.distance_squared_to(destination)
            if separation < float(nearest[candidate]):
                nearest[candidate] = separation
                parent[candidate] = current
    return lanes

static func valid(stars: Array, lanes: Array) -> bool:
    if stars.is_empty():
        return lanes.is_empty()
    if lanes.size() != stars.size() - 1:
        return false
    var connected: Array = [0]
    var seen: Dictionary = {0: true}
    while not connected.is_empty():
        var current := int(connected.pop_front())
        for lane in lanes:
            if typeof(lane) != TYPE_ARRAY or lane.size() != 2:
                return false
            var a := int(lane[0])
            var b := int(lane[1])
            if a < 0 or b < 0 or a >= stars.size() or b >= stars.size() or a == b:
                return false
            var next := b if a == current else (a if b == current else -1)
            if next >= 0 and not seen.has(next):
                seen[next] = true
                connected.append(next)
    return seen.size() == stars.size()
