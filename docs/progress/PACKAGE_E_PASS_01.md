# Paket E — Durchlauf 1 (2026-11-12)

## Pflichten und konkreter Umfang
P40–P43, P50–P55. Dies ist ein erster daten- und regelbasierter Integrationsschnitt, **keine vollständige Abnahme**.

- Vorhandene zivile Handelsrouten, physische Lager und zeitversetzte Frachten bleiben das zugrundeliegende Gameplay.
- Die Jahresprüfung validiert nun jedes Frachtdispatch-Manifest gegen die aggregierte Versandmenge; Frachtdauer muss den geografischen Hops entsprechen und Transportkosten = Hops × Warenmenge. Ankunftsmanifest und aggregierte Ankunft werden abgeglichen.
- 75 Jahre deterministische Fracht-/Markt-Replays, absichtliche Manipulation der Versand- und Ankunftsmenge, Beschäftigungs-/Kapazitätsgrenzen und bestehende Forschungsfeldregeln werden im neuen E1-Godot-Test kontrolliert.
- Kein neues sichtbares Feature: ausschließlich Prüf- und Bilanzlogik der bereits vorhandenen Fracht-/Forschungsmechanik; deshalb keine neue Grafik. Bestehende Originalgrafiken bleiben unverändert.
- CI-Workflow um E1-Smoke erweitert.

## Offene Anforderungen für E2 / spätere Abnahme
P41: Piraterie, echte Lieferunterbrechungen und Sicherheit; P42: Zoll- und Embargoverträge sowie internationale Marktpreise; P43: wirtschaftliche KI-Steuerung; P50: Nachrichtenlaufzeiten/Propaganda; P52: Bildungs-/Wissenschaftlerressourcen; P55: Technologietransfer und Rückstand. Die vorhandenen Forschungszweige und Handelsverträge sind nicht als vollwertige Erfüllung dieser Pflichten zu werten.

## Nachweis
CI-Lauf und Commit nach erfolgreicher Prüfung ergänzen.
