# Phase 16 / Durchlauf 2 — CI-Fehleranalyse und isolierte Regressionstests

## Gesicherter Befund
- Workflow-Lauf `43099177950` aus Durchlauf 1 meldete beim Abruf alle drei Jobs `queued` (`godot-smoke`, `render-check`, `windows-export`).
- Daher keine belastbaren Godot-Fehlerlogs, keine bestandenen Tests, keine Windows- oder Renderartefakte.
- Lokale Godot-Ausführung nicht möglich: keine Godot-Binary; GitHub-Klon wegen DNS-Auflösungsfehler nicht verfügbar.

## Umsetzung
- `.github/workflows/godot-ci.yml`: Acht Phase-13–15-Tests aus dem sequenziellen `godot-smoke`-Job in eine separate `regression-matrix` verschoben.
- `strategy.fail-fast: false`: unabhängige Ergebnisse auch bei einzelnen Fehlschlägen.
- Pro Matrix-Eintrag wird Godot 4.3 installiert, das Projekt importiert und das Testskript mit 120-Sekunden-Timeout ausgeführt.
- Bestehende Godot-Smoke-, Rendering- und Windows-Export-Jobs bleiben erhalten.

## Offene Aufgaben
1. Auf die Ausführung der GitHub-Jobs warten und Logs aller fehlschlagenden Matrix-Einträge abrufen.
2. Erst nach konkreten Fehlermeldungen Parser-/Laufzeitfehler reproduzieren und korrigieren.
3. Echte Spielpartie und 120-Jahre-Simulation ausführen; Ergebnis anhand Logs dokumentieren.
4. Narrativen Director mit dem zentralen Spielablauf und UI integrieren.
5. Rendering- und Windows-Artefakte auf Korrektheit prüfen.

## Abnahme
- Kein P87–P91/P96 als vollständig abgenommen markiert.
- 0/98 Pflichtanforderungen vollständig abgenommen.
- Ein CI-Commit ist kein Nachweis für einen bestandenen Test.
