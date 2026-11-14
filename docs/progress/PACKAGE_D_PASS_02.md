# Paket D — Durchlauf 2 (2026-11-12)

## Integrationsumfang
Betroffene Pflichten: P25–P39, P44–P49; konkreter Integrationsfortschritt bei P27, P31, P32, P34, P37, P38 und P45. Keine Pauschalabnahme.

- Die bereits von autonomen Privatbetrieben abgeführten `civilian_taxes` werden **einmal jährlich** als Einnahme in den Staatshaushalt übertragen, nicht erneut aus Privatkapital abgezogen.
- Drei Sozialhaushaltsstufen (0/3/6 Credits je aktive Kolonie) finanzieren begrenzte öffentliche Dienstleistungen. Sie verbessern Zufriedenheit ohne die Güterlager zu erhöhen. Die Ausgaben sind auf verfügbare Credits begrenzt und beeinflussen die öffentliche Zustimmung vor der politischen Jahresberechnung.
- Der deterministische `public_budget_ledger` enthält Eröffnungsbestand, Steuertransfer, Ausgaben, Endbestand und Kolonieempfänger; er wird im Spielstand gespeichert.
- `GESELLSCHAFT`, `WIRTSCHAFT` und `POLITIK` zeigen bzw. steuern die neuen Informationen. Neue Originalgrafik `game/assets/art/scene_society.svg`, eingebunden in `galaxy_ui.gd`; Importtest in D2.
- Neuer 40-Jahre-Test kontrolliert fiskalische Bilanz, Ausgabengrenzen, Determinismus, Save/Load und Bildimport.

## Einschränkungen
Dies ist **kein** vollständiges Geldkreislaufmodell: Unternehmens-/Haushaltszahlungen, Staatsschulden, Preisbildung, sektorale Subventionen, differenzierte Bedürfnisse und politische Interessenkonflikte benötigen weiteren Ausbau. Die vorhandene Prognose nutzt die zuletzt festgestellten Steuern als Schätzung; tatsächliche Jahreswerte können abweichen. Die Sozialleistung ist als abstrakte Dienstleistung modelliert, nicht als produziertes Konsumgut. Reale Windows-GUI-Bedienung und Bildreview sind weiterhin offen.

## Verifikation
CI-Ergebnisse nach dem Implementierungscommit nachtragen. Ohne grünen CI-Lauf keine technische Abnahme.
