# ADR-001 — Pivot from fantasy RPG to galactic grand strategy
Date: 2026-11-08
Decision: Approved by user; implementation pending.

## Context
The earlier Land der Sonne vision targeted a walkable fantasy RPG with extensive character animation, landscape assets and per-NPC simulation. User explicitly requests replacing the active game concept with a procedural galactic empire simulator while preserving visual ambition and systemic depth.

## Decision
Use a 2D pixel-art space strategy framework combining all three interfaces: direct interactive 4X galaxy map, deep click-driven administration, and richly illustrated text events/decisions. Procedural seeded galaxies, customizable species/empires, configurable AI opponents and comprehensive new-game settings are core. **Main menu and new game/load game flows are first-priority features**, not deferred polish.

## Rationale
Less world-scale animation, collision and handcrafted terrain burden; supports early playable strategic loops. Strategic AI, balance, UI and systemic causality remain hard; no claim of automatic speedup magnitude.

## Migration and preservation
- Keep existing Git history, original fantasy vision and foundation documents; mark previous vision superseded rather than erase it.
- Preserve Godot foundation where reusable (determinism, saves, CI, tests); inventory and assess incompatible terrain/player scenes before changing or deleting anything.
- Do not change the abandoned Grenzmark repository.
- Existing 64x64 terrain chunk contracts are **legacy prototype contracts**, not galactic coordinates. Introduce new galaxy/system identifiers and versioned saves; never reinterpret old save data silently.
- First implement on a feature branch, review via PR; avoid destructive changes to main until validated.
- Update README, GAME_VISION, PROJECT_STATUS and other contracts when the pivot implementation is integrated; distinguish planning from code.

## Technical outline
Godot 4.x version pinned to verified project; GDScript for UI and initial simulation. Separate deterministic galaxy generation, domain simulation, AI, event rule engine, persistence and presentation. Seeded PRNG streams by subsystem, tick scheduling, stable entity IDs, versioned schemas, profiling and testable contracts. Headless sim must not depend on scene tree. Scale AI via abstraction and budgets, not always-on individual actors.

## Implementation stages
0. Verify current branch, CI, engine and foundation; archive design baseline via Git history.
1. Main menu, settings and robust New/Load flow.
2. Wizard and empire editor with presets, validation and preview.
3. Deterministic small galaxy and selectable interactive map.
4. Economy, time control, first AI opponent and meaningful exploration.
5. Event/decision cards, state changes and history.
6. Save/load roundtrip, screenshot evidence, Windows export and native launch.
7. Expand diplomacy, trade, warfare, internal politics, AI and art through measured milestones.

## Open questions
Travel model (hyperlanes/free movement), exact time granularity, initial combat abstraction, UI reference resolution, localization priority, minimum hardware and game-end conditions. Defaults may be prototyped; record decisions before locking them.
