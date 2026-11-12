# Land der Sonne – verbindlicher Fertigstellungs- und Ausführungsplan

**Beschluss:** 2026-11-12 · **Branch:** `design/galactic-grand-strategy-pivot` · **Ziel:** ein vollständig spielbares, qualitativ geprüftes Godot-4.3-Grand-Strategy-Spiel für Windows. Dieser Plan konkretisiert [den Gesamt-Audit](../quality/FINAL_GAME_SCOPE_AUDIT_2026_11_12.md) und die [verbindliche P01–P98-Checkliste](../vision/BINDING_GAME_REQUIREMENTS_CHECKLIST.md). Die Pflichtliste wird nicht durch diesen Plan ersetzt.

## Verbindliche Entwicklungsregeln

1. **Feature-Freeze:** Keine neuen Hauptsysteme, Fraktionen oder Mechanik-Kategorien. Nur vorhandene Systeme fertigstellen, vertiefen, verbinden und nachweisbare P01–P98-Lücken schließen.
2. **Tiefe statt Breite:** Zuerst bestehende Spielentscheidungen, wirtschaftliche/gesellschaftliche/militärische Folgen, KI, Benutzerführung, Grafik und langfristige Motivation verbessern.
3. **Kein Scheinabschluss:** Ein Arbeitsschritt ist nur abgeschlossen, wenn Code, tatsächliche Integration, deterministische Tests, erfolgreiche CI und erforderliche visuelle/manuelle Evidenz vorliegen.
4. **Kanon und Scope:** Spielvision, Datenverträge, Architekturregeln und P01–P98 gelten weiter. Keine abgeschlossenen Punkte ohne Einzelbelege; keine ungefragte Erweiterung der Pflichtliste.
5. **Branch-Schutz:** Nur `design/galactic-grand-strategy-pivot` ändern; `main`, `development/foundation` und andere Projekte unberührt lassen.
6. **Fehler vor Features:** Bei Regression oder fehlerhafter CI zuerst beheben; keine weiteren Schritte als fertig melden.
7. **Nachweisbare Qualität:** Vollständige spielbare Partien und Nutzerfeedback sind wichtiger als bloße Testanzahl oder erfolgreiche Exporte.
8. **Keine endlose Iteration:** Pro Arbeitsschritt eine feste Definition of Done; nach Erfüllung wird der Umfang geschlossen. Neue Ideen werden in ein gesondertes, nicht verpflichtendes Nach-Release-Backlog aufgenommen.

## Ausführungsreihenfolge: sechs Pakete, zwölf gebündelte Durchläufe

### Paket 1 – Fehlerfreiheit und Spielbarkeit (2 Durchläufe)

**1.1 – Vollständige technische Inventur und Blocker-Fixes.** Alle 18 Galaxie-Skripte, Save-/Load-Verträge, Datenmigration, Welt-Tick, Scheduler, KI-Aktionen und die vorhandenen Tests prüfen. Reproduzierbare Bugs nach Kritikalität P0/P1/P2 erfassen; zuerst P0/P1 beheben. Testabdeckung für Endgame-Krisen, Ereignisketten, Ressourcenbuchhaltung, Spielstand-Wiederaufnahme und KI-Regeltreue erweitern. **Abnahme:** alle CI-Jobs grün, keine reproduzierten P0/P1-Fehler, jeder Fix mit Regressionstest.

**1.2 – Spielbare End-to-End-Partie.** Startassistent → Galaxie → Exploration → Expansion → Wirtschaft/Forschung/Politik/Diplomatie/Krieg → Krise/Megaprojekt → Ziel/Weiterspielen → Save/Load. Fehlende Übergänge und UI-Aktionen schließen; Langzeit- und Save/Resume-Test mit mehreren Seeds. **Abnahme:** automatisierter kompletter Pfad, dokumentierte manuelle Testpartie und Save/Load ohne verlorene Fortschritte.

### Paket 2 – Tiefe und Verzahnung der vorhandenen Mechaniken (3 Durchläufe)

**2.1 – Wirtschaft, Kolonien und Gesellschaft.** Reale Warenflüsse, Engpässe, Frachtrouten, Versorgung, Produktionsketten, Arbeitskräfte, Bevölkerung, Kultur, Staatshaushalt und Politik durchgehend koppeln; Prognosen und Konsequenzen plausibilisieren. **Abnahme:** deterministische Bilanz-/Erhaltungsinvarianten, Engpass-/Schock-Szenarien und nachvollziehbare Spielereingriffe.

**2.2 – Forschung, Diplomatie, Militär und KI.** Technologische Freischaltungen mit echten Wirkungen, Verträge mit Kosten und Konsequenzen, KI unter denselben Ressourcen-/Informationsregeln, Flottenlogistik, Kriegsziele und Friedensfolgen vertiefen. **Abnahme:** gleiche Regelpfade für Spieler und KI, mindestens drei reproduzierbare Konflikt-/Verhandlungs-Szenarien, kein kostenloser KI-Vorteil ohne explizite Schwierigkeitseinstellung.

**2.3 – Ereignisketten, Krisen und Endspiel.** Bereits vorhandene Chronik-/Krisen-/Megaprojekt-Module zu echten mehrstufigen Entscheidungen mit verzögerten Folgen, technologischen Voraussetzungen und intersystemischen Effekten verbinden. Vorhandene Sieg-/Sandboxziele schließen; keine neuen Ereignisfamilien ohne Notwendigkeit. **Abnahme:** persistente Folgeentscheidungen über Save/Load, zwei abgeschlossene Krisenpfade und mehrere sinnvoll unterscheidbare Endspielstrategien.

### Paket 3 – UI, UX und Zugänglichkeit (2 Durchläufe)

**3.1 – Informationsarchitektur und Bedienbarkeit.** Bestehende UI in wartbare Teilmodule aufteilen, ohne Verhalten zu verlieren; Navigation, Such-/Filterfunktionen, Warnungen, Tooltips, Prognosen, Aktionskosten und Fehlermeldungen vereinheitlichen. **Abnahme:** jede Kernaktion per UI erreichbar, testbare Tastaturnavigation und UI-Regressionen.

**3.2 – Onboarding und Darstellungskomfort.** Hauptmenü, Spielassistent, Tutorial, Hilfen, Skalierung, Pausen-/Geschwindigkeitseinstellungen, Save-Slots, visuelle Hierarchie und KI-Automation aus Nutzersicht testen und korrigieren. **Abnahme:** dokumentierter Erstspieler-Pfad, keine Sackgassen, lesbare Ansichten bei Zielauflösungen.

### Paket 4 – Grafik, Animation, Audio (2 Durchläufe)

**4.1 – Art-Produktionsaudit und konsistente Grafik.** Alle vorhandenen 21 Art-Dateien und ihre tatsächlichen UI-/Kartenverwendungen prüfen; vorhandene Original-Assets im verbindlichen Navy/Petrol/Cyan/Violett/Orange-Pixel-Art-Stil überarbeiten und fehlende *für bestehende Ansichten notwendige* Assets erstellen. Sprite-Atlas, Pixelraster, Palette, Größen, Filterung und Zustände vereinheitlichen. **Abnahme:** echte Godot-Screenshots sämtlicher Hauptansichten, keine Platzhalter oder unlesbaren Grafiken, dokumentierte Originalität/Lizenzen.

**4.2 – Animation und Audio.** Bestehende Karten-, Schiffs-, Ereignis- und UI-Interaktionen gezielt animieren; eigenes/rechtlich nutzbares Musik- und SFX-Set, Audio-Busse und Einstellungen integrieren. **Abnahme:** Grafik-/Audio-Regressionscheck, optische Review und Lautstärke-/Stummschaltungsprüfung. Keine urheberrechtlich geschützten Fremdassets übernehmen.

### Paket 5 – Balancing, Performance und Langzeitmotivation (2 Durchläufe)

**5.1 – Reproduzierbare Balancing-Matrix.** Gleiche Seeds × mehrere Strategien × Schwierigkeitsgrade, Endzustände und Zwischenmetriken; Wirtschaft, KI, Krieg, Expansion, Forschung und Krisen systematisch vergleichen. **Abnahme:** messbare Auswertung, konkrete Parameterkorrekturen, keine dominierende triviale Strategie ohne begründete Gegenstrategie.

**5.2 – Performance und vollständige Spielpartien.** Große Galaxien mit 250 Sternen/20 KI, UI-Interaktion, Tickzeiten, RAM und Windows-Bildraten messen; mehrere tatsächlich vollständige Partien und Save/Resume protokollieren. **Abnahme:** dokumentierte Zielhardware-Budgets, keine kritischen Performance-/Speicherblocker, vollständige Spielprotokolle.

### Paket 6 – Release und P01–P98-Einzelabnahme (1 Durchlauf)

**6.1 – Release-Kandidat und Abnahme.** Alle 98 Pflichten mit Commit, Test, Ergebnis und gegebenenfalls Screenshot/Windows-/Nutzerbeleg einzeln abnehmen; alle Regressionen grün, Windows-10/11-Start und echte Nutzer-Spieltests, Lizenzprüfung, Build-Reproduzierbarkeit, Changelog, bekannte Einschränkungen und Release-Archiv. **Abnahme:** keine offenen releaseblockierenden P01–P98-Pflichten; sonst ausdrücklich kein Release.

## Verbindliche Statusführung

Jeder Durchlauf erhält `docs/progress/FINAL_PASS_<paket>_<lauf>.md` mit: Scope, betroffenen Pflichten, Fehlern vor/nach Änderung, Code-Dateien, Commit-SHA, Testbefehlen, CI-Run/Ergebnis, manueller/visueller Evidenz, offenen Blockern und eindeutiger Entscheidung **BESTANDEN / NICHT BESTANDEN**.

Status nur aus realen Belegen ableiten: **OFFEN → IN ARBEIT → CI BESTANDEN → ABGENOMMEN**. Ein CI-Erfolg ist nicht automatisch die manuelle Abnahme.

### Arbeitsboard (Startstatus)

| Durchlauf | Status | Abhängigkeit |
| --- | --- | --- |
| 1.1 Technik/Blocker | OFFEN | sofort |
| 1.2 End-to-End | OFFEN | 1.1 |
| 2.1 Wirtschaft/Gesellschaft | OFFEN | 1.2 |
| 2.2 Forschung/Diplomatie/Militär/KI | OFFEN | 2.1 |
| 2.3 Ereignisse/Endspiel | OFFEN | 2.2 |
| 3.1 Informationsarchitektur | OFFEN | 2.3 |
| 3.2 UX/Onboarding | OFFEN | 3.1 |
| 4.1 Originalgrafik | OFFEN | 3.2 |
| 4.2 Animation/Audio | OFFEN | 4.1 |
| 5.1 Balancing | OFFEN | 4.2 |
| 5.2 Performance/Playtests | OFFEN | 5.1 |
| 6.1 Release-Abnahme | OFFEN | 5.2 |

**Erster konkreter Auftrag:** `Paket 1 – Durchlauf 1`. Vorherige A–H-Implementierungen bleiben erhalten; die neue Nummerierung ist ein Abschlussplan, kein Neustart.
