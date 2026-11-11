# Phase 13 / Durchlauf 1 — Kausale Ereignisse

Commit: 46f0eb7bb2761fa85fcdf132f7bb21745bb2d880

## Implementiert (noch nicht integriert)
- `game/scripts/galaxy_event_engine.gd` ist eine isolierte, datengetriebene GDScript-Klasse.
- Drei originale Ereignisdefinitionen mit aus dem Weltzustand abgeleiteten Auslösebedingungen, Gewichtungen und Cooldowns.
- Reine Auswahlfunktion `choose(world, roll)` ohne versteckte Zufallsquelle; der Aufrufer übergibt einen reproduzierbaren Zufallswert.
- `can_apply` prüft finanzierbare Entscheidungen; `apply` verändert Ressourcen, schreibt die Cooldown-Marke und protokolliert die Wahl.
- Die beiden neuen Zustandsfelder `event_last_seen` und `event_journal` werden als Dictionary/Array geschrieben, müssen aber vor einer Integration mit Save-/Load-Verträgen und der bestehenden Ereignisarchitektur abgestimmt werden.

## Noch nicht geleistet
- Kein Anschluss an den zentralen Tick, das vorhandene Ereignissystem oder die UI; kein spielbarer Ereignisdialog.
- Keine Godot-Ausführung, keine CI-Registrierung, keine Render- oder Windows-Prüfung in diesem Durchlauf.
- Kein Anspruch auf P07, P65, P66, P67, P69 oder P70 als abgenommen.
- Für den Folgedurchlauf: vorhandene Ereignis-Skripte/Tests vollständig lokalisieren, Weltfeld-Namen validieren, deterministische RNG-Quelle anschließen, UI-Entscheidungen integrieren, Save/Load und Negativtests in Godot-CI ausführen.
- Die drei Ereignisse sind erste Beispiele, keine vollständigen Geschichtenketten oder galaktischen Krisen.
