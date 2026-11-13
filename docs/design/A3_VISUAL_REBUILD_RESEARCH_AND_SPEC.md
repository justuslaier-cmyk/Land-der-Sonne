# A3 – Visuelle Neuproduktion: Recherche, Designregeln und Abnahmematrix

**13.11.2026 · Branch `design/galactic-grand-strategy-pivot` · Status: FORSCHUNG/PRODUKTIONSSPEZIFIKATION, NICHT IMPLEMENTIERT.**

## 1. Verbindliche Grundlagen und Quellenhierarchie

1. Projekt: `docs/vision/GAME_VISION.md`, `docs/vision/GALACTIC_GAME_VISION.md`, `docs/vision/BINDING_GAME_REQUIREMENTS_CHECKLIST.md`, `docs/AI_DEVELOPMENT_RULES.md`, `docs/progress/FOUR_PASS_CLOSURE_PLAN.md`. Feature-Freeze, originäre Navy/Petrol/Cyan/Violett/Amber-Pixel-Art und echte Engine-/Windows-Nachweise sind bindend.
2. Nutzer-Referenzbilder vom 12.11.2026 sind **Stilreferenzen** (Stern- und Schiffs-Silhouetten, differenzierte Planetenoberflächen, klare Sci-Fi-Ikonografie, differenzierte Helligkeit), keine Importdateien. Mindestens eine Vorlage trägt Adobe-Stock-Wasserzeichen. Kein Kopieren von Einzelmotiven.
3. Nutzer-Spielvideo vom 13.11.2026: weiße Speziesbilder, visuell schwache Karte, überladene Navigation, mangelnde kausale Orientierung. Dies ist ein beobachteter kurzer Spieler-Test, kein Nachweis einer vollständigen Kampagne.
4. Externes Handwerk: Pixel Joint, cure, *The Pixel Art Tutorial* (2010), https://pixeljoint.com/forum/forum_posts.asp?TID=11299 – Pixelcluster, bewusste Kanten, Vermeidung von Banding, Pillow Shading und Einzelpixelrauschen.
5. Lospec, *Pixel Art Tutorials*, https://lospec.com/pixel-art-tutorials/ – Pixel Logic (Michael Azzi), Paletten und Lichtführung, Animation.
6. Godot Engine 4.3, *Multiple resolutions*, https://docs.godotengine.org/en/4.3/tutorials/rendering/multiple_resolutions.html – Pixel-Art-Viewport/Integer-Skalierung vs. dynamische GUI; keine ungeprüfte Umstellung des vorhandenen Canvas-Items-Layouts.
7. Godot Engine 4.3, *UI*, https://docs.godotengine.org/en/4.3/tutorials/ui/ und *Using Containers*, https://docs.godotengine.org/en/4.3/tutorials/ui/gui_containers.html – Controls, Anchors, ScrollContainer und dynamische Layouts.
8. Godot Engine, *Importing images*, https://docs.godotengine.org/en/latest/tutorials/assets_pipeline/importing_images.html – verlustfreier Import für Pixel-Art und Filterung auf CanvasItem-Ebene.
9. Game Accessibility Guidelines, *Provide high contrast between text/UI and background*, https://gameaccessibilityguidelines.com/provide-high-contrast-between-text-ui-and-background/ – Textkontrast mindestens 4,5:1 als Prüfziel.
10. Hunicke, LeBlanc, Zubek (2004), *MDA: A Formal Approach to Game Design and Game Research*, https://aaai.org/papers/ws04-04-001-mda-a-formal-approach-to-game-design-and-game-research/ – Mechanics, Dynamics, Aesthetics: Grafik muss die Ursache-Wirkungs-Struktur des Spielsystems vermitteln.

**Quellenabgrenzung:** Technische Filter-/Layout-Eigenschaften stammen aus Godot-Dokumentation; die nachfolgenden Pixelmaße, Palette, Art-Aufträge und Qualitätsgrenzen sind **projektbezogene Designentscheidungen/Vorschläge**, nicht Aussagen aus der Dokumentation.

## 2. Visuelles System

### Palette und Licht

- Hintergründe: #071123, #0B182B, #10263A. Dunkle Tiefe mit sehr zurückhaltender Textur; keine funktionslosen Sternenpartikel über Information.
- Struktur/Neutral: #28435A, #44647B, #9CBFC7, #E4F3F2.
- Spieler und positive Navigation: #7CE3CC / #9FF8EF. Feind: #E991B3. Warnung: #F3B879. Kritisch: #F18476. Archäologie: #C7A8F2.
- Lichtquellen konsequent oben links oder durch lokale Sonne motiviert. Mindestens drei unterscheidbare Helligkeitsstufen pro wichtigem Material; Schatten folgen Körperform, nicht einfach einem konzentrischen Ring.
- Farben kodieren **nie allein** Status: Form, Kontur, Symbol und Kurzlabel tragen denselben Zustand.
- Dekorative Details maximal in ruhigen Bildflächen. Nicht mehr Detail als in 1×-Darstellung lesbar.

### Raster und Form

- Entwurfsraster: 16/32/64/128 logische Pixel je nach Funktion, klare Pixelcluster, kein beliebiges hochskaliertes Vektor-Glätten.
- 16–32 px: Funktionssymbol, 32–64 px: Stern-/Schiff-/Kolonie-Silhouette, 96–128 px: Planetensystem-Vignette, 128–192 px: Porträt, 320×180 oder 640×360 px: Ereignisillustration.
- Größere Illustrationen dürfen bewusst reichhaltiger sein, müssen aber dieselbe Licht-/Materiallogik und Palette respektieren.
- Ausspielung auf 1280×720, 1600×900, 1920×1080 und 2560×1440 testen. Pixel-Art und Text-UI separat auf Skalierungsfehler prüfen.

## 3. Verbindliche Art-Kategorien und tatsächliche Spielbedeutung

| Kategorie | Grafische Neuproduktion | Spielzustand, der sichtbar werden muss | Integrations- und Prüfkriterium |
|---|---|---|---|
| Hauptmenü | Originäre Galaxie-Illustration mit Tiefe, klarer Titelzone und zurückhaltender Animation | Spiel starten/laden/fortsetzen; kein Menüpunkt im Motiv versteckt | Screenshot + Keyboard-Fokus |
| Galaxie-Setup | Unterschiedliche Galaxieformen als Miniaturkarten; Dichte, Startabstände, Ressourcen | Änderungen der Parameter sind in der Vorschau erkennbar | Seed-/Einstellungs-Test + Screenshot |
| Spezies | Fünf **unterschiedliche** original gezeichnete Porträts, nicht bloß fünf Farbvarianten | Ausgewählte Spezies deutlich markiert, keine weißen Texturflächen | Godot-Import + echte Windows-Screenshots |
| Reiche/Regierungen | Eigenständige Heraldik-/Ethik-Icons | Form/Prinzip und gewählte Kombination | Screenreader-/Tooltip-/Fokusprüfung |
| Schiffe | Silhouetten je Schiffsstil, klar erkennbare Antriebe, Bug, Flügel und Waffenträger | Besitzer, Schiffstyp, Flugrichtung, aktiver Auftrag | 1×-Lesbarkeit, mehrere Zoomstufen |
| Sterne | Sternklassen mit eigenständiger Form, Korona und Farbrampe | Kartiert/unbekannt, Sternklasse, ausgewählt | Karten-Zoom 0,25–3,0 |
| Planeten | Fels/Eis/Gas/Wasser/Wüste/habitable Welten mit Material- und Lichttiefe | Bewohnbarkeit, Ressourcen, Kolonie, Risiko | Planetenvorschau + Systemansicht |
| Nebel/Karte | Hintergrund mit Tiefenstaffelung, ruhigen negativen Flächen | Sternsysteme bleiben Fokus, kein Hintergrundrauschen | Vergleichsscreenshots 75/250 Sterne |
| Hyperraumrouten | Dünne Linien, Richtung/Zugänglichkeit/Status, reduzierte visuelle Gewichtung | Entdeckt, erreichbar, blockiert, beflogen | Fog-of-War-Regressionsprüfung |
| Reichsgrenzen | Gut lesbare Flächenkonturen mit klarer Trennung von Systempunkten | Besitzwechsel, Bündnis, Kriegszustand | Save/Load + Grenzwechsel-Screenshot |
| Flotten/HUD | Differenzierte Spieler-/KI-/feindliche Symbole und Indikatoren | Stärke, Ziel, Versorgung, Bewegung, Auswahl | Keine Verwechslung bei 250 Sternen |
| Wirtschaft | Credits, Legierungen, Wissenschaft, Produktion, Versorgung als eigene Icon-Familie | Bestand, Fluss, Kosten, Engpass, Ursache | Tatsächliche Forecast-/Action-Preview-Werte |
| Kolonien | Siedlungs-/Industrie-/Forschungs-/Infrastruktur-Illustrationen | Ausbaustufe, Baukosten, Wirkung, Fertigstellung | Ressourcen- und Zustandswechsel |
| Forschung | Fachbereiche und Freischaltungen als zusammenhängender Symbolsatz | Vorbedingung, Preis, Forschungseffekt | Gesperrt/verfügbar/erforscht |
| Diplomatie | Eigene Status- und Vertrags-Ikonografie | Haltung, Kosten, Dauer, Krieg/Frieden | Treaty-/War-Regressionspfad |
| Ereignisse/Krisen | Originalillustration je bestehender Ereigniskategorie, keine Einheitskarte | Wahl, Kosten, Risiko, verzögerte Folge | Save/Resume- und Ereignis-Screenshots |
| Chronik/Ziele | Zeitachsen-, Meilenstein- und Zielzustände | Ursache → Entscheidung → Konsequenz | Kausale Einträge und Siegpfade |
| Optionen/Audio | Lautstärke-/Stumm-/Kontrast-/Skalierungsindikatoren | Einstellungen wirksam und persistent | Audio-/UI-Optionen-Test |
| UI-Rahmen | Konsistente Panel-Ecken, Fokus-, Hover-, Aktiv-, Deaktiviert- und Warnzustände | Interaktivität und Aktionsverfügbarkeit | Fokus-/Kontrast-/Hover-Regression |

**Wichtig:** Dies ist eine Funktions-/Kategorie-Matrix, **keine verifizierte Dateiliste aller vorhandenen Assets**. Vor dem Anspruch „jede einzelne Grafik ersetzt“ ist eine rekursive Dateiliste mit altem Pfad, Import, konkreter Szene, neuem Pfad, Asset-Hash und tatsächlichem Screenshot zwingend.

## 4. Grafik als Ausdruck der Spielregeln

Jede wichtige Entscheidung benötigt fünf sichtbare Informationen: **aktueller Zustand → mögliche Aktion → Voraussetzung/Kosten → erwartete Veränderung → tatsächliches Ergebnis**.

Beispiele für die vorhandenen Systeme:
- **Kolonisieren:** Habitable Welt erkennbar, eigene stationierte Flotte markiert, 50 Credits als Kosten, fehlende Voraussetzungen direkt am deaktivierten Befehl, nach erfolgreicher Kolonisation neuer Besitz-/Siedlungszustand.
- **Forschung:** Fachgebundene Voraussetzung und Ressourcenpreis am Technologieeintrag, tatsächliche Freischaltung und Veränderung einer messbaren Kennzahl.
- **Flotte:** Flugroute und ETA vor Ausführung, Versorgung/Unterhalt, Ankunft und Kampfzustand visuell unterscheidbar.
- **Krise:** Warnstufe und konkrete Verteidigungsanforderung, Folgen verschiedener Entscheidungen, nachfolgender Zustand.
- **Wirtschaft:** Bestände **und** Nettoänderungen, Ursachen eines Engpasses, erwartete Wirkung eines Bauauftrags.
- **Diplomatie:** Beziehungs-/Vertragszustand und Ressourcenfolge, nicht nur dekorative Fraktionsporträts.

Damit wird MDA auf die Oberfläche übertragen: Mechanik wird als verständliche Aktion angeboten; Dynamik ist in der Folge sichtbar; Atmosphäre entsteht durch lesbare visuelle Rückmeldung statt durch reine Dekoration.

## 5. Produktions- und Abnahmeverfahren

1. Rekursiv alle tatsächlichen `game/assets/art/`-Dateien und alle `res://assets/art/`-Referenzen erfassen. Jede Datei und jede prozedurale Zeichnung als eigener Inventareintrag.
2. Für jede Grafik Zweck, 1×-Abmessung, Palette, Licht, Silhouette, Zustandsvarianten, Rechte/Urheberschaft, vorhandene Referenzen und Abnahmescreenshot definieren.
3. **Eigene** Bilddatei mit kontrolliertem Raster und ohne fremde Motive erstellen. Originalquellen erhalten. Wasserzeichen-/Stockvorlagen niemals übernehmen.
4. In die echte Godot-Ansicht integrieren, SVG-/PNG-Import prüfen, keine weißen Texturen, keine Platzhalter. Nicht referenzierte alte Dateien erst nach Nachweis entfernen.
5. Rendering bei unterschiedlichen Bildschirmgrößen, Helligkeiten, Farbsehvarianten, Spielzuständen und Zoomstufen vergleichen; UI-Aktionen zusätzlich funktional testen.
6. Automatisierte Tests, CI, Windows-Export und native menschliche Spieltests durchführen; erst danach je Grafik **BESTANDEN** setzen.

### Harte A3-Stoppsignale

- Ein weißes/fehlendes Porträt, ein nicht importiertes Bild oder ein unsichtbarer Funktionszustand.
- Unlesbare oder gleichartige Symbole für unterschiedliche Entscheidungen.
- Ein Screenshot ohne tatsächlich ausgeführte Godot-Szene als vermeintlicher Rendernachweis.
- Eine schöne Illustration ohne verifizierte Gameplay-Integration.
- Nicht nachgewiesene FPS/RSS/VRAM auf definierter Windows-Zielhardware.
- Behauptung „alle Grafiken ersetzt“, solange keine 1:1-Inventar-/Integrations-/Abnahmeliste existiert.

**Aktueller Stand:** Forschung und Produktionsanforderungen spezifiziert. **Keine** Behauptung, dass die grafische Neuproduktion ausgeführt, importiert oder visuell abgenommen sei. A3 bleibt **NICHT BESTANDEN**.
