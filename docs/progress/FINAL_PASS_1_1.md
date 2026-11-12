# Paket 1 – Durchlauf 1: technische Bestandsprüfung und Blocker

**Status:** IN ARBEIT – keine Abnahme vor vollständig grüner GitHub-CI.

## Inventur
Die aktuelle Repository-Struktur umfasst 25 GDScript-Produktionsskripte (davon 18 unter `game/scripts/galaxy`) und 80+ GDScript-Testdateien. Die vorhandene CI prüft Godot-Import, Kernsimulation, militärische Versorgung, Diplomatie, Wirtschafts-/Bevölkerungsinvarianten, Langzeitkampagnen, Rendering, Windows-Export und Windows-Runtime. Dies ist eine technische Bestandsprüfung, **kein Beweis**, dass jeder Codepfad vollständig manuell auditiert wurde.

## Reproduzierter P1-Fehler
`GalaxyAI.tick` verwendete die vor dem Flottenunterhalt und der Gesellschaftssimulation zwischengespeicherte Staatskasse für Flottenbau und Kolonisierung. Die Rekrutierung schrieb den alten Betrag minus 28 zurück, wodurch bezahlter Unterhalt überschrieben wurde; anschließend konnte eine Kolonisierung denselben veralteten Betrag erneut nutzen. Erste Korrektur `f87f699` führte zu einer CI-Regression: `galaxy_ai_test.gd` meldete `AI empires never expanded`, weil regelmäßige Rekrutierung die Kolonisationsreserve vor der Expansion verbrauchte.

## Korrektur
`9e302a7`: Kolonisierung (45 Credits) vor optionaler Flottenverstärkung (28 Credits) ausführen; **jede** Transaktion liest danach den aktuellen Kontostand. `galaxy_ai_treasury_regression_test.gd` prüft Grenzfälle 28, 29, 45 und 46 Credits sowie Flottenunterhalt und kolonisationsfähige Liquidität. Bestehender `galaxy_ai_test.gd` prüft weiterhin echte KI-Expansion über 18 Jahre.

## Weitere zu prüfende Risiken
- Save-Ladepfad `GalaxyModel._read` prüft Grundschema und Version, aber nicht sämtliche Querverweise. `GalaxyContracts.errors` existiert als separate nicht-mutierende Validierung; Integration ohne Legacy-Save-Regression prüfen.
- Gesellschafts- und Warenbilanzen werden jährlich geprüft; zusätzliche Tests für mehrfache konkurrierende KI-Ausgaben und Wiederaufnahme nach Save/Load sinnvoll.
- Der automatisierte End-to-End-Test ersetzt keinen vollständigen menschlichen Spieltest; dieser ist in Durchlauf 1.2 vorgesehen.

## Abnahmekriterien
1. Aktuelle Branch-CI vollständig erfolgreich (inklusive Godot-Smoke, Regression-Matrix, Render und Windows).
2. Keine reproduzierten P0/P1-Fehler in den geprüften Kernpfaden.
3. Für jeden behobenen Fehler ein Regressionstest.
4. Restliche Prüfgrenzen und nachfolgende Durchläufe ausdrücklich dokumentiert.

**Entscheidung:** OFFEN bis CI-Nachweis vorliegt.
