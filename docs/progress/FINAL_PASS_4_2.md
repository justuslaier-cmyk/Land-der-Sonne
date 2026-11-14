# Paket 4 – Durchlauf 2: Animation und Audio

**Datum:** 2026-11-12. **Branch:** `design/galactic-grand-strategy-pivot`. **Implementierung:** `1950a0a362399b72c9eb9a65d375ae87c4f3a003`, `952621346fb26b3c7e4edb32b2ead30e97a66bfb`.

## Scope und Pflichten

P05 (Karteninteraktion), P07 (Ereigniskarten), P08 (Zeitbedienung), P83 (Animation/Übergänge), P84 (Musik/SFX/konfigurierbarer Ton), P85 (Bedienbarkeit), P90/P91 (Regression/Render). Keine Pflichten allein wegen dieses Durchlaufs abgehakt. Verbindlicher Umfang laut `docs/progress/FINAL_GAME_EXECUTION_PLAN.md`: vorhandene Karte, Schiffe, Ereignisse, UI gezielt animieren; eigene/rechtlich nutzbare Musik/SFX, Busse und Einstellungen integrieren; Grafik-/Audio-Regression und visuelle Review.

## Bestandsfehler und Reparatur

- Vorher: Die vorhandenen Optionen `volume`/`muted` regelten lediglich den Master-Bus; es gab keinen Audio-Player, kein Musik-/Effektmaterial, keine getrennten Kanäle.
- Neu `game/scripts/galaxy/galaxy_audio.gd`: vollständig originär im Projektcode synthetisierte, achtsekündige geloopte atmosphärische Klangfläche und drei kurze Signaltypen (Klick, Systemauswahl, Ereignis). `AudioStreamWAV` mit 22.050 Hz/PCM16. Keine Samples, Musikstücke oder Bibliotheken Dritter. Reproduzierbare algorithmische Komposition, kein Import fremder Aufnahmen.
- `Music`- und `SFX`-Busse werden einmalig angelegt und auf `Master` geroutet; ein dauerhaftes `GalaxyAudioDirector`-Kind übersteht alle Bildschirmwechsel. Musik wird bei Start der UI gestartet, SFX sind an Menü-, Navigations-, Toolbar-, Systemauswahl- und Ereignisaktionen gebunden.
- `game/scripts/galaxy/galaxy_comfort.gd`: persistente, begrenzte `music_volume`- und `sfx_volume`-Einstellungen ergänzen bestehende Master-Lautstärke, Master-Mute, UI-Skalierung und Vollbild. Alte Konfigurationsdateien werden durch Defaults ergänzt.
- `game/scripts/galaxy/galaxy_ui.gd`: unabhängige Musik-/SFX-Slider in den vorhandenen Optionen; Übergangs-Fade der bestehenden originalen Szenenillustrationen; zeitgesteuerter pulsierender Ring des ausgewählten Sterns auf der Galaxiekarte, mit 120-ms-Redraw-Timer, der zusammen mit der Kartenansicht freigegeben wird. Bestehende Sprites/Artdateien werden wiederverwendet, keine neuen sichtbaren Funktionskategorien.
- `game/tests/galaxy_audio_animation_test.gd`: prüft Busse, Wellenform-Byteanzahl, Loop-Modus, drei Effekte, Audioknoten-Lebensdauer über UI-Navigation, Master-Mute, Master-Lautstärke und beide Einzelbus-Regler. Test setzt Preferences am Ende zurück.
- CI: Test in `.github/workflows/godot-ci.yml` aufgenommen; bestehende vollständige Regression- und Screenshot-Matrix bleibt aktiv.

## Abnahme / Reproduzierbarkeit

- Test: `godot --headless --path game --editor --quit` und `timeout 90s godot --headless --path game --script res://tests/galaxy_audio_animation_test.gd`.
- GitHub-CI: https://github.com/justuslaier-cmyk/Land-der-Sonne/actions/runs/43256080933.
- Render: `xvfb-run -a -s "-screen 0 1920x1080x24" godot --path game --rendering-method gl_compatibility --script res://tests/render_capture.gd`; echte Renderdateien als CI-Artefakt.
- Rechte: ausschließlich originale mathematisch erzeugte Wellenformen; keine externen Tondateien und keine Fremdkomposition.
- **Offene manuelle Prüfungen:** Audition von Musik und SFX über reale Lautsprecher/Kopfhörer auf Windows, Beurteilung der akustischen Qualität und Lautheitsbalance; Sichtprüfung der Übergänge und des pulsierenden Kartenmarkers mit laufendem Godot-Fenster. Statische CI-Screenshots können eine zeitliche Animation nicht visuell belegen. Windows-Nativtest offen.
- **Abnahme:** Technische CI-Prüfung wird separat am angegebenen Run festgestellt; visuelle und akustische Endabnahme bleibt **NICHT BESTANDEN**, bis echte manuelle Wahrnehmungsbelege vorliegen. Diese offene externe Abnahme blockiert gemäß Entwicklungsregeln nicht die Bearbeitung unabhängiger Folgepakete.
