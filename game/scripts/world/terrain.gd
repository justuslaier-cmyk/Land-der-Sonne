extends RefCounted
class_name Terrain

const CHUNK_WIDTH: int = 64

static func terrain_at(cell: Vector2i, seed_value: int) -> int:
    var value: int = (cell.x * 73856093) ^ (cell.y * 19349663) ^ seed_value
    value = (value ^ (value >> 13)) * 1274126177
    value = value ^ (value >> 16)
    return posmod(value, 11) % 3

static func chunk_for_cell(cell: Vector2i) -> Vector2i:
    return Vector2i(floori(float(cell.x) / CHUNK_WIDTH), floori(float(cell.y) / CHUNK_WIDTH))

static func local_cell(cell: Vector2i) -> Vector2i:
    return Vector2i(posmod(cell.x, CHUNK_WIDTH), posmod(cell.y, CHUNK_WIDTH))
