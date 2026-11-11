# Stabilisierung – Durchlauf 4: Windows-Testbuild

Datum: 2026-11-11. Branch: `design/galactic-grand-strategy-pivot`.

## Umgesetzt
- `windows-export` hängt nun explizit von `godot-smoke`, `regression-matrix` und `render-check` ab. Der Windows-Build läuft nur, wenn alle drei vorherigen Jobs erfolgreich sind.
- Export mit Godot 4.3 Stable nach `dist/LandDerSonne.exe` und `dist/LandDerSonne.pck`; beide Dateien müssen vorhanden und nicht leer sein.
- Release-ZIP `LandDerSonne-Windows-x64.zip` enthält EXE, PCK, `BUILD_INFO.txt` mit Commit-SHA/Workflow-ID/Godot-Version und `SHA256SUMS.txt`.
- Artifact-Name bleibt `LandDerSonne-Windows-experimental`, um bestehende Downloadpfade nicht unnötig zu ändern.
- Paket ist ein **experimenteller** Windows-Build, keine signierte Produktionsversion.

## Abnahmeblocker
- Workflow 43103680355 war bei Abfrage `pending` ohne Jobs oder Artifacts.
- Kein tatsächlicher Windows-Build, kein bestätigter Import, kein grüner Testlauf, kein auf Windows gestartetes Spiel.
- Kein downloadbares Windows-ZIP ist bisher bestätigt. Ein GitHub-Quellcode-ZIP ist kein Ersatz für einen exportierten Build.
- Auch ein erfolgreicher Linux-Godot-Export beweist noch nicht, dass der Windows-Build auf einem echten Windows-Rechner startet. Dies muss zusätzlich manuell getestet werden.

## Freigabeschritte
1. GitHub Actions Queue-/Runner-Problem lösen; vollständigen Workflow ausführen.
2. Alle Testjobs grün; Renderartefakt auf UI-Fehler prüfen.
3. Windows-Export-Job erfolgreich; ZIP-Artefakt vorhanden.
4. ZIP herunterladen, entpacken und `LandDerSonne.exe` auf Windows 10/11 starten.
5. Neues Spiel, Galaxiekarte, Forschung, KI-Zeitlauf, Ereignisse, Speichern/Laden testen. Ergebnis und Build-SHA dokumentieren.
6. Erst dann Version als getestete Windows-Testversion freigeben.

## Status
Build-Pipeline und Release-Gating implementiert. **Durchlauf 4 technisch nicht abgenommen**, da die Runner-Ausführung noch aussteht.
