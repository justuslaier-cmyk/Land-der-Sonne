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
Die D3-Testkonfiguration setzte ursprünglich `settings["events"] = 0`, obwohl `GalaxyModel.validate` ausschließlich 1–100 akzeptiert. Dadurch schlug der Readback beim Speichern fehl; dies war ein **ungültiger Testfixture**, kein nachgewiesener Save-Limit-Defekt. Der Test verwendet jetzt `events = 1`. Der 375-Jahre-Langlauf und Save/Load der Startkonfiguration werden getrennt verifiziert. Save/Load nach 20 bzw. 125 Jahren ist weiterhin nicht eigens abgenommen. **CI erfolgreich:** GitHub Actions Run `43225320080`, Commit `a21a43035d5b8a8a0fdc5b0953b88555c56d889f`, 17/17 Jobs erfolgreich einschließlich Godot-Smoke, Regressionen, Render-Check und Windows-Export/Runtime. https://github.com/justuslaier-cmyk/Land-der-Sonne/actions/runs/43225320080. Der D3-Smoke umfasst drei Seeds × 125 Jahre, deterministische Replays, absichtliche Ledger-Korruption, Audit-Historie und Startspielstand-Roundtrip. **Keine native manuelle Windows-GUI-Abnahme** und keine Pauschalabnahme der P25–P39/P44–P49.
