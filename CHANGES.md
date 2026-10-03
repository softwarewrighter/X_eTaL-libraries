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

- 16:55 `lib` Random (`r:`): `s_huffle!`, `d_eal!`, `c_hoice!`, `s_ample!`, `u_niform!`, `n_ormal!` (Box-Muller), `w_eighted!`; seeded tests and statistical checks on 20000 draws with Check, the dice demo, page.
- 19:00 `chore` Saga step matrix completed.
- 16:35 `lib` Matrix (`mx:`): `t_ranspose`, `i_dentity`, `d_iag`, `t_race`, `m_ul`, `d_et`, `s_olve` and `i_nverse` (Gauss-Jordan with partial pivoting); tests (nine algebraic laws with Check), the line-fit demo (least squares), page; ask X7 (transpose, matrix divide).
- 16:30 `fix` Check: `k:n_ear` also accepts an absolute difference up to 1e-12, so a computed `1e-17` is near an exact 0 (`e_q~` is relative only); found by Matrix's inverse check.
- 16:00 `chore` Saga step lists completed.
- 15:55 `lib` Lists (`q:`): `d_eltas`, `w_indows`, `m_ovingMean`, `r_unValues`, `r_unLengths`, `c_hunks`, `r_aze`, `s_hift`, `i_nterleave`, `b_search` (dfns bsearch); tests (eight properties with Check), the temperatures demo, page.
- 15:33 `chore` Saga step library-dirs completed.
- 15:30 `refactor` Every library is its own directory, `libs/<Name>/` (the user's request): `src/`, reg-rs `tests/` (each program's `.rgt`/`.out`/`.err`, `types.rgt`, `demo-*.rgt`), `docs/README.md`, `demos/`, a README; a demo for each library (grading, word-count, clubs, primes, lottery); `scripts/xt` (every `libs/*/src` on XETAL_PATH, relative); tooling, templates/Library, self-test, recipes (`demo`, `show`, `path`) moved to reg-rs; plan A3-A5 and layout, README, CLAUDE.md. Finishes the move that b0e3960 pushed half-done.
- 14:58 `docs` The X_eTaL logo (the corrected one: "eXperimental Extensible Typed Array Language") at the top of the README, images/xetal-logo.jpg.
- 13:47 `chore` Saga step combinatorics completed.
- 13:45 `lib` Combinatorics (`cb:`): `f_actorial`, `c_hoose` (exact, multiplicative), `c_ombinations` (dfns cmat), `p_ermutations` (dfns pmat), `s_ubsets`, `p_owerset`, `p_roduct`; lists as matrices, a row each, lexicographic; tests (counts and orders checked with Check), pinned types, docs/libs/Combinatorics.md.
- 13:40 `feat` Check: a value longer than 60 characters in a message is shown by its start and its shape (`1 2 3 ... (shape 100)`).
- 13:17 `chore` Saga step numbers completed.
- 13:15 `lib` Numbers (`n:`): `g_cd`, `l_cm`, `i_sqrt`, `p_rimes` (sieve), `p_rime?`, `f_actors`, `d_ivisors`, `b_ase`, `d_igits`, `f_ib`; tests (eight properties checked with Check; the 64-bit limit recorded), pinned types, docs/libs/Numbers.md; ask X6 (big whole numbers).
- 12:57 `chore` Saga step sets completed.
- 12:55 `lib` Sets (`se:`): `u_nion`, `i_ntersect`, `d_ifference`, `s_ymmetric`, `s_ubset?`, `s_ame?`, `d_isjoint?`, `c_ounts`, `m_ode`; any Eq vector, first-seen order; tests (the set laws checked with Check), pinned types, docs/libs/Sets.md.
- 12:35 `plan` Saga foundation archived; saga core started (sets, numbers, combinatorics, lists, matrix, random, release-1); saga 1 retrospective in docs/plan.md.
- 10:52 `chore` Saga step strings completed; saga foundation complete.
- 10:50 `lib` Strings (`t:`): `u_pper`, `l_ower`, `t_rim`, `t_rimStart`, `t_rimEnd`, `w_ords`, `s_queeze`, `j_oin`, `s_plit`, `l_ines`, `f_ind`, `o_ccurrences`, `r_eplace`, `p_refix?`, `s_uffix?`, `i_nfix?`, `p_adLeft`, `p_adRight`, `c_enter`, `r_epeat`; ported from J strings, BQN strings.bqn and dfns; tests (one checked with Check), pinned types, docs/libs/Strings.md; asks X4 (`[]U_CS` not implemented) and X5 (an empty Char vector drawn as numbers).
- 10:27 `chore` Saga step check completed.
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
