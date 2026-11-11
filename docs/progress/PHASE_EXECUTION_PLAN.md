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
