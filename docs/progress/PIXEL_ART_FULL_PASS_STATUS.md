# Grafik-Austausch – gebündelter Durchlauf (2026-11-11)

## In diesem Durchlauf tatsächlich eingebunden
- 5 neu gezeichnete Speziesporträts: `game/assets/art/species_portrait_strip.svg`; Verwendung in `_draw_species` der Reichserstellung.
- 4 neu gezeichnete Sternsprites: `game/assets/art/star_sprite_strip.svg`; Verwendung in `_draw_pixel_star` der interaktiven Galaxiekarte.
- 1 neu gezeichnetes Stationssprite: `game/assets/art/orbital_station.svg`; Verwendung in `_draw_orbital_station` der Sternensystemansicht.
- 8 Planetenvarianten und 4 Schiffssprites aus dem unmittelbar vorangegangenen Pass bleiben in Planeten-/Schiffsvorschauen eingebunden.
- Bereits vorhandene zehn Szenenillustrationen bleiben für Hauptmenü, Forschung, Ereignisse, Politik, Wirtschaft, Kolonien, Flotte, Diplomatie und Chronik verfügbar.
- Karte: illustriertes Nebelmotiv im Hintergrund, Sternsprites anstelle der einfachen prozeduralen Sternflächen.
- UI: zentrale Palette Navy/Petrol/Türkis/Bernstein, thematisierte Hauptkartenleiste, Galeriebuttons und Seitenpanel.
- Test `game/tests/galaxy_art_resources_test.gd` prüft die Assetimporte und die Atlasabmessungen.

## Verbindliche Regel
`docs/AI_DEVELOPMENT_RULES.md` verlangt bei jeder neuen visuellen Spielfunktion zugleich originäres passendes Asset, tatsächliche Integration und dokumentierte Tests.

## Abnahme: nicht abgeschlossen
- Hier konnte Godot nicht ausgeführt werden. Keine bestätigten Engine-Imports, Screenshots, CI-Erfolge oder Windows-Builds.
- Kein vollständiger, qualitätsgeprüfter Ersatz *aller* visuellen Elemente: Sternensystem-Linien, Kartenmarker, Technologie-Icons, Gebäude-/Kolonie-Sprites, alle HUD-Controls, Tooltip-Grafiken, Effekte und Animationen benötigen weiterhin spezifische Assets.
- Die neuen SVG-Sprites sind kleine originale Pixel-Art-Atlanten, erreichen aber noch nicht die Materialtiefe, Komposition und Detaildichte der vom Nutzer gelieferten Referenzen.
- `game/scripts/galaxy/galaxy_ui.gd` enthält weiterhin Fallback-Prozeduralzeichnungen. Diese werden genutzt, falls Texturen nicht importiert werden können.
- Die 98 Pflichtanforderungen bleiben von diesem Grafikpass unberührt; keine als vollständig abgenommen markieren.

## Qualitätssicherung für die endgültige Grafikabnahme
1. Godot 4.3 Projektimport und automatisierte Ressourcentests ausführen.
2. Hauptmenü, Reichserstellung, Galaxiekarte, Sternensystem, Flotte und alle Ereigniskarten in 1280×720 und 1920×1080 tatsächlich rendern und Screenshots vergleichen.
3. Fehlende funktionsspezifische Pixel-Icons, Gebäude, Einheiten, Zustandsbilder, 9-Slice-Rahmen, Tooltips und Animationen ergänzen.
4. UI-Fokus, Hover, Kontrast, Skalierung und Bildlesbarkeit manuell überprüfen.
