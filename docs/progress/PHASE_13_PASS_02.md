# Phase 13 / Durchlauf 2 — Ereignisketten

## Code
- `game/scripts/galaxy_story_chains.gd`: persistente, verzweigte Kette „Das Echo der Ersten“; Zustandsfelder `story_chains` und `story_journal`; Verzögerungen, Optionen, Kosten und Abschluss.
- `game/tests/galaxy_story_chains_test.gd`: Godot-Regressionstest als Script (noch nicht ausgeführt / nicht in CI registriert).
- Die Kette kann nach `GalaxyEventEngine.apply(..., "study")` explizit mit `GalaxyStoryChains.begin(...)` begonnen werden; **noch keine automatische Verdrahtung**.

## Nachweisgrenzen
- GitHub-Commits sind Code-Nachweise, keine Test- oder Spielbarkeitsnachweise.
- Weder Godot-Parser noch Testscript noch CI wurden hier ausgeführt. Keine GUI, keine Bildintegration, keine automatische Tick-Anbindung.
- JSON-Roundtrip wird im Testscript abgedeckt, aber noch nicht ausgeführt; echtes Spielstand-Laden und Migrationspfad nicht verifiziert.
- P07, P65–P70, P87–P91 bleiben offen. Keine Pflicht abhaken.
- Für den nächsten Integrationsschritt die tatsächlich vorhandenen Szenen und Simulationseinstiegspunkte anhand des Repository-Baums ermitteln, dann Eventqueue und UI anschließen, Tests in Workflow aufnehmen und CI auswerten.
