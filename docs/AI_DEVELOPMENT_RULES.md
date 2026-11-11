# Binding AI development rules

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
