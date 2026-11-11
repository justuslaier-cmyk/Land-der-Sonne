# Grafik-Pass: Übergabe an Stabilisierung und Integration

Stand: 2026-11-11. Branch: `design/galactic-grand-strategy-pivot`.

## Eingebunden
- 8 Planetensprites, 4 Schiffssprites, 5 Speziesporträts, 4 Sternsprites, 1 Stationssprite und 8 Domänen-Icons (je zwei Varianten im Atlas).
- Zehn thematische Szenenillustrationen für Hauptmenü und die wesentlichen Verwaltungs-/Ereignisansichten.
- Galaxiekarte: Sternsprites und dezenter Nebelhintergrund; Systemansicht: Planeten- und Stationssprites; Reichserstellung: Porträt- und Schiffsauswahl.
- UI: abgestimmte Navy/Türkis/Bernstein-Palette, Fokus/Hover-Styles, scrollbar gemachte Aktionsleiste, reduzierte Mindestbreiten, passende Funktionsicons.
- Neue visuelle Funktionen müssen gemäß `docs/AI_DEVELOPMENT_RULES.md` im selben Entwicklungsschritt ein eigenständiges integriertes Asset erhalten.

## Stabilisierungsgates
1. GitHub Actions `Godot foundation checks`: `galaxy_art_resources_test.gd` und `galaxy_art_ui_smoke_test.gd` müssen grün sein.
2. Godot 4.3 Import-/Parserfehler beseitigen, wenn CI rot ist.
3. Tatsächliche Screenshots von Menü, Reichserstellung, Galaxiekarte, Sternensystem und Forschung bei 1280×720 aufnehmen; Asset-Cropping und Fokus prüfen.
4. UI-Regressionsfälle: Zoom, Drag, Sternauswahl, Laden/Speichern, Spielstart, Events, Navigation, Toolbar-Scroll und Fenstergrößen.
5. Wenn die Baseline stabil ist, die vorherige Integrations-/Stabilisierungsarbeit fortsetzen; verbleibende zusätzliche Detailillustrationen und Animationen als visuelle Qualitätsverbesserungen behandeln, nicht als Beweis für technische Abnahme.

## Wahrheitsgemäßer Status
Der Code und die Text-/SVG-Ressourcen sind committed. Beim Schreiben dieser Notiz wurde **kein** erfolgreicher Godot-Run oder visueller Screenshot bestätigt. Die neuen Grafiken sind originale einfache Pixel-Art-Motive und nicht vollständig auf der Detailstufe der Referenzbilder. Die technische Freigabe zur Stabilisierung ist deshalb **bedingt**, bis CI und Renderprüfung abgeschlossen sind. Keine der 98 Produktanforderungen allein hierdurch als vollständig abgenommen markieren.
