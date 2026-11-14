# Visuelle Neuausrichtung — Pixel-Art-Referenzpaket (2026-11-11)

## Neue verbindliche Stilrichtung
- Detaillierte Science-Fiction-Pixel-Art statt einfacher Godot-Kreise und Farbflächen.
- Palette: tiefes Navy, Petrol, Cyan/Türkis, Violett/Magenta und warmes Orange/Gold für Akzente.
- Szene: lesbare Architektur, Schiffe, Planeten, Lichter, Materialien, Tiefe und kontrolliertes Dithering.
- UI: schmale leuchtende Konturen, klare Lesbarkeit, dunkle Flächen, einheitliche Symbole.
- Keine Wasserzeichen oder Stockbildkopien in den Spielassets.

## Tatsächlich im Spiel geändert
- Vier neue, eigenständig erstellte SVG-Pixel-Art-Szenen unter `game/assets/art/`: `menu_city.svg`, `event_reactor.svg`, `event_ruins.svg`, `galaxy_nebula.svg`.
- `galaxy_ui.gd`: Hauptmenü und Ereignisse laden nun SVG-Szenen als `TextureRect` mit nearest filtering; vorhandene prozedurale Darstellung bleibt als Fehler-Fallback erhalten.
- Das Motiv `galaxy_nebula.svg` ist bislang nur eine Ressource, noch nicht mit der strategischen Karte verbunden.
- Separates Downloadpaket enthält einen neuen, eigenständig generierten Entwurfsatlas und 16 PNG-Motivausschnitte. Diese PNGs sind **noch nicht** als GitHub-Binärdateien hochgeladen und sind nicht dieselben Dateien wie die integrierten SVGs.

## Offene Punkte
- Keine vollständige Ersetzung sämtlicher Karten-, Schiffs-, Planeten-, UI- und Charaktergrafiken.
- SVG-Motive sind ein erster stilistischer Integrationsschritt und noch nicht so detailliert wie die bereitgestellten Referenzbilder.
- Godot-Import, Layout und tatsächliche Screenshots sind nicht verifiziert.
- Ein finales, durchgehend originales Produktions-Artset benötigt getrennte Sprite-Atlanten, Varianten, UI-9-Slices, Animationen und Spielintegration.
