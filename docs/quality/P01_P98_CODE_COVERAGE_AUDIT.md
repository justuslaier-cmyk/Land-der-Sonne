# Datei-Inventur und P01–P98-Abdeckungsmatrix — 2026-11-12

## Methode und Beweisgrenzen

- **Quelle:** Vergleich `main...design/galactic-grand-strategy-pivot` über den GitHub-Connector: **127 geänderte/neu hinzugefügte Dateien**, 453 Commits. Dies ist eine **Diff-Inventur**, keine vollständige rekursive Dateiliste des Basisbranches; unveränderte Altdateien können fehlen.
- Ergänzende Quellcodeinspektion: `galaxy_model.gd`, `galaxy_strategy.gd`, `galaxy_systems.gd`, `galaxy_civilians.gd`, `galaxy_ui.gd`, `galaxy_ai.gd`, `galaxy_routes.gd`, `galaxy_contracts.gd`, `galaxy_event_engine.gd`, `galaxy_narrative_director.gd`, `galaxy_progress.gd`, `galaxy_identity.gd`; Funktionen und grobe Struktur gelesen. **Keine vollständige Zeile-für-Zeile-Sicherheitsprüfung**.
- Prüfbeleg: [CI-Lauf 43214501265](https://github.com/justuslaier-cmyk/Land-der-Sonne/actions/runs/43214501265) mit 17 erfolgreichen Jobs; Windows-2022-Headless-Lauf meldet `GALAXY_INTEGRATION_PASS`. Das ist kein Beweis für 98 vollständig umgesetzte Systeme.
- Die unten angegebenen Dateien sind **Einstiegspunkte für die weitere Prüfung**, keine Behauptung, dass die genannte Anforderung darin vollständig realisiert sei. Wo keine direkte Datei genannt wird, ist keine eindeutige Zuordnung belegt.
- Status **Offen** folgt unverändert dem bindenden [Pflichtkatalog](../vision/BINDING_GAME_REQUIREMENTS_CHECKLIST.md). Erst nach **einzelner** Integration, Akzeptanzkriterium, Engine-Test, ggf. Render/Windows-Nachweis und dokumentierter Abnahme darf ein Häkchen gesetzt werden.

## Quantitative Bestandsaufnahme

- Diff-Dateien: **127**; davon `18` GDScript-Implementierungsdateien, `59` Testskripte, `16` originale SVG-Art-Dateien und `30` Dokumentationsdateien.
- `galaxy_ui.gd` umfasst 1654 Zeilen, `galaxy_strategy.gd` 854 Zeilen, `galaxy_systems.gd` 374 Zeilen, `galaxy_civilians.gd` 360 Zeilen, `galaxy_ai.gd` 214 Zeilen und `galaxy_model.gd` 144 Zeilen. **Risiko:** UI- und Strategie-Module sind stark konzentriert; Refactoring nur mit Tests und funktionalen Integrationsgrenzen.
- Die 98 Zeilen unten sind vollständig aus dem verbindlichen Register übernommen, **nicht aus einer KI-generierten Ersatzanforderungsliste**.

## Abdeckungsmatrix

| ID | Verbindliche Anforderung (Kurzform) | Zu prüfende vorhandene Implementierung/Testdatei | Vollabnahme |
|---|---|---|---|
| P01 | Atmosphärisches, vollständig bedienbares Hauptmenü: Neues Spiel, Laden, Einstellungen, Beenden. | `game/scripts/galaxy/galaxy_ui.gd`; `game/tests/galaxy_ui_interaction_regression_test.gd` | **Offen** |
| P02 | Vollständiger Neuer-Spiel-Assistent mit Zurück, Abbrechen, Zurücksetzen, Vorschau, Validierung und gespeicherten Einstellungen. | `game/scripts/galaxy/galaxy_ui.gd`; `game/tests/galaxy_wizard_test.gd` | **Offen** |
| P03 | Galaxieparameter: Größe, Form, Dichte, Seed, Gegnerzahl, Startabstände, Bewohnbarkeit, Ressourcen, Anomalien, Krisen, Schwierigkeit und Spieltempo. | `game/scripts/galaxy/galaxy_ui.gd`; `game/tests/galaxy_wizard_test.gd` | **Offen** |
| P04 | Wiederverwendbare Reichs- und Speziesvorlagen mit korrekter Startvalidierung. | `game/scripts/galaxy/galaxy_ui.gd`; `game/tests/galaxy_wizard_test.gd` | **Offen** |
| P05 | Interaktive Galaxiekarte mit Kamera, Zoom, Auswahl, Kontextaktionen, Reichsgrenzen, Routen und Fog of War. | `game/scripts/galaxy/galaxy_ui.gd`; `game/tests/galaxy_map_interaction_test.gd` | **Offen** |
| P06 | Tiefgehende, übersichtliche Verwaltungsansichten mit Filtern, Tooltips, nachvollziehbaren Kennzahlen und Navigation. | `game/scripts/galaxy/galaxy_ui.gd`; `game/tests/galaxy_wizard_test.gd` | **Offen** |
| P07 | Illustrierte Ereigniskarten mit echten Entscheidungen, Voraussetzungen, Kosten und Folgen. | `game/scripts/galaxy_event_engine.gd`; `game/tests/galaxy_event_card_test.gd` | **Offen** |
| P08 | Pause, mehrere Simulationsgeschwindigkeiten, Benachrichtigungen und Ereigniswarteschlange. | `game/scripts/galaxy/galaxy_ui.gd`; `game/tests/galaxy_wizard_test.gd` | **Offen** |
| P09 | Verständlicher Einstieg, Tutorial, kontextuelle Hilfe und Rückmeldungen für ungültige Befehle. | `game/scripts/galaxy/galaxy_ui.gd`; `game/tests/galaxy_wizard_test.gd` | **Offen** |
| P10 | Mehrere tatsächlich sinnvolle langfristige Spielwege, Sieg-/Endspieloptionen und offene Sandbox ohne erzwungenes Ende. | `game/scripts/galaxy/galaxy_ui.gd`; `game/tests/galaxy_wizard_test.gd` | **Offen** |
| P11 | Deterministische, versionierte Galaxiegenerierung mit sicherer Startlage und garantierter Erreichbarkeit. | `game/scripts/galaxy/galaxy_model.gd`; `game/tests/galaxy_geography_test.gd` | **Offen** |
| P12 | Unterschiedliche Galaxieformen, Sternregionen, Nebel, Anomalien, Rohstoffverteilung und strategische Geografie. | `game/scripts/galaxy/galaxy_model.gd`; `game/tests/galaxy_geography_test.gd` | **Offen** |
| P13 | Vielfältige Sternsysteme, Sterne, Planeten, Monde, Asteroiden und andere Himmelskörper mit sinnvollen Eigenschaften. | `game/scripts/galaxy/galaxy_model.gd`; `game/tests/galaxy_geography_test.gd` | **Offen** |
| P14 | Erforschung, Vermessung, Sichtweite, unvollständige Information und nachvollziehbare Entdeckungen. | `game/scripts/galaxy/galaxy_model.gd`; `game/tests/galaxy_geography_test.gd` | **Offen** |
| P15 | Reisen und strategische Verkehrswege mit Entfernung, Zeit, Kapazität und Risiken. | `game/scripts/galaxy/galaxy_model.gd`; `game/tests/galaxy_geography_test.gd` | **Offen** |
| P16 | Kolonisierung, Terraforming/Anpassung, bewohnbare Nischen und langfristige planetare Entwicklung. | `game/scripts/galaxy/galaxy_model.gd`; `game/tests/galaxy_geography_test.gd` | **Offen** |
| P17 | Planetare Ökosysteme, Klima, Umweltbelastung und Folgen der Ausbeutung. | `game/scripts/galaxy/galaxy_model.gd`; `game/tests/galaxy_geography_test.gd` | **Offen** |
| P18 | Visuell unterscheidbare, gestaltbare Spezies mit Namen, Porträts, Herkunft und Eigenheiten. | `game/scripts/galaxy/galaxy_ui.gd`; `game/tests/galaxy_art_ui_smoke_test.gd` | **Offen** |
| P19 | Mehrere kombinierbare biologische Traits mit Punktbudget, Konfliktprüfung und tatsächlichen Konsequenzen. | `game/scripts/galaxy/galaxy_identity.gd`; `game/tests/galaxy_identity_test.gd` | **Offen** |
| P20 | Ethiken, Civics, Regierungsformen und Staatsautorität mit strukturellen, nicht nur numerischen Unterschieden. | `game/scripts/galaxy/galaxy_identity.gd`; `game/tests/galaxy_identity_test.gd` | **Offen** |
| P21 | Herkunftsgeschichten, Startbedingungen, Flaggen, Farben und Schiffsstile. | `game/scripts/galaxy/galaxy_identity.gd`; `game/tests/galaxy_identity_test.gd` | **Offen** |
| P22 | Unterschiedliche Kultur-, Religions- und Weltanschauungssysteme mit Veränderung und Verbreitung. | `game/scripts/galaxy/galaxy_identity.gd`; `game/tests/galaxy_identity_test.gd` | **Offen** |
| P23 | Langfristiger kultureller Wandel, historische Generationen, Assimilation, Minderheiten und kulturelle Erinnerung. | `game/scripts/galaxy/galaxy_identity.gd`; `game/tests/galaxy_identity_test.gd` | **Offen** |
| P24 | Glaubwürdige, eigenständige und asymmetrische KI-Zivilisationen mit individuellen Ambitionen und Historien. | `game/scripts/galaxy/galaxy_ai.gd`; `game/tests/galaxy_ai_test.gd` | **Offen** |
| P25 | Skalierbare Bevölkerungskohorten nach Spezies, Beruf, Wohlstand, Kultur, Alter und Aufenthaltsort. | `game/scripts/galaxy/galaxy_civilians.gd`; `game/tests/galaxy_demographics_test.gd` | **Offen** |
| P26 | Bedürfnisse nach Nahrung, Wohnen, Energie, Gesundheit, Sicherheit, Bildung, Teilhabe und Luxus. | `game/scripts/galaxy/galaxy_civilians.gd`; `game/tests/galaxy_demographics_test.gd` | **Offen** |
| P27 | Realeinkommen, tatsächliche Güterverfügbarkeit, Lebensstandard und nachvollziehbare Zufriedenheit. | `game/scripts/galaxy/galaxy_civilians.gd`; `game/tests/galaxy_demographics_test.gd` | **Offen** |
| P28 | Beschäftigung, Arbeitsmärkte, Bildung, Qualifikation und Produktivität. | `game/scripts/galaxy/galaxy_civilians.gd`; `game/tests/galaxy_demographics_test.gd` | **Offen** |
| P29 | Geburten, Sterblichkeit, Gesundheit, Alterung und biologische Unterschiede. | `game/scripts/galaxy/galaxy_civilians.gd`; `game/tests/galaxy_demographics_test.gd` | **Offen** |
| P30 | Freiwillige und erzwungene Migration, Binnenwanderung und Einwanderung zwischen Reichen. | `game/scripts/galaxy/galaxy_civilians.gd`; `game/tests/galaxy_demographics_test.gd` | **Offen** |
| P31 | Ungleichheit, Klassen, Interessengruppen, Proteste, Streiks, soziale Konflikte und Krisen. | `game/scripts/galaxy/galaxy_civilians.gd`; `game/tests/galaxy_demographics_test.gd` | **Offen** |
| P32 | Autonome Reaktionen der Bevölkerung auf Gesetze, Krieg, Wirtschaft, Umwelt und kulturelle Ereignisse. | `game/scripts/galaxy/galaxy_civilians.gd`; `game/tests/galaxy_demographics_test.gd` | **Offen** |
| P33 | Einzelne historisch bedeutsame Persönlichkeiten mit Lebensläufen und glaubwürdiger Rolle; keine teure Vollsimulation jedes Bewohners. | `game/scripts/galaxy/galaxy_civilians.gd`; `game/tests/galaxy_demographics_test.gd` | **Offen** |
| P34 | Getrennte, miteinander verbundene Staats-, Unternehmens- und Haushaltswirtschaft. | `game/scripts/galaxy/galaxy_civilians.gd`; `game/tests/galaxy_goods_ledger_test.gd` | **Offen** |
| P35 | Vollständige Produktionsketten, Ressourcen, Betriebe, Infrastruktur, Investitionen und Eigentumsformen. | `game/scripts/galaxy/galaxy_civilians.gd`; `game/tests/galaxy_goods_ledger_test.gd` | **Offen** |
| P36 | Güternachfrage, Angebot, Preise, Einkommen, Löhne, Inflation/Deflation und Marktreaktionen. | `game/scripts/galaxy/galaxy_civilians.gd`; `game/tests/galaxy_goods_ledger_test.gd` | **Offen** |
| P37 | Nachweisbar bilanzierte Ressourcenströme ohne Duplikation, Geldschöpfungsfehler oder doppelte Steuerverbuchung. | `game/scripts/galaxy/galaxy_civilians.gd`; `game/tests/galaxy_goods_ledger_test.gd` | **Offen** |
| P38 | Steuern, öffentliche Ausgaben, Schulden/Haushalt, Subventionen und wirtschaftspolitische Instrumente. | `game/scripts/galaxy/galaxy_civilians.gd`; `game/tests/galaxy_goods_ledger_test.gd` | **Offen** |
| P39 | Autonome Unternehmen, Händler und private Investitionen mit begrenzten Ressourcen und wirtschaftlichen Zielen. | `game/scripts/galaxy/galaxy_civilians.gd`; `game/tests/galaxy_goods_ledger_test.gd` | **Offen** |
| P40 | Physisch/abstrakt nachvollziehbare Frachter, Handelsrouten, Lieferkapazitäten, Transportzeiten und -kosten. | `game/scripts/galaxy/galaxy_civilians.gd`; `game/tests/galaxy_freight_transit_test.gd` | **Offen** |
| P41 | Lieferengpässe, Lagerbestände, strategische Reserven, Piraterie und Versorgungssicherheit. | `game/scripts/galaxy/galaxy_civilians.gd`; `game/tests/galaxy_goods_ledger_test.gd` | **Offen** |
| P42 | Handelsverträge, Zölle, Embargos, Abhängigkeiten und internationale Märkte. | `game/scripts/galaxy/galaxy_civilians.gd`; `game/tests/galaxy_goods_ledger_test.gd` | **Offen** |
| P43 | Wirtschaftliche KI-Automatisierung mit sinnvoller menschlicher Eingriffsmöglichkeit. | `game/scripts/galaxy/galaxy_civilians.gd`; `game/tests/galaxy_goods_ledger_test.gd` | **Offen** |
| P44 | Unterschiedliche Entscheidungsverfahren für Republik, Monarchie, Technokratie, Kollektiv und weitere Staatsmodelle. | `game/scripts/galaxy/galaxy_strategy.gd`; `game/tests/galaxy_governance_reforms_test.gd` | **Offen** |
| P45 | Gesetzgebung, Reformen, politische Zuständigkeiten und reale Implementierungsfolgen. | `game/scripts/galaxy/galaxy_strategy.gd`; `game/tests/galaxy_governance_reforms_test.gd` | **Offen** |
| P46 | Wahlen, Koalitionen, Nachfolge, Räte oder entsprechende verfassungsspezifische Machtwechsel. | `game/scripts/galaxy/galaxy_strategy.gd`; `game/tests/galaxy_governance_reforms_test.gd` | **Offen** |
| P47 | Fraktionen, politische Interessen, Lobbyismus, Machtkämpfe und gesellschaftliche Repräsentation. | `game/scripts/galaxy/galaxy_strategy.gd`; `game/tests/galaxy_governance_reforms_test.gd` | **Offen** |
| P48 | Legitimität, Stabilität, Unruhen, Revolutionen, Separatismus und mögliche Regierungswechsel. | `game/scripts/galaxy/galaxy_strategy.gd`; `game/tests/galaxy_governance_reforms_test.gd` | **Offen** |
| P49 | Föderale Strukturen, Autonomie, Zentralisierung und Konflikte zwischen Kolonien und Hauptstadt. | `game/scripts/galaxy/galaxy_strategy.gd`; `game/tests/galaxy_governance_reforms_test.gd` | **Offen** |
| P50 | Informationspolitik, Nachrichten, Propaganda, Geheimhaltung und Kommunikationsverzögerungen. | `game/scripts/galaxy/galaxy_strategy.gd`; `game/tests/galaxy_governance_reforms_test.gd` | **Offen** |
| P51 | Verzweigte, balancierte und verständliche Forschungsbereiche mit unterschiedlichen Spezialisierungen. | `game/scripts/galaxy/galaxy_systems.gd`; `game/tests/galaxy_research_branches_test.gd` | **Offen** |
| P52 | Forschung abhängig von Wissenschaftlern, Institutionen, Bildung, Infrastruktur und Ressourcen. | `game/scripts/galaxy/galaxy_systems.gd`; `game/tests/galaxy_research_branches_test.gd` | **Offen** |
| P53 | Technologien mit realen Folgen für Schiffe, Wirtschaft, Gesellschaft, Kolonien und Diplomatie. | `game/scripts/galaxy/galaxy_systems.gd`; `game/tests/galaxy_research_branches_test.gd` | **Offen** |
| P54 | Wissenschaftliche Entdeckungen, seltene Durchbrüche, Paradigmenwechsel und archäologisches Wissen. | `game/scripts/galaxy/galaxy_systems.gd`; `game/tests/galaxy_research_branches_test.gd` | **Offen** |
| P55 | Technologische Verbreitung, Handel, Spionage, Rückstand und Aufholmechanismen. | `game/scripts/galaxy/galaxy_systems.gd`; `game/tests/galaxy_research_branches_test.gd` | **Offen** |
| P56 | Diplomatische Beziehungen, Interessen, Vertrauen, Verhandlungen und dauerhafte Vertragsfolgen. | `game/scripts/galaxy/galaxy_strategy.gd`; `game/tests/galaxy_diplomatic_negotiations_test.gd` | **Offen** |
| P57 | Bündnisse, Föderationen, Vasallen-/Abhängigkeitsverhältnisse und galaktische Institutionen. | `game/scripts/galaxy/galaxy_strategy.gd`; `game/tests/galaxy_diplomatic_negotiations_test.gd` | **Offen** |
| P58 | Geheimdienst, Spionage, Gegenspionage und unvollständige strategische Information. | `game/scripts/galaxy/galaxy_strategy.gd`; `game/tests/galaxy_espionage_test.gd` | **Offen** |
| P59 | Eigener Schiffsentwurf mit Komponenten, Rollen, Kosten, Technik und optischer Unterscheidbarkeit. | `game/scripts/galaxy/galaxy_strategy.gd`; `game/tests/galaxy_diplomatic_negotiations_test.gd` | **Offen** |
| P60 | Flottenbau, Bewegung, Befehle, Doktrinen, Admiräle und strategische Planung. | `game/scripts/galaxy/galaxy_strategy.gd`; `game/tests/galaxy_diplomatic_negotiations_test.gd` | **Offen** |
| P61 | Gefechte mit nachvollziehbaren Regeln, Sensorik, Reichweiten, Verteidigung und Verlusten. | `game/scripts/galaxy/galaxy_strategy.gd`; `game/tests/galaxy_diplomatic_negotiations_test.gd` | **Offen** |
| P62 | Militärische Logistik, Nachschub, Reparatur, Wartung und Kriegskosten. | `game/scripts/galaxy/galaxy_strategy.gd`; `game/tests/galaxy_military_logistics_test.gd` | **Offen** |
| P63 | Kriegsziele, Friedensverträge, Besetzung, Kriegsfolgen und zivile Konsequenzen. | `game/scripts/galaxy/galaxy_strategy.gd`; `game/tests/galaxy_diplomatic_negotiations_test.gd` | **Offen** |
| P64 | Militärische KI mit eigenständigen, begrenzten und verständlichen Entscheidungen. | `game/scripts/galaxy/galaxy_strategy.gd`; `game/tests/galaxy_diplomatic_negotiations_test.gd` | **Offen** |
| P65 | Verlorene Zivilisationen, Ruinen, Artefakte, uralte Geheimnisse und erforschbare Geschichten. | `game/scripts/galaxy_event_engine.gd`; `game/tests/galaxy_story_chains_test.gd` | **Offen** |
| P66 | Datengetriebene, kausale Ereignis-Engine mit Bedingungen, Optionen, Cooldowns, Konsequenzen und Tests. | `game/scripts/galaxy_event_engine.gd`; `game/tests/galaxy_event_card_test.gd` | **Offen** |
| P67 | Verknüpfte Erzählketten, dynamische Geschichten und systemisch ausgelöste Zwischenfälle. | `game/scripts/galaxy_event_engine.gd`; `game/tests/galaxy_story_chains_test.gd` | **Offen** |
| P68 | Historische Persönlichkeiten, Dynastien, gesellschaftliche Erinnerung und Generationenfolgen. | `game/scripts/galaxy_event_engine.gd`; `game/tests/galaxy_story_chains_test.gd` | **Offen** |
| P69 | Galaktische Chronik mit nachvollziehbarer Ursache-Wirkungs-Geschichte und Zeitstrahl. | `game/scripts/galaxy_event_engine.gd`; `game/tests/galaxy_story_chains_test.gd` | **Offen** |
| P70 | Unterschiedliche Mittel- und Endspielkrisen, die aus dem Weltzustand oder festgelegten Regeln entstehen. | `game/scripts/galaxy_event_engine.gd`; `game/tests/galaxy_story_chains_test.gd` | **Offen** |
| P71 | Große Langzeitprojekte, Megastrukturen und mehrere wirtschaftliche, diplomatische, wissenschaftliche und militärische Entwicklungspfade. | `game/scripts/galaxy_event_engine.gd`; `game/tests/galaxy_story_chains_test.gd` | **Offen** |
| P72 | Fortschrittsziele und Erfolge werden korrekt angezeigt, gespeichert und nur einmal vergeben. | `game/scripts/galaxy_event_engine.gd`; `game/tests/galaxy_story_chains_test.gd` | **Offen** |
| P73 | Strategische KI für langfristige Ziele, Bedrohungen, Chancen und Charakterunterschiede. | `game/scripts/galaxy/galaxy_ai_planner.gd`; `game/tests/galaxy_ai_planner_test.gd` | **Offen** |
| P74 | Operative KI für Wirtschaft, Forschung, Expansion, Politik, Diplomatie und Flotten. | `game/scripts/galaxy/galaxy_ai.gd`; `game/tests/galaxy_ai_soak_test.gd` | **Offen** |
| P75 | KI handelt nach denselben Weltregeln und Ressourcenbeschränkungen wie der Spieler. | `game/scripts/galaxy/galaxy_ai.gd`; `game/tests/galaxy_ai_soak_test.gd` | **Offen** |
| P76 | Begrenzte KI-Information, Unsicherheit, Erinnerungen und anpassungsfähige Reaktionen. | `game/scripts/galaxy/galaxy_ai.gd`; `game/tests/galaxy_ai_soak_test.gd` | **Offen** |
| P77 | Beobachtbare Eigenentwicklung der Galaxis auch ohne Spielerintervention. | `game/scripts/galaxy/galaxy_ai.gd`; `game/tests/galaxy_ai_soak_test.gd` | **Offen** |
| P78 | Skalierte Simulation mit unterschiedlichen Detailstufen und überprüfbarer Performance. | `game/scripts/galaxy/galaxy_ai.gd`; `game/tests/galaxy_ai_soak_test.gd` | **Offen** |
| P79 | Erklärbare wichtige KI- und Ereignisentscheidungen; keine willkürlichen Scheinursachen. | `game/scripts/galaxy/galaxy_ai.gd`; `game/tests/galaxy_ai_soak_test.gd` | **Offen** |
| P80 | Konsistente, hochwertige Original-Pixel-Art für Karte, Sterne, Planeten, Schiffe, Spezies und Ereignisse. | `game/scripts/galaxy/galaxy_ui.gd`; `game/tests/galaxy_art_resources_test.gd` | **Offen** |
| P81 | Aussagekräftige Symbole und Icons für Ressourcen, Traits, Politik, Bedürfnisse und Aktionen. | `game/scripts/galaxy/galaxy_ui.gd`; `game/tests/galaxy_art_ui_smoke_test.gd` | **Offen** |
| P82 | Visuelle Lesbarkeit von Sternsystemen, Handelsrouten, Flotten, Grenzen, Konflikten und ziviler Aktivität. | `game/scripts/galaxy/galaxy_ui.gd`; `game/tests/galaxy_art_ui_smoke_test.gd` | **Offen** |
| P83 | Animationen, Übergänge, atmosphärische Effekte und kohärente Farb-/Typografiesprache. | `game/scripts/galaxy/galaxy_ui.gd`; `game/tests/galaxy_art_ui_smoke_test.gd` | **Offen** |
| P84 | Passende Musik, Soundeffekte und konfigurierbare Audioausgabe mit geklärten Nutzungsrechten. | Kein direkter Nachweis in dieser Inventur | **Offen** |
| P85 | Skalierbare, barrierearme UI mit verständlichen Informationen, Tastaturbedienung und Einstellmöglichkeiten. | `game/scripts/galaxy/galaxy_ui.gd`; `game/tests/galaxy_art_ui_smoke_test.gd` | **Offen** |
| P86 | Fortschrittliche Übersichtsfunktionen: Filter, Suchfunktionen, Warnungen, Statistiken und Hilfetexte. | `game/scripts/galaxy/galaxy_ui.gd`; `game/tests/galaxy_art_ui_smoke_test.gd` | **Offen** |
| P87 | Versionierte, deterministische Simulations- und Datenverträge mit stabilen Entitäts-IDs. | `game/scripts/galaxy/galaxy_model.gd`; `game/tests/galaxy_full_integration_test.gd` | **Offen** |
| P88 | Einheitlicher Scheduler, getrennte Zufallsströme und reproduzierbare Simulationsverläufe. | `game/scripts/galaxy/galaxy_model.gd`; `game/tests/galaxy_full_integration_test.gd` | **Offen** |
| P89 | Sichere Spielstände, Save-Slots, Autosave, Backups, Datenmigration und Wiederherstellung. | `game/scripts/galaxy/galaxy_model.gd`; `game/tests/galaxy_full_integration_test.gd` | **Offen** |
| P90 | Automatisierte Tests für Regeln, Integrationen, Speicherstände, Ökonomie und Langzeitsimulation. | `game/scripts/galaxy/galaxy_contracts.gd`; `game/tests/galaxy_full_integration_test.gd` | **Offen** |
| P91 | Erfolgreiche Godot-Parser-, Smoke-, Interaktions- und Renderprüfungen für den aktuellen Commit. | `game/scripts/galaxy/galaxy_ui.gd`; `game/tests/galaxy_ui_interaction_regression_test.gd` | **Offen** |
| P92 | Tatsächlich gestarteter und geprüfter Windows-Build; Export allein genügt nicht. | `game/scripts/galaxy/galaxy_model.gd`; `game/tests/galaxy_full_integration_test.gd` | **Offen** |
| P93 | Performancebudgets, Profiling und stabile Spielgeschwindigkeit auch in großen Galaxien. | `game/scripts/galaxy/galaxy_ai_spatial_index.gd`; `game/tests/galaxy_ai_scaling_test.gd` | **Offen** |
| P94 | Dokumentierte Balancingtests und mehrere nachweislich sinnvolle Strategien. | `game/scripts/galaxy/galaxy_model.gd`; `game/tests/galaxy_full_integration_test.gd` | **Offen** |
| P95 | Visuelle Abnahme anhand echter Godot-Screenshots, nicht Konzeptbildern. | `game/scripts/galaxy/galaxy_ui.gd`; `game/tests/render_capture.gd` | **Offen** |
| P96 | Verständliche Dokumentation, Änderungsprotokolle, bekannte Einschränkungen und reproduzierbare Builds. | `game/scripts/galaxy/galaxy_model.gd`; `game/tests/galaxy_full_integration_test.gd` | **Offen** |
| P97 | Vollständige, längere Spielpartien mit reproduzierbaren Testprotokollen und ohne kritische Blocker. | `game/scripts/galaxy/galaxy_ai.gd`; `game/tests/galaxy_ai_soak_test.gd` | **Offen** |
| P98 | Konsistenter Release-Gate-Prozess einschließlich Regressionsprüfungen und realer Nutzer-Spieltests. | `game/scripts/galaxy/galaxy_model.gd`; `game/tests/galaxy_full_integration_test.gd` | **Offen** |

## Konkrete Code-Risiken aus der Stichprobe

1. **P89 – Save-Backup-Rotation:** `GalaxyModel.save_game()` löscht `galaxy_v1.json.bak` **vor** dem Versuch, die aktuelle Datei umzubenennen. Schlägt die anschließende Umbenennung fehl, ist das ältere Backup verloren. Für eine robuste Save-Rotation zuerst Testfälle für Dateisystemfehler, Wiederherstellung und atomare Rotation ergänzen, dann sichere Implementierung.
2. **P89 – Nur ein Save-Slot:** `GalaxyModel.SAVE_PATH = "user://galaxy_v1.json"`; Save-Slots, Autosave und Migration sind damit nicht nachgewiesen. Der bestehende Backup-Fallback ist nur eine Teilfunktion.
3. **P87/P89 – Datenvalidierung:** `GalaxyModel._read()` prüft Version, oberste Typen und Grundparameter; es gibt keine nachgewiesene vollständige Schema-/Referenzvalidierung aller verschachtelten Entitäten vor der Wiederherstellung.
4. **P08/P93 – Simulationsschleife:** `galaxy_ui.gd::_process()` führt maximal acht Jahre pro Frame aus. Das ist eine Schutzgrenze, aber kein gemessener Performance-Nachweis für 250 Sterne oder lange Spielpartien.
5. **P95/P98 – Visuelle Freigabe:** Render-Screenshots und Windows-Headless-Test existieren; ein sichtbarer Windows-10/11-Bedienungstest und längere echte Spielpartien fehlen.

## Abnahmestrategie und Aufwand

**Keine seriöse Fertigstellung in einem Durchlauf**: Die Matrix enthält 98 voneinander abhängige Vollabnahmen. Eine schnelle Zahl in Stunden ohne tatsächliche Laufzeit- und Fehlermessungen wäre erfunden.

Empfohlene **8 integrierte Arbeitspakete** (keine Garantie, dass jeweils ein Chat-Durchlauf reicht):

1. **Qualitätsfundament (P87–P98):** Save-Integrität, CI-Belege, Windows-Interaktion, Performance- und Testmetriken.
2. **Bedienbarer Spielkern (P01–P10, P85–P86):** Nutzerführung, Datenvisualisierung, Geschwindigkeit, Tutorial.
3. **Galaxis und Identität (P11–P24):** Kartentiefe, Erkundung, Kolonien, Spezies und Kulturen.
4. **Gesellschaft und Politik (P25–P33, P44–P50):** Kausalität, autonome Reaktionen, Institutionen.
5. **Wirtschaft und Logistik (P34–P43):** Erhaltungssätze, Unternehmen, Güter, Transport.
6. **Forschung, Diplomatie und Krieg (P51–P64):** Entwicklungspfade, Kriegskosten, Verträge, Spionage.
7. **KI, Geschichte und Endspiel (P65–P79):** Strategien, Krisen, Chronik, KI-Erklärbarkeit.
8. **Art, Audio, Balancing und Release (P80–P84, P93–P98):** pro Funktion Originalgrafik und Render-Nachweis, Musikrechte, Langzeitspieltests.

**Zeitmodell:** Pro Paket getrennt erfassen: Code-/Dateninventur, Akzeptanztests, Implementierung, CI-Retry, visuelle Prüfung, Benutzerabnahme. Erst nach zwei bis drei repräsentativen, gemessenen Paketen Aufwandsspannen für den Rest kalibrieren. Die zuvor genannten 8–12 oder 16–24 Durchläufe sind Planungsvarianten, keine validierten Schätzungen.

## Nächster messbarer Schritt

Mit **P89 (Save-Integrität)** beginnen: reproduzierbare Fehlerfälle für Backup-Rotation, beschädigte JSON-Dateien und Dateisystem-Rename-Fehler definieren; Tests zunächst rot nachweisen, Korrektur implementieren, CI grün nachweisen. Parallel eine echte native GUI-Spieltest-Checkliste und Performancebudget festlegen. Erst danach das erste Teilpaket individuell abnehmen.
