# Paket 4 – Durchlauf 1: Art-Produktionsaudit und konsistente Grafik

**Stand:** 2026-11-12. **Branch:** `design/galactic-grand-strategy-pivot`. **Technischer Implementierungscommit:** `207c2570ab5ca89cb661209ba58b37fb8742a203`.

## Scope, Quellen, unveränderte Pflichten

Verbindlich: `docs/AI_DEVELOPMENT_RULES.md`, `docs/progress/FINAL_GAME_EXECUTION_PLAN.md`, `docs/vision/BINDING_GAME_REQUIREMENTS_CHECKLIST.md`, `docs/design/PIXEL_ART_VISUAL_OVERHAUL.md`, `docs/design/PIXEL_ART_FUNCTION_MAPPING.md`. Betroffen: visuelle P01–P98-Pflichten (keine automatisch abgehakt). Keine neue Mechanikkategorie; keine Fremdassets oder externen Stockbilder.

## Vollständige Bestandsaufnahme

Rekursiver GitHub-Baum am Beginn: 240 Einträge; 23 vorhandene SVG-Dateien unter `game/assets/art/` (21 Altbestand aus früherer Audit-Phase plus zwei später hinzugefügte Motive). Zuordnung der vorhandenen Dateien:

| Bereich | Bestandsdateien | tatsächliche Integration |
| --- | --- | --- |
| Menü | `menu_city.svg` | Menüillustration |
| Kartenhintergrund/Chronik | `galaxy_nebula.svg` | Karte und Chronik |
| Sterne | `star_sprite_strip.svg` | Galaxiekarte und jetzt Sternsystem |
| Planeten | `planet_sprite_strip.svg` | System- und Planetenvorschau |
| Schiffe | `ship_sprite_strip.svg` | Legacy-Atlas vorhanden; Galeriedarstellung zuvor wegen weißer Kacheln auf Prozedural-Fallback |
| Spezies | `species_portrait_strip.svg` | Legacy-Atlas vorhanden; Galeriedarstellung zuvor wegen weißer Kacheln auf Prozedural-Fallback |
| Station | `orbital_station.svg` | Sternsystem/Orbit |
| UI-Funktionsicons | `function_icon_atlas.svg` | zentrale Aktionsbuttons |
| Optionen | `ui_comfort_panel.svg` | Optionsansicht |
| Ereignisse | `event_reactor.svg`, `event_ruins.svg`, `event_political.svg`, `event_colonies.svg`, `event_market.svg` | Ereigniskarten/Verwaltung |
| Verwaltungsszenen | `scene_fleet.svg`, `scene_diplomacy.svg`, `scene_research.svg`, `scene_society.svg`, `scene_freight_security.svg`, `scene_information_policy.svg`, `scene_research_exchange.svg`, `scene_trade_policy.svg` | Berichte und Aktionsansichten |
| Ergebnis/War | `chronicle_aftermath.svg`, `war_objective.svg` | Ziel-/Chronikzustände |

**Befund:** Bereits existierende Illustrationen sind überwiegend als SVG-Texturen eingebunden. Im tatsächlichen Code standen jedoch `var ship_strip: Texture2D = null` und `var portraits: Texture2D = null` mit Kommentaren zu weißen Atlas-Kacheln in Godot 4.3. Damit waren neun vorhandene Original-Spritevarianten trotz Artdateien nicht als Spielgrafik sichtbar. Legacy-Atlanten nicht gelöscht, weil Ressourcenregressionen und potenzielle Referenzen weiterhin bestehen.

## Integrierte Reparatur / Produktion

- Aus den **originalen projektspezifischen** Pixel-Art-Atlanten neun **separat importierbare Original-SVG-Sprites** mit exakt zugeschnittenem SVG-`viewBox` erzeugt: `ship_style_0.svg` bis `ship_style_3.svg` (64×64), `species_portrait_0.svg` bis `species_portrait_4.svg` (64×96). Die Motive sind Originalmaterial des Projekts, keine neuen Fremdwerke.
- `game/scripts/galaxy/galaxy_ui.gd`: Schiffs- und Speziesgalerien nutzen nun tatsächliche Sprite-Texturen per `draw_texture_rect` anstelle des deaktivierten `null`-Pfads bzw. der fehlerhaften Atlas-Region. Fallback-Prozeduralzeichnung bleibt nur bei nicht importierbarer Ressource. Flottenmarker auf der strategischen Karte verwenden Schiffssprites statt bloßer Dreiecke. Die Sternsystemansicht nutzt den vorhandenen Stern-Atlas mit Fallback.
- `game/tests/galaxy_art_production_test.gd`: alle neun neuen Assets müssen als Texture2D importierbar sein und korrekte Maße haben; Schiffs-/Spezies-Draw-Callbacks werden in realen UI-Instanzen ausgeführt.
- `game/tests/render_capture.gd`: Matrix auf 15 Ansichten × 2 Auflösungen erweitert, darunter Galerien und Sternsystem. Bilddateien werden mit dem echten Godot-Renderer erzeugt.
- `.github/workflows/godot-ci.yml`: neuen Sprite-Import- und Galerietest in die vollständige Smoke-Matrix aufgenommen.

## Palette, Raster, Filter und Zustände

- Verbindliche Palette in `GalaxyVisualTheme`: Navy `#071123`, Petrol `#10263a`, Cyan/Fokus `#9ff8ef`, Gold `#f3b879`; zusätzliche Violett-/Korallakzente in Sprite-Varianten.
- Sprite-Maße: 64×64 Schiffe, 64×96 Porträts, 32×32 Sterne, 64×64 Planeten. `game/project.godot` verwendet nearest filtering. Original-SVGs haben `shape-rendering=crispEdges`.
- UI-Buttons besitzen bereits Normal-, Hover-, Pressed-, Focus- und Disabled-Zustände; ausgewählte Schiffe/Spezies bleiben golden umrahmt. Keine unnötige Ersetzung des etablierten Themes.
- Originalität: Die neun Einzeldateien sind ausschließlich abgeleitete Zuschnitte der zuvor im Projekt vorhandenen Original-Atlanten. Externe Referenzbilder wurden nicht eingebunden.

## Nachweise und Abnahme

- GitHub Actions: https://github.com/justuslaier-cmyk/Land-der-Sonne/actions/runs/43254991184. Im Lauf erfolgreich: Godot-4.3-Projektimport, `galaxy_art_production_test.gd`, `godot-smoke` und `render-check` mit echten Rendereraufnahmen.
- Der Render-Job publiziert die Aufnahmen als `godot-render-evidence`-Artefakt. Eine **menschliche visuelle Prüfung dieser PNGs** liegt hier nicht vor; ein bestandener Render-Job beweist allein fehlerfreie Bildgenerierung, nicht die ästhetische Qualität.
- Native Windows-GUI-Ansichten, Bildlesbarkeit bei realer Windows-Skalierung, Pixel-Art-Materialtiefe gegenüber Nutzerreferenzen und unabhängige visuelle Review sind **offen**.
- Die bestehenden illustrativen SVGs sind nicht alle individuell neu gestaltet; die grafische Qualität aller 23 Ausgangsassets wurde nicht durch einen menschlichen Bildvergleich bestätigt. Insbesondere werden die neuen Einzel-Sprites als Wiederverwendung des Originalmotivs, nicht als Qualitätssteigerung der Detailtiefe ausgegeben.
- **Abnahmeentscheidung: NICHT BESTANDEN für die vollständige visuelle Paket-4.1-Produktabnahme**, solange die erforderliche tatsächliche visuelle Sichtung und der Nachweis „keine unlesbaren Grafiken/Platzhalter“ fehlen. **Technischer Teil: CI BESTANDEN.** Dies ist kein stillschweigender Abschluss der gesamten grafischen Produktionsqualität.
