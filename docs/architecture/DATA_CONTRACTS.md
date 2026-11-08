# Initial data contracts

## World state v1
JSON object with integer `version`, integer `seed`, nonnegative integer `tick`, and dictionary `flags` mapping nonempty string IDs to booleans.

This is a prototype contract, not a final production save schema. Future contracts need stable entity IDs, migrations, backups, checksums, chunk deltas and explicit failure recovery.

## Coordinates
Terrain coordinates use signed Vector2i cells. Chunks are 64x64 cells, with floor division for negative positions and positive local coordinates in [0, 63].

## Determinism
The same seed and coordinates must produce the same terrain classification. A stable terrain function is not sufficient to establish deterministic NPC simulation or cross-platform save reproducibility.

## Separation
WorldState and Terrain must remain independent of rendered scenes. Scene scripts may reference these modules; the world simulation must not depend on scene nodes.
