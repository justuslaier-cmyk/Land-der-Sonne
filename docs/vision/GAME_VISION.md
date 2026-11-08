# Land der Sonne — active vision (2026-11-08)

**ACTIVE GENRE:** 2D pixel-art galactic grand strategy / 4X / narrative read-and-click empire simulation.

The original fantasy open-world RPG vision has been superseded by user decision on 2026-11-08. Its previous contents remain recoverable through Git history. Do not implement fantasy RPG gameplay under the active project without a new explicit decision.

## Authoritative new design
- [Complete galaxy game vision](GALACTIC_GAME_VISION.md)
- [Main menu, New Game, Load Game, galaxy settings and empire creator](../design/FRONTEND_AND_NEW_GAME_FLOW.md)
- [ADR-001: genre pivot, migration, preservation](../decisions/ADR-001-GENRE-PIVOT.md)

## Fixed requirements
All three play styles coexist: interactive galactic map, deep administration and illustrated event/decision panels. Procedural seed-based galaxies with configurable AI empires; species/empire creation with portrait, traits, government and ship style; causal events, independent AI, diplomacy, war, trade and evolving history. Polished launch menu and New Game/Load Game flow are foundational.

## Evidence boundary
These are **approved requirements, not implemented functionality**. Existing Godot terrain/movement foundation may be reused only where technically compatible; do not claim the old prototype implements a galaxy simulator.
