# Phase 14 / Durchlauf 2 — Simulationsskalierung

## Änderungen
- `GalaxyAISpatialIndex.build(world)` aggregiert jährlich in einem Sternendurchlauf Anzahl und Rohstoffsumme je rivalisierendem Eigentümer.
- `GalaxyAI.tick` erzeugt diesen Index vor den rivalisierenden Gesellschaftsaktualisierungen.
- `GalaxyAI._society_tick` verwendet den Index statt für jedes Reich die vollständige Sternenliste zu durchlaufen.
- `game/tests/galaxy_ai_scaling_test.gd` prüft Besitzerwechsel, Summen und deterministische KI-Bewertung.

## Leistungsbewertung
- Nur der bisherige Teilpfad zur Eigentümer-/Ressourcensumme sinkt von O(Reiche * Sterne) auf O(Reiche + Sterne).
- Flottenbewegung, Expansion, Konfliktsuche und weitere Systeme scannen weiterhin Sterne; eine allgemeine O(R+S)-Komplexität der KI ist NICHT gegeben.
- Keine Benchmarks, Soak-Tests oder realen Godot-Ausführungen durchgeführt. Die Regressionstests sind erstellt, aber nicht ausgeführt oder in CI registriert.

## Einschränkungen
- Die KI hat noch keine umfassend begrenzte Wahrnehmung oder nachweislich skalierte Detailstufen.
- Das neue Indexobjekt ist absichtlich transient und darf nach Eroberungen im selben Tick nicht als aktueller Besitzstand wiederverwendet werden; der Gesellschaftsteil wird vor späteren Eroberungen berechnet.
- Frühere Phase-13-Ereignisketten sind weiterhin nicht an den zentralen Tick und die UI angeschlossen.
- P73–P79, P87–P91 und P93 bleiben offen. 0/98 vollständig abgenommen.

## Nächste Schritte
- CI-Workflow und Godot-Tests anschließen, Godot-Parser/Smoke und Rendering ausführen.
- Laufzeitmessungen für verschiedene Stern- und Reichszahlen, einschließlich Langzeit-Simulation.
- Weitere Vollscans gezielt ersetzen, ohne deterministische Regeln zu verändern.
- KI-Wahrnehmung, Entscheidungsprotokoll und operative Budgets getrennt integrieren.
