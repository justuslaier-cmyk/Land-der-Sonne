# Verbindliche Pflicht-Checkliste — Land der Sonne

**Beschluss:** 2026-11-11. **Status:** vom Auftraggeber als eigenständiger, verbindlicher Abnahmekatalog bestätigt.  
**Geltungsbereich:** Aktives 2D-Pixel-Art-Singleplayer-First-Galaxis-Grand-Strategy-Spiel. Diese Liste ergänzt die Vision, ADRs und technischen Verträge; sie ersetzt sie nicht. Die abgelöste Fantasy-RPG-Vision wird nicht wieder aktiviert.

## Unveränderliche Abnahmeregeln

- Ein Häkchen `[x]` bedeutet **vollständig implementiert, in das reale Spiel integriert und anhand definierter Akzeptanzkriterien nachweislich getestet**. Bloßer Code, ein UI-Text, ein CI-Export oder ein theoretisches Konzept reichen NICHT.
- **Stand 2026-11-11: Kein Punkt wird ohne vollständigen Nachweis als erledigt markiert.** Existierende Prototypen werden ausdrücklich als Teilimplementierungen bezeichnet.
- Für jedes Häkchen sind im Abschnitt „Abnahmenachweise“ Commit-SHA, Test/Prüfmethode, tatsächliches Ergebnis, ggf. Screenshot/Build und offene Einschränkungen zu dokumentieren. Bei Regression wird das Häkchen wieder entfernt.
- `[ ]` bedeutet **Pflicht offen oder noch nicht vollständig abgenommen**, nicht zwangsläufig „kein Code vorhanden“.
- Neue Spielideen dürfen als weitere Pflichten ergänzt werden; bestehende Punkte dürfen nicht stillschweigend gestrichen, abgeschwächt oder in „optional“ umbenannt werden. Änderungen der verbindlichen Ziele bedürfen ausdrücklicher Nutzerentscheidung.
- Die Liste bleibt unabhängig von Entwicklungsphasen und den vorläufigen **36 geplanten Arbeitsdurchläufen**. 36 ist **keine verifizierte Fertigstellungsprognose**.
- Alle Systeme müssen über gemeinsame, versionierte Weltzustands- und Regelverträge miteinander interagieren; isolierte Scheinsysteme gelten nicht als erfüllt.
- Nicht das bloße Vorhandensein, sondern tatsächliche Spielbarkeit, Kausalität, Qualität, Performance und langfristige Motivation sind Abnahmebedingungen.
- Referenzspiele dienen nur der Analyse von Designprinzipien. Keine geschützten Assets, Texte, Musik, Markenwelten oder Codes übernehmen.

## 01 — Spielkern, Navigation und allgemeine Spielbarkeit

- [ ] P01 Atmosphärisches, vollständig bedienbares Hauptmenü: Neues Spiel, Laden, Einstellungen, Beenden.
- [ ] P02 Vollständiger Neuer-Spiel-Assistent mit Zurück, Abbrechen, Zurücksetzen, Vorschau, Validierung und gespeicherten Einstellungen.
- [ ] P03 Galaxieparameter: Größe, Form, Dichte, Seed, Gegnerzahl, Startabstände, Bewohnbarkeit, Ressourcen, Anomalien, Krisen, Schwierigkeit und Spieltempo.
- [ ] P04 Wiederverwendbare Reichs- und Speziesvorlagen mit korrekter Startvalidierung.
- [ ] P05 Interaktive Galaxiekarte mit Kamera, Zoom, Auswahl, Kontextaktionen, Reichsgrenzen, Routen und Fog of War.
- [ ] P06 Tiefgehende, übersichtliche Verwaltungsansichten mit Filtern, Tooltips, nachvollziehbaren Kennzahlen und Navigation.
- [ ] P07 Illustrierte Ereigniskarten mit echten Entscheidungen, Voraussetzungen, Kosten und Folgen.
- [ ] P08 Pause, mehrere Simulationsgeschwindigkeiten, Benachrichtigungen und Ereigniswarteschlange.
- [ ] P09 Verständlicher Einstieg, Tutorial, kontextuelle Hilfe und Rückmeldungen für ungültige Befehle.
- [ ] P10 Mehrere tatsächlich sinnvolle langfristige Spielwege, Sieg-/Endspieloptionen und offene Sandbox ohne erzwungenes Ende.

## 02 — Galaxis, Astronomie und Erkundung

- [ ] P11 Deterministische, versionierte Galaxiegenerierung mit sicherer Startlage und garantierter Erreichbarkeit.
- [ ] P12 Unterschiedliche Galaxieformen, Sternregionen, Nebel, Anomalien, Rohstoffverteilung und strategische Geografie.
- [ ] P13 Vielfältige Sternsysteme, Sterne, Planeten, Monde, Asteroiden und andere Himmelskörper mit sinnvollen Eigenschaften.
- [ ] P14 Erforschung, Vermessung, Sichtweite, unvollständige Information und nachvollziehbare Entdeckungen.
- [ ] P15 Reisen und strategische Verkehrswege mit Entfernung, Zeit, Kapazität und Risiken.
- [ ] P16 Kolonisierung, Terraforming/Anpassung, bewohnbare Nischen und langfristige planetare Entwicklung.
- [ ] P17 Planetare Ökosysteme, Klima, Umweltbelastung und Folgen der Ausbeutung.

## 03 — Spezies, Kulturen und Zivilisationsidentität

- [ ] P18 Visuell unterscheidbare, gestaltbare Spezies mit Namen, Porträts, Herkunft und Eigenheiten.
- [ ] P19 Mehrere kombinierbare biologische Traits mit Punktbudget, Konfliktprüfung und tatsächlichen Konsequenzen.
- [ ] P20 Ethiken, Civics, Regierungsformen und Staatsautorität mit strukturellen, nicht nur numerischen Unterschieden.
- [ ] P21 Herkunftsgeschichten, Startbedingungen, Flaggen, Farben und Schiffsstile.
- [ ] P22 Unterschiedliche Kultur-, Religions- und Weltanschauungssysteme mit Veränderung und Verbreitung.
- [ ] P23 Langfristiger kultureller Wandel, historische Generationen, Assimilation, Minderheiten und kulturelle Erinnerung.
- [ ] P24 Glaubwürdige, eigenständige und asymmetrische KI-Zivilisationen mit individuellen Ambitionen und Historien.

## 04 — Bevölkerung und Gesellschaft

- [ ] P25 Skalierbare Bevölkerungskohorten nach Spezies, Beruf, Wohlstand, Kultur, Alter und Aufenthaltsort.
- [ ] P26 Bedürfnisse nach Nahrung, Wohnen, Energie, Gesundheit, Sicherheit, Bildung, Teilhabe und Luxus.
- [ ] P27 Realeinkommen, tatsächliche Güterverfügbarkeit, Lebensstandard und nachvollziehbare Zufriedenheit.
- [ ] P28 Beschäftigung, Arbeitsmärkte, Bildung, Qualifikation und Produktivität.
- [ ] P29 Geburten, Sterblichkeit, Gesundheit, Alterung und biologische Unterschiede.
- [ ] P30 Freiwillige und erzwungene Migration, Binnenwanderung und Einwanderung zwischen Reichen.
- [ ] P31 Ungleichheit, Klassen, Interessengruppen, Proteste, Streiks, soziale Konflikte und Krisen.
- [ ] P32 Autonome Reaktionen der Bevölkerung auf Gesetze, Krieg, Wirtschaft, Umwelt und kulturelle Ereignisse.
- [ ] P33 Einzelne historisch bedeutsame Persönlichkeiten mit Lebensläufen und glaubwürdiger Rolle; keine teure Vollsimulation jedes Bewohners.

## 05 — Wirtschaft, Handel und Logistik

- [ ] P34 Getrennte, miteinander verbundene Staats-, Unternehmens- und Haushaltswirtschaft.
- [ ] P35 Vollständige Produktionsketten, Ressourcen, Betriebe, Infrastruktur, Investitionen und Eigentumsformen.
- [ ] P36 Güternachfrage, Angebot, Preise, Einkommen, Löhne, Inflation/Deflation und Marktreaktionen.
- [ ] P37 Nachweisbar bilanzierte Ressourcenströme ohne Duplikation, Geldschöpfungsfehler oder doppelte Steuerverbuchung.
- [ ] P38 Steuern, öffentliche Ausgaben, Schulden/Haushalt, Subventionen und wirtschaftspolitische Instrumente.
- [ ] P39 Autonome Unternehmen, Händler und private Investitionen mit begrenzten Ressourcen und wirtschaftlichen Zielen.
- [ ] P40 Physisch/abstrakt nachvollziehbare Frachter, Handelsrouten, Lieferkapazitäten, Transportzeiten und -kosten.
- [ ] P41 Lieferengpässe, Lagerbestände, strategische Reserven, Piraterie und Versorgungssicherheit.
- [ ] P42 Handelsverträge, Zölle, Embargos, Abhängigkeiten und internationale Märkte.
- [ ] P43 Wirtschaftliche KI-Automatisierung mit sinnvoller menschlicher Eingriffsmöglichkeit.

## 06 — Politik und Regierung

- [ ] P44 Unterschiedliche Entscheidungsverfahren für Republik, Monarchie, Technokratie, Kollektiv und weitere Staatsmodelle.
- [ ] P45 Gesetzgebung, Reformen, politische Zuständigkeiten und reale Implementierungsfolgen.
- [ ] P46 Wahlen, Koalitionen, Nachfolge, Räte oder entsprechende verfassungsspezifische Machtwechsel.
- [ ] P47 Fraktionen, politische Interessen, Lobbyismus, Machtkämpfe und gesellschaftliche Repräsentation.
- [ ] P48 Legitimität, Stabilität, Unruhen, Revolutionen, Separatismus und mögliche Regierungswechsel.
- [ ] P49 Föderale Strukturen, Autonomie, Zentralisierung und Konflikte zwischen Kolonien und Hauptstadt.
- [ ] P50 Informationspolitik, Nachrichten, Propaganda, Geheimhaltung und Kommunikationsverzögerungen.

## 07 — Forschung und technologische Entwicklung

- [ ] P51 Verzweigte, balancierte und verständliche Forschungsbereiche mit unterschiedlichen Spezialisierungen.
- [ ] P52 Forschung abhängig von Wissenschaftlern, Institutionen, Bildung, Infrastruktur und Ressourcen.
- [ ] P53 Technologien mit realen Folgen für Schiffe, Wirtschaft, Gesellschaft, Kolonien und Diplomatie.
- [ ] P54 Wissenschaftliche Entdeckungen, seltene Durchbrüche, Paradigmenwechsel und archäologisches Wissen.
- [ ] P55 Technologische Verbreitung, Handel, Spionage, Rückstand und Aufholmechanismen.

## 08 — Diplomatie, Krieg und militärische Strategie

- [ ] P56 Diplomatische Beziehungen, Interessen, Vertrauen, Verhandlungen und dauerhafte Vertragsfolgen.
- [ ] P57 Bündnisse, Föderationen, Vasallen-/Abhängigkeitsverhältnisse und galaktische Institutionen.
- [ ] P58 Geheimdienst, Spionage, Gegenspionage und unvollständige strategische Information.
- [ ] P59 Eigener Schiffsentwurf mit Komponenten, Rollen, Kosten, Technik und optischer Unterscheidbarkeit.
- [ ] P60 Flottenbau, Bewegung, Befehle, Doktrinen, Admiräle und strategische Planung.
- [ ] P61 Gefechte mit nachvollziehbaren Regeln, Sensorik, Reichweiten, Verteidigung und Verlusten.
- [ ] P62 Militärische Logistik, Nachschub, Reparatur, Wartung und Kriegskosten.
- [ ] P63 Kriegsziele, Friedensverträge, Besetzung, Kriegsfolgen und zivile Konsequenzen.
- [ ] P64 Militärische KI mit eigenständigen, begrenzten und verständlichen Entscheidungen.

## 09 — Ereignisse, Geschichte und langfristige Motivation

- [ ] P65 Verlorene Zivilisationen, Ruinen, Artefakte, uralte Geheimnisse und erforschbare Geschichten.
- [ ] P66 Datengetriebene, kausale Ereignis-Engine mit Bedingungen, Optionen, Cooldowns, Konsequenzen und Tests.
- [ ] P67 Verknüpfte Erzählketten, dynamische Geschichten und systemisch ausgelöste Zwischenfälle.
- [ ] P68 Historische Persönlichkeiten, Dynastien, gesellschaftliche Erinnerung und Generationenfolgen.
- [ ] P69 Galaktische Chronik mit nachvollziehbarer Ursache-Wirkungs-Geschichte und Zeitstrahl.
- [ ] P70 Unterschiedliche Mittel- und Endspielkrisen, die aus dem Weltzustand oder festgelegten Regeln entstehen.
- [ ] P71 Große Langzeitprojekte, Megastrukturen und mehrere wirtschaftliche, diplomatische, wissenschaftliche und militärische Entwicklungspfade.
- [ ] P72 Fortschrittsziele und Erfolge werden korrekt angezeigt, gespeichert und nur einmal vergeben.

## 10 — KI und Simulationstiefe

- [ ] P73 Strategische KI für langfristige Ziele, Bedrohungen, Chancen und Charakterunterschiede.
- [ ] P74 Operative KI für Wirtschaft, Forschung, Expansion, Politik, Diplomatie und Flotten.
- [ ] P75 KI handelt nach denselben Weltregeln und Ressourcenbeschränkungen wie der Spieler.
- [ ] P76 Begrenzte KI-Information, Unsicherheit, Erinnerungen und anpassungsfähige Reaktionen.
- [ ] P77 Beobachtbare Eigenentwicklung der Galaxis auch ohne Spielerintervention.
- [ ] P78 Skalierte Simulation mit unterschiedlichen Detailstufen und überprüfbarer Performance.
- [ ] P79 Erklärbare wichtige KI- und Ereignisentscheidungen; keine willkürlichen Scheinursachen.

## 11 — Kunst, Audio, Benutzererfahrung

- [ ] P80 Konsistente, hochwertige Original-Pixel-Art für Karte, Sterne, Planeten, Schiffe, Spezies und Ereignisse.
- [ ] P81 Aussagekräftige Symbole und Icons für Ressourcen, Traits, Politik, Bedürfnisse und Aktionen.
- [ ] P82 Visuelle Lesbarkeit von Sternsystemen, Handelsrouten, Flotten, Grenzen, Konflikten und ziviler Aktivität.
- [ ] P83 Animationen, Übergänge, atmosphärische Effekte und kohärente Farb-/Typografiesprache.
- [ ] P84 Passende Musik, Soundeffekte und konfigurierbare Audioausgabe mit geklärten Nutzungsrechten.
- [ ] P85 Skalierbare, barrierearme UI mit verständlichen Informationen, Tastaturbedienung und Einstellmöglichkeiten.
- [ ] P86 Fortschrittliche Übersichtsfunktionen: Filter, Suchfunktionen, Warnungen, Statistiken und Hilfetexte.

## 12 — Qualität, Release und technische Sicherheit

- [ ] P87 Versionierte, deterministische Simulations- und Datenverträge mit stabilen Entitäts-IDs.
- [ ] P88 Einheitlicher Scheduler, getrennte Zufallsströme und reproduzierbare Simulationsverläufe.
- [ ] P89 Sichere Spielstände, Save-Slots, Autosave, Backups, Datenmigration und Wiederherstellung.
- [ ] P90 Automatisierte Tests für Regeln, Integrationen, Speicherstände, Ökonomie und Langzeitsimulation.
- [ ] P91 Erfolgreiche Godot-Parser-, Smoke-, Interaktions- und Renderprüfungen für den aktuellen Commit.
- [ ] P92 Tatsächlich gestarteter und geprüfter Windows-Build; Export allein genügt nicht.
- [ ] P93 Performancebudgets, Profiling und stabile Spielgeschwindigkeit auch in großen Galaxien.
- [ ] P94 Dokumentierte Balancingtests und mehrere nachweislich sinnvolle Strategien.
- [ ] P95 Visuelle Abnahme anhand echter Godot-Screenshots, nicht Konzeptbildern.
- [ ] P96 Verständliche Dokumentation, Änderungsprotokolle, bekannte Einschränkungen und reproduzierbare Builds.
- [ ] P97 Vollständige, längere Spielpartien mit reproduzierbaren Testprotokollen und ohne kritische Blocker.
- [ ] P98 Konsistenter Release-Gate-Prozess einschließlich Regressionsprüfungen und realer Nutzer-Spieltests.

## Aktueller Prototypenstand — ausdrücklich KEINE Häkchen

- Prozedurale 20–250-Sterne-Galaxis, konfigurierbare KI-Reiche, UI-Grundgerüst und versioniertes JSON-Speichern sind im Code angelegt.
- Civics, Speziesmerkmale, zivile Bevölkerung, Warenströme, politische KI-Fraktionen, Diplomatie, Flotten, Archäologie und sechs Meilensteine besitzen erste Implementierungen.
- Keine dieser Kategorien wird dadurch als vollständig, integriert, ausbalanciert, visuell abgenommen und releasefertig behauptet.
- Der letzte überprüfte CI-Lauf für Commit `1d178dbe789ec9b8c8a1cf9dbdcfc42764e5f982` war **fehlgeschlagen**: Godot-Smoke-Test mit Parserfehler in `galaxy_ui.gd:657` (reservierter Name `trait`) und Typinferenzfehler in `galaxy_progress_test.gd:23`. Render-Check und Windows-Export allein genügen nicht.
- `docs/progress/PROJECT_STATUS.md` ist inhaltlich veraltet und muss aktualisiert werden.

## Theoretischer Planungsrahmen — nicht als Abschlussversprechen zu verstehen

12 parallele Entwicklungsfelder: (1) Architektur/Qualität, (2) Galaxis/Erkundung, (3) Planeten/Kolonien, (4) Bevölkerung/Kultur, (5) Wirtschaft/Logistik, (6) Politik, (7) Forschung, (8) Diplomatie/KI, (9) Militär, (10) Geschichte/Endspiel, (11) Art/Audio/UX, (12) Balancing/Performance/Release.

**36 Durchläufe** (12 × 3) sind eine vorläufige Organisationsannahme, **keine** objektiv ermittelte Zahl, die alle 98 Pflichten garantiert erfüllt. Dauer und tatsächliche Durchlaufzahl sind erst nach gemessenen integrierten Entwicklungszyklen seriös schätzbar. Bereiche müssen parallel und inkrementell umgesetzt werden; kein isoliertes „erst sämtliche Simulation, dann Grafik“.

## Abnahmenachweise

| Pflicht-ID | Commit | Prüfmethode | Beobachtetes Ergebnis | Status |
|---|---|---|---|---|
| — | — | — | Noch keine vollständig abgenommenen Pflichtpunkte dokumentiert | Offen |

**Arbeitsregel für jede weitere Entwicklungssitzung:** Diese Datei vor Änderungen lesen; betroffene Pflicht-IDs nennen; nach erfolgreicher Integration, Test und Qualitätsabnahme mit konkretem Nachweis abhaken; offene Punkte und Regressionen ehrlich stehen lassen.
