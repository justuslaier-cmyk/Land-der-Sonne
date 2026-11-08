# Foundation exit criteria

This is the decision checklist for ending the foundation-only chat and starting the creative/gameplay chat.

| Criterion | Current evidence / limitation |
|---|---|
| Repository governance and AI rules versioned | Done |
| Architectural boundaries and initial data contracts | Done, provisional |
| Engine version pinned and imported in CI | Done, Godot 4.3 |
| Deterministic world and coordinate tests | Done |
| Save roundtrip and corrupted-primary backup recovery | Done in CI; crash-consistency not proven |
| Automated scene and input tests | Done for basic movement |
| Real Godot rendering capture | Done; screenshot quality not reviewed |
| Windows export generated as downloadable artifact | Done; native Windows launch not verified |
| Development branch and PR review path | Done; PR #1 still draft |
| Reproducible handoff to separate gameplay chat | Documented |
| CI branch policy, caching and permissions hardening | In progress |
| Full-scale simulation benchmarks | Deferred to vertical-slice phase |
| Final game art or design | Out of scope |

## Exit rule
The foundation is sufficient for a separate gameplay chat when all three CI jobs pass on the final foundation commit, the handoff and rules are committed, and the PR is merged or the handoff clearly names the unmerged branch. Production-grade crash recovery, visual art and gameplay are deliberately *not* prerequisites for this handoff; they remain separately tracked risks.

## Remaining external validation
A native Windows startup test on a real Windows environment is strongly recommended before calling the build broadly usable. A successful Linux-based cross-export alone is not that test.
