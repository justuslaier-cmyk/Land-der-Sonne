# Paket 3 – Durchlauf 2: Onboarding und Darstellungskomfort

**Stand:** 2026-11-12 · **Branch:** `design/galactic-grand-strategy-pivot`
**Status:** CI BESTANDEN – native manuelle Windows-Sichtprüfung/Erstspielerbeobachtung offen.
**Pflichten:** P01, P02, P05, P08, P09, P81, P85, P86, P88, P90; keine P01–P98-Pflicht allein dadurch abgenommen.

## Verbindliche Erkenntnis aus den vorherigen Chats

Ein Paketdurchlauf umfasst immer die vollständige Definition of Done, nicht einzelne Verbesserungen, Tests oder einen Statusbericht. Erst Repository/Regeln/Plan/Abhängigkeiten lesen, dann integriert implementieren, bestehende Regressionen beheben, echte CI/Render/Windows-Nachweise abwarten und einen konsolidierten Abschluss dokumentieren. Die in `docs/AI_DEVELOPMENT_RULES.md` festgelegte Pflicht zur erneuten Preflight-Lektüre vor **jedem** Entwicklungsbefehl bleibt maßgeblich. Dieser Hinweis ist dauerhaft im Repository abgelegt, nicht bloß eine Chat-Zusage.

## Gesamtsichtung und relevante Ausgangslage

- Rekursiver Branch-Baum: 236 Einträge vor diesem Durchlauf; Galaxie-UI ~106 KB, UI-Komponenten, Wizard-/Tutorial-/Help-/Save-/Automation-/Accessibility-/Render-Tests sowie CI-Workflow vorhanden.
- Hauptmenü, dreistufiger Spielassistent, vierstufiges Tutorial, vier manuelle Save-Slots, 1×/2×/4×/8×-Simulation und KI-Auto-Erkundung bereits implementiert. Keine unnötigen Duplikate dieser Systeme.
- Vorherige Komfortoptionen bestanden nur aus einem nicht persistenten Fenster/Vollbild-Umschalter. Das Optionen-Menü war nicht aus der Galaxie erreichbar. Keine Lautstärke-/Mute- oder Skalierungseinstellungen.
- Speicherslots boten für leere Slots anklickbare Ladeaktionen ohne aussagekräftige Metadaten. Erstspielhinweise waren nicht in die Galaxie eingebettet. Render-Matrix deckte Optionen, Tutorial und Slots nicht ab.

## Integrierte Umsetzung

1. `game/scripts/galaxy/galaxy_comfort.gd`: gekapselte, normalisierte und getrennt von Savegames persistierte Anzeige-/Audioeinstellungen (`ConfigFile`, `user://galaxy_preferences.cfg`), UI-Skalierung 80–150 %, Master-Lautstärke 0–100 %, Mute, Fenster/Vollbild.
2. `game/scripts/galaxy/galaxy_ui.gd`: zugängliche Slider, Checkbox, Reset und kontextgerechtes Zurück; Optionen auch aus laufender Galaxie. Kontextueller erster Hinweis in der Galaxie, ausblendbar; Simulationstempo, Pause, F1, Wizard, Tutorial und Auto-Erkundung bleiben auf vorhandenen Pfaden erreichbar. Leere Slots sind nicht mehr als gültige Ladeaktionen präsentiert; belegte Slots zeigen Reich, Jahr und Seed.
3. `game/assets/art/ui_comfort_panel.svg`: eigens für diese Einstellungsansicht erstelltes Original-SVG in Navy/Petrol/Cyan/Violett/Amber, als `TextureRect` tatsächlich eingebunden.
4. `game/tests/galaxy_comfort_flow_test.gd`: importiertes Artwork, Präferenzpersistenz, Einstellungsnavigation, Tutorial, Erstspielpfad, Save-Slots und KI-Automation getestet.
5. `game/tests/render_capture.gd`: echte Godot-Renderaufnahmen auch für Optionen, Tutorial und Save-Slots in 1280×720 und 1920×1080.
6. `.github/workflows/godot-ci.yml`: Komfort-/Erstspielerregression in Godot-Smoke-Job integriert.

## Reproduzierte Regression und Behebung

- Commit `3322219917a9cd31197a98efa062832c6804dd8b`: `galaxy_test.gd` schlug fehl, weil eine Änderung den bisherigen automatischen Echtzeitstart der Simulation pausierte. Die bestehenden Startvertragsregeln haben Vorrang; nach Analyse des Joblogs wurde das Startverhalten im Fixcommit `5d1810c91fd96342a35c49ec98109bfa19662f4c` wiederhergestellt. Der Erstspielhinweis bleibt erhalten.
- Erfolgreicher vollständiger CI-Lauf auf Fixcommit: https://github.com/justuslaier-cmyk/Land-der-Sonne/actions/runs/43254097513. Weitere Wiederholung: https://github.com/justuslaier-cmyk/Land-der-Sonne/actions/runs/43254110480 (Status vor finaler Dokumentation gesondert prüfen).

## Tests und Abnahmegrenzen

- Godot 4.3: `godot --headless --path game --editor --quit`, `timeout 90s godot --headless --path game --script res://tests/galaxy_comfort_flow_test.gd`, bestehende Smoke-/Regressionsmatrix.
- Render-Matrix: `game/tests/render_capture.gd` auf zwei Zielauflösungen, echte Godot-Renderdateien als CI-Artefakte; keine Behauptung manueller Bildprüfung.
- CI beinhaltet Windows-Export und Windows-Runtime-Headless-Smoke. Native Windows-10/11-Bedienung mit sichtbarer GUI, visuelle Bewertung der tatsächlichen Pixelqualität, tatsächlicher Audio-Höreindruck und unabhängiger Erstspieler-Test sind **nicht** erfolgt und bleiben einmalig als offene externe Abnahmen dokumentiert.
- Die automatisierte First-Play-Navigation ist getestet, aber eine reale menschliche Erstspielerbeobachtung wird nicht vorgetäuscht.
- **Technische Entscheidung: CI BESTANDEN; vollständige manuelle Produktabnahme weiterhin OFFEN.** Gemäß Entwicklungsregeln darf dieser externe Gate die unabhängige Arbeit an Paket 4 nicht dauerhaft blockieren.
