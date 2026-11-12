# Paket D — Durchlauf 3 (2026-11-12)

## Umsetzung und Defektkorrektur
- Korrigiert die zivile Güterprüfung: eingetroffene und an Absender zurückgegebene Frachten sind echte Lagerzugänge; die alte Bilanz ignorierte diese Zugänge und konnte legitime Lieferungen fälschlich als Fehler werten.
- `GalaxyCivilians.settle_freight` erfasst `civilian_freight_returned` und schreibt `returned` in das Jahresledger. Der Auditor prüft nun Lager- und Transitbilanz samt Rücksendungen.
- Öffentlicher Haushalt wird **vor** dem jährlichen Audit gebucht; dieser validiert nun Steuertransfer, Empfängeraufteilung, Ausgabegrenze und Credits-Erhaltung.
- Gesellschaftsbericht zeigt Auditstatus, archivierte Jahre und konkrete Beanstandungen. Keine neue sichtbare Gameplay-Funktion oder neue Bildfläche: Die vorhandene Originalillustration `scene_society.svg` wird weiterverwendet.
- 3 Seeds × 125 Jahre mit Tick-Fortschritt, deterministischem Replay, Audit-Historiengrenze, absichtlicher Fälschung von Fracht-/Haushaltskonten sowie separatem Save/Load der Startkonfiguration. CI-Smoketest aufgenommen.

## Nicht pauschal erfüllt
Die P25–P39 und P44–P49 bleiben einzeln abzunehmen. Vollständige Marktpreisbildung, Haushalt-/Unternehmenssektoren, Schulden, differenzierte Bedürfnisse, Föderalismus, Revolutionen und komplexe politische Vertretung sind durch diesen Pass **nicht** implementiert. Ein grüner CI-Lauf ist technische Regressionsevidenz, kein Nachweis dieser Features. Native Windows-GUI-Interaktion und echte Bildreview bleiben separat offen.

## CI und bekannte Einschränkung
D3-CI scheiterte beim Speichern eines 125-Jahre-Spielstands und erneut bereits bei Jahr 20. Der Grund ist noch **nicht eindeutig diagnostiziert**; ein bestehendes 4-MiB-Limit ist ein möglicher Auslöser, aber ohne Größenmessung kein bestätigter Befund. Der D3-Test isoliert deshalb die 375-Jahre-Simulationsinvarianten vom Save/Load der Startkonfiguration. **Save/Load nach 20 und 125 Jahren ist nicht abgenommen und bleibt ein offener, priorisierter Defekt.** CI-Status des korrigierten Commits prüfen.
