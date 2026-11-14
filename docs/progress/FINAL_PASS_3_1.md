# Paket 3 – Durchlauf 1: Informationsarchitektur und Bedienbarkeit

**Stand:** 2026-11-12 · **Branch:** `design/galactic-grand-strategy-pivot`
**Status:** CI BESTANDEN – manuelle Windows-GUI-Sichtabnahme offen; keine finale Abnahme.
**Betroffene Pflichten:** P05, P06, P09, P81, P85, P86, P90, P91; keine P01–P98-Häkchen ohne Einzelbeleg.

## Scope und tatsächliche Änderungen

- `game/scripts/galaxy/galaxy_ui_components.gd`: wiederverwendbare fokussierbare Aktionsschaltflächen, einheitliche Icon-/Tooltip-Konventionen, fog-of-war-sichere Systemsuche und Filterkomponente für Berichtstexte.
- `game/scripts/galaxy/galaxy_ui.gd`: Aktionsschaltflächen aus Hauptmenü/Berichten, Werkzeugleiste und Systeminspektor auf gemeinsame Komponente umgestellt. Kartografierte Systeme über Strg+F und Enter suchen; unbekannte Systeme werden nicht offengelegt. Esc kehrt aus Unteransichten zur Galaxie zurück, ohne aus einer offenen Ereignisentscheidung auszubrechen. Gesellschafts-, Wirtschafts- und Chronikbericht erhalten einheitliche Textfilter.
- `game/tests/galaxy_ui_architecture_test.gd`: Regression für Systemsuche, unbekannte Suchtreffer, gemeinsamen Button, Tooltip, Tastaturfokus, Escape-Navigation und Berichtfilter.
- `.github/workflows/godot-ci.yml`: neuer Regressionstest im Godot-Smoke-Job.
- Vorhandene Simulations- und Save-Verträge wurden nicht verändert; keine neuen Hauptmechaniken.

## Reproduzierte Fehler und Korrekturen

- Erster Implementierungscommit `fafc83c96bb84dbd3308c8b72ba0b67ff780ca0b`: CI fehlgeschlagen wegen GDScript-Typinferenz im neuen Test (`var previous := ui.selected`). Ursache anhand echter Joblogs bestimmt.
- Fixcommit `5de797582a42256e76c39e2cf50d67be0fed0bb9`: explizite Typannotation; zwei vollständige CI-Läufe erfolgreich (`43252475042`, `43252485930`).
- Erweiterungscommit `0606a7c0cb94d608e0921fb84bf60b450b72effc`: gemeinsame Berichtfilter und Regression. Zwei CI-Läufe erfolgreich: `43252781324`, `43252794777`.

## Tatsächliche Testbelege

- Godot 4.3: `godot --headless --path game --editor --quit`.
- `timeout 90s godot --headless --path game --script res://tests/galaxy_ui_architecture_test.gd` im Smoke-Job erfolgreich.
- Gesamte Workflow-Matrix einschließlich Render-Check, Godot-Smoke, Regression-Matrix, Windows-Export und Windows-Runtime-Smoke für Commit `0606a7c0`: zwei vollständige erfolgreiche Runs.
- https://github.com/justuslaier-cmyk/Land-der-Sonne/actions/runs/43252781324
- https://github.com/justuslaier-cmyk/Land-der-Sonne/actions/runs/43252794777

## Abnahme und offene Grenzen

- Die neuen Such-/Filter- und Tastaturpfade sind automatisiert geprüft; die bisherige Navigations- und Spielmechaniktestmatrix blieb grün.
- Eine vollständige manuelle Sichtprüfung aller Ansichten, Bedienbarkeit bei Windows-Zielauflösungen und realer Erstspielertest wurden hier nicht durchgeführt. Headless-Render- und Windows-Runtime-Smoke sind keine manuelle GUI-Abnahme.
- Die zentrale `galaxy_ui.gd` enthält weiterhin viele domänenspezifische Ansichten; die gemeinsame Interaktionsschicht ist ausgelagert, aber keine vollständige Trennung aller Domänenansichten erfolgt. Umfassende Tooltips zu allen konkreten Voraussetzungen und Aktionskosten sind noch nicht für jede Einzelaktion belegt.
- **Entscheidung: CI BESTANDEN; finale Abnahme NICHT BESTANDEN**, bis alle Kriterien einschließlich manueller Evidenz und vollständiger Informationsarchitektur nachgewiesen sind.
