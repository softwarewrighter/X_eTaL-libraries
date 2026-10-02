# Changes

Every commit, newest first, grouped by day. Times are Pacific
(UTC-07:00), as committed.

Categories: `feat` new capability, `fix` a bug or wrong behavior,
`refactor` structure without behavior change, `test` tests only,
`build` build and tooling, `lib` a library or a change to one, `docs`
documentation, `plan` saga planning and reordering, `release`
milestone release, `chore` agentrail bookkeeping (step complete, saga
archive), `vendor` a refresh of the vendored X_eTaL.

## 2026-10-02

- 10:25 `lib` Check (`k:`): `i_s`, `n_ear`, `t_rue`, `t_est`, `a_nd`, `c_ount`, `f_ailures`, `p_assed?`, `r_eport`; a check is a line of text, values shown on one line; tests and pinned types; docs/libs/Check.md; ask X3 (assert and errors of one's own). The test runner fails any `FAIL` line unless the program says `# shows failures`.
- 10:05 `docs` The name spelled out correctly: "eXperimental Extensible Typed Array Language" (README, CLAUDE.md, plan).
- 09:52 `chore` Saga step library-layout completed.
- 09:50 `build` Library layout: lib/<Name>.xtl (the XETAL_PATH directory), tests/<Name>/ goldens and expected/types.out pinning each export's type, docs/libs/<Name>.md, templates/; scripts/libs.py (list, table, check: header, import line, tests, page documents every export, no standard-library name), scripts/test-libs.sh (XETAL_BLESS=1), its self-test in the gate, new-lib, run-lib; recipes libs, path, new-lib, run, show, types, test, test-lib, bless; `just eval` sees lib/.
- 09:30 `chore` Saga step vendor-xetal completed.

- 09:25 `docs` Macro library design aligned with research.txt and X_eTaL's MC10: `.xtlm` macros are defined `m:u_nless< := ...` (not `l:`); `u_if<`/`u_each<` are X_eTaL's own standard macro library, not this repo's; the samples here are Control (`x:u_nless<`, `x:w_hen<`) and Test (`test:e_xpect<`) (plan A9, catalog, saga 4; asks X1; README).
- 09:20 `build` Vendoring: `just vendor [REF]` snapshots a committed ref of ../X_eTaL into vendor/xetal/ (VENDORED records it); `just xetal`, `xetal-version`, `eval`, `check-vendor` (the CLI answers, names the vendored commit, runs life.xtl, imports Stats); in the gate.
- 09:18 `vendor` X_eTaL 0caf584 vendored.

- 09:12 `chore` Saga step scaffold completed.

- 09:10 `plan` Scaffold: the agentrail process (saga foundation), CLAUDE.md/AGENTS.md, README, COPYRIGHT, LICENSE, CHANGES.md, justfile, the gate, docs/plan.md (architecture A1-A12, the catalog of 16 libraries, four sagas, the `.xtlm` design), docs/xetal-asks.md (X1 macro libraries, X2 expansion).

- 08:47 `chore` First commit: an empty README.
