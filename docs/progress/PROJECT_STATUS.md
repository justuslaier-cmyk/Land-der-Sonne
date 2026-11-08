# Project status — 2026-11-08 — galactic pivot

## Current phase
Design migration and architecture review for a new 2D pixel-art galactic grand strategy game. User approved replacing the former fantasy RPG concept. This file supersedes the earlier outdated phase-0 status.

## Verified in this design branch
- User requirements documented in docs/vision/GALACTIC_GAME_VISION.md.
- Main menu, Load Game, New Game, detailed galaxy settings, species/empire creator and initial playable loop specified in docs/design/FRONTEND_AND_NEW_GAME_FLOW.md.
- Migration safety and old concept preservation documented in docs/decisions/ADR-001-GENRE-PIVOT.md.
- Previous fantasy concept remains in Git history; no existing code or foundation files intentionally deleted.

## Existing foundation (from earlier handoff; must be reverified)
Godot 4.3 experimental terrain/movement prototype, deterministic chunk helpers, JSON save prototype, tests and CI/export were reported. These are **not** evidence that any new galaxy game mechanics exist.

## Not implemented or verified
New main menu, new/load flow, galaxy setup, empire creator, galactic map, AI empires, galactic simulation, event cards, actual new-game pixel-art assets, save/load for galaxy data, new CI or Windows launch.

## Immediate next steps
1. Verify current main branch and CI, inventory reusable foundation.
2. Create migration architecture/contracts without silently breaking old prototype tests.
3. Implement launch menu, settings and New/Load navigation with actual Godot rendering and tests.
4. Implement wizard, empire creator and seeded small galaxy.
5. Build the first end-to-end playable slice with AI, causal events and save/load.
6. Review screenshots, export and native Windows launch; update evidence per commit.

## Safety
Never touch Grenzmark. Do not delete legacy content before inventory and preservation. Keep changes in feature branches/PRs; distinguish plans from implemented and tested work.
