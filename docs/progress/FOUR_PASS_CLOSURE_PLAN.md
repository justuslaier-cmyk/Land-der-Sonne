# Aktueller verbindlicher Abschlussplan: vier gebündelte Durchläufe

**Genehmigt 13.11.2026.** Ab jetzt operative Reihenfolge für `design/galactic-grand-strategy-pivot`. Ersetzt die weitere Arbeitsorganisation des bisherigen Zwölf-Durchläufe-Plans, **nicht** dessen historische Nachweise, die unveränderten P01–P98, die Entwicklungsregeln oder den Feature-Freeze. Vier neue Abschlussbündel, keine Behauptung, dass die historischen zwölf Pakete abgenommen seien.

## A1 – Gesamtaudit (jetzt)
Gesamten Branchbaum, Pflichttexte, vorhandene Code- und Test-Einstiege, historische Erkenntnisse und CI prüfen; pro P-ID die konkrete noch fehlende Einzelprüfung und Abnahmegrenze dokumentieren. **Done:** 98/98 klassifiziert, P0/P1/P2-Befunde mit reproduzierbaren oder ausdrücklich nur statischen Belegen getrennt, priorisierte A2-Arbeit, CI nach Dokumentationsänderung grün.

## A2 – Spielmechanik und aktive End-to-End-Kampagnen
Belegte P0/P1-Defizite korrigieren, Wirtschaft/Forschung/Politik/Diplomatie/Krieg/KI/Krisen/Endspiel über reale Aktionen verbinden. Drei deterministische, vollständig aktive Kampagnen mit verschiedenen Strategien, echten Ressourcen- und Forschungsbedingungen, Save/Resume, keine künstlich gesetzten Endgame-Voraussetzungen. Balancing und Kostenparität messen. **Done:** drei komplette Pfade, CI grün, keine bekannten P0/P1, programmierbare Pflichtlücken belegt geschlossen.

## A3 – Produktqualität und native Tests
Echte unterschiedliche Screenshots, Original-Pixel-Art, Animationen, Audio, Onboarding, UI-Skalierung und Barrierefreiheit prüfen; 250 Sterne/20 KI mit aktivem Spieler auf definierter Windows-Zielhardware messen. Windows-10/11-GUI und menschliche vollständige Spielpartien dokumentieren. **Done:** überprüfbare FPS/RSS/VRAM-Budgets, Grafik-/Audio-/Bedienungsbelege, keine kritischen Produktfehler. Nicht verfügbare menschliche Prüfungen ausdrücklich offen lassen.

## A4 – Release und P01–P98-Einzelabnahme
Alle 98 mit Commit, Test, Ergebnis, Integration und ggf. Screenshot/native Evidenz einzeln prüfen. Rechteakte, reproduzierbarer gepinnter Build, Changelog, SHA256, Archiv und acht Release-Gates. **Done:** 98/98, acht Gates, alle CI-Jobs grün, Release-Gate erfolgreich; andernfalls **KEIN RELEASE**.

## Ausführungsregeln
Kein neuer Mechanik-Scope, keine Mikrodurchläufe, keine erfundenen CI-/Windows-/Hörbelege. Ein Abschlussbündel umfasst Prüfung, erforderliche Änderungen, Regression, CI und Bericht. Frühere `FINAL_PASS_*.md` bleiben erhalten. Der jeweils letzte Auditbericht ist für Restarbeit aktueller als historische Momentaufnahmen.
