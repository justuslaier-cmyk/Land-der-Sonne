# Pixel-Art-Austausch – laufender Produktionspass (2026-11-11)

## Neue verbindliche Regel
Siehe `docs/AI_DEVELOPMENT_RULES.md`: Jede neu implementierte visuelle Spielfunktion erhält gleichzeitig ein eigenständig geschaffenes, stilkonformes Asset, tatsächliche UI-/Rendering-Integration, Importtest und dokumentierten visuellen Prüfstatus. Kein bloßer dekorativer Banner gilt als komplette Grafik.

## In diesem Pass implementiert
- `game/assets/art/planet_sprite_strip.svg`: acht eigenständig programmatisch gezeichnete 64×64-Pixel-Planetenvarianten mit Schatten und Farbstruktur.
- `game/assets/art/ship_sprite_strip.svg`: vier eigenständige 64×64-Pixel-Schiffssilhouetten.
- `game/scripts/galaxy/galaxy_ui.gd`: Planetenübersicht und Systemkarte verwenden die neue Planeten-Textur mit prozeduralem Fallback; Schiffs-Galerie und Schiffsvorschau verwenden die neue Schiffstextur; interaktive Galaxiekarte zeichnet die bestehende Galaxieillustration als dezenten Hintergrund.
- `game/scripts/galaxy/galaxy_visual_theme.gd`: globale Palette auf Navy/Petrol/Türkis/Bernstein angepasst.
- `game/tests/galaxy_art_resources_test.gd`: zwei neue Sprite-Atlanten inklusive Größe und Importierbarkeit in den bestehenden CI-Ressourcentest aufgenommen.

## Wichtig: offener Umfang
- Die bisherigen einfachen Grafiken sind **nicht vollständig ausgetauscht**: Galaxiekarten-Sternsymbole, HUD, Bevölkerungsporträts, diverse Funktionsbuttons, Einheiten, Stationen, Monde, Icons und UI-Panels brauchen weiter individuelle Pixel-Art-Ressourcen.
- Die neu erstellten SVG-Sprites sind ein erster integrierter Satz, aber nicht die Detailqualität der Nutzerreferenzen.
- Die aus dem früheren ZIP bekannten PNG-Entwürfe sind weiterhin nicht als Binärassets in GitHub integriert.
- Kein Godot-Rendering, kein visueller Screenshotvergleich und kein erfolgreiches CI-Ergebnis in diesem Pass bestätigt.
- Die strategische Karte bleibt interaktiv; die Hintergrundgrafik ist nicht als fertige spielbare Karte zu verstehen.
- Keine der 98 Pflichtanforderungen allein durch diese Grafikänderungen vollständig abgenommen.

## Nächste Grafikumstellung
1. Originäre Stern-/Flotten-/Stationen-Sprites direkt in der interaktiven Karte rendern, Auswahlzustände und Zoom verifizieren.
2. Fünf eigenständige Speziesporträts und koloniale Architekturvarianten mit einheitlicher Pixelauflösung.
3. Vollständiges UI-Theme mit echten 9-Slice-Panels, Hover-/Fokus- und Icon-Assets; Lesbarkeit bei 640×360, 1280×720 und 1920×1080.
4. Für jedes neue Gameplay-Feature Grafik + Code + Test im selben Arbeitsschritt.
