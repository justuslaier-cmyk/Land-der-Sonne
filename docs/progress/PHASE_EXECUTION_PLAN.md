# 16-Phasen-Produktionsplan — verbindliche Arbeitszuordnung

Beschlossen 2026-11-11 auf Nutzeranweisung: Der Nutzer steuert mit „Phase N Durchlauf M“. **Die 98 Pflicht-IDs in [BINDING_GAME_REQUIREMENTS_CHECKLIST.md](../vision/BINDING_GAME_REQUIREMENTS_CHECKLIST.md) sind die unabhängigen Abnahmekriterien und bleiben unabhängig von dieser Planung.** Dieses Dokument teilt die Arbeit auf 16 Phasen mit jeweils drei **geplanten** Durchläufen auf. Es ersetzt die frühere vorläufige 12-Phasen/36-Durchläufe-Organisation; **48 Durchläufe sind kein garantierter Fertigstellungstermin oder ehrlicher Vollständigkeitsbeweis**. Wenn nach Phase 16 / Durchlauf 3 Pflichten offen bleiben, müssen diese offen ausgewiesen und zusätzliche Arbeit geplant werden. Keine fiktiven Häkchen.

Jeder Durchlauf: (a) aktuellen Branch und relevante Pflicht-IDs prüfen; (b) konkrete Dateien, Abhängigkeiten und CI ansehen; (c) Änderungen in kleinen nachvollziehbaren Commits; (d) Tests und tatsächliche Ergebnisse dokumentieren; (e) Checkliste nur bei vollständiger Abnahme abhaken; (f) nächsten Durchlauf vorbereiten. Entwicklung erfolgt **parallel** über Systemgrenzen, nicht als starre Sperre auf spätere Phasen.

| Phase | Primärer Verantwortungsbereich | Pflicht-IDs | Durchlauf 1 | Durchlauf 2 | Durchlauf 3 |
|---|---|---|---|---|---|
| 01 | Technischer Ausgangspunkt und Verträge | P87–P91, P96 | CI-Fehler beheben, Bestand und Risiken inventarisieren | Simulationsverträge, Testinvarianten | Integration, CI, technische Baseline |
| 02 | Hauptmenü, Einstellungen, Einstieg | P01–P04, P09 | Flows und Zustände | Einstellungen, Vorlagen, Validierung | End-to-end-UX und Abnahme |
| 03 | Galaxis, Karte, Reisen | P05, P11–P15 | Generator und Startbedingungen | Erkundung und Navigation | Skalierung und Test |
| 04 | Sternsysteme, Planeten, Kolonien | P13, P16–P17 | Planetendaten | Kolonisierung/Ökologie | Integration und Test |
| 05 | Spezies und Kulturen | P18–P24 | Traits, Herkunft | kulturelle Evolution | Integration und Test |
| 06 | Bevölkerung und Bedürfnisse | P25–P33 | Kohorten/Bedarfe | Arbeit, Gesundheit, Migration | Sozialdynamik und Test |
| 07 | Produktionswirtschaft | P34–P39 | Warenbilanz | Unternehmen, Märkte, Finanzen | Integration und Test |
| 08 | Logistik und Handel | P40–P43 | Routen und Transport | Piraterie, Engpässe, Verträge | KI-Integration und Test |
| 09 | Regierungsformen und Politik | P44–P50 | Entscheidungsverfahren | Gesetze, Fraktionen, Konflikte | Krisen und Test |
| 10 | Forschung und Fortschritt | P51–P55 | Technologiearchitektur | Wissenssysteme | Integration und Test |
| 11 | Diplomatie und Beziehungen | P56–P58, P24 | Diplomatie und Informationsmodell | Föderationen/Spionage | KI-Integration und Test |
| 12 | Militär und Krieg | P59–P64 | Schiffsdesign/Flotten | Gefechte, Nachschub, Kriegsfolgen | KI-Integration und Test |
| 13 | Geschichte und Ereignisse | P07, P65–P72 | Kausale Engine | Erzählketten, Archive, Krisen | Langzeitziele und Test |
| 14 | KI und Systemintegration | P73–P79 | Strategie/Operations-KI | Simulationsskalierung | Erklärbarkeit, Soak-Tests |
| 15 | Grafik, Audio, Zugänglichkeit | P06, P80–P86, P95 | Visuelle Designsprache | Assets, Audio, UI | Screenshots, UX- und Zugänglichkeitsabnahme |
| 16 | Spielbarkeit, Balance und Release | P08, P10, P89–P98 | Vollständige Spielpartien, Bugs | Balance, Profiling, Windows-Tests | Release-Gates, dokumentierte Endabnahme |

**Wichtig:** Die Reihenfolge bezeichnet den primären Fokus, nicht den erstmaligen Beginn. Jede Phase muss Kernfunktionen aus anderen Bereichen weiterführen. P98 wird nicht automatisch durch „Phase 16 / Durchlauf 3“ erfüllt.

## Durchlaufprotokoll

### Phase 01 — Durchlauf 01 (2026-11-11)
- **Ziel:** Nachweislich vorhandene CI-Blocker isolieren und beheben; verbindliche Planung auf 16 Phasen umstellen; Bestandsdokumentation aktualisieren.
- **Bisherige Beobachtung:** CI-Run `43086718250` für `1d178dbe789ec9b8c8a1cf9dbdcfc42764e5f982`: Render-Check und Windows-Export erfolgreich; `godot-smoke` fehlgeschlagen. Parserfehler `galaxy_ui.gd:657` (reservierter Variablenname `trait`) und `galaxy_progress_test.gd:23` (Typinferenz).
- **Änderungen:** `trait` in `trait_data` umbenannt; `achieved` explizit als `int` typisiert.
- **Betroffene Pflicht-IDs:** P87, P90, P91, P96; **alle weiterhin offen**, bis die nötigen Abnahmen vorliegen.
- **Verifikation:** Nachfolgende CI-Runs und ggf. neue Fehler separat protokollieren; nicht aus bloßen Commits auf Erfolg schließen.

### Phase 01 — Durchlauf 02 (2026-11-11)
- **Ziel:** Simulationsverträge, strukturelle Weltinvarianten und begrenzte deterministische Replay-Tests.
- **CI-Ausgangsbefund:** Run `43088330913` nach den Parserkorrekturen: `render-check` und `windows-export` bestanden, `godot-smoke` scheiterte im Identitätstest mit `AI empire has no cultural identity`. Vorherige Galaxie-, Wirtschafts- und Strategietests meldeten PASS.
- **Codekorrektur:** `GalaxyStrategy.prepare` initialisiert jetzt `GalaxyAI.prepare` vor weiteren Simulationen; dadurch sollen KI-Identitäten und Gesellschaftsdaten bereits vor dem ersten Tick existieren.
- **Neue Verträge:** `GalaxyContracts.errors(world)` prüft ohne Mutation IDs, Eigentümer, ausgewählte zivile Bestände und Frachtdatensätze.
- **Neue Tests:** `galaxy_contracts_test.gd` prüft Initialzustand, zwei gleich gestartete 12-Tick-Simulationen, Negativfälle und Save/Load. In CI aufgenommen.
- **Dokumentation:** `docs/architecture/DATA_CONTRACTS.md` enthält das tatsächliche Galaxie-Schema, die Tick-Reihenfolge und offene Bilanzierungs-/Migrationsrisiken.
- **Betroffene Pflicht-IDs:** P24, P75, P87, P88, P89, P90, P91, P96; **weiterhin offen**.
- **Nachweisgrenze:** Neuer vollständiger CI-Lauf zum Stand der Änderungen war bei der letzten Abfrage noch nicht abgeschlossen. Tests gelten daher nicht als bestanden.

### Phase 01 — Durchlauf 03 (2026-11-11)
- **Ziel:** technische Baseline anhand realer CI-Ergebnisse bestätigen, Qualitätsgrenzen und Übergang in Phase 02 dokumentieren.
- **Nachgewiesen:** CI-Run [43088734325](https://github.com/justuslaier-cmyk/Land-der-Sonne/actions/runs/43088734325), SHA `9d713605c708b6792dd6aace330e845961df8df6`: `godot-smoke` **success** und `render-check` **success**. Der Godot-Test meldet `GALAXY_IDENTITY_PASS`, `GALAXY_PROGRESS_PASS`, `GALAXY_CONTRACTS_PASS` und `GALAXY_AI_PASS`, neben den anderen vorhandenen Tests.
- **Abschließend bestätigt:** `windows-export` **success**, gesamter CI-Workflow **success**. Ein tatsächlicher Windows-Spielstart wurde weiterhin nicht geprüft.
- **Fazit:** Die bislang bekannten CI-Blocker sind im Smoke-Test behoben. Eine begrenzte technische Regression-Baseline ist vorhanden. Die Produktionsarchitektur ist **nicht** fertig: kein vollständiges Ressourcenledger, keine versionierte Save-Migration, keine unabhängigen RNG-Streams, keine langfristigen Soak- und nativen Interaktionstests.
- **Betroffene Pflicht-IDs:** P87–P92, P96; **alle offen**, da die jeweiligen umfassenden Akzeptanzkriterien noch nicht erfüllt sind.
- **Folgearbeit:** Phase 02 / Durchlauf 01 fokussiert Hauptmenü und vollständige Startflows. Architektur- und Bilanzierungsrisiken bleiben parallele Aufgaben und dürfen nicht als „Phase 1 erledigt“ verschwinden.

### Phase 02 — Durchlauf 01 (2026-11-11)
- **Ziel:** Einstieg, Startassistent, Zustandswechsel und Navigation überprüfen und konkrete Lücken beheben.
- **Ist-Befund:** Der Menüeintrag `NEUES SPIEL` öffnete zuvor die Einstellungen ohne Zurücksetzen eines älteren Entwurfs. `_start_game` setzte den Seed immer auf 0, selbst wenn ein fester Seed im Einstellungszustand vorhanden war. Der Wizard hatte keine eigene Abbrechen-/Zurücksetzen-Funktion.
- **Implementiert:** `_begin_new_game` setzt den neuen Entwurf auf Defaults zurück; `_cancel_new_game` verwirft ihn; `_reset_new_game` setzt alle Werte zurück. Die drei Wizard-Seiten bieten jetzt Abbrechen und die Einstellungen bieten Zurücksetzen. Vorwärts-/Rückwärtsnavigation bewahrt den laufenden Entwurf. `_start_game` respektiert einen gesetzten Seed; 0 erzeugt weiterhin zufällige Galaxien.
- **Test:** `game/tests/galaxy_wizard_test.gd` deckt Menüzustand, Navigation, Entwurfserhalt, Reset, Abbrechen, Validierung und Seed-Erhalt ab; im Godot-CI-Workflow registriert.
- **Betroffene Pflichten:** P01–P04, P09, P90–P91; alle **offen** bis zur vollständigen Abnahme.
- **Nicht in diesem Durchlauf umgesetzt:** UI-Fehlermeldungen unmittelbar auf jeder Wizard-Seite, vollständig konfigurierbare Galaxieparameter, Reichsvorlagen, Einstellungen-Persistenz, optische Abnahme und Tutorial.
- **CI:** Der neue Workflow muss nach dem letzten Code-Commit abgeschlossen und ausgewertet werden, bevor ein Testerfolg behauptet wird.

### Phase 02 — Durchlauf 02 (2026-11-11)
- **Ziel:** Konfigurierbarer Seed, editierbare Reichsvorlagen, vollständigeres Eingabe-Feedback und neue Validierungstests.
- **Bestätigter Ausgangsstand:** CI-Run `43089149418` für den letzten Stand von Durchlauf 01 vollständig `success`.
- **Implementiert:** `GalaxyModel.validate` prüft Seed, Form, Schwierigkeit, Bewohnbarkeit, Ressourcen, Ereignisrate und Heimatwelt. Die UI besitzt einen Seed-SpinBox-Eingang (0 = zufällig), begrenzt die KI-Zahl anhand der aktuellen Sternenzahl, bietet drei vordefinierte Reichsprofile und zeigt den Seed in der Zusammenfassung. Der Wizard meldet ungültige Einstellungen beim Weiterklicken.
- **Tests erweitert:** `galaxy_wizard_test.gd` prüft alle drei Vorlagen, Technokratie-Voreinstellung, ungültige Form, Bewohnbarkeit und fehlende Heimatwelt.
- **Betroffene Pflichten:** P02–P04, P09, P90–P91. Alle **offen**.
- **Noch offen:** Die Vorlagen sind vordefiniert, nicht dauerhaft vom Spieler speicherbar. Nicht alle theoretisch vorgesehenen Galaxieparameter sind implementiert; manche UI-Validierungen erfolgen erst bei Navigation; visuelle Interaktion und Windows-Start sind nicht abgenommen.
- **CI-Status:** Der aktualisierte Testlauf für Durchlauf 02 war zum Zeitpunkt der Implementierung noch nicht abgeschlossen. Keine Aussage über dessen Bestehen.

### Phase 02 — Durchlauf 03 (2026-11-11)
- **Ziel:** End-to-end-Startfluss, konkrete Bedienungsfehler, Test- und Abnahmegrenzen prüfen.
- **Befund:** Der zuvor erfolgreiche CI-Run `43089149418` betrifft Durchlauf 01. Neuere Runs für Durchlauf 02 wurden bei nachfolgenden Commits abgebrochen (GitHub-Actions-Concurrency); sie sind **kein** Testerfolgsnachweis.
- **Korrekturen:** Bei Größenänderung der Galaxis wird die KI-Obergrenze erneut berechnet und `ai_count` nötigenfalls reduziert; die Reichserstellung meldet ungültige Einstellungen unmittelbar vor dem Wechsel zur Zusammenfassung; Hauptmenü und Einstellungen beschreiben die Seed-Funktion korrekt.
- **Regression:** `galaxy_wizard_test.gd` prüft zusätzlich die 20-Sterne-Grenze mit 5 unzulässigen und 4 zulässigen KI-Reichen. Bereits bestehende Tests prüfen die Wizard-Zustände, Vorlagen, Validierung und Seed-Übernahme.
- **Dokumentationskorrektur:** Pflichtcheckliste verweist jetzt auf die vom Nutzer festgelegten 16 × 3 = 48 geplanten Durchläufe; keine Fertigstellungsgarantie.
- **CI bei letzter Abfrage:** Run `43089548236` für Code-SHA `7375fccad4b19b19c1c74fca0fb624000ce10340` war `queued`. Keine vollständige CI-Abnahme behaupten.
- **Pflichtstatus:** P01–P04, P09, P90–P91 bleiben **offen**. Grund: fehlende vollständige UI-Einstellungen, persistente eigene Reichsvorlagen, alle geforderten Galaxieparameter, Tutorial, native/visuelle UX-Abnahme.
- **Übergang:** Phase 03 / Durchlauf 01 beginnt mit Galaxiegenerator, sicheren Startbedingungen und Geografie; die unvollständigen Phase-02-Pflichten bleiben unabhängig als verbindliche offene Arbeit bestehen.
