# Paket 2 – Durchlauf 2: Forschung, Diplomatie, Militär und KI

**Status:** Umsetzung und Integration fortgesetzt; Abnahme erst nach erfolgreicher CI und Überprüfung der vollständigen Paketkriterien. Kein Scheinabschluss.

## Bestehende integrierte Systeme

- Forschung: `GalaxySystems.research_preview/start_research/technology_bonuses` mit realen Wissenschaftskosten, Labor- und Forschungsfeldvoraussetzungen, Flottenreichweite, Industrie- und Stabilitätseffekten; Regression `galaxy_research_effects_test.gd`.
- Diplomatie: `GalaxyStrategy.negotiate_treaty/advance_diplomacy` mit bezahlten Verhandlungen, Wartezeit, Diplomatiebruch und persistenten Verträgen; `galaxy_diplomatic_negotiations_test.gd` und drei Szenarien in `galaxy_conflict_negotiation_matrix_test.gd`.
- Krieg/Frieden: Kriegserklärung, Friedenszahlungen, Waffenstillstandsfristen, Kampfstärke, Flottenversorgung und Abnutzung; `galaxy_military_logistics_test.gd`.
- KI: `GalaxyAIPlanner` und `GalaxyAI.tick` nutzen eine eigene Live-Staatskasse; Kolonisation und Rekrutierung sind kostenpflichtig; `galaxy_ai_treasury_regression_test.gd`.

## Konkrete Korrekturen dieses Durchlaufs

- Spielerflotten konnten bisher bei leerer Staatskasse weiter kostenlosen Nachschub in eigenen Häfen erhalten, weil Unterhaltskosten lediglich auf null gekappt wurden. Jetzt wird bezahlter Unterhalt explizit erfasst und unbezahlte Versorgung verschlechtert den Nachschub.
- KI-Flotten nutzten bei Angriffen bislang die volle nominelle Kampfstärke unabhängig von kritischer Versorgung. Jetzt wirkt die gleiche Versorgungsschwellen-/Prozentstrafe wie bei Spielerflotten.
- `galaxy_fleet_upkeep_parity_test.gd` kontrolliert bezahlte/unbezahlte Versorgung beider Seiten.
- Die deterministische Verhandlungsmatrix prüft Handelsvertrag, scheiterndes Bündnis und finanzierten Frieden mit Waffenstillstand über Save/Load.

## Abnahmekriterien und noch zu prüfen

Automatische CI des neuen Commits, reale Kriegsziele und Friedensfolgen im Langzeitspiel sowie keine verdeckten KI-Vorteile außerhalb der ausdrücklichen Schwierigkeitseinstellungen. Bis zur vollständigen Evidenz **keine abgeschlossene Paketabnahme**. Fehlende manuelle Windows-Prüfung separat offen; unabhängige weitere Planarbeiten nicht blockieren.
