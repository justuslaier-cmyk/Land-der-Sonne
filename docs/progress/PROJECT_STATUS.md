# Projektstatus — 2026-11-11 — Land der Sonne (galaktisches Strategiespiel)

## Arbeitsstand
**Phase 16 / Durchlauf 03** im Entwicklungsbranch `design/galactic-grand-strategy-pivot`. Die **16 × 3 geplanten Durchläufe** wurden als Arbeitsrunden bearbeitet; dies ist **keine** technische Abnahme oder Veröffentlichung.

## Verbindliche Abnahme
**0 / 98 Pflichtanforderungen vollständig abgenommen.** Maßgeblich ist `docs/vision/BINDING_GAME_REQUIREMENTS_CHECKLIST.md`; einzelne implementierte Teilfunktionen dürfen nicht als vollständig erfüllte Pflichten gezählt werden.

## Implementierte Teilfunktionen
- Godot-4.3-Prototyp mit Galaxiekarte, Neues-Spiel-Assistent, Zeitsteuerung und versionierter JSON-Speicherung.
- Prozedurale Galaxie und Himmelskörper, Gesellschaften, zivile Wirtschaft, Logistik, Diplomatie, Forschung, Flotten und KI als unterschiedliche Ausbaustufen.
- Phase 13: Ereignis-/Story-Module und Narrative-Director **isoliert**, nicht als vollständiger Spiel-UI/Tick-Pfad integriert.
- Phase 14: strategische KI-Bewertung, einmaliger Eigentumsindex pro Tick und begrenztes Entscheidungsjournal.
- Phase 15: zentrale UI-Farbwerte, Ereigniskartenkopf, responsive Abstände, Textumbruch und Kontrastprüffunktionen.
- Phase 16: CI-Testmatrix für acht Phase-13–15-Regressionstests mit `fail-fast: false`. Der 120-Jahre-KI-Replaytest prüft nun auch den jährlichen Fortschritt und JSON-Zwischenstände.

## Nachweisbare Qualität
- **Historischer, nicht aktueller Stand:** Workflow [43088734325](https://github.com/justuslaier-cmyk/Land-der-Sonne/actions/runs/43088734325) war bei einem frühen Phase-01-Commit erfolgreich. Dieser Erfolg ist **kein** Nachweis für den aktuellen Branchstand.
- Workflow [43099177950](https://github.com/justuslaier-cmyk/Land-der-Sonne/actions/runs/43099177950) für Phase 16/1: Beim letzten Abruf standen `godot-smoke`, `render-check` und `windows-export` weiterhin auf **queued**. Keine Fehlerlogs oder Erfolgsergebnisse verfügbar.
- Godot lokal nicht installiert; GitHub-Klon über das lokale Netzwerk wegen DNS-Fehler nicht möglich. Daher keine lokalen Godot-Test-, Render- oder Windows-Laufzeitnachweise.
- Die neue Matrix und der überarbeitete Soak-Test sind **nicht** erfolgreich ausgeführt oder abgenommen.

## Release-Blocker (priorisiert)
1. GitHub-Actions-Jobs tatsächlich ausführen; CI-Logs und konkrete Fehlschläge analysieren, beheben und grün nachweisen.
2. 120-Jahre-Simulation inklusive Save/Load real bestehen lassen; Langzeitinvarianten und Laufzeit messen.
3. Narrative-Director in den tatsächlichen Tick-, Auswahl-, Speicher- und UI-Pfad integrieren.
4. Grafik-/Audioressourcen, Lesbarkeit und Steuerung bei mehreren Auflösungen real prüfen.
5. Windows-Export **nativ** starten und vollständige Spielpartien testen.
6. Für jeden der 98 Pflichtpunkte getrennte Integration, Tests, Artefakte und Abnahmebelege führen.


## Verifizierter CI-Stand und Gesamtaudit — 2026-11-12

- Aktueller geprüfter Prototyp: CI-Lauf [43214501265](https://github.com/justuslaier-cmyk/Land-der-Sonne/actions/runs/43214501265), **17/17 Jobs erfolgreich**: Godot-Smoke, 13 Regressionen, Render-Check, Windows-Export, Windows-2022-Headless-Start und Integration mit Marker `GALAXY_INTEGRATION_PASS`.
- Diese Evidenz ersetzt die oben genannten historischen CI-Blocker, **aber nicht** die unabhängigen 98 Vollabnahmen. Die 0/98 bleiben ohne individuelle Nachweise bestehen.
- Verifiziert: automatisierte Integrationspfade und Windows-Headless-Lauf. Nicht verifiziert: sichtbare Windows-10/11-Bedienung, reale vollständige Spielpartien, Langzeitbalance, größere Galaxien unter Performancebudget, vollständige Anforderungserfüllung.
- Korrigierte README im Audit-Commit: die ursprüngliche Fantasy-RPG-Beschreibung war überholt.

### Priorisierte Restarbeit nach Pflichtkatalog

1. **P87–P98 / Release und Stabilität:** individuelle Nachweise, Save-Slot/Backup/Migration, Performancebudgets, reproduzierbare lange Spielpartien, tatsächliche Benutzerabnahme. Headless-Start allein reicht nicht.
2. **P01–P10, P80–P86 / Bedienung und Präsentation:** durchgängige Navigation, skalierbare Informationsdichte, Tooltips, Tutorials, konsistente Originalgrafik, Audio und reale Interaktionsprüfung.
3. **P25–P50 / Gesellschaft, Wirtschaft, Politik:** kohärente Bilanzierung, autonome Reaktionen, Regierungssysteme, Markt- und Logistikketten, historische Auswirkungen. Existierende Teilmodule sind nicht mit vollständiger Integration gleichzusetzen.
4. **P51–P64 / Forschung, Diplomatie, Militär:** echte Spezialisierungen, Technologieverbreitung, Spionage, Versorgung, Kriegsziele, Friedensfolgen und balancierte KI.
5. **P11–P24, P65–P79 / Galaxis, Identität, Geschichte, KI:** systemische Tiefe, Erkundungsrisiken, Krisen, dynamische Geschichte, KI-Transparenz und großskalige Reproduzierbarkeit.

### Durchlaufplanung und Zeitrisiko

Ein einziger Entwicklungsdurchlauf ist für 98 voneinander abhängige Pflichtabnahmen nicht seriös als ausreichend belegbar. Die im Pflichtkatalog genannte Zahl **48** ist eine Organisationsannahme, keine verifizierte Fertigstellungsprognose. Die minimale Zahl hängt von messbaren Durchlaufzeiten, den noch fehlenden vertikalen Integrationen und der tatsächlichen Testabdeckung ab. Keine Zusage einer fixen Dauer oder vollständigen Erledigung ohne diese Messungen.

### Vergleichsmaßstäbe (Recherche, 2026-11-12)

- Godot Windows-Export und CI: https://docs.godotengine.org/en/latest/tutorials/export/exporting_for_windows.html ; https://github.com/abarichello/godot-ci/blob/master/.github/workflows/godot-ci.yml
- Galactic Civilizations IV: Schiffsentwurf, mehrere Siegespfade, Kultur, KI, Diplomatie: https://archive.stardock.com/galciv4/press/gc4-documents/galciv4_reviewguide.pdf
- Distant Worlds 2: Automatisierung, private Wirtschaft, Logistik, kontextuelle Hilfe, Galaxiegröße: https://store.steampowered.com/app/1531540/Distant_Worlds_2/
- Vergleich ist eine Design-Gap-Analyse, **kein** Beleg, dass jedes Referenzspielsystem unverändert übernommen werden soll. Die verbindlichen P01–P98 entscheiden den Umfang.

## Prozess
Keine ungeprüften Merges nach `main`; das andere Projekt `grenzmark` bleibt unangetastet. Die 48 Planungsdurchläufe sind **kein** Fertigstellungsversprechen.
