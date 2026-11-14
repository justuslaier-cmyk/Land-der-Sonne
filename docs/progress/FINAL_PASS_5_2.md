# Paket 5 – Durchlauf 2: Performance und vollständige Spielpartien

**Datum:** 2026-11-12 · **Branch:** `design/galactic-grand-strategy-pivot` · **Entscheidung: NICHT BESTANDEN (vollständige Paketabnahme).** Technische Maximalskalen-, UI- und Save/Resume-Regressionen: **CI BESTANDEN**. Die verlangten tatsächlich vollständig gespielten Partien, die Zielhardware-Abnahme und Windows-GUI-Spieltests sind nicht vorhanden und werden nicht behauptet.

## Quellen, Umfang und Anforderungen

Verbindlich: `docs/AI_DEVELOPMENT_RULES.md`, `docs/progress/FINAL_GAME_EXECUTION_PLAN.md` (5.2), `docs/vision/BINDING_GAME_REQUIREMENTS_CHECKLIST.md`, Spielvision und Projektstatus. Betroffene Pflichten: P05, P06, P08, P10, P11, P24, P64, P79, P88–P90, P94–P98 (jeweils nur Teilnachweise; **keine Checklisten-Häkchen**). Bestandsaufnahme: 256 Einträge im rekursiven Repositorybaum, bestehende Performance-Baseline (250/20, 30 Jahre), H1-Langläufe (100/8, 110 Jahre), Save-Resume-Regression (60/4, 36 Jahre), Endgame-Integration (60/3 mit bewusst gesetzten Krisenvoraussetzungen), Godot-Render-Matrix 1280×720 und 1920×1080. Diese bisherigen Nachweise ersetzen keine reale Maximalskalen-Partie.

## Implementierung und Fehlerbefunde

- `game/scripts/galaxy/galaxy_ui.gd`: wiederkehrende `load()`-Aufrufe aus der Kartenzeichnung und Stern-Rendering-Schleife durch konstante `preload()`-Ressourcen für Nebel, Sternatlas und zwei Flottenmotive ersetzt. **Keine neue sichtbare Spielfunktion und keine neuen Assets nötig**; die Originalgrafiken bleiben unverändert eingebunden. Die Godot-Render-Matrix prüft die Bildressourcen weiterhin.
- `game/tests/galaxy_max_scale_campaign_test.gd`: drei feste Seeds, je **250 Systeme, 20 KI, 180 Jahre**; 540 jährliche Simulationsticks, 90/90 Save/Resume mit tatsächlicher Datei und exaktem Weltzustandsvergleich, Zwischenstände alle 30 Jahre, Weltvertragsprüfungen, Generation, mittlere/p95/maximale Tickzeit, statischer Godot-Speicher und Spielstandgröße. Dies sind **drei automatische Langzeitsimulationen**, keine menschlichen vollständigen Partien.
- `game/tests/galaxy_max_scale_render_test.gd`: tatsächliche Godot-GL-Compatibility-Frames über Xvfb, 90 Frames je 1280×720 und 1920×1080 mit Kamera-/Zoom-/Auswahländerungen und wiederholtem Öffnen von Wirtschafts- und Forschungsansichten. Erfasst mittlere/p95/maximale Framezeit und statischen Godot-Speicher. **Xvfb ist kein Windows-GPU-Test**.
- `.github/workflows/godot-ci.yml`: beide Tests verpflichtend in Smoke- bzw. Render-Job integriert. CI-Regressiongrenzen: Galaxiegenerierung unter 1000 ms, maximaler Tick unter 50 ms, Spielstand unter 4 MiB, Godot-Static-Memory unter 256 MiB, interaktiver Xvfb-Frame unter 150 ms. Diese bewusst großzügigen **CI-Regressionbudgets** sind nicht als finale Zielhardware-/FPS-Budgets ausgegeben.
- Erster CI-Versuch `eb35c1f1`: GDScript-Parserfehler in neuer Testdatei (untypisierte Pfadvariable); in `6c8533dc` behoben. Erweiterung um explizite Budgets und UI-Ansichtswechsel in `0c79cdf9`, CI erneut ausgeführt. Kein bekanntes neues P0/P1-Problem aus den ausgeführten automatisierten Szenarien.

## Reale Messungen

**GitHub Actions [43259441993](https://github.com/justuslaier-cmyk/Land-der-Sonne/actions/runs/43259441993), Commit `0c79cdf90efd6b30809fbfdd4efff5db12b1ee1a`**, Godot 4.3 auf GitHub Ubuntu-Runner. Marker `GALAXY_MAX_SCALE_CAMPAIGN_PASS` und `GALAXY_MAX_SCALE_RENDER_PASS`.

| Seed | Generation (ms) | Ø Tick (ms) | p95 Tick (ms) | Max Tick (ms) | Peak statischer Speicher (MiB) | Save (KiB) |
|---|---:|---:|---:|---:|---:|---:|
| 20261112 | 54.34 | 2.50 | 2.62 | 3.81 | 21.73 | 180.95 |
| 731927 | 57.91 | 2.57 | 2.81 | 3.50 | 23.70 | 174.88 |
| 110317 | 55.57 | 2.62 | 3.01 | 3.76 | 23.70 | 177.63 |

| Xvfb-Viewport | Frames | Ø Frame (ms) | p95 Frame (ms) | Max Frame (ms) |
|---|---:|---:|---:|---:|
| 1280×720 | 90 | 11.27 | 38.25 | 42.29 |
| 1920×1080 | 90 | 12.71 | 39.14 | 45.88 |

**Interpretation:** Kein Überschreiten der oben genannten CI-Regressionsbudgets, keine Save/Resume-Divergenz in den drei geprüften Seeds. Die Frame-Mittelwerte dürfen **nicht** als verlässlich gemessene Windows-FPS interpretiert werden (Xvfb, synthetische Interaktionen, keine Dauerbelastung der Zielhardware). `OS.get_static_memory_usage()` misst nur den von Godot gemeldeten statischen Speicher, **nicht den gesamten Prozess-RSS oder GPU-VRAM**. Die Werte sind Hardware-/Runner-abhängig.

**Wichtige spielerische Erkenntnis:** In allen drei Maximalskalenläufen besitzt der Spieler nach 180 Jahren weiterhin nur **ein** System; die Tests steuern den Spieler nicht aktiv. Damit fehlt gerade die geforderte Last aus einem expandierten, komplex verwalteten Spielerreich. Keine belegte vollständige Sieg-/Sandbox-Partie, keine echte Langzeitmotivation aus menschlichem Feedback.

## Befehle, Evidenz und Grenzen

- `godot --headless --path game --editor --quit`
- `timeout 240s godot --headless --path game --script res://tests/galaxy_max_scale_campaign_test.gd`
- `timeout 180s xvfb-run -a -s "-screen 0 1920x1080x24" godot --path game --rendering-method gl_compatibility --script res://tests/galaxy_max_scale_render_test.gd`
- Vorhandene Godot-Smoke-, 13 Regressionen, 30 Render-Screenshots, Windows-x64-Export und Windows-2022-Headless-Runtime sind unverändert als CI-Gates aktiv.

**Noch offen für ABGENOMMEN:** echte vollständige Spielprotokolle mit aktiver Expansion, Forschung, Diplomatie, Krieg, Krisen und Endspiel; Messungen bei entwickelten 250-System-Reichen; Prozess-RSS und GPU-Speicher; native Windows-10/11-Bildraten auf definierter Zielhardware (CPU/GPU/RAM, Auflösung, Lastprofil, FPS-Ziel); manuelle UI- und Langzeit-Spieltests mit Ergebnissen. Diese Anforderungen können nicht aus Xvfb- oder Headless-Simulationen abgeleitet werden. Paket 6.1 darf dadurch nicht als Release-fähig markiert werden.
