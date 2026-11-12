# Land der Sonne

**Active project:** 2D pixel-art single-player galactic grand strategy / 4X game, built with Godot 4.3 and GDScript.

The earlier fantasy RPG concept was superseded on 2026-11-08. The active development branch is `design/galactic-grand-strategy-pivot`.

## Current status (2026-11-12)

**Experimental Windows x64 prototype; not a finished or balanced game.**

- A seed-based galaxy, empire setup, strategic map, AI turns, research, economy, diplomacy, fleets, events, and JSON persistence have working prototype implementations.
- GitHub Actions run Godot smoke tests, 13 isolated regressions, a real-engine render capture, a Windows x64 export, and a headless Windows-2022 startup/integration check.
- [Verified CI run 43214501265](https://github.com/justuslaier-cmyk/Land-der-Sonne/actions/runs/43214501265) passed all 17 jobs, including native Windows headless startup and gameplay integration.
- This does **not** establish full Windows 10/11 interactive playability, long-form balancing, complete production-quality content, or acceptance of the full game specification.
- The [binding 98-requirement register](docs/vision/BINDING_GAME_REQUIREMENTS_CHECKLIST.md) remains the authority for full-game completion. A passing CI run must not be counted as blanket acceptance of those requirements.

## Development and evidence

- [Binding development rules](docs/AI_DEVELOPMENT_RULES.md)
- [Active vision](docs/vision/GAME_VISION.md)
- [Detailed galactic vision](docs/vision/GALACTIC_GAME_VISION.md)
- [Binding requirements checklist](docs/vision/BINDING_GAME_REQUIREMENTS_CHECKLIST.md)
- [Project status](docs/progress/PROJECT_STATUS.md)
- [Architecture](docs/architecture/ARCHITECTURE.md)
- [Quality plan](docs/quality/QUALITY_PLAN.md)
- [Research register](docs/research/RESEARCH_REGISTER.md)

## Running the experimental build

Download `LandDerSonne-Windows-experimental` from the successful GitHub Actions run, extract the downloaded artifact and its contained `LandDerSonne-Windows-x64.zip`, then keep `LandDerSonne.exe` beside `LandDerSonne.pck`. Windows Defender and unsigned-binary warnings may apply; no code-signing claim is made.

## Scope and rights

All 98 requirements must be assessed individually with real integration evidence. Do not import files or assets from the separate Grenzmark project without explicit approval and licensing review.
