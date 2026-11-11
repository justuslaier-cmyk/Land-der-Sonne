# Phase 14 / Durchlauf 3 — KI-Erklärbarkeit und Soak-Test

## Implementiert
- `game/scripts/galaxy/galaxy_ai.gd`: jedes strategische Planungsintervall protokolliert Reich, Jahr, Strategie, Score-Tabelle und Entscheidungsgründe.
- Das persistente Feld `ai_decision_log` wird auf maximal 240 Einträge begrenzt.
- `game/tests/galaxy_ai_soak_test.gd`: 120-Jahres-Replay mit zwei identisch generierten Galaxien, JSON-Zustandsvergleich je Tick, Bevölkerungs-/Legitimitätsgrenzen und Journal-Invarianten.

## Verifikation — explizite Grenzen
- Das neue Testscript wurde **nicht** in Godot ausgeführt. Keine Aussage zu Parsererfolg, Performance, deterministischem Bestehen oder CI-Erfolg.
- Der Test wurde **nicht** in den bestehenden CI-Workflow eingebunden.
- Ein 120-Jahre-Replay mit 80 Sternen/3 KI-Reichen ist keine skalierte 250-Sterne-Performance-Messung.
- Keine visuelle Darstellung des Entscheidungsjournals; bisher nur persistierte Daten.
- Die älteren Phase-13-Skripte bleiben ohne nachgewiesenen Anschluss an die laufende Simulation.
- Es wurde kein automatisierter FPS-/Frame-Time-Benchmark ausgeführt.
- P73–P79, P87–P91, P93, P96 bleiben offen; 0/98 Anforderungen vollständig abgenommen.

## Qualitätsschritte für die nächste Phase / Integrationsschuld
1. Godot-Tests der Phasen 13–14 im tatsächlichen Projekt ausführen, Parserfehler und Testfehlschläge beheben, CI registrieren.
2. Save-/Load-Verträge für neue narrative und KI-Felder validieren.
3. Entscheidungsjournal in der UI sichtbar machen, bei unzureichendem Wissen nur erlaubte Informationen offenlegen.
4. 80/150/250-Sterne-Soak- und Laufzeitprofile auf echter Engine messen.
5. Ereignis- und Story-Director mit dem zentralen Tick und Entscheidungs-UI verbinden.
