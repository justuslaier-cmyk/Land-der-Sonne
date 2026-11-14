# Forschungsbasierter komprimierter Fertigstellungsplan — 2026-11-12

**Status:** Priorisierter Arbeitsplan, kein Fertigstellungsversprechen. Verbindliche Quelle: [P01–P98](../vision/BINDING_GAME_REQUIREMENTS_CHECKLIST.md); [Codeinventur](../quality/P01_P98_CODE_COVERAGE_AUDIT.md); [bestehender 48-Runden-Plan](PHASE_EXECUTION_PLAN.md). Der bisherige Plan bleibt als historischer Arbeitsnachweis erhalten; die neue Reihenfolge betrifft **künftige** Arbeit.

## Entscheidung: 8 Pakete / 18 geplante Durchläufe

Die acht Pakete enthalten 2 + 2 + 2 + 3 + 2 + 3 + 2 + 2 = **18** geplante Durchläufe. Diese Zahl ist eine **komprimierte Planungshypothese** und nicht empirisch als ausreichend bewiesen. Der 48-Runden-Plan war ebenfalls keine Fertigstellungsgarantie. Die **98 Abnahmepflichten bleiben unabhängig** und dürfen nicht zu acht Häkchen zusammengefasst werden.

## Quellen und Begründung

1. **Interne Befunde (Stand 2026-11-12):** 127 Dateien im GitHub-Branchvergleich, darunter 18 Implementierungs- und 59 Testskripte; P01–P98 bisher nicht individuell abgenommen. Große zentrale Dateien `galaxy_ui.gd` (1654 Zeilen), `galaxy_strategy.gd` (854 Zeilen). Save-Backup-Rotation und Save-Slots (P89) sind konkret risikobehaftet.
2. **GDC Vertical Slice:** https://media.gdcvault.com/gdc2015/presentations/Donovan_Greg_TheVerticalSlice.pdf — spielbare Querschnitte an Zielqualität prüfen, Risiken/technische Schulden quantifizieren; Slice ≠ fertiges Spiel.
3. **Godot 4.3 Kommandozeile und CI:** https://docs.godotengine.org/en/4.3/tutorials/editor/command_line_tutorial.html — Headless-Test, Editor-/Export-Kommandos; GUI-Tests separat.
4. **Godot 4.3 Windows-Export:** https://docs.godotengine.org/en/4.3/tutorials/export/exporting_for_windows.html — Exportvorlagen, Signierung, PCK-/Antivirus-Risiken.
5. **Godot Projekt-Export:** https://docs.godotengine.org/en/4.3/tutorials/export/exporting_projects.html — Ressourcenpakete, Exportpresets, CI.
6. **Godot CI-Beispiel:** https://github.com/abarichello/godot-ci/blob/master/.github/workflows/godot-ci.yml — wiederholbare Pipeline und Build-Artefakte.
7. **Komplexitäts-/UX-Vergleich:** https://stellarisdb.com/news/2026-06-18-stellaris-dev-diary-425-nomads-roam-the-galaxy-whats-next — Automatisierung und Micromanagement als Designrisiko; externe Vergleichsquelle, keine bindende Spielanforderung.

## Minimierungsstrategie

- **Wiederverwenden:** 59 bestehende Testskripte und aktuelle Godot-CI zuerst auswerten; keine Doppelimplementierungen.
- **Integrationsbündel:** Zusammengehörige Datenregeln, KI, UI, Grafik, Save und Tests **im selben Durchlauf**; neue sichtbare Funktionen benötigen originale integrierte Art im selben Change.
- **Eine Pipeline:** gezielte Tests während der Implementierung, vollständige CI + Render + Windows am Paketende. Kein CI-Verzicht bei sicherheits-/persistenzkritischen Änderungen.
- **Frühe Risikoreduktion:** Save-Integrität, Determinismus, Bilanzierung und echte GUI-Bedienung vor Content-Masse.
- **Keine falschen Abnahmen:** Jede der 98 Anforderungen bekommt Test-/Render-/Playtestbeleg; ein grüner 17-Job-Lauf allein reicht nicht.
- **Parallelisierbarkeit:** Art-/UX-Konzept und Balancing-Instrumente dürfen parallel vorbereitet werden; finale Abnahme erfolgt erst mit echter Integration.

## Priorisierte Pakete und Durchläufe

| Priorität | Paket | Inhalt | Pflichten | Durchläufe | Kumulativ |
|---|---|---|---|---:|---:|
| 1 | A | Datenintegrität und technische Basis | P87–P93, P96 | 2 | 2 |
| 2 | B | Spielstart, UX und Informationsarchitektur | P01–P10, P85–P86 | 2 | 4 |
| 3 | C | Galaxis, Kolonien und Identität | P11–P24 | 2 | 6 |
| 4 | D | Gesellschaft, Politik und Wirtschaftskern | P25–P39, P44–P49 | 3 | 9 |
| 5 | E | Logistik, Handel und Technologie | P40–P43, P50–P55 | 2 | 11 |
| 6 | F | Diplomatie, Militär und KI-Integration | P56–P64, P73–P79 | 3 | 14 |
| 7 | G | Geschichte, Krisen, Endspiel und Medien | P65–P72, P80–P84 | 2 | 16 |
| 8 | H | Balancing, Langzeittests und Release | P90–P98 und Restabnahmen | 2 | 18 |

### Paket A — Datenintegrität und technische Basis (2 Durchläufe)

- **Pflichten:** P87–P93, P96
- **Umfang:** P89-Rotation, Save-Slots, Autosave, Recovery, Migration; deterministische RNG-/Tick-Verträge, Profiling, Windows-Gates
- **Abnahme:** Save-Fault-Injection, Save-Roundtrips, Migration, 250-Sterne-Benchmark, Windows-CI
- **Durchläufe:**
  1. D1: Bündelung von Modell, Gameplay, UI, Originalgrafik und gezielten Tests
  2. D2: übergreifende Integration, Regression, Performance-/Render- und Windows-Abnahme
- **Stop-/Split-Regel:** Wenn ein Kernvertrag oder seine Tests nicht grün sind, wird kein Vollabnahme-Häkchen gesetzt. Ein Paket wird nur dann geteilt, wenn ein eigenständiger Integrationsschnitt mit eigener Testevidenz möglich ist.

### Paket B — Spielstart, UX und Informationsarchitektur (2 Durchläufe)

- **Pflichten:** P01–P10, P85–P86
- **Umfang:** Menü/Wizard, persistente Vorlagen, Settings, Tooltips, Karten- und Verwaltungsnavigation, Tutorial, Event-Queue, Ziele
- **Abnahme:** GUI-Interaktionsmatrix, 720p/1080p, Tastatur, invalid commands, Windows-Screenshots
- **Durchläufe:**
  1. D1: Bündelung von Modell, Gameplay, UI, Originalgrafik und gezielten Tests
  2. D2: übergreifende Integration, Regression, Performance-/Render- und Windows-Abnahme
- **Stop-/Split-Regel:** Wenn ein Kernvertrag oder seine Tests nicht grün sind, wird kein Vollabnahme-Häkchen gesetzt. Ein Paket wird nur dann geteilt, wenn ein eigenständiger Integrationsschnitt mit eigener Testevidenz möglich ist.

### Paket C — Galaxis, Kolonien und Identität (2 Durchläufe)

- **Pflichten:** P11–P24
- **Umfang:** Sichere Generierung und Erreichbarkeit, Exploration, Stern-/Planetenvielfalt, Kolonien, Traits/Civics, Kulturwandel und Herkunft
- **Abnahme:** Seed-Property-Tests, Pfadgarantie, KI-Startfairness, Colony-Save/Load, original artwork
- **Durchläufe:**
  1. D1: Bündelung von Modell, Gameplay, UI, Originalgrafik und gezielten Tests
  2. D2: übergreifende Integration, Regression, Performance-/Render- und Windows-Abnahme
- **Stop-/Split-Regel:** Wenn ein Kernvertrag oder seine Tests nicht grün sind, wird kein Vollabnahme-Häkchen gesetzt. Ein Paket wird nur dann geteilt, wenn ein eigenständiger Integrationsschnitt mit eigener Testevidenz möglich ist.

### Paket D — Gesellschaft, Politik und Wirtschaftskern (3 Durchläufe)

- **Pflichten:** P25–P39, P44–P49
- **Umfang:** Bevölkerungsgruppen und Bedürfnisse, Beschäftigung, Haushalte, Unternehmen, Produktion, Markt, Fiskalpolitik, Regierung, Machtwechsel, soziale Reaktionen
- **Abnahme:** Doppelte Buchführung und Güterinvarianten, Mehrjahres-Simulation, Governance- und UI-Tests
- **Durchläufe:**
  1. D1: Datenmodell, Kernregeln, Akzeptanztests und notwendige Originalgrafiken
  2. D2: volle Welt-/KI-/UI-Integration mit Regressionen
  3. D3: Systemausbau, lange Tests, Bild-/Windows-Abnahme und Defektbehebung
- **Stop-/Split-Regel:** Wenn ein Kernvertrag oder seine Tests nicht grün sind, wird kein Vollabnahme-Häkchen gesetzt. Ein Paket wird nur dann geteilt, wenn ein eigenständiger Integrationsschnitt mit eigener Testevidenz möglich ist.

### Paket E — Logistik, Handel und Technologie (2 Durchläufe)

- **Pflichten:** P40–P43, P50–P55
- **Umfang:** Transportkapazitäten, Verzögerungen, Versorgung, Handel/Embargos, Informationsverzögerung, Forschungsinstitutionen, Tech-Diffusion
- **Abnahme:** Lieferkettenbilanz, Blockaden, Forschungsvoraussetzungen, Handels-KI, Performance
- **Durchläufe:**
  1. D1: Bündelung von Modell, Gameplay, UI, Originalgrafik und gezielten Tests
  2. D2: übergreifende Integration, Regression, Performance-/Render- und Windows-Abnahme
- **Stop-/Split-Regel:** Wenn ein Kernvertrag oder seine Tests nicht grün sind, wird kein Vollabnahme-Häkchen gesetzt. Ein Paket wird nur dann geteilt, wenn ein eigenständiger Integrationsschnitt mit eigener Testevidenz möglich ist.

### Paket F — Diplomatie, Militär und KI-Integration (3 Durchläufe)

- **Pflichten:** P56–P64, P73–P79
- **Umfang:** Verhandlungen, Föderationen, Spionage, Schiffsentwurf, Flottenlogistik, Kriege/Frieden, KI-Ressourcenfairness, Informationsgrenzen und Erklärbarkeit
- **Abnahme:** Mehrfraktions-Simulation, Krieg/Versorgung, AI-vs-player parity, deterministic soak
- **Durchläufe:**
  1. D1: Datenmodell, Kernregeln, Akzeptanztests und notwendige Originalgrafiken
  2. D2: volle Welt-/KI-/UI-Integration mit Regressionen
  3. D3: Systemausbau, lange Tests, Bild-/Windows-Abnahme und Defektbehebung
- **Stop-/Split-Regel:** Wenn ein Kernvertrag oder seine Tests nicht grün sind, wird kein Vollabnahme-Häkchen gesetzt. Ein Paket wird nur dann geteilt, wenn ein eigenständiger Integrationsschnitt mit eigener Testevidenz möglich ist.

### Paket G — Geschichte, Krisen, Endspiel und Medien (2 Durchläufe)

- **Pflichten:** P65–P72, P80–P84
- **Umfang:** Narrative-Kausalität, Chronik, Endspielkrisen, Megastrukturen, Erfolge, originäre Grafik, Audio, Animation
- **Abnahme:** End-to-end Event/History, Bildimport/Render, Audio-Rechte, Victory/Continue, Save
- **Durchläufe:**
  1. D1: Bündelung von Modell, Gameplay, UI, Originalgrafik und gezielten Tests
  2. D2: übergreifende Integration, Regression, Performance-/Render- und Windows-Abnahme
- **Stop-/Split-Regel:** Wenn ein Kernvertrag oder seine Tests nicht grün sind, wird kein Vollabnahme-Häkchen gesetzt. Ein Paket wird nur dann geteilt, wenn ein eigenständiger Integrationsschnitt mit eigener Testevidenz möglich ist.

### Paket H — Balancing, Langzeittests und Release (2 Durchläufe)

- **Pflichten:** P90–P98 und Restabnahmen
- **Umfang:** Mehrere reale Vollpartien, Strategievielfalt, 250-Sterne-Budgets, Fehlerbehebung, Windows-GUI, Dokumentation, Release-Gates
- **Abnahme:** CI grün, realer Windows-10/11-Nutzertest, Playtestprotokolle, P01–P98-Nachweise
- **Durchläufe:**
  1. D1: Bündelung von Modell, Gameplay, UI, Originalgrafik und gezielten Tests
  2. D2: übergreifende Integration, Regression, Performance-/Render- und Windows-Abnahme
- **Stop-/Split-Regel:** Wenn ein Kernvertrag oder seine Tests nicht grün sind, wird kein Vollabnahme-Häkchen gesetzt. Ein Paket wird nur dann geteilt, wenn ein eigenständiger Integrationsschnitt mit eigener Testevidenz möglich ist.


## Zeitmodell statt erfundener Laufzeiten

Ein **Durchlauf** ist eine Entwicklungs- und Verifikationsschleife, keine konstante Stunden- oder Chatnachrichtenzahl. Exakte Kalenderzeit ist nicht seriös aus dem Repository ableitbar, da noch keine vergleichbaren Messwerte für Funktionskomplexität, Fehlerraten, CI-Wartezeit, Renderreview und Nutzer-Playtests vorliegen.

**Planungsannahmen, nicht gemessene Zeiten:** leichte Schleife 2–6 Stunden aktive Arbeit; mittlere 6–16 Stunden; schwere 16–40+ Stunden, jeweils **ohne** garantierte Verfügbarkeit von Windows-Tester, Originalgrafik und externe Blocker. Für die 18 Durchläufe: A=2 schwere; B=2 mittlere/schwere; C=2 schwere; D=3 schwere; E=2 schwere; F=3 schwere; G=2 schwere; H=2 schwere. Die Spannen dürfen nicht als feste Lieferzusage verwendet werden.

**Messprotokoll pro Durchlauf:** Start/Ende, Dateien, Pflicht-IDs, neue Tests, Codezeit, CI-Laufzeit, Fehlversuche, Render/Windows-Nachweise, offene Defekte, Nacharbeit. Nach A und B Plan aktualisieren: tatsächliche Median-/P80-Dauer, Defektrate, Tests pro Pflicht-ID, Paketumfang.

## Definition of Done

1. Alle betroffenen Pflicht-IDs und Akzeptanzkriterien vor Codeänderung benannt.
2. Reale Spielregel und gemeinsame Weltzustands-/Speicherverträge integriert; keine nur dekorative Funktion.
3. Originalgrafik mit Pfad und tatsächlicher Godot-Einbindung bei jeder neuen sichtbaren Funktion; Bildimport und Screenshots geprüft.
4. Unit-/Integration-/Determinismus-/Langzeittests für geänderte Systeme grün; vollständige CI am Paketende grün.
5. Windows-Headless-Start erfolgreich; tatsächliche GUI-Bedienung unter Windows 10/11 gesondert nachgewiesen, wo nötig.
6. P01–P98-Häkchen **nur einzeln** mit Commit, Test, Ergebnis, ggf. Render/Windows und Einschränkungen; sonst offen lassen.
7. Fortschrittsdatei und bekannte Risiken aktualisiert.

## Anpassungsregel

- **18 = Basisplan**, nicht objektive Untergrenze.
- **14–16 Durchläufe** nur als optimistisches Szenario bei sehr hoher Wiederverwendbarkeit und ohne kritische Integrationsprobleme; **18–24** als Arbeitskorridor; **25+** bei tiefen Systemlücken, langem Balancing oder Windows-/Performanceproblemen.
- Nach Paket A und B neu kalibrieren, nicht künstlich zusätzliche Arbeit verstecken.
- Vollständigkeit hängt an 98 realen Abnahmen und Nutzer-Playtests, nicht an der Anzahl durchgeführter Chatbefehle.

## Sofortiger nächster Auftrag

**Paket A / Durchlauf 1:** P87–P90, P93; zuerst reproduzierbare Save-Rotations-/Korruptions-/Migrationstests und Performancebaseline, danach gezielte Korrektur im bestehenden `galaxy_model.gd`, Integration in `galaxy_ui.gd`, Tests in Godot CI. Abschluss nur mit grünem CI-Beleg.
