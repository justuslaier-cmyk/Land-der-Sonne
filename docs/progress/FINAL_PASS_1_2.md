# Paket 1 – Durchlauf 2: End-to-End und Speicherintegrität

**Status:** IN ARBEIT. **Keine Abnahme**, bevor neue CI erfolgreich ist.

## Nachweise und Änderungen

- CI für den vorausgegangenen Parser-Fix `3874ed5` zweimal vollständig erfolgreich: [43235367182](https://github.com/justuslaier-cmyk/Land-der-Sonne/actions/runs/43235367182), [43235381142](https://github.com/justuslaier-cmyk/Land-der-Sonne/actions/runs/43235381142).
- `GalaxyModel._read` verwendet die nicht-mutierende `GalaxyContracts.errors`-Prüfung, um parsebare, aber inkonsistente Spielstände zurückzuweisen.
- `galaxy_save_integrity_regression_test.gd` prüft unbekannte Sternbesitzer, doppelte Reichs-IDs und negative Jahre sowie Rückfall auf intakte Sicherungen.
- `galaxy_full_integration_test.gd` deckt die tatsächliche UI-Reihenfolge Startassistent → Galaxie → Forschung → Wirtschaft → Diplomatie → Flotte → Ereignis → Speichern/Laden ab; bestehender Test bleibt erhalten.
- `galaxy_save_resume_determinism_test.gd` vergleicht einen 36-jährigen ununterbrochenen Lauf mit 18 Jahren + Spielstand + 18 Jahren, inklusive automatischer Auflösung anstehender Ereignisse.

## Grenzen der Abnahme

Automatisierte End-to-End- und Langzeittests belegen **keine vollständige menschliche Kampagne** und keine subjektive Spielqualität. Diese manuellen Nachweise sind im Releaseplan ausdrücklich offen. Das Protokoll darf nur nach erfolgreicher aktueller CI auf **CI BESTANDEN** gesetzt werden.
