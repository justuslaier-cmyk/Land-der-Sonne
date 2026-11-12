# Paket 2 – Durchlauf 3: Ereignisketten, Krisen und Endspiel

**Status: IN ARBEIT – CI-Nachweis ausstehend.**

## Verbindlicher Umfang
Vier bestehende narrative Ereignisfamilien: verzögerte Folgeentscheidungen mit realen Kosten, Risiko und Save/Load. Zwei vorhandene Krisen: unterschiedliche militärische und forschungsbasierte Lösungen, echte Forschungsstufen und Ressourcenkosten. Drei vorhandene Endspielwege: Erkundung, Prosperität und Krisenresilienz; Sandbox bleibt spielbar.

## Integrierte Dateien
`game/scripts/galaxy/galaxy_narrative.gd`, `galaxy_endgame.gd`, `galaxy_progress.gd`, `galaxy_ui.gd`; Originalgrafik `game/assets/art/chronicle_aftermath.svg` (48x48, eigenständig erzeugte Pixelrasterformen, Navy/Petrol/Cyan/Violett/Amber); UI-Chronik, SVG-Ressourcentest und Godot-CI. Kein neues Hauptsystem oder neue Ereignisfamilie.

## Akzeptanz
`godot --headless --path game --script res://tests/galaxy_package_2_3_test.gd` prüft Folgeentscheidung, Doppelbuchung, Save/Load, wissenschaftlichen Spaltungs- und militärischen Alten-Krisenpfad, Endspiel-Speicherung. Ergänzend vorhandene Kampagnen-, Krisen-, UI-, Import- und Renderregressionen. Manuelle Windows-GUI-Prüfung gesondert offen. Kein P01–P98-Häkchen ohne Einzelabnahme.

## CI
Ausstehend. Keine Abnahme ohne vollständig erfolgreiches Workflow-Ergebnis.
