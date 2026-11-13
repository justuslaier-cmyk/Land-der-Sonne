# Abschlussdurchlauf A2 – Spielmechanik und drei aktive End-to-End-Kampagnen

**Stand 13.11.2026 · Branch `design/galactic-grand-strategy-pivot` · Entscheidung: BESTANDEN (technischer A2-Umfang).**

## Scope und betroffene Anforderungen
P10, P14–P16, P34–P43, P51–P55, P56–P64, P70–P75, P90, P94, P95 sowie P98 (Nachweiskette). Der vierteilige Abschlussplan bleibt maßgeblich; historische zwölf Paketberichte bleiben unverändert. Keine neuen Hauptsysteme, keine neuen sichtbaren Spielfunktionen und daher keine neuen Original-Art-Dateien nötig. Vorhandene UI-/Kartenassets werden unverändert genutzt; A3-Visual-/Audio-/Windows-GUI-Abnahme ist **nicht** durch Headless-CI ersetzt.

## Tatsächlich implementierte Korrekturen
1. **Ereignisbudget:** `galaxy_systems.gd` verhindert unfinanzierte 20-/40-Credit-Ereignisentscheidungen und lässt die Entscheidung bis zu einer bezahlbaren Alternative offen. Ausgangsfehler: echte aktive Wohlstandskampagne mit negativem Guthaben bei Jahr 119; reproduziert in GitHub Actions `43413228658`. Regression mit 0-Credit-Fixture.
2. **Krisenabwehr:** `galaxy_endgame.gd` verlangt für Flottenabwehr mindestens fünf reale Flottenstärkepunkte und 20 Nachschubpunkte, verbraucht Nachschub. Wissenschaftliche Abwehr erfordert neben Gesamtforschung eine reale Gesellschafts-Spezialisierung. Regressionen für leere Flotte und fehlenden Forschungszweig.
3. **Großprojekte:** Orbitalarchiv und Einheitsleuchtfeuer verlangen Gesellschaftsforschung, Sternenschmiede Industrieforschung. Ein künstlich erhöhter globaler `research_level` allein schaltet sie nicht frei. Legacy-Fixtures in `galaxy_campaign_endgame_test.gd`, `galaxy_package_2_3_test.gd`, `galaxy_package_g2_test.gd` auf reale Fachvoraussetzungen aktualisiert.
4. **KI-Kostenparität:** `galaxy_ai.gd` besiedelt nur bewohnbare unbeanspruchte Sterne, bezahlt wie der Spieler 50 Credits statt 45, reserviert kolonisationsfähige Eigenmittel vor Rekrutierung, plant von tatsächlich besessenen Grenzsystemen aus und variiert nur Entscheidungsfrequenz und Planungsradius innerhalb der 170-Karten-Einheiten-Surveygrenze. Bestehende KI-Kassenregression auf 49/50-Credit-Grenzen und bewohnbare Zielwelt angepasst.
5. **Drei vollständige aktive Kampagnen:** `galaxy_a2_active_campaigns_test.gd` und `.github/workflows/godot-ci.yml` integrieren 3×210 Jahre mit echten Spielaktionen, nicht künstlich gesetzten Credits, Legierungen, Forschungsstufen, Jahren, Kriegszuständen oder Krisenprädikaten. Speichern/Laden mit exakter Weltzustandsgleichheit im Jahr 91, fortgesetzte Simulation, keine negativen Bestände, jährliche `GalaxyContracts.errors`-Prüfung.

## Ausgeführte Belege und Ergebnisse
**GitHub Actions `43416578913` auf Commit `95d95208489e4c7a5c97da83ea561874ed7f19e2`: 18/18 Jobs erfolgreich**, einschließlich Godot 4.3 Import, Headless-Simulation, bestehender Regressionen, Renderprüfungen, Windows-Export und Windows-Headless-Runtime. Kein menschlicher Windows-GUI-Test.

Befehl des neuen integrierten Tests:
`timeout 240s godot --headless --path game --script res://tests/galaxy_a2_active_campaigns_test.gd`

| Strategie | Seed | Ziel tatsächlich erreicht | Erkundungen | Flottenbewegungen | Kolonisierungen | Forschung | Diplomatie | Kriege | Krisenabwehr | Projekt |
|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---|
| Erkundung | 72119 | exploration | 58 | 32 | 12 | 5 | 1 | 0 | 0 | orbital_archive |
| Wohlstand | 82331 | prosperity | 56 | 32 | 13 | 5 | 1 | 0 | 0 | unity_beacon |
| Widerstandskraft | 93443 | resilience | 35 | 32 | 5 | 5 | 1 | 2 | 7 | stellar_foundry |

Widerstandskraft: zwei **durch natürliche Weltbedingungen** ausgelöste Krisen überstanden. Für alle drei Pfade reguläre Exploration, Forschung, Kolonisierung, politische Schwerpunkte, ökonomische Investitionen, Diplomatie, Megaprojekt und Save/Resume. Das alte `galaxy_campaign_endgame_test.gd` bleibt als isolierter Fixture-/UI-Regressionstest bestehen und wird **nicht** als natürliche Kampagne ausgegeben.

**Balance:** `galaxy_balance_matrix_test.gd` führt 27 Seed×Strategie×Schwierigkeit-Szenarien mit 85 Jahren aus. In der letzten CI: 9/9 differenzierte Strategieblöcke; KI-Systeme aggregiert nach Schwierigkeit `[108, 90, 90]` und mittlere KI-Flottenstärke ca. `[226, 239, 241]`. Dies zeigt einen **realen Trade-off**, keine monotone Gebietsexpansion. Die stärkere Schwierigkeit verfügt über etwas größere Flotten, aber nicht mehr Gebiet; diese Einschränkung bleibt für A3-Menschentests und künftige Feinkalibrierung ausdrücklich offen. Die Matrix simuliert weiterhin passive Spielerstrategien; sie wird nun durch die drei aktiven A2-Kampagnen ergänzt, nicht ersetzt.

## Geänderte Dateien
`game/scripts/galaxy/galaxy_systems.gd`, `galaxy_endgame.gd`, `galaxy_ai.gd`; `game/tests/galaxy_a2_active_campaigns_test.gd`, `galaxy_campaign_endgame_test.gd`, `galaxy_package_2_3_test.gd`, `galaxy_package_g2_test.gd`, `galaxy_ai_treasury_regression_test.gd`; `.github/workflows/godot-ci.yml`. Einzelcommits von `5ef959d8` bis `95d95208` auf dem vorgeschriebenen Branch, keine Änderungen an anderen Repositories.

## Abgrenzung und verbleibende Risiken
- **A2 BESTANDEN** bedeutet: drei tatsächlich erspielte Siegpfade, Ressourcen-/Forschungs-/Krisengates, Save/Resume und vollständige technische CI. Nicht: 98/98 Einzelabnahmen oder finaler Release.
- **A3 offen:** menschliche vollständige Spielpartien, Windows-10/11-GUI, Audio-/Visualreview, Zielhardware-FPS/RSS/VRAM, aktive 250/20-Performance.
- **A4 offen:** 98 Einzelabnahmen, acht native Gates, Rechte-/Build-/Release-Nachweise.
- **Qualitätsrisiken für A3:** nicht-monotone KI-Territorien trotz wachsender Flottenstärke; keine echte menschliche Bewertung der Schwierigkeit, KI-Expansion abstrahiert Flottenbewegung; keine 250/20-Kampagne mit menschlichem aktiven Spieler. Nicht als gelöst behauptet.

**Ergebnis:** A2 als programmierter, reproduzierbar getesteter Abschlussdurchlauf bestanden; A3 ist nächster Durchlauf. Die 98-Punkte-Checkliste bleibt unverändert offen bis zur individuellen Abnahme.
