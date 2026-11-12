# Paket 1 – Durchlauf 2: End-to-End und Speicherintegrität

**Status:** CI BESTANDEN – manuelle End-to-End-Abnahme weiterhin OFFEN.

## Nachweise und Änderungen

- CI für den vorausgegangenen Parser-Fix `3874ed5` zweimal vollständig erfolgreich: [43235367182](https://github.com/justuslaier-cmyk/Land-der-Sonne/actions/runs/43235367182), [43235381142](https://github.com/justuslaier-cmyk/Land-der-Sonne/actions/runs/43235381142).
- `GalaxyModel._read` verwendet die nicht-mutierende `GalaxyContracts.errors`-Prüfung, um parsebare, aber inkonsistente Spielstände zurückzuweisen.
- `galaxy_save_integrity_regression_test.gd` prüft unbekannte Sternbesitzer, doppelte Reichs-IDs und negative Jahre sowie Rückfall auf intakte Sicherungen.
- `galaxy_full_integration_test.gd` deckt die tatsächliche UI-Reihenfolge Startassistent → Galaxie → Forschung → Wirtschaft → Diplomatie → Flotte → Ereignis → Speichern/Laden ab; bestehender Test bleibt erhalten.
- `galaxy_save_resume_determinism_test.gd` vergleicht einen 36-jährigen ununterbrochenen Lauf mit 18 Jahren + Spielstand + 18 Jahren, inklusive automatischer Auflösung anstehender Ereignisse.

## CI-Nachweis des Durchlaufs

- Commit `95e1b14cb1467de99e9383d4b66936bfed6324f2` ist in beiden vollständigen GitHub-Actions-Läufen erfolgreich: [43236035586](https://github.com/justuslaier-cmyk/Land-der-Sonne/actions/runs/43236035586) und [43236047514](https://github.com/justuslaier-cmyk/Land-der-Sonne/actions/runs/43236047514).
- Godot-Smoke, Save-Integrität, Save/Resume-Determinismus, bestehender UI-Integrationspfad, Regression-Matrix, Render-Check, Windows-Export und Windows-Runtime-Smoke wurden erfolgreich ausgeführt.
- Die technische CI-Freigabe ist **nicht** mit der vollständigen Paketabnahme gleichzusetzen.

## Offene verbindliche Abnahmeschritte

1. End-to-End-Pfad von Exploration/Expansion bis Krieg, Krisen, Megaprojekt und Endspiel mit nachvollziehbaren Aktionen in einer zusammenhängenden Partie automatisiert belegen; der vorhandene UI-Integrationstest deckt bislang nur einen Teil davon ab.
2. Eine echte, manuell gesteuerte Windows-Spielpartie mit Screenshots, Eingaben, Fortschritt, Save/Resume und Endspiel dokumentieren. Headless-Godot- und Windows-Smoke-Tests ersetzen dies nicht.
3. Gefundene Blocker mit Reproduktion, Fix und Regressionstest schließen; danach erst Status **ABGENOMMEN**.

## Grenzen der Abnahme

Automatisierte End-to-End- und Langzeittests belegen **keine vollständige menschliche Kampagne** und keine subjektive Spielqualität. Diese manuellen Nachweise sind im Releaseplan ausdrücklich offen. Der CI-Nachweis liegt vor; **ABGENOMMEN** bleibt bis zur dokumentierten manuellen End-to-End-Partie gesperrt.

## Konsolidierung innerhalb des einzigen Durchlaufs 1.2

- Der Endgame-Test `galaxy_campaign_endgame_test.gd` wurde mit Commit `21598822` eingeführt; beide CI-Läufe `43236888123` und `43236901496` waren erfolgreich.
- In Commit `15014756` erweitert: tatsächliche Erkundungsaktion, Flottenflug, Kolonisierung, Erstkontakt/Kriegserklärung und bezahlte Krisenabwehr statt direkter Manipulation des Bedrohungswerts. Die Voraussetzungen für späte Krisen (Jahreszahl, Kriegszustand, antike Geschichte) werden weiterhin gezielt gesetzt; dieser Test ist kein Beleg einer natürlich vollständig gespielten Partie.
- Die CI für die Erweiterung ist erneut zu prüfen. Es gibt **keinen zusätzlichen Durchlauf**: alle Korrekturen zählen zu 1.2.
- **Verbleibende Abnahmegrenze:** Manuelle Windows-Partie mit echter Bedienung und Screenshots kann aus GitHub-Actions-Smoke-Tests nicht abgeleitet werden. Ohne diesen Beleg darf gemäß Ausführungsplan weder `ABGENOMMEN` noch der Beginn von 2.1 behauptet werden.
