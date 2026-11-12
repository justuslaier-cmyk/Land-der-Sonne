# Binding AI development rules

## Zwingendes Preflight-Gate vor JEDEM Entwicklungsbefehl (Nutzeranweisung 12.11.2026)

**Nicht nur einmal pro Sitzung:** Vor **jedem einzelnen** GitHub-Schreibbefehl, Tool-Aufruf mit Entwicklungswirkung, Commit, Testauftrag und jeder Entwicklungsabgabe die aktuelle Fassung von `docs/AI_DEVELOPMENT_RULES.md` **und** `docs/progress/FINAL_GAME_EXECUTION_PLAN.md` erneut lesen und auf den beabsichtigten Befehl anwenden. Ohne diesen Preflight den Befehl nicht ausführen. Auch bei Wiederholung, Eile und Chatwechseln keine Ausnahme.

**Ausführungs-Gate:** (1) Gehört die Aktion zum derzeitigen, unveränderten Paketdurchlauf? (2) Ist sie Teil einer vollständigen gebündelten Implementierung statt einer isolierten Mikroabgabe? (3) Werden Spielmechanik, Integration, Tests und Abnahme gemeinsam vorangetrieben? (4) Sind offene Prüfungen ehrlich dokumentiert, ohne Fortschritt an anderen Paketen zu blockieren? (5) Ist der Branch korrekt? Wenn eine Antwort nein ist: zuerst Arbeitsweise korrigieren.

**Stoppsignal vor Nutzerantwort:** Keine Entwicklungsabgabe, die nur einen einzelnen neuen Test, Commit oder die Ankündigung weiterer Arbeit enthält. Nur zusammenhängendes Durchlaufergebnis oder eine explizit angeforderte Statusauskunft. Eine technisch erzwungene Unterbrechung niemals als fertigen Durchlauf darstellen.

## Verbindliche Arbeitsdisziplin: ein Durchlauf ist eine vollständige Arbeitseinheit

**Ausdrückliche Nutzerkorrektur vom 12.11.2026. Diese Regel hat Vorrang vor der bisherigen Gewohnheit, nach jedem Commit einen Zwischenbericht abzugeben.** Für Land der Sonne gilt der genehmigte Plan `docs/progress/FINAL_GAME_EXECUTION_PLAN.md` mit **sechs Paketen und zwölf Durchläufen**.

1. **Keine Mikrodurchläufe:** Ein Durchlauf ist der gesamte im Plan benannte Umfang, nicht ein einzelner Test, Commit, Bugfix oder Teilaspekt. Unteraufgaben dürfen intern existieren, aber werden nicht als Nutzerabgabe ausgegeben oder als weitere Durchläufe gezählt.
2. **Zusammenhängende Umsetzung:** Innerhalb eines Durchlaufs Bestandsaufnahme, fachliche Implementierung/Integration, Fehlerkorrektur, Tests, CI-Überprüfung und Dokumentation soweit technisch möglich erledigen. Tests allein ersetzen keine erforderlichen Spielmechanik-Verbesserungen.
3. **Keine Zwischenabgaben als Endergebnis:** Nicht nach jeder kleinen Codeänderung anhalten und auf \"weiter\" warten. Erst bei einem tatsächlich konsolidierten Durchlauf-Ergebnis berichten. Bei technisch begrenzter Ausführungszeit den Rest als offenen Arbeitsstand dokumentieren, ohne ihn als erledigten Durchlauf auszugeben.
4. **Keine endlose Blockade durch nicht verfügbare Abnahmen:** Nicht selbst durchführbare manuelle Windows- oder visuelle Abnahmen **einmal** konkret als offen dokumentieren; anschließend unabhängige geplante Pakete bearbeiten, statt denselben Vorbehalt in jeder Antwort zu wiederholen. Eine fehlende Abnahme bleibt ehrlich offen.
5. **Prüfstatus präzise:** `CI ausstehend` ist keine Abnahme. Bei fehlerhafter CI zuerst Fehler beheben; bei laufender CI die Prüfung später nachholen, ohne eine zusätzliche Durchlaufnummer zu erzeugen.
6. **Keine widersprüchlichen Versprechen:** Ein bloßes Bekenntnis zu zwölf Durchläufen genügt nicht. Das Verhalten muss der gebündelten Abarbeitung entsprechen. Vor einer Nutzerantwort prüfen: \"Liefere ich ein zusammenhängendes Paketresultat oder bloß einen einzelnen Arbeitsschritt?\" Im zweiten Fall möglichst weiterarbeiten.
7. **Planstabilität:** Die genehmigten zwölf Durchläufe nicht stillschweigend umnummerieren, ausweiten oder durch neue Forschungsphasen ersetzen. Abweichungen nur mit ausdrücklicher Nutzerzustimmung.

Diese Regeln sind eine dauerhafte Repository-Vorgabe für künftige Entwicklungs-Chats und werden bei jedem Arbeitsbeginn zusammen mit dem Ausführungsplan gelesen.


## Binding independent completion checklist

The user-approved mandatory acceptance register is [BINDING_GAME_REQUIREMENTS_CHECKLIST.md](vision/BINDING_GAME_REQUIREMENTS_CHECKLIST.md). Read it at the start of each game-development session alongside the vision and status documents. Its 98 independently tracked requirements are **mandatory** and may not be silently removed, reclassified or checked off based on implementation claims alone. Mark `[x]` only after integrated implementation and documented successful acceptance evidence (commit, executed tests, observed outcome, visual/native evidence where applicable); uncheck regressions. Cite affected requirement IDs in progress reports. The tentative 36-pass framework is not a promise or verified completion estimate.

## Source of truth
Read this document, GAME_VISION.md, PROJECT_STATUS.md and applicable architecture/quality files at the start of every development session. The repository, not chat memory, is the authoritative project record. Preserve user-approved decisions; record proposed changes in decision records.

## Evidence and honesty
Never label a feature finished without defined acceptance criteria and executed tests. Distinguish proposed, implemented, statically checked, engine-run, visually verified, build-tested and released. Report exact commands, outcomes, failures and relevant commit identifiers. No fabricated screenshots, benchmarks or test results.

## Workflow
Inspect existing code and dependencies -> research as necessary -> define acceptance tests -> implement a cohesive vertical slice -> run relevant checks -> review visual output in the real engine -> document changes and open risks. Prefer working integrations over large unverified code dumps.

## Binding art-with-feature rule (approved 2026-11-11)
Every newly implemented gameplay function that has a visible representation **must ship with its own original, style-consistent graphic in the same change**. Do not defer visual assets to a later phase or reuse generic placeholders as final art. Use the approved detailed science-fiction pixel-art language: deep navy, petrol, cyan/teal, violet/magenta and warm amber; readable silhouettes, pixel-grid discipline, lighting, material depth and coherent UI borders. Source files must be committed in `game/assets/art/`, referenced from the actual Godot screen or interactive element, and covered by a resource/import regression test. For features without a meaningful graphic, explicitly document the rationale. Verify copyright ownership; user-supplied stock/watermarked images are style references, never direct imports. No feature is considered visually complete without an actual Godot-rendered screenshot and review.

For each feature PR/commit report: function → asset path → integration point → import test → real render verification status. Do not claim that adding a decorative banner completes sprite, animation, icon or HUD work.

## Quality gates
No silent disabling of tests, hiding of warnings, placeholder features presented as finished, broken asset references or regressions in core gameplay. A passing headless test does not prove graphics. A screenshot does not prove interaction. Visual quality requires real rendered scenes and review against approved references.

## Repository safety
Use feature branches and pull requests after initialization. Do not force-push, rewrite history, delete critical files, or change repository visibility without explicit permission. Audit references and unique value before removing files. Avoid committing generated caches, giant binaries or transient build artifacts. Do not modify Grenzmark.

## Research and rights
Record dated sources, licensing, tradeoffs, evidence and open questions. Analyze external games for principles; never copy protected code, art, story, characters, music or proprietary assets without suitable rights. Verify licenses before importing dependencies or artwork.

## Autonomy limits
Use available tools to implement and test, but do not pretend continuous unattended work, permissions, compute, budgets or visual judgment exist when they do not. Ask before expenses, irreversible operations, or fundamental art-direction changes.

## Scope discipline
The full vision is intentionally huge. Build proof-of-concept vertical slices and measure performance before mass content generation. Prioritize simulation correctness, art consistency, reproducibility and player experience over inflated counts.
