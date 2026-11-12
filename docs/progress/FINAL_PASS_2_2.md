# Paket 2 – Durchlauf 2: Forschung, Diplomatie, Militär und KI

**Abnahmeentscheidung:** NICHT BESTANDEN, solange die vollständigen GitHub-Actions-Läufe für den aktuellen HEAD nicht erfolgreich abgeschlossen sind. Die technische Umsetzung ist integriert; CI- und visuelle Evidenz werden nicht erfunden.

## Scope und Aufgabenprüfung

Verbindlicher Scope aus `FINAL_GAME_EXECUTION_PLAN.md`: echte Forschungsfreischaltungen, Diplomatiekosten und Folgen, KI unter Ressourcen-/Informationsregeln, Flottenlogistik, Kriegsziele, Friedensfolgen, mindestens drei reproduzierbare Szenarien. P01–P98 bleiben unabhängig offen, soweit nicht einzeln abgenommen.

Repository-Sichtung: rekursiver Git-Tree mit 226 Einträgen, vorhandene Galaxie-Skripte, CI-Tests, aktiver Spielkanon, Vision, Gesamtaudit und Projektstatus überprüft. Frühere 2.2-Regressionen und CI-Ergebnisse ausgewertet; keine stillschweigende Scope-Erweiterung.

## Tatsächlich implementierte Integration

- **Forschung:** Spielerforschung benötigt reale Wissenschaftspunkte, Labor- und Technologievorbedingungen; Industrie beeinflusst Erträge, Antrieb Reichweite, Gesellschaft Stabilität. KI sammelt nun `ai_science` aus realen eigenen Kolonien, bezahlt 25 Wissenschaftspunkte je freigeschalteter Grundtechnologie und entwickelt die drei bestehenden Felder deterministisch. KI-Industrie wirkt auf Angriffsstärke, Antrieb auf Reichweite und Gesellschaft auf Legitimität. Forschungspunkte und Stufen persistieren über Save/Load.
- **Diplomatie:** Verhandlungen belasten die Staatskasse und werden zeitversetzt angenommen oder abgelehnt. Verträge und Fehlschläge bleiben im Save.
- **Militär:** Spieler und KI müssen Flottenunterhalt bezahlen; ohne vollständige Zahlung kein kostenloses Auffüllen in eigenen Häfen. Unterversorgung reduziert Kampfstärke beider Seiten; Versorgung und Verluste werden protokolliert.
- **KI-Ökonomie:** Grundlegende territoriale Steuereinnahmen von Spieler und KI nutzen dieselbe Formel `Kolonien * 2 + Ressourcen / 3` statt eines pauschalen KI-Bonus. Rekrutierung und Kolonisierung belasten die Live-Kasse; die KI liest keine versteckten Spielerbestände in ihrem Strategieplaner.
- **Kriegsziel/Frieden:** Kriegserklärung setzt ein reales, vom Gegner kontrolliertes Zielsystem. Tatsächlicher Sieg im `GalaxyStrategy.attack` markiert das Ziel als erreicht. Friedensverträge kosten bei schlechter Beziehung 70 Credits bzw. 35 bei erreichtem Ziel, setzen eine Waffenstillstandsfrist und schreiben einen persistenten `peace_history`-Eintrag. Das bestehende Diplomatiemenü zeigt Kriegsziel, Zielstatus und exakte Friedenskosten.
- **Originalgrafik:** `game/assets/art/war_objective.svg`, handgezeichnetes 48×48-Pixelraster-Motiv im Navy/Petrol/Cyan/Violett/Amber-Stil; eingebunden in `galaxy_ui.gd`; SVG-Import und Maße im `galaxy_art_resources_test.gd`. Echte Godot-Renderprüfung erfolgt über CI; manuelle visuelle Abnahme bleibt gesondert offen.

## Abnahmetests

- `galaxy_research_effects_test.gd`, `galaxy_research_branches_test.gd`: Technologieeffekte und Voraussetzungen.
- `galaxy_diplomatic_negotiations_test.gd`, `galaxy_conflict_negotiation_matrix_test.gd`: Vertragskosten, Fristen, drei Szenarien (Handelsabschluss, Bündnisbruch, Krieg/Frieden).
- `galaxy_military_logistics_test.gd`, `galaxy_fleet_upkeep_parity_test.gd`: Versorgung und Kosten.
- `galaxy_war_goal_peace_test.gd`: realer Kampf, Zielerfüllung, Finanzierbarkeit, Persistenz.
- `galaxy_ai_treasury_regression_test.gd`, `galaxy_ai_income_parity_test.gd`, `galaxy_ai_research_parity_test.gd`: KI-Kosten, gemeinsame Einnahmeformel, finanzierte Forschung.
- `galaxy_ai_soak_test.gd`: deterministisches Replay mit Save/Resume.

Alle neuen Tests sind im `.github/workflows/godot-ci.yml` registriert. Aufrufsmuster: `godot --headless --path game --script res://tests/<test>.gd`.

## Konkrete Regressionen und Korrekturen

- Commit `fc752e99` enthielt einen GDScript-Typinferenzfehler beim neuen Kriegszielstatus. Behoben in `f428ae98`; dessen GitHub-Actions-Läufe erfolgreich.
- Die neue KI-Einnahmeprüfung verwendete anfangs einen noch nicht initialisierten KI-Kassenwert. Behoben in `9f7e357b`; aktuelle vollständige CI-Evidenz ausstehend.
- `galaxy_strategy_test.gd` prüft Politikänderungen nun gegen eine deterministische Gegenwelt statt absolute Stabilitätszunahme; CI-Läufe für `7d8cb074` erfolgreich.
- Nachfolgende Implementierungs-Commits: `d9fda5f5` (UI), `0e9cc586` (Originalgrafik), `e6aae8da` (Einnahmenparität), `6d61d536` (KI-Forschung), `e4ebba09` (Forschungsfolge), `d973bb20` (echte Kampfintegration).

## Offene Nachweise

Vollständige aktuelle CI inkl. Godot-Smoke, Regression-Matrix, Render-Check und Windows-Export; echte manuelle Windows-GUI-Spielprüfung; Sichtkontrolle des neuen Kriegsziels im tatsächlich gerenderten Diplomatiemenü. Diese Punkte nicht als bestanden ausgeben. Paket 2.3 erst als abgenommen markieren, wenn dessen eigene Kriterien nachgewiesen sind.
