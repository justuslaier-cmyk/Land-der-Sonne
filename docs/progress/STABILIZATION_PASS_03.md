# Stabilisierung — Durchlauf 3: Renderprüfung, Eingabe und Langzeitstabilität

Stand: 2026-11-11. Branch: `design/galactic-grand-strategy-pivot`.

## Implementiert
- `game/tests/render_capture.gd` rendert in Godot die Ansichten menu, settings, empire, review, galaxy, research, economy, diplomacy und fleet_command bei 1280×720 sowie 1920×1080. Insgesamt 18 PNGs; feste Weltgenerierung mit Seed 21015 und zwei KI-Reichen. Die Simulation wird während der Galerieaufnahmen pausiert.
- CI `render-check` startet Xvfb mit 1920×1080, veröffentlicht alle `render-*.png` als `godot-render-evidence`.
- Neuer `game/tests/galaxy_ui_interaction_regression_test.gd` prüft Map-Wheel-Zoom, Zoom-Rückkehr, rechte Maustaste/Kameradrag, Drag-Ende, Pause und 4×-Geschwindigkeit. Der Test ist in der Regression-Matrix.
- Bereits vorhandener `galaxy_ai_soak_test.gd` prüft 120 Jahre deterministischen KI-Replay inklusive JSON-Checkpoint alle 30 Jahre, Bevölkerungs-/Legitimitätsgrenzen und bounded decision log. Dieser Test bleibt aktiv.

## Abnahme
**Implementiert, aber nicht erfolgreich ausgeführt oder visuell freigegeben.** GitHub Actions Run 43103425442 war bei Abfrage `pending`; keine erfolgreichen Godot-Tests oder tatsächlichen Screenshots konnten bestätigt werden. Die neuen Screenshots sind erst nach erfolgreichem Workflow als Artefakt verfügbar. Ihre tatsächliche Qualität muss dann geprüft werden.

## Nötige Nacharbeit nach CI-Start
1. Parser-/Runtimefehler anhand echter CI-Logs beheben.
2. Screenshots aller 18 Ansichten visuell auf Überlauf, abgeschnittene Bedienelemente, Kontrast und Grafikimport prüfen.
3. Inputtest und 120-Jahre-KI-Test müssen grün sein; bei Fehlern Ursache korrigieren und erneut ausführen.
4. Erst danach Durchlauf 4 Windows-Build und Freigabe.

## Ergänzung 2026-11-12
- Zusätzlicher UI-Regressionstest `game/tests/galaxy_map_interaction_test.gd` committed (`31c83429`), in CI-Matrix eingebunden (`886fdbef`). Er ergänzt die bestehende UI-Regression um Sternauswahl und Forschungsnavigation.
- `game/tests/render_capture.gd` validiert nun exakt die Bilddimensionen und dass 18 Screenshots aufgenommen werden (`74576b03`).
- Diese Änderungen sind noch nicht mit einer erfolgreichen Godot-Ausführung belegt; CI-Queue/Runner weiterhin Abnahmeblocker.
