# Paket 5 – Durchlauf 1: Reproduzierbare Balancing-Matrix

**Datum:** 2026-11-12 · **Branch:** `design/galactic-grand-strategy-pivot` · **Status:** CI-geprüfte technische Matrix, spielerische Vollabnahme noch offen.

## Scope, Quellen und Anforderungsbezug

Plan `docs/progress/FINAL_GAME_EXECUTION_PLAN.md`, Paket 5.1: gleiche Seeds × mehrere Strategien × Schwierigkeitsgrade; Wirtschaft, KI, Krieg, Expansion, Forschung, Krisen und Zwischenmetriken vergleichen; konkrete Parameterkorrekturen; triviale Dominanz vermeiden. Pflichten P10, P38–P50, P51–P64, P74–P79, P90, P94 und P97 berührt, **keine Pflicht allein hierdurch abgenommen**. Grundlage: tatsächliche Weltzustands- und Aktionsverträge in `galaxy_model.gd`, `galaxy_strategy.gd`, `galaxy_ai.gd` sowie bestehender H1-Langzeittest.

## Befunde und integrierte Korrekturen

1. **Schwierigkeitsgrad war nur gespeichert/validiert**, hatte aber keinen nachweisbaren Einfluss auf die KI-Entscheidungsfrequenz. `GalaxyAI.action_interval()` nutzt nun den bereits vorhandenen Einstellungswert 0/1/2: Expansion alle 9/6/4 Jahre, Flottenrekrutierung alle 5/3/4 Jahre (jeder KI-Spieler individuell phasenverschoben). **Alle Kolonisations-, Forschungs-, Rekrutierungs- und Unterhaltskosten bleiben unverändert.** Das harte Profil wurde nach einem ersten Messlauf von einer überteuerten Rekrutierungsfrequenz 2 auf 4 korrigiert: der zusätzliche Flottenkauf verdrängte die für Expansion erforderliche Liquidität. Die bestehende Normal-Einstellung 1 bleibt in ihrem Verhalten unverändert.
2. **Unterfinanzierter Kolonieunterhalt konnte negative Credits erzeugen.** Die Jahresabrechnung begrenzt die tatsächlich bezahlte Wartung auf die verfügbaren Credits, speichert `treasury_shortfall` und reduziert Stabilität bei ungedeckter Wartung. Keine stillschweigende Geldschöpfung, kein negativer Kontostand, Fehlbetrag im Weltzustand sichtbar und deterministisch; alle fünf Jahre erfolgt eine Chronikmeldung.
3. **Transparenz:** Der bestehende Galaxieassistent erläutert die konkrete Wirkung des Schwierigkeitsgrads und stellt ausdrücklich klar, dass keine Gratisressourcen gewährt werden. Es handelt sich um eine Textkorrektur einer bestehenden Funktion, keine neue sichtbare Spielmechanik.

## Testdesign und gemessene Ergebnisse

`game/tests/galaxy_balance_matrix_test.gd`: 3 Seeds (22071, 45199, 87331) × 3 vorhandene Politikpfade (Industrie/Haushalt, Forschung, Sozialhaushalt) × 3 Schwierigkeitsgrade = **27 Kampagnen mit je 85 Jahresticks** (2295 Simulationstakte), zusätzliche deterministische Wiederholung einer Paarung. 75 Sterne und fünf KI-Reiche je Kampagne. Zwischenstände nach 20, 50 und 85 Jahren. Erfasste Größen: Credits, Forschung, Legierungen, Stabilität, eigene und KI-Systeme, KI-Flottenstärke, KI-Forschungsstände, Kriege, Krisen, Meilensteine, zivile Zustimmung, Szenariolaufzeit. Jährlich: Sozialaudit, keine negativen Ressourcen, finale Weltverträge. Chronikereignisse werden deterministisch mit Option 0 abgearbeitet.

**Ausgeführter Messlauf** [GitHub Actions 43257568496](https://github.com/justuslaier-cmyk/Land-der-Sonne/actions/runs/43257568496), Commit `9f45a8555ce09b9b845b1c493bdcabc15cf4cec8`: `GALAXY_BALANCE_MATRIX_PASS`, 27 Szenarien × 85 Jahre, **9/9 gematchte Seed-/Schwierigkeitsblöcke unterscheiden sich zwischen Strategien**, 1850 ms für die Matrix auf dem CI-Runner (nur die Matrix; kein Hardware-Benchmark). Deterministische Wiederholung bestanden.

Gemittelte Endstände der drei Seeds, pro Strategie:
| Schwierigkeit | Strategie | Credits | Forschung | Legierungen | Stabilität | KI-Systeme |
|---|---|---:|---:|---:|---:|---:|
| Entspannt | Industrie | 1728 | 1029 | 208 | 67 | 10 |
| Entspannt | Forschung | 1388 | 1369 | 208 | 67 | 10 |
| Entspannt | Sozial/Legierungen | 72 | 813 | 463 | 100 | 10 |
| Normal | Industrie | 1728 | 1029 | 208 | 67 | 8 |
| Normal | Forschung | 1388 | 1369 | 208 | 67 | 8 |
| Normal | Sozial/Legierungen | 72 | 813 | 463 | 100 | 8 |
| Herausfordernd | Industrie | 1728 | 1029 | 208 | 67 | 17 |
| Herausfordernd | Forschung | 1388 | 1369 | 208 | 67 | 17 |
| Herausfordernd | Sozial/Legierungen | 72 | 813 | 463 | 100 | 17 |

**Interpretation:** Industrie maximiert Liquidität, Forschung die Forschungspunkte, Sozial-/Legierungspolitik die Stabilität und Legierungen, aber mit deutlich geringerer Liquidität. Keine dieser drei Strategien dominiert die anderen in *allen vier* gemessenen Ressourcendimensionen. Das ist **kein** Beleg für global ausgewogenes Sieg-/Kriegsbalancing. Herausfordernd erhöht KI-Territorium deutlich, aber Entspannt erzielt in dieser Stichprobe mehr KI-Systeme als Normal: **Schwierigkeitsmonotonie ist noch nicht nachgewiesen**. Die unveränderten Spieler-Endstände über die Schwierigkeitsgrade zeigen zudem, dass der Druck auf das Spielerreich innerhalb dieser 85 Jahre noch nicht ausreichend direkt ist.

## Test-/CI-Befehle und Abnahmegrenze

`godot --headless --path game --editor --quit` und `timeout 240s godot --headless --path game --script res://tests/galaxy_balance_matrix_test.gd`, plus gesamte bestehende Godot-Smoke-, Regression-, Render-, Windows-Export- und Windows-Runtime-Pipeline.

**Einschränkungen:** Drei feste, nicht adaptiv optimierte Politikpfade; kein aktives Spielerexpansions-, Kriegsführungs- oder Diplomatie-Mikromanagement im Matrixlauf. Krieg und Krise werden erfasst, aber nicht als ausreichend häufiges Balancing-Szenario belegt. Keine menschlichen vollständigen Partien, keine Nutzerwertung, keine Windows-GUI-Spieltests. P94 und Paket 5.1 werden daher **nicht als vollständig spielerisch abgenommen** geführt; der technische Mess- und Korrekturdurchlauf ist implementiert und regressionsgeprüft. Weitere Balancing-Arbeit darf nicht als bereits erledigt ausgegeben werden.
