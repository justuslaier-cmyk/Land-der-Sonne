# Land der Sonne — Galactic Grand Strategy Vision v1.0
Date: 2026-11-08. Status: user-approved genre pivot, design specification; not implemented.

## Non-negotiable identity
Land der Sonne is now a **single-player-first, 2D pixel-art space grand strategy / 4X / narrative decision simulation**. Each new save creates a seeded procedural galaxy. The player designs a species and empire; rival AI empires have independent histories and ambitions. There is no fixed main story: causal events, player decisions and AI actions create emergent history. Preserve the name Land der Sonne pending any explicit future renaming. The old fantasy RPG vision is superseded, **not deleted**; Git history retains it.

## Three complementary play modes (ALL required)
1. **Interactive galactic map:** inspect systems, survey, colonize, explore, expand borders, command fleets, plan routes, declare wars and manage diplomacy.
2. **Deep administration:** empire, planets, populations, production, logistics, trade, research, ship designs, laws, factions, governments, policies, warfare and diplomacy through readable menus and dashboards.
3. **Illustrated read-and-click events:** narrative cards with pixel-art illustrations, contextual text, multiple meaningful choices, prerequisites, costs, risks, state effects, follow-ups and historical records. Events do not replace the map or management layer.

## Galaxy generation
Seeded deterministic generation with selectable size, shape, star density, AI empire count, difficulty, habitable-world frequency, resources, anomalies, ancient civilizations, starting distance, hostile threats and victory/endgame settings. Galaxy generation must guarantee valid starts and navigable routes. Each generated galaxy is reproducible from seed + generation rules version; record settings and generation version in save.

## Empire and species creation
Preset portraits assembled from licensed/original coherent pixel-art components. Select species archetype, appearance, names, homeworld, flag, colors, ship visual family, ship naming convention, ethics, traits with point-budget benefits/penalties, civics, government, authority, starting technologies and origins. Selections have real mechanical consequences; validate incompatible combinations; show clear modifiers and summaries. Save and reuse custom empire templates.

## Core simulation
Discrete deterministic ticks, speed control and pause. AI empires pursue economic, diplomatic, military and internal political goals with distinct preferences and constraints. Systems include exploration, colonization, population and demographics, happiness/stability, resources, production, interstellar logistics, market/trade, research, ship construction and fleet operations, diplomacy/treaties, espionage (later), combat, laws, factions, unrest, secession, federations and crises. Start small, add depth by tested vertical slices.

## Event engine
Three sources: (a) authored canonical event chains, (b) procedural event templates with contextual slots and conditions, (c) state-triggered systemic incidents caused by simulation/player/AI actions. Each event has stable ID, localization key, deterministic trigger rules, priority, cooldown, options, eligibility, effect contracts, history entry and tests. Event frequency is user-configurable; never imply pure random selection is causality. Narrative outcomes must correspond to actual game state.

## Differentiation
Causal galactic history; rich internal politics and cultural divergence; distinct AI civilizations; trade dependencies and supply networks; multiple viable paths (science, diplomacy, commerce, conquest, federation, isolation); visible and inspectable causes for major events. No copyrighted Stellaris/Distant Worlds assets, lore or code.

## Visual direction
Original high-detail **2D top-down pixel art**: atmospheric starfields, nebulae, stellar bodies, readable borders and fleet symbols, beautiful illustrated event cards, distinctive species portraits, ship silhouettes and UI. Cohesive palette, lighting, scale, typography, iconography, transitions and accessibility. Produce and inspect real Godot screenshots before bulk art production. Reference pictures in chat are mood references, not production assets.

## Quality and scope
Do not confuse long-term goals with implemented content. Build a vertical slice with main menu -> new game -> setup -> empire creator -> galaxy generation -> playable map -> one AI -> a causal event -> save/load. A passing CI build alone does not establish a Windows-tested playable release.
