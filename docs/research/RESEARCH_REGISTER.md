# Research register

Status: initial hypotheses; no completed benchmark or exhaustive source review.

| Topic | Current hypothesis | Required evidence |
|---|---|---|
| Engine | Godot 4.x is a strong top-down 2D candidate | Version-specific rendering/export tests; comparison against Unity and Bevy |
| Language | GDScript for gameplay; optimized extensions if profiling requires | Benchmark representative simulation workloads |
| Unit testing | Evaluate GdUnit4 | Confirm compatibility, license, CI and input simulation |
| Visual tests | Real Godot screenshots plus regression comparison | Build screenshot capture and threshold-based review |
| Procedural generation | Seeded deterministic chunks | Boundary, navigation and reproducibility tests |
| NPC scaling | Near/region/far simulation tiers | Profile 100, 1,000 and 10,000 simulated NPCs at different fidelity |
| Pixel-art production | Original modular tiles and sprites | Art-style benchmark, animation and tile-seam validation |
| Knowledge | Git-versioned decisions and registries | Validate session handoff and change tracking |

## Research requirements
Each completed investigation needs a date, exact source URLs, license review where applicable, method, limitations, recommendation and decision status. Prefer primary documentation and actual prototype results. Never convert hypotheses into facts without evidence.
