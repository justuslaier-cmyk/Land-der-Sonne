# Paket H – Durchlauf 1: Langzeit- und Balancing-Gates

## Reproduzierbare Testmatrix
Der automatisierte Godot-Test `galaxy_package_h1_test.gd` führt drei 110-Jahres-Kampagnen mit 100 Sternen, acht KI-Reichen und festen Seeds 22071, 45199 und 87331 aus. Für jede Kampagne wird ein unabhängiger deterministischer Replay-Weltzustand fortgeschrieben.

Drei ausdrücklich unterschiedliche wirtschaftspolitische Ansätze werden geprüft: Wohlfahrtsstaat (Wohlfahrtsstufe 2), strategische Handelsreserve (40) und Informationspolitik (Propaganda 2). Für jedes Jahr gelten harte Invarianten: Sozial-/Wirtschaftsaudit gültig, keine negativen Ressourcen, Replay-Identität der vier zentralen Staatswerte und der kausalen Chronik. Am Ende wird der Gesamtzustand gegen den Datenvertrag geprüft. Die Testausgabe enthält je Strategie Seed, Dauer, Endbestände, Chronik- und Meilensteinzahl.

**Interpretationsgrenze:** Drei Strategien mit verschiedenen Seeds zeigen technische Stabilität und unterschiedliche Ergebnisse, aber noch keine isolierte Kausalaussage über strategische Überlegenheit. Für eine echte Balance-Abnahme braucht es eine gekreuzte Seed×Strategie-Matrix, objektive Erfolgsmetriken, menschliche Spieltests und dokumentierte Feinanpassungen. Der Test misst Laufzeit, setzt jedoch bewusst keine willkürlichen, hardwareabhängigen FPS-Grenzen.

## H1-Abnahme
- Implementiert: automatisierter Langzeit-/Replay-/Audit-/Vertrags- und Laufzeitnachweis in Godot-CI.
- Noch extern zu prüfen: Windows-10/11-Start, manuelle Interaktion und echte Screenshots. CI-Export ist kein Windows-Nutzertest.
- H2: vollständige Release-Gates, Playtestprotokolle und P01–P98-Einzelabnahmen.
