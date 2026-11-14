# Paket 6 – Durchlauf 1: Release-Kandidat und P01–P98-Einzelabnahme

**Stand:** 2026-11-12 · **Branch:** `design/galactic-grand-strategy-pivot` · **Entscheidung: NICHT BESTANDEN – KEIN RELEASE.**

## Verbindlicher Umfang

Plan `docs/progress/FINAL_GAME_EXECUTION_PLAN.md` (6.1): alle 98 Pflichtanforderungen mit tatsächlichen Commit-, Test-, Ergebnis- und ggf. Windows-/Screenshot-/Nutzerbelegen einzeln abnehmen, alle Regressionen grün, Windows-10/11-GUI-Start, reale Nutzerpartien, Rechteprüfung, Build-Reproduzierbarkeit, Changelog, Einschränkungen, Release-Archiv. **Diese Vollabnahme kann durch Headless- und CI-Läufe allein nicht erbracht werden.**

## Bestandsprüfung und konkrete Änderungen

- Rekursive GitHub-Inventur: **259 Tree-Einträge** vor diesem Durchlauf, 98 bindende Pflichtpunkte, 98/98 im vorhandenen Code-Coverage-Audit mit möglichen Prüf-Einstiegspunkten, **0/98 mit dokumentierter vollständiger Einzelabnahme**. Die alten Inventurwerte in früheren Berichten sind zeitpunktgebunden und nicht als aktueller Umfang zu interpretieren.
- `docs/quality/RELEASE_6_1_REQUIREMENTS_REGISTER.md`: jede der 98 Anforderungen mit Originalwortlaut, bestehender Codezuordnung, individuellem Abnahmestatus und fehlender Evidenz; keine stillschweigende Streichung.
- `docs/quality/RELEASE_6_1_NATIVE_EVIDENCE.json`: separates maschinenlesbares, zunächst leeres Akzeptanzregister für individuelle Vollabnahmen und acht explizite native/manuelle Release-Gates.
- `tools/release_gate.py`: **fail-closed** Prüfung auf vollständige 98 IDs, exakte Übereinstimmung der Pflichttexte, Häkchen/Status-Synchronität, Pflichtfelder pro abgenommener ID und Windows-/Spieltest-/Art-/Lizenz-/Build-/Archivbelege. `--mode audit` gibt bei korrekt blockiertem Release Status 0 aus, `--mode release` verweigert die Freigabe (Exit 1), bei inkonsistenten Registern Exit 2.
- `game/tests/release_gate_test.py`: drei automatisierte Regressionen zu 98er Vollständigkeit, blockiertem Release und Auditverhalten; in `.github/workflows/godot-ci.yml` als eigener Pflichtjob eingebunden.
- `docs/quality/RELEASE_6_1_NOTES.md`: Änderungsübersicht, bekannte Einschränkungen, Build-Anleitung und explizite Blocker. Kein Release-Tag oder öffentliches Release-Archiv erstellt.

## Vorher/Nachher, bekannte Grenzen

**Vorher:** verstreute Nachweise, keine releasebezogene 98er-Statusmatrix und kein automatisierter Gate-Test, der eine Freigabe bei fehlender Einzelabnahme verweigert. **Nachher:** vollständiges Einzelregister und ein maschinenprüfbarer Release-Blocker. Das ersetzt keine noch fehlenden Spieleigenschaften und keine manuellen Prüfungen. Eine positive Gate-Antwort würde nur formal vorhandene Daten bestätigen; Echtheit und Qualität müssen weiterhin unabhängig überprüft werden.

## Prüfbelege

- Technische Vorbasis: [Commit 3d0ed275](https://github.com/justuslaier-cmyk/Land-der-Sonne/commit/3d0ed27528c3331a762fdc1612a8bb5d512311ef), [Actions 43259805258](https://github.com/justuslaier-cmyk/Land-der-Sonne/actions/runs/43259805258), **17/17 Jobs erfolgreich**.
- Paket-6.1-Implementierung: `f4c94c5df000c9accb7e0f0053ed388d5a0c6f8d`, Root-Pfad-Korrektur `f3cc953f6af0ed77add996782f493227529f1c9c`.
- **Finaler integrierter CI-Nachweis des Dokumentationscommits `d3088fe7aebf4b222f4eae236b400060788c4971`: [GitHub Actions 43260926145](https://github.com/justuslaier-cmyk/Land-der-Sonne/actions/runs/43260926145), 18/18 Jobs erfolgreich**, einschließlich `release-evidence-audit`, Godot-Smoke, Regression-Matrix, Render, Windows-Export und Windows-2022-Headless-Runtime. **Audit-Gate erfolgreich blockiert** die Freigabe; kein Release-Erfolg behauptet.
- Neue Tests: `python3 -m unittest discover -s game/tests -p release_gate_test.py -v`; `python3 tools/release_gate.py --mode audit`; `python3 tools/release_gate.py --mode release` (erwartet Exit 1, keine Freigabe). CI-Nachweis des finalen Dokumentationscommits separat prüfen.

## Offene Blocker / Endentscheidung

**0/98 Einzelabnahmen**, acht native/manuelle Gategruppen offen, keine vollständig protokollierten menschlichen Spielpartien, keine Windows-10/11-GUI-Abnahme, keine Zielhardware-Performanceabnahme, keine abschließende Rechteakte und kein archiviertes Release. **NICHT BESTANDEN.** Eine vollständige Erledigung des vom Nutzer verlangten 6.1-Durchlaufs wird ausdrücklich **nicht** behauptet. Weiterarbeit am vorhandenen Umfang bleibt notwendig; keine neue Paketnummer und keine ungefragten Features.

## Nachprüfung am 13.11.2026 – striktere Release-Evidenz

Commit `2207fd3aa1c97073014d5acec74c8f4eabb5dc35` erweitert `tools/release_gate.py` und `game/tests/release_gate_test.py`: Ein fehlender nativer Gate-Eintrag ist nun ein Strukturfehler statt bloß eine unauffällige fehlende Abnahme; unbekannte Gate-Status werden verworfen; ein als abgenommen markierter Einzelpunkt muss zusätzlich explizit `status: verified` und ein Artefaktfeld aufweisen. Der neue Regressionstest manipuliert eine temporäre Kopie des Registers und prüft fehlende sowie unbekannte Gate-Definitionen. Keine Änderung am eigentlichen Spielinhalt, keine neuen Grafikassets erforderlich. Betroffene Pflichten P90, P96, P98; **keine neuen Vollabnahmen**. GitHub Actions [43410161664](https://github.com/justuslaier-cmyk/Land-der-Sonne/actions/runs/43410161664) wurde ausgelöst; der finale CI-Status ist erst nach Abschluss sämtlicher Jobs belastbar. Release bleibt **NICHT BESTANDEN**, insbesondere wegen 0/98 individuellen Abnahmen und acht offenen nativen Gates.
