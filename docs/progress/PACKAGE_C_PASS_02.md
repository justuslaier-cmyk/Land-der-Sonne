# Paket C / Durchlauf 2 — Integration (2026-11-12)

**Ausgangsbasis:** `design/galactic-grand-strategy-pivot`, `c216b07730b8893d15eaffdedc021262484edad5`. Verbindlich sind P11–P24 und die Entwicklungsregeln.

## Änderungen

- Der Generator skaliert bei Bedarf die deterministisch erzeugten Sternkoordinaten einheitlich, damit sämtliche geografischen MST-Kanten kürzer als 170 Karteneinheiten sind. Die relative Form bleibt bestehen; absolute Distanzen neuer Galaxien ändern sich gegenüber früheren Seeds. Bestehende gespeicherte Galaxien werden nicht migriert.
- Ein unabhängiger Reichweitenprüfer testet tatsächliche Mehrsprung-Erreichbarkeit über die vorhandene direkte Flottenreichweite. Die gezeichneten Lanes sind weiterhin **keine** Hyperraumflugrouten.
- Systemkolonisierung ist nur nach Erkundung, mit bewohnbarer neutraler Welt, 50 Credits und eigener stationierter Flotte erlaubt. Der UI-Knopf wird bei nicht erfüllten Vorbedingungen ausgeblendet und ein Grund angezeigt.
- Der neue `galaxy_package_c2_test.gd` prüft 36 Konfigurationen sowie Erkundung, Flottenflug, Eigentumswechsel, doppelte Befehle, Kosten und JSON-Save/Load in Slot 4. CI-Smoketest ist ergänzt.

## Abnahmegrenzen

Die Änderung schließt **nicht** P11–P24 vollständig ab. Insbesondere fehlen physisches Routing, Kapazitäts-/Risikomodelle, Terraforming, tiefe Religion/Kulturverbreitung, manuelle Bildbewertung und native Windows-10/11-GUI-Tests. Die 36 Seeds sind Stichproben. CI-Nachweise sind nach dem letzten Commit separat einzuholen; vorher kein Testerfolg behaupten.


## Verifizierte Ausführung

- Integrationscommit: [`c91545310ee2c2294cc5936595a2f12b0a5fe24d`](https://github.com/justuslaier-cmyk/Land-der-Sonne/commit/c91545310ee2c2294cc5936595a2f12b0a5fe24d).
- GitHub Actions: [Run 43221450804](https://github.com/justuslaier-cmyk/Land-der-Sonne/actions/runs/43221450804), **completed / success, 17 von 17 Jobs erfolgreich**, einschließlich Render, Regressionen, Windows-Export und Windows-2022-Headless-Runtime.
- Im `godot-smoke`-Log bestätigt: `GALAXY_PACKAGE_C2_PASS`, `GALAXY_GEOGRAPHY_PROPERTY_PASS`, `GALAXY_NAVIGATION_PASS`, `GALAXY_COLONY_SIMULATION_PASS`, `GALAXY_IDENTITY_PASS`, `GALAXY_SAVE_RECOVERY_PASS`.
- **Abgenommen:** dieser begrenzte Paket-C2-Integrationsschnitt und die beschriebenen automatisierten Regressionen.
- **Nicht abgenommen:** vollständiges Paket C, sämtliche P11–P24, echte manuelle Windows-GUI-Navigation, vollständige spielerische Qualitätsprüfung. Erfolg eines Headless-Jobs ist kein Windows-GUI-Playtest.
