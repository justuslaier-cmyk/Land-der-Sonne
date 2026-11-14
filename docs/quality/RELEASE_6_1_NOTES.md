# Land der Sonne – Release-Candidate-Prüfbericht und Änderungsübersicht

**Datum:** 2026-11-12. **Status:** EXPERIMENTELL / KEIN RELEASE-KANDIDAT. Kein Tag, keine GitHub-Release-Veröffentlichung, keine Freigabe für Spieler.

## Technisch vorhanden

- Godot 4.3, Windows-x64-Export als **experimentelles** CI-Artefakt mit EXE, PCK, Build-Info und SHA-256-Prüfsummen.
- Galaxie- und Reichsgründung, Karte, Wirtschaft/Gesellschaft, Forschung, Diplomatie, Flotten, KI, Chronik/Krisen und Speicherslots in unterschiedlicher Integrationstiefe.
- CI-Matrix: Godot-Import/Smoke, isolierte Regressionen, reale Linux-Xvfb-Godot-Renderprüfungen, Windows-Export und Windows-2022-Headless-Start/Integration.
- Paket 5.2: drei 250-Sterne-/20-KI-/180-Jahre-Simulationen mit Save/Resume und synthetischen UI-Interaktionen. Details in `docs/progress/FINAL_PASS_5_2.md`.
- Paket 6.1: eigenständiges 98-Punkte-Register und ein **fail-closed** Release-Gate. Ein erfolgreicher *Auditmodus* bestätigt nur die korrekte Erfassung fehlender Nachweise; er ist ausdrücklich keine Releasefreigabe.

## Release-Blocker und bekannte Einschränkungen

1. **98/98 Pflichten nicht einzeln vollabgenommen.** Viele Teilsysteme sind implementiert, aber Vollabnahme fehlt; Details pro ID in `docs/quality/RELEASE_6_1_REQUIREMENTS_REGISTER.md`.
2. **Keine vollständigen manuellen Spielprotokolle** mit Expansion, Diplomatie, Krieg, Krisen und Sieg-/Sandbox-Endzustand. Drei passive Langzeitsimulationen sind keine Spieltests.
3. **Windows 10 und 11 GUI**: native menschliche Sicht-, Bedien- und Accessibility-Prüfungen fehlen. Windows-2022-Headless-Start ersetzt sie nicht.
4. **Zielhardware**: keine definierte Mindest-/Empfehlungshardware, kein reproduzierbarer nativer FPS-, Prozess-RSS- oder VRAM-Nachweis. Xvfb ist nicht vergleichbar.
5. **Visuelle Qualität**: Screenshots werden automatisiert erzeugt, eine vollständige dokumentierte menschliche Review gegen die Art-Richtlinie ist nicht belegt.
6. **Lizenz/Integrität**: eigene SVGs und programmatisch erzeugtes Audio sind im Repo, aber es fehlt eine abgeschlossene Rechte-/Attributionsakte. GitHub Actions `actions/checkout@v4`, `actions/upload-artifact@v4`, `actions/download-artifact@v4` sind nicht auf unveränderliche Commit-SHAs gepinnt; Godot-Binaries und Exporttemplates werden ohne fest dokumentierte SHA-256-Erwartungswerte heruntergeladen. Produktions-Release damit nicht reproduzierbar abgesichert.
7. **Release-Archiv**: experimentelles Artefakt mit begrenzter Aufbewahrung, kein versioniertes, langfristig archiviertes Releasepaket und keine unterzeichnete Abnahme.
8. **Inhaltliche Nachweise**: die Tests bestätigen Teilpfade, nicht vollständige wirtschaftliche, politische und kulturelle Tiefe über alle 98 Anforderungen.

## Build-Nachvollziehbarkeit

`game/project.godot` ist das Projekt; Godot-Version **4.3 stable**. Workflow `.github/workflows/godot-ci.yml` führt die Tests und den Windows-Export aus. Erfolgreicher letzter *vor Paket 6.1* überprüfter Gesamtstand: Commit `3d0ed27528c3331a762fdc1612a8bb5d512311ef`, GitHub Actions `43259805258` (17/17). Neue P6.1-CI ist separat nachzutragen. Das experimentelle ZIP enthält `LandDerSonne.exe`, `LandDerSonne.pck`, `BUILD_INFO.txt`, `SHA256SUMS.txt`; im Workflow werden ZIP-Integrität und Prüfsummen validiert. Der Windows-2022-Runner startet die exportierte EXE headless.

## Verbindliche nächste Abnahmeschritte

Für jede ID P01–P98: Funktionsnachweis im realen Spiel, Commit, reproduzierbarer Test, Ergebnis, ggf. Render-/Windows-Nachweis, unabhängige Review; dann erst Checklisten-Häkchen und `requirements`-Beleg in `RELEASE_6_1_NATIVE_EVIDENCE.json`. Native Windows-10/11-Tests, vollständige menschliche Spielpartien, Zielhardware-Benchmarks, visuelle Review, Rechteakte, Build-Reproduzierbarkeit und Archiv müssen mit konkretem Artefakt dokumentiert sein. `python3 tools/release_gate.py --mode release` muss anschließend erfolgreich sein; dieser strukturelle Gate-Test ersetzt **keine** Prüfung der Authentizität eingetragener Belege. Erst danach darf über eine Release-Freigabe entschieden werden.
