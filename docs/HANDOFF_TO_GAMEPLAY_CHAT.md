# Handoff to the game-development chat

## Scope separation
This repository's foundation phase owns CI, engine configuration, architecture boundaries, save contracts, test harnesses, build tooling, reproducibility, security and project governance.

The future **game-development chat** owns creative vision, art direction, graphics/assets, game mechanics, lore, quests, NPC behavior, combat, UX and gameplay implementation. It must follow the binding repository rules and quality gates.

## Mandatory session startup
1. Inspect the actual GitHub repository and branch; do not assume the chat's memory is current.
2. Read `docs/AI_DEVELOPMENT_RULES.md`, `docs/vision/GAME_VISION.md`, `docs/progress/PROJECT_STATUS.md`, this handoff, `docs/architecture/ARCHITECTURE.md`, `docs/architecture/DATA_CONTRACTS.md` and `docs/quality/QUALITY_PLAN.md`.
3. Check latest CI status, open pull requests and branch head.
4. Define a vertical-slice goal, acceptance tests and visual acceptance criteria before coding.
5. Work on a new feature branch and PR. Do not edit `main` directly.

## Baseline (as of 2026-11-08)
- Godot 4.3 experimental foundation under `game/`.
- Top-down debug scene with movement and one persistent world flag.
- Seeded terrain and signed 64x64 chunk-coordinate helpers.
- Versioned JSON world state and backup-based recovery prototype.
- GitHub Actions: import, smoke/world/input tests, rendered screenshot artifact, Windows x86_64 export artifact.
- CI run 42482503307 passed all three jobs for commit faf7c96d. A Windows machine launch has **not** been verified.
- Foundation pull request #1 remains separate from `main` until merged.

## First creative-development task
Propose an original, visually coherent top-down forest clearing vertical slice. Do not confuse the current circles and color blocks with production art. Establish an art reference and rendering acceptance gate, then implement the first slice with tests and genuine screenshots.

## Required reporting
For each batch: changed paths, branch/commit, executed test commands, CI links, downloadable artifacts, visual evidence, defects, limitations and next priorities. Distinguish planned from implemented and implemented from verified.

## Safety
Do not modify the abandoned Grenzmark repository. Do not copy protected game assets or code from reference games. Never assert that an experimental export is a finished playable release.
