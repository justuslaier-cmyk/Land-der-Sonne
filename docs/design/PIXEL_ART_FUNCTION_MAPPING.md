# Pixel-Art-Neugestaltung — Funktionszuordnung (2026-11-11)

## Urheberrecht und Referenzen
Die vom Nutzer gezeigten Bilder dienen als allgemeine Stilreferenzen für Farbgebung, Pixeltechnik, Komposition und Detaildichte. Wasserzeichen-/Stockmotive wurden nicht kopiert oder als Spielressourcen eingebunden. Alle hier hinzugefügten SVGs sind neu programmatisch gezeichnete Motive.

## Aktuell im GitHub-Projekt
| Asset | Nutzung |
|---|---|
| `menu_city.svg` | Hauptmenü |
| `event_reactor.svg` | archäologische Ereignisse |
| `event_ruins.svg` | sonstige Ereignisse |
| `event_political.svg` | politische Krise, Reichspolitik |
| `event_market.svg` | Markt, Wirtschaft |
| `event_colonies.svg` | Kolonieereignis, Planetenverwaltung |
| `scene_fleet.svg` | Flottenkommando, Flottendoktrin, Schiffswerft |
| `scene_diplomacy.svg` | Diplomatie |
| `scene_research.svg` | Forschung |
| `galaxy_nebula.svg` | Chronik |

`galaxy_ui.gd` verwendet `TextureRect` mit nearest filtering; die ältere prozedurale Ereignisillustration ist Fehler-Fallback.

## Test
`game/tests/galaxy_art_resources_test.gd` überprüft Importierbarkeit der zehn SVGs als Godot-Texturen und ist in der CI-Testmatrix registriert. **Keine erfolgreiche Ausführung bestätigt.**

## Noch nicht umgesetzt
- Die eigentliche Galaxiekarte wird weiterhin programmatisch gezeichnet, keine neue Karte als spielbare Art-Ansicht integriert.
- Keine neuen individuellen Planetensprites, Flotteneinheiten, animierten Charakterporträts, vollständigen Icon-Atlanten oder Pixel-UI-Theme-Ressourcen im GitHub-Spiel.
- Die neuen SVGs sind einfache originale Illustrationen, **nicht** gleichwertig zur Detaildichte aller hochgeladenen Referenzen.
- Das separat zuvor generierte ZIP mit PNG-Atlas ist ein Designpaket und noch nicht als diese PNGs im Spiel integriert.
- Keine visuelle Abnahme in Godot, kein grüner CI-Lauf, kein nativer Windows-Test.

## Nächste Produktionsschritte
1. Alle PNG-Sprites sauber als Einzelassets (keine UI-Mockups als funktionale UI) schneiden, mit Transparentbereichen und konsistenter Pixelauflösung.
2. Binärdateien im Repository importieren und an Karte, Planeten- und Schiffsdarstellung anbinden.
3. Funktionales Godot-UI mit einheitlichen 9-Slice-Panels, Fonts, Icons, Focus/Hover/Pressed-Zuständen aufbauen.
4. Echte Godot-Screenshots, Lesbarkeit und Assetlizenzen prüfen.
