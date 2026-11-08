# Quality plan v0.1

## Test layers
Static checks; unit tests; integration tests; property-based deterministic generation tests; save/load roundtrips; simulation invariants; navigation and dungeon solvability; automated gameplay interactions; actual-render screenshot regression; performance benchmarks; export and startup smoke tests.

## Release gate
A release candidate must have: defined acceptance criteria, successful mandatory tests, a bootable exported build, verified key interactions, visual evidence from real rendering, no unresolved critical defects, and a versioned test report. Otherwise label it experimental or unverified.

## First acceptance criteria
1. Engine launches without import or parse errors.
2. Same seed and input produce same specified map and event outputs.
3. Player can move, collide and interact in a rendered top-down area.
4. A changed world object remains changed after save/reload.
5. A scripted automated test executes the interaction and verifies resulting state.
6. Screenshots are produced by the engine, not by concept-art generation.
7. A Windows build launches on the intended test environment.

## Evidence record template
Feature; commit SHA; engine/tool versions; exact command; test environment; expected result; observed result; pass/fail/unrun; screenshot/build artifact references; known limitations.

## Failure policy
Never disable or weaken a failing test solely to make CI green. Reproduce, isolate, fix, rerun and document. Treat unrun tests as unverified.
