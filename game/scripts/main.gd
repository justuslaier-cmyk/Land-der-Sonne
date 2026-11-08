extends Node2D

const CELL_SIZE: int = 32
const GRID_WIDTH: int = 30
const GRID_HEIGHT: int = 18
const WORLD_SEED: int = 20261108
const WALK_SPEED: float = 210.0

var player_position: Vector2 = Vector2(16 * CELL_SIZE, 9 * CELL_SIZE)
var player_direction: Vector2 = Vector2.ZERO
var landmark_changed: bool = false

func _ready() -> void:
    get_window().title = "Land der Sonne - Technical Prototype"
    queue_redraw()

func _process(delta: float) -> void:
    player_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    player_position += player_direction * WALK_SPEED * delta
    player_position.x = clampf(player_position.x, 16.0, GRID_WIDTH * CELL_SIZE - 16.0)
    player_position.y = clampf(player_position.y, 16.0, GRID_HEIGHT * CELL_SIZE - 16.0)
    if Input.is_key_pressed(KEY_E) and player_position.distance_to(Vector2(15 * CELL_SIZE, 8 * CELL_SIZE)) < 70.0:
        landmark_changed = true
    queue_redraw()

func _draw() -> void:
    for y in range(GRID_HEIGHT):
        for x in range(GRID_WIDTH):
            var cell := Vector2i(x, y)
            var terrain := terrain_at(cell, WORLD_SEED)
            var tint := Color("#4f8a54") if terrain == 0 else Color("#5b985d")
            if terrain == 2:
                tint = Color("#d5b979")
            draw_rect(Rect2(Vector2(x, y) * CELL_SIZE, Vector2.ONE * CELL_SIZE), tint)
    var landmark := Vector2(15 * CELL_SIZE, 8 * CELL_SIZE)
    draw_circle(landmark, 16.0, Color("#ffcc70") if landmark_changed else Color("#6c668b"))
    draw_circle(player_position, 12.0, Color("#f4e4b7"))
    draw_circle(player_position + Vector2(0, -4), 5.0, Color("#473a35"))

static func terrain_at(cell: Vector2i, seed_value: int) -> int:
    # Stable integer hash; no mutable global random state.
    var value: int = (cell.x * 73856093) ^ (cell.y * 19349663) ^ seed_value
    value = (value ^ (value >> 13)) * 1274126177
    value = value ^ (value >> 16)
    return posmod(value, 11) % 3
