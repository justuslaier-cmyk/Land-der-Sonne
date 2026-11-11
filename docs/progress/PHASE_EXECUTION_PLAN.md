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

### Phase 03 — Durchlauf 01 (2026-11-11)
- **Ziel:** Deterministische Sternverteilung und sicherere, räumlich getrennte Startpositionen.
- **Befund:** Der Generator verteilte gegnerische Hauptwelten bisher nach Array-Index, nicht nach räumlicher Distanz. Bei spiralförmiger, elliptischer und ringförmiger Galaxie kann Indexabstand eine schlechte räumliche Trennung bedeuten. Die Spielerhauptwelt war bereits immer bewohnbar und besessen.
- **Implementiert:** Deterministisches farthest-first-Verfahren wählt für jedes KI-Reich den noch freien Stern, dessen minimale quadratische Entfernung zu allen bereits gesetzten Hauptwelten maximal ist. Stabiler Tie-Break durch aufsteigende Stern-ID. Bestehende `star.id`-Indizes und `ai[].capital`-Referenzen bleiben gültig. Keine neue Save-Schema-Version.
- **Test:** `galaxy_start_spacing_test.gd` prüft 12 feste Seed/Form-Kombinationen mit jeweils 100 Sternen und 12 Rivalen auf deterministische Gleichheit, Weltstruktur, Spielerhauptwelt, eindeutige KI-Hauptwelten und farthest-first-Auswahl; in CI registriert.
- **Einschränkungen:** Keine garantierten Ressourcen-/Technologie-/Nachbar-Gleichheiten, keine Sternrouten-/Erreichbarkeitsgarantie, keine Kollisionsfreiheit aller Sternkoordinaten. Diese Anforderungen bleiben offen und sind Gegenstand weiterer Phase-03-Durchläufe.
- **Betroffene Pflichten:** P11–P12, P14–P15, P87–P91. **Keine Pflicht als vollständig abgenommen markiert.**
- **CI:** Ergebnisse zum neuen Code-SHA abwarten und gegebenenfalls Fehler korrigieren.

### Phase 03 — Durchlauf 02 (2026-11-11)
- **Ziel:** Erkundungs- und Flottennavigation als nachvollziehbare, getestete Spielbefehle weiterentwickeln.
- **Bestand:** Zoom, Pan, Sternselektion, Sichtbarkeitszustand `known`, Erkundung und Direktflug existierten bereits. Kein interstellares Routennetz.
- **Implementiert:** `GalaxySystems.route_preview(world, target)` liefert für bekannte Ziele ohne Zustandsänderung Zulässigkeit, Ablehnungsgrund, Distanz, Reisezeit und Reichweite; `survey_preview` liefert Reichweitenprüfung für unbekannte Ziele. Die tatsächlichen Befehle `move_fleet` und `explore` nutzen dieselben Kriterien.
- **UI:** Sternendetails zeigen Erkundungsberechtigung bzw. Sperrgrund, für bekannte Ziele Flugdistanz und Reisezeit oder konkreten Ablehnungsgrund; ungültige Aktionsknöpfe werden nicht angeboten. Rückmeldungen nennen den tatsächlichen Grund.
- **Test:** `galaxy_navigation_test.gd` prüft Vorschau ohne Mutation, unbekannte/ungültige Ziele, Erkundung, bekannten Zielanflug und blockierte Doppelaufträge; CI-Workflow ergänzt.
- **Einschränkungen:** Flüge bleiben direkte euklidische Strecken ohne Hyperraumgraphen, Mehrstopp-Routing, Wegfindung, Treibstoffverbrauch, taktische Risiken oder differenzierte Sensoren. Die UI ist noch nicht visuell/manuell abgenommen. Neuer CI-Lauf muss noch bestätigt werden.
- **Pflichtstatus:** P05, P11–P15, P90–P91 bleiben offen.

### Phase 03 — Durchlauf 03 (2026-11-11)
- **Ziel:** Galaxieskalierung, Erreichbarkeit der geografischen Sternverbindungen und deterministische Kartennavigation absichern.
- **Implementiert:** `GalaxyRoutes.build(stars)` erzeugt mit einem deterministischen Prim-MST einen zusammenhängenden ungerichteten Sternverbindungsgraphen (N−1 Kanten). `GalaxyModel.generate` speichert ihn in `world.lanes`; `GalaxySystems.prepare` rekonstruiert ihn für alte Version-1-Spielstände. `GalaxyRoutes.valid` prüft Kantenanzahl, Indexgrenzen und graphische Zusammenhangseigenschaft. Die Karte zeichnet Verbindungen ausschließlich zwischen bereits kartografierten Sternen.
- **Regression:** `galaxy_geography_test.gd` prüft 3 Größen (20, 60, 250) × 3 Formen × 2 Seeds = 18 Fälle auf Zusammenhang, reproduzierbare Kanten, gültige Koordinaten und Legacy-Rekonstruktion; in CI registriert.
- **Architekturgrenze:** MST-Kanten sind **geografische Referenzverbindungen**, keine derzeit von Flotten befahrenen Hyperraumrouten. `move_fleet` nutzt weiterhin direkte Distanz und maximale Reichweite; damit ist die Erreichbarkeit über beliebig viele Etappen **nicht** nachgewiesen. MST kann lange Kanten enthalten, die außerhalb der Flottenreichweite liegen.
- **Weitere Grenzen:** Kein vollständiger graphbasierter Pfadfinder, keine Kosten-/Gefahrmodellierung, kein Vermeiden von Sternüberlagerungen, keine visuelle oder native Windows-Abnahme. Keine Pflichtanforderung P05/P11–P15 vollständig erfüllt.
- **CI:** Die neuen Tests gelten erst nach einem abgeschlossenen grünen Lauf als bestanden; keine vorgezogene Abnahme.
- **Nächste Phase:** Phase 04 / Durchlauf 01 beginnt mit detaillierten Stern- und Planetensystemen. Offene Navigations- und Graphanforderungen bleiben im Pflichtenregister bestehen.

### Phase 04 — Durchlauf 01 (2026-11-11)
- **Ziel:** Vorhandene Stern- und Planetengenerierung an sieben Sternklassen und garantiert bewohnbare Reichshauptwelten anbinden.
- **Befund:** `GalaxyCelestials` enthielt sieben Sternklassen, acht Planetentypen und stabile On-Demand-Generierung, aber `GalaxyModel` erzeugte `star.kind` nur zwischen 0 und 3. KI-Hauptwelten konnten unbewohnbare Systeme erhalten. Die generierte Bewohnbarkeit der Planeten war nicht explizit an die Hauptweltgarantie gebunden.
- **Implementiert:** `star.kind` wird von 0 bis 6 erzeugt. KI-Hauptsterne werden als bewohnbar markiert. `GalaxyCelestials.generate` erzwingt bei bewohnbaren Systemen einen bewohnbaren zweiten Planeten. Bereits existierende Save-Daten bleiben strukturell kompatibel; für ältere Saves ohne bewohnbare KI-Hauptsterne wird keine rückwirkende Garantie behauptet.
- **Regression:** `galaxy_planet_systems_test.gd` prüft drei feste Seeds × 100 Sterne = 300 Sternsysteme, sieben Sternklassen, Determinismus, Planeten-/Mond-Grenzen, Umlaufbahnen und alle Reichshauptwelten; im CI-Workflow registriert.
- **Grenzen:** Planetensysteme sind weiter on-demand generiert und nicht als vollständige eigenständige Weltobjekte persistent gespeichert. Es fehlen Orbitalsimulation, Sternphysik, individuelle Planetenzustände und tiefere Besiedlungsregeln. Bestehende Planetenkolonien sind Prototypen.
- **Pflichten:** P13, P16–P17, P87–P91 bleiben offen. Keine vollständige Abnahme vor CI und Integrationstests.

### Phase 04 — Durchlauf 02 (2026-11-11)
- **Ziel:** Planetare Eigenschaften, Kolonisierung und erste ökologische Folgen in die bestehende planetenspezifische Verwaltung integrieren.
- **Bestand:** `GalaxyStrategy.settle_planet` verlangt eigene Systemhoheit, einen bewohnbaren Planeten und 50 Credits; planetenspezifische Gebäude existieren bereits. Die Himmelskörper werden stabil on-demand generiert.
- **Implementiert:** `GalaxyCelestials.generate` ergänzt Klima, Ökosystem, Umweltbelastung (0–100) und Kennzeichnung des Terraforming-Potenzials als rein abgeleitete Felder, ohne zusätzliche RNG-Aufrufe. Neue Kolonien speichern einen anfänglichen Belastungswert und eine einfache Tragfähigkeit. Minen erhöhen die persistierte Belastung um 6, Fabriken um 4 bis höchstens 100. Die Planetenverwaltung zeigt alle Werte und die Terraforming-Eignung an.
- **Regression:** `galaxy_planet_colonization_test.gd` prüft Determinismus, Grenzen, Koloniegründung, 50-Credit-Kosten, Doppelgründungs-/Indexschutz und steigende Umweltbelastung. In CI registriert.
- **Kompatibilität:** Alte Kolonien ohne neue Felder bleiben lesbar und nutzen UI-Fallbacks. Es gibt keine automatische Migration ihrer Umweltbasis.
- **Einschränkungen:** Tragfähigkeit und Umweltbelastung sind aktuell gespeicherte Parameter, **noch ohne** Bevölkerungswachstums-, Produktivitäts-, Klima- oder Ökosystemfolgen im Jahres-Tick. Terraforming ist nicht ausführbar. Die koloniale Bewohnbarkeit ist weiterhin ein binäres Merkmal.
- **Pflichtstatus:** P16–P17 sowie P87–P91 bleiben offen. CI und native UI-Abnahme ausstehend.

### Phase 04 — Durchlauf 03 (2026-11-11)
- **Ziel:** Die in Durchlauf 02 gespeicherten Umwelt- und Tragfähigkeitswerte in den Simulations-Tick und die Wirtschaftsprognose integrieren.
- **Implementiert:** `GalaxyStrategy.colony_capacity` reduziert die effektive Tragfähigkeit um je eine Einheit pro 20 Belastungspunkte (mindestens 1). `advance_colonies` erhöht Bevölkerung bei vorhandener Kapazität alle fünf Spieljahre um höchstens 1; oberhalb der Kapazität sinkt sie um 1 je Tick. `colony_upkeep` belastet die Staatskasse um je einen Credit pro 25 Belastungspunkte und eigener Kolonie. Prognose und Tick verwenden denselben Kostenrechner.
- **Regression:** `galaxy_colony_simulation_test.gd` prüft Wachstum, Intervall, Umweltgrenzen, Rückgang, Unterhaltskosten, Forecast und deterministische Wiederholung; in CI registriert.
- **Kompatibilität:** Für ältere Kolonien ohne neue Felder greifen konservative Fallbacks. Es gibt noch keine vollständige Save-Migration.
- **Grenzen:** Es handelt sich um ein vereinfachtes Bevölkerungskapazitäts- und Umweltkostenmodell, noch ohne planetare Klimadynamik, Terraforming, artspezifische Lebensräume, Ressourcenerschöpfung, Ökosystemrückkopplungen oder separate Kolonialverwaltung mit differenzierten Bevölkerungsklassen. Die visuellen Spieltests und CI-Abnahme sind ausstehend.
- **Pflichtstatus:** P13, P16–P17, P87–P91 bleiben offen. Phase 04 ist als drei Durchläufe bearbeitet, nicht vollständig abgenommen.
- **Nächster Planabschnitt:** Phase 05 / Durchlauf 01: Spezies und Kulturen. Die nicht erfüllten Planetensystem-Pflichten bleiben verbindlich offen.

### Phase 05 — Durchlauf 01 (2026-11-11)
- **Ziel:** Bereits bestehende Spezies-/Staatsidentitäten um einen eigenständigen, zeitlich veränderlichen Kulturzustand erweitern.
- **Bestand:** `GalaxyIdentity` definiert sechs Civics, acht Traits, vier Ethiken, vier Regierungsformen, Budget-/Konfliktprüfung und numerische Modifikatoren. Spieler- und KI-Reiche nutzen diese bereits teilweise in Zivilwirtschaft und KI-Gesellschaft.
- **Implementiert:** `GalaxyIdentity.culture_defaults` legt vier Kulturachsen (Tradition, Offenheit, Zusammenhalt, Handelsorientierung) als Werte 0–100 an. `culture_tick` verändert sie deterministisch anhand von Wohlstand, Zufriedenheit und Ethik; alle 20 Jahre entsteht eine Generation mit begrenztem historischem Snapshot (max. acht Einträge). `GalaxyStrategy` und `GalaxyAI` führen unabhängige Spieler- bzw. KI-Kulturen in der Jahressimulation; das Politikmenü zeigt den Spielerzustand.
- **Regression:** `galaxy_culture_test.gd` prüft Spieler-/KI-Initialisierung, idempotente Vorbereitung, 20-Jahres-Generationen, Wertebereich, Determinismus, getrennte KI-Entwicklung und Save-/Load-Persistenz; im CI-Workflow registriert.
- **Kompatibilität:** Vorhandene Saves erhalten fehlende Kulturzustände beim nächsten `prepare` automatisch. Bestehende biologische Traits und Civics werden nicht geändert.
- **Grenzen:** Kulturachsen sind bisher **beschreibende Simulationszustände** ohne eigene politische, religiöse, diplomatische oder wirtschaftliche Wirkungen. Keine Kulturverbreitung, Assimilation, Minderheiten, Herkunfts-/Flaggen-Editoren oder strukturellen Regierungssysteme. Generationschronik erfasst nur numerische Zustände, keine historischen Personen oder Ereignisinterpretationen.
- **Pflichtstatus:** P18–P24 und P87–P91 bleiben offen. CI-Bestätigung und visuelle Abnahme ausstehend.
