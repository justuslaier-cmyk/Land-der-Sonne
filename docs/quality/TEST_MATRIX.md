# Test matrix

| Gate | Evidence | State |
|---|---|---|
| Godot project import | GitHub Actions run 42481720888 | Passed on initial foundation commit |
| Deterministic terrain | Headless smoke test | Passed on initial foundation commit |
| Main scene startup | Headless CI startup | Passed on initial foundation commit |
| Negative coordinate chunk boundaries | world_test.gd | Added, pending CI |
| Versioned world state save/load | world_test.gd | Added, pending CI |
| Save corruption / interruption recovery | Recovery test and backup design | Not implemented |
| Actual input interaction | Automated input replay | Not implemented |
| Visual screenshot regression | Engine render artifacts | Not implemented |
| Windows executable export | CI artifact and launch smoke test | Not implemented |
| High-quality pixel art | Approved rendered art benchmark | Not implemented |
| NPC, economy, combat and quests | Dedicated integration suites | Not implemented |

Tests must not be marked passed until the corresponding workflow completes successfully on the relevant commit.
