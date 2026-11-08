# Ownership and extension contracts

## Foundation-owned
`game/project.godot`, `game/scripts/world/world_state.gd`, `world_storage.gd`, `terrain.gd`, `game/tests/`, `game/export_presets.cfg`, `.github/workflows/`, core data schemas and developer tooling.

## Gameplay-owned
Future art assets, scenes, player mechanics, NPC behavior, combat, quests, dialogue, UI and content definitions.

## Change control
Gameplay features may call core APIs but should not silently change save formats, coordinate conventions, CI quality gates or engine versions. Changes to shared contracts require an architecture decision record, migration/test plan and review.

## Current interfaces
- `Terrain.terrain_at(cell: Vector2i, seed_value: int) -> int`
- `Terrain.chunk_for_cell(cell: Vector2i) -> Vector2i`
- `Terrain.local_cell(cell: Vector2i) -> Vector2i`
- `WorldState.new(seed: int)`, `advance(steps)`, `set_flag(id, bool)`, `has_flag(id)`
- `WorldState.to_dict()` / `WorldState.from_dict(data)`
- `WorldStorage.save_world(world, path)` / `WorldStorage.load_world(path)`

These are prototype interfaces and not a commitment to an immutable public API. Tests must be updated whenever contracts intentionally evolve.
