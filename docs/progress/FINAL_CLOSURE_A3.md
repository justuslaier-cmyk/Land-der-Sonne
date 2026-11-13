# A3 – Produktqualität: Arbeitsstand nach Spieler-Video (13.11.2026)

**Entscheidung: NICHT BESTANDEN.** Dies ist ein Arbeitsnachweis, keine abgeschlossene A3-Abgabe.

## Tatsächliche Spielerbeobachtung

Der Nutzer stellte einen rund siebenminütigen nativen Windows-Spieltest als Video zur Verfügung und beanstandete Grafik, Übersichtlichkeit, Spielerführung, Sinnhaftigkeit und Komplexität. Die Videobeobachtung ist ein manueller Produktbefund, **kein** vollständiger Langzeitspieltest und kein Performance-Benchmark.

- Speziesporträts wurden im Test weiß angezeigt; die ursprüngliche Darstellung verwendete importierte SVG-Texturen.
- Die Galaxieansicht zeigte eine horizontal scrollende Aktionsleiste mit mehr als zwanzig Aktionen.
- Die Systemauswahl schrieb umfangreiche Chronik- und Ereignistexte in den globalen Seiten-Root statt in ein begrenztes Kontextfenster.
- Informationen über Kosten, Konsequenzen und sinnvolle nächste Schritte sind weiterhin nicht hinreichend vermittelt.

## Implementierter, noch nicht abgenommener Korrektursatz

Commit `9215c557eaf636efaec60dfe6e804e5f4515d84a` auf `design/galactic-grand-strategy-pivot`, Datei `game/scripts/galaxy/galaxy_ui.gd`:

1. Horizontale Endlos-Aktionsleiste durch feste Kommandogruppen (Erkundung, Reich, Außenpolitik, Chronik, Spiel) mit Popup-Menüs ersetzt. Pausieren und Geschwindigkeit bleiben direkt erreichbar.
2. Seitenbereich der Sternsysteme mit eigenem ScrollContainer ausgestattet.
3. Unbegrenzte Chronik- und Ereignislisten aus dem Galaxie-Root entfernt; Verweis auf den vorhandenen Chronikbildschirm bleibt erhalten.
4. Speziesporträts werden nun durch den bereits vorhandenen prozeduralen Godot-Zeichenpfad dargestellt, statt auf potentiell weiß gerenderte SVG-Imports zu vertrauen.

**Evidenzgrenze:** GitHub-Änderung ist erfolgt. Kein Godot-Engine-Lauf und kein erfolgreicher CI-Run für diesen Commit nachgewiesen; keine neuen Windows-Screenshots, Hörtests, FPS-/RAM-/VRAM-Messungen oder vollständigen menschlichen Spielpartien. Die Korrekturen sind daher ausdrücklich **nicht visuell abgenommen**.

## Noch notwendige A3-Arbeiten

- Vollständige Neugestaltung der Galaxiekarte und visuellen Informationshierarchie, konsistente Original-Pixel-Art und Asset-Import-/Screenshotregression.
- Verständliche Ursache-Wirkungs-Anzeigen für Wirtschaft, Forschung, Politik, Diplomatie, Militär und Kolonien; testbares Onboarding und Tastatur-/Skalierungsabnahme.
- Audio, Animationen, Kontrast, Bedienbarkeit und reale Fenstergrößen überprüfen.
- CI für den aktuellen Commit erfolgreich ausführen und neue Windows-Testversion bereitstellen.
- 250-Sterne-/20-KI-Spiel mit aktivem Spieler auf definierter Windows-Hardware messen; FPS/RSS/VRAM protokollieren.
- Vollständige menschliche Windows-10/11-Spielpartien inklusive Save/Resume dokumentieren und alle kritischen Befunde beseitigen.

Keine P01–P98-Pflicht wurde allein durch diesen Code-Commit als abgenommen markiert. A3 bleibt offen; A4 ist nicht freigegeben.
