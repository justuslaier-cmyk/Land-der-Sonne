# ADR-0001: Minimal Godot 4.3 foundation

Status: provisional experiment, not final engine decision.
Date: 2026-11-08

Use Godot 4.3 stable for the first reproducible CI experiment, with GDScript and GL Compatibility renderer. This is a pinned experimental baseline rather than a claim that 4.3 is the best current engine version. Upgrade evaluation remains required.

The initial scene intentionally uses debug primitives instead of production pixel art. Its only purpose is to establish that scripts, deterministic terrain, input and engine startup can be tested. It is not an artistic milestone, a complete world, a save system or a playable release.

Acceptance: GitHub Actions imports the project, runs deterministic smoke tests and loads the scene. Visual rendering, Windows export, actual input automation and persistence remain future gates.

If CI fails, diagnose and correct the issue before expanding the feature set.
