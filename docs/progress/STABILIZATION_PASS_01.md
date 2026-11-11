# Stabilisierung — Durchlauf 1: CI-Basis und Fehlerdiagnose

Datum: 2026-11-11. Branch: `design/galactic-grand-strategy-pivot`.

## Untersucht
- GitHub Actions Lauf 43102471343: alle 13 Jobs abgeschlossen mit `cancelled`, keine Artefakte. Daraus lässt sich **kein** Godot-Fehler und kein erfolgreicher Test ableiten.
- Lauf 43102538900: alle 13 Jobs bei Abfrage `queued`, ebenfalls keine Artefakte.
- Workflow `.github/workflows/godot-ci.yml`: `concurrency.group=godot-foundation-${{ github.ref }}`, bisher `cancel-in-progress: true`. Bei aufeinanderfolgenden Commits wird die laufende Prüfung abgebrochen, bevor vollständige Testergebnisse vorliegen.
- Bestehende CI prüft Import, mehrere Dutzend Godot-Smoke-/Systemtests, 10 isolierte Regressionen, Screenshot-Capture und Windows-x64-Export.
- Lokale Ausführung: keine Godot-Binary installiert; GitHub-Netzzugriff im Container schlägt mit DNS-Fehler fehl. Kein lokaler Testnachweis.

## Implementierter Fix
- `cancel-in-progress: false` in der Workflow-Concurrency. Damit werden bereits gestartete Läufe bei weiteren Pushes nicht mehr automatisch abgebrochen. Die Einschränkung durch begrenzte Runner-Verfügbarkeit bleibt bestehen.
- Commit: `c1b16d60717a2d20c1220c339606b2bd3b2a51db`.

## Blocker und Abnahmekriterien
- **Durchlauf 1 ist nicht abgenommen**, bis der neueste CI-Lauf erfolgreich beendet wurde. Weder Godot-Parser-/Importfehler noch Laufzeitfehler können ohne Logs seriös als behoben gelten.
- Falls der neue Lauf weiterhin `queued` bleibt: GitHub Actions Runner-/Account-Kontingent, Workflow-Berechtigungen, Queue-Status und eventuelle Repository-/Organisationsbeschränkungen prüfen.
- Sobald Runner laufen: Fehlerlogs pro Job sichern; Parser-/Importfehler zuerst, danach System-/Regressionstests, Rendering, Windows-Export.
- Erst nach grünem Gesamtworkflow zu Durchlauf 2 (Integration der Spielsysteme) übergehen.

## Verifikation
Nur GitHub-Codeprüfung und Commit nachgewiesen. Kein erfolgreicher Godot-Lauf, kein exportiertes Windows-Artefakt, keine aktualisierte Anforderungsabnahme.
