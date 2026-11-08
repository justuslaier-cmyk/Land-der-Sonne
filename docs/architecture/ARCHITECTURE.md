# Technical architecture v0.1 — proposed, not implemented

## Candidate stack
Godot 4.x with GDScript for 2D rendering and gameplay. Evaluate C# or GDExtension for measured hot paths only. Python may be used for offline tools. Engine and dependency versions require a reproducible proof-of-concept before being pinned.

## Boundaries
1. **Simulation core**: deterministic world state transitions, agents, economy, ecosystems and events; avoid scene-tree dependence.
2. **World generator**: seeded terrain, climate, biomes, locations and dungeons; reconstruct unchanged regions.
3. **Persistence**: versioned world state and deltas, stable entity identifiers, migration and corruption recovery.
4. **Presentation**: Godot rendering, animation, UI, player controls and camera; instantiate only nearby entities.
5. **Content data**: schema-validated definitions of items, professions, creatures, quests, abilities and assets.
6. **Tooling**: generation, static validation, automated playtests, screenshots, profiling and builds.

## Scaling principles
Chunk streaming; spatial indexes; near/region/far simulation tiers; time budgets and profiling. Do not equate theoretical world coordinates with loaded tiles or measured capacity.

## First technical proofs
- Boot and export a minimal project on Windows.
- Generate and reload a deterministic test region with one persistent change.
- Render a coherent top-down pixel-art scene and capture reproducible screenshots.
- Run automated movement/interactions and report measurable frame times.

## Decision policy
Architecture is provisional until supported by benchmark, reproducibility and maintainability evidence. Record changes in dated architecture decision records.
