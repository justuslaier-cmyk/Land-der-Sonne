# Paket F – Durchlauf 3: militärische KI und Kriegslogistik

Implementiert: fraktionsbezogene KI-Flottenversorgung mit realen Wartungsausgaben aus der KI-Staatskasse, Versorgungserholung in eigenen Häfen, Verbrauch außerhalb eigener Systeme, Flottenverluste bei vollständigem Versorgungszusammenbruch, zunehmende Kriegsmüdigkeit und Angriffssperre bei kritischer Versorgung bzw. Kriegsmüdigkeit. Der bestehende KI-Entscheidungsbericht dokumentiert Nachschub, Kosten und Kriegsmüdigkeit.

Zusätzlich wurde die E2-Forschungs-Testfixture an die inzwischen eingeführte echte Wissenschaftlerkapazität angepasst, statt die Produktivlogik zu umgehen.

Godot-CI: neuer Test `galaxy_package_f3_test.gd` neben den bisherigen E1–E6- und F1–F2-Regressionen.

Technischer CI-Abnahmestand nach Ausführung nachtragen. Paket F als Ganzes benötigt weiterhin gesonderte P56–P64/P73–P79-Prüfung, insbesondere UI und manuelle visuelle Abnahme.
