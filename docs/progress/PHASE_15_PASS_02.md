# Phase 15 / Durchlauf 2 — Ereigniskarten / UI

## Code
- `game/scripts/galaxy/galaxy_ui.gd`: Die vorhandene Ereignisansicht zeigt nun einen gerahmten Kopfbereich mit Jahr, Kategorie und Entscheidungshinweis. Die Kategorie ist für archäologische Ereignisse, politische Krisen, Kolonien, Märkte und sonstige Entdeckungen definiert.
- Der Kopfbereich verwendet die Farb- und StyleBox-Tokens aus `GalaxyVisualTheme`.
- Die vorhandene prozedurale Ereignisillustration und die bisherigen Entscheidungsbuttons bleiben erhalten; die Ereigniswirkung wurde nicht geändert.
- `game/tests/galaxy_event_card_test.gd`: Regressionstest für die Kategoriezuordnung erstellt.

## Abnahmegrenzen
- Keine neu produzierten oder eingebundenen Pixel-Art-Dateien; bestehende `_draw_illustration`-Routine ist programmatisch erzeugte Grafik, keine externe Bilddatei.
- Keine neuen Soundeffekte oder Musik integriert; Lizenz- und Lautstärkekonzept noch offen.
- Keine Integration des separaten Phase-13-Narrative-Directors. Die vorhandene `pending_event`-UI wird weiter genutzt.
- Kein Godot-Test oder Rendering in dieser Sitzung ausgeführt; keine CI-Registrierung und kein Windows-Nachweis.
- Textumbruch, Tastaturbedienung und Lesbarkeit auf kleinen Auflösungen noch nicht visuell geprüft.
- P06, P07, P80–P86, P95 sowie P87–P91 bleiben offen. 0/98 vollständig abgenommen.

## Nächste Schritte
1. Tatsächliche Godot-Renderaufnahme und UI-Prüfung bei mehreren Auflösungen.
2. Lizenzsichere Pixel-Art-Assets, einheitliche Icons, Panels und visuelle Zustände erstellen und einbinden.
3. Audio-Bus, Lautstärkeregler und originale/lizenzierte Audioressourcen.
4. Narrative-Director-Integration und CI-Testausführung nachholen.
