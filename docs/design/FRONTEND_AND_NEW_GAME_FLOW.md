# Frontend, setup and first-play experience — binding product requirements
Status: design, not implemented. 2026-11-08.

## First screen: Main menu (high priority)
On application launch show a polished, atmospheric, keyboard/mouse accessible pixel-art main menu with:
- **Neues Spiel** (new game)
- **Spiel laden** (load saved game; disabled with clear explanation if no saves)
- **Einstellungen** (video/window resolution/UI scaling, audio, controls, language, accessibility)
- **Beenden** (quit; safe confirmation if appropriate)
- Optional later: empire designer, credits, tutorial.
No debug scene as the default player-facing launch. Settings persist separately from saves. Provide navigation, hover/focus/pressed states and clear back behavior.

## New game wizard (revisitable steps)
Main Menu -> New Game -> Galaxy Settings -> Empire/Species Creation -> Review -> Generate Galaxy -> Galaxy Map.
Allow Back, Cancel, Reset to Defaults, tooltips, live validation and preset management. Maintain selections when navigating back. Do not silently start simulation before confirmation. Seed can be random or user-entered; show/copy the actual seed.

### Galaxy Settings
- Galaxy size (small/medium/large; exact star counts performance-gated)
- Shape (spiral, elliptical, irregular, ring where supported)
- Seed (random/manual)
- Star density and navigable connectivity
- AI empire count, empire generation style, advanced AI starts
- Fallen/ancient empires and independent factions
- Habitable planet density, planet diversity
- Resource abundance and anomaly frequency
- Hyperlane/connectivity settings or chosen travel model
- Aggressiveness, diplomacy tendency and AI difficulty
- Crisis/threat intensity, event frequency, research/economy pace
- Starting conditions, fog of war, victory conditions, optional game end
- Ironman/autosave options only after save integrity is proven
Every setting must show meaning, supported range, dependencies and effect on performance. Validate AI count vs galaxy capacity and safe starting distances. Store full settings in save metadata.

### Empire Creator
Steps: species portrait/body plan -> species name/adjective/plural and homeworld -> trait advantages/disadvantages with point budget -> ethics/culture -> government/authority/civics -> origin and starting bonuses -> empire name/flag/colors -> ship design family -> summary. Offer diverse curated presets plus customization. Allow save/load of empire templates. Warn about conflicts; never allow invalid start combinations. Ship visuals are customizable; mechanical ship loadout design may unlock in gameplay.

### Review and generation
Review seed, settings, species, government, traits and ship style. Confirm -> deterministic generator with progress and cancellation -> initial camera centered on home system -> optional contextual tutorial -> first decisions.

## In-game layout
Galaxy map as primary canvas. Top resource/status bar; left empire/navigation rail; right contextual inspector; bottom time controls, pause, notifications and event queue; accessible overlays for planets, diplomacy, fleet designer, technology, market, policies, diplomacy and history. Avoid overwhelming new players: progressive disclosure and searchable panels.

## Save/load UX
Main menu Load Game shows save slots with empire, galaxy seed, date/tick, playtime, save format version, thumbnail if supported, compatibility warning and delete confirmation. Autosave/manual save with atomic writes/backups, validation and recovery. Return to menu, pause and quit safely.

## First vertical slice acceptance tests
1. Main menu starts and all buttons navigate correctly.
2. New game wizard keeps state across Back/Next; invalid configurations cannot start.
3. Two identical seed+settings produce identical galaxy signatures.
4. Empire creator applies at least one positive and one negative trait to actual simulation.
5. Galaxy contains one player empire and configurable AI count in supported range.
6. Map displays selectable systems and an actionable exploration/colonization command.
7. A causal event is shown as illustrated text with choices and measurable state changes.
8. Save, return to menu, Load Game restores galaxy, empire, tick, choices and history.
9. Automated Godot checks, actual-render screenshots, export and native Windows launch are tracked separately.
