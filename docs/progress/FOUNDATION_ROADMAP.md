# Foundation roadmap

## Phase A — verified
- Repository bootstrap and binding AI development rules.
- Godot 4.3 experimental baseline.
- Headless CI project import, smoke test and startup.
- Deterministic cell classification and signed chunk coordinates.
- Versioned world flags and save/load test.

## Phase B — in progress
- Backup-based save recovery with corruption test.
- CI resource usage reduction.
- Reliable build artifacts and platform startup verification.
- Automated input playback and visible screenshot capture.
- Asset licenses, art-style test and visual acceptance criteria.

## Phase C — after foundations
- Real tilemap and collision.
- Persistent chunk deltas.
- NPC agent simulation, economy and event bus.
- First coherent original art assets and animated protagonist.
- One integrated playable vertical slice.

## Hard rules
Do not claim the game is finished because CI passes. Do not generate mass content before the vertical slice is visually and interactively verified. Avoid uncontrolled GitHub Actions fan-out. No changes to Grenzmark.
