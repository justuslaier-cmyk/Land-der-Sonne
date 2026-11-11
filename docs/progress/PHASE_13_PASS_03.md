# Phase 13 / Durchlauf 3 — Narrative Director und offene Integration

## Implementiert
- `game/scripts/galaxy_narrative_director.gd`: Orchestrierung der Phase-13-Ereignisdefinitionen und Ereigniskette mit persistenter Einzelentscheidung (`narrative_pending`).
- Priorisierung fälliger Story-Etappen vor normalen Ereignissen; deterministische, seed- und tickbasierte Auswahl ohne globalen RNG.
- `resolve_choice` führt die vorhandenen Entscheidungswirkungen aus und startet nach der Signaluntersuchung die Kette `first_signal`.
- `history` führt `event_journal` und `story_journal` zu einer chronologisch sortierten Datenansicht zusammen.
- `game/tests/galaxy_narrative_director_test.gd`: Regressionstest als Script angelegt.

## Noch offen und nicht als erledigt behauptet
- Die zentrale Godot-Simulation ruft `advance` noch nicht auf; es existiert noch kein spielbarer Dialog und kein UI-Anschluss für `resolve_choice`.
- Das Testscript wurde nicht in der Engine ausgeführt und nicht in GitHub Actions registriert; kein grüner CI-Nachweis.
- Save-/Load-Vertrag und Datenmigration sind noch nicht angepasst oder end-to-end geprüft. JSON-Roundtrip ist nur im ungetesteten Script beschrieben.
- Es gibt keine implementierten Mittel- oder Endspielkrisen, Megastrukturen oder vollständigen Langzeitziele. Diese sind ausdrücklich nicht als erledigt zu zählen.
- Der Director erzeugt derzeit bei vorhandener Kandidatenmenge bei jedem Aufruf ohne ausstehende Wahl ein Ereignis. Für Produktivbetrieb ist ein Frequenz-/Scheduling-Limit nötig.
- Die aktuelle Ereignis-Engine erzeugt für die Rationierungsoption Legierungen ohne Ressourcenherkunft; für P37 ist das keine akzeptierte Wirtschaftsverbuchung.
- Ein Story-Abschluss verhindert nur das erneute Starten derselben Kette, nicht automatisch das erneute Auftreten des zugrunde liegenden Signals nach dessen Cooldown.
- Pflicht-IDs P07, P65–P72 und P87–P91 bleiben offen.

## Nächste verbindliche Qualitätsschritte
1. Existierende zentrale Tick-/UI-Dateien anhand der tatsächlichen Repositorystruktur ermitteln.
2. Ereignisfrequenz, Wirtschaftsledger und Save-Schema korrigieren.
3. Neue Tests in vorhandenen Godot-CI-Workflow einhängen und Ergebnisse abwarten.
4. Spielbare Ereigniskarten, Krisen und Langzeitprojekte als getrennte integrierte Slices entwickeln.
