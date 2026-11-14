# Paket 2 – Durchlauf 3: Ereignisketten, Krisen und Endspiel

**Status: CI BESTANDEN – manuelle Windows-GUI-Sichtabnahme offen.**

## Verbindlicher Umfang
Vier bestehende narrative Ereignisfamilien: verzögerte Folgeentscheidungen mit realen Kosten, Risiko und Save/Load. Zwei vorhandene Krisen: unterschiedliche militärische und forschungsbasierte Lösungen, echte Forschungsstufen und Ressourcenkosten. Drei vorhandene Endspielwege: Erkundung, Prosperität und Krisenresilienz; Sandbox bleibt spielbar.

## Integrierte Dateien
`game/scripts/galaxy/galaxy_narrative.gd`, `galaxy_endgame.gd`, `galaxy_progress.gd`, `galaxy_ui.gd`; Originalgrafik `game/assets/art/chronicle_aftermath.svg` (48x48, eigenständig erzeugte Pixelrasterformen, Navy/Petrol/Cyan/Violett/Amber); UI-Chronik, SVG-Ressourcentest und Godot-CI. Kein neues Hauptsystem oder neue Ereignisfamilie.

## Akzeptanz
`godot --headless --path game --script res://tests/galaxy_package_2_3_test.gd` prüft Folgeentscheidung, Doppelbuchung, Save/Load, wissenschaftlichen Spaltungs- und militärischen Alten-Krisenpfad, Endspiel-Speicherung. Ergänzend vorhandene Kampagnen-, Krisen-, UI-, Import- und Renderregressionen. Manuelle Windows-GUI-Prüfung gesondert offen. Kein P01–P98-Häkchen ohne Einzelabnahme.

## CI
**Zwei vollständige GitHub-Actions-Läufe erfolgreich für den integrierten Code-Commit `0ffe41e58cb844a28a0af1fa837f31c7adf370dc`:** [43246974757](https://github.com/justuslaier-cmyk/Land-der-Sonne/actions/runs/43246974757) und [43246989227](https://github.com/justuslaier-cmyk/Land-der-Sonne/actions/runs/43246989227), beide `success`. Godot-Smoke einschließlich Paket-2.3-Szenarien, vollständige Regression-Matrix, Render-Check und Windows-Export/Headless-Lauf sind grün.\n\n**Korrigierte Regressionen:** Ein untypisierter lokaler Testwert verursachte einen Godot-4.3-Parserfehler (Fix `8c0e4915`). Eine erste Sperre für offene Ereignisfolgen verletzte die vorhandene Wiederholungs-/Cooldown-Regel; Fix `0ffe41e5` erhält offene Folgeentscheidungen, ohne reguläre Ereignis-Cooldowns zu blockieren.\n\n**Manuelle Abnahme:** Interaktive Windows-GUI-Spielpartie und Sichtprüfung der Chronik-Illustration weiterhin offen. Diese nicht verfügbaren Prüfungen sind ausdrücklich keine bestandenen manuellen Abnahmen; unabhängige weitere Paketarbeit bleibt möglich.
