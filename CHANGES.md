# Changes

Every commit, newest first, grouped by day. Times are Pacific
(UTC-07:00), as committed.

Categories: `feat` new capability, `fix` a bug or wrong behavior,
`refactor` structure without behavior change, `test` tests only,
`build` build and tooling, `lib` a library or a change to one, `docs`
documentation, `plan` saga planning and reordering, `release`
milestone release, `chore` agentrail bookkeeping (step complete, saga
archive), `vendor` a refresh of the vendored X_eTaL.

## 2026-10-03

- 16:10 `lib` Control ready to ship (docs/control.md): `docs/control/Control.xtlm` (`m:i_f<`, `m:u_nless<`, `m:e_ach<`), its macro bodies tested in the gate by `docs/control/check.sh` (expansions and their results, five cases, the lazy branch included), the demo and page drafted, the steps for the day `.xtlm` lands, Test sketched.
- 15:44 `chore` Saga step start-here completed.
- 15:40 `docs` The front door: the README's first screen (Start here: try one now, use one, how it fits the three ways X_eTaL extends, the ecosystem) and a grouped catalog; the live demo's Start here landing (the same, with the libraries as cards in groups), a Start here entry in the side list; groups kept in site/src/lib.rs with a test that every library is in one.
- 14:29 `chore` Saga step promotion-blockers completed.
- 15:00 `test` `scripts/asks.sh` (`just asks`, `just asks-upstream`): every ask's repro run against the vendored xetal or X_eTaL's committed HEAD built from a snapshot; all still open at 23ddfeb. The asks gain a promotion-blocker table: X1/X2 (launch gate), X5/X10 (correctness) P0, the rest after launch.
- 14:04 `chore` Saga step geometry completed.
- 14:40 `lib` Geometry (`ge:`): `d_istances`, `a_rea`, `c_entroid` (shoelace), `r_otate`, `s_cale`, `m_ove`, `h_ull` (gift wrapping by cross-product tables), `s_how!`; tests (invariants with Check), the hull demo (with Random), page. The last ordinary library before the freeze.
- 14:00 `plan` Reprioritized after ../X_eTaL/docs/research4.txt: ordinary libraries frozen after Geometry; saga more gains promotion-blockers, start-here and control-ready before release-3 (a tagged compatible snapshot); ask X10 (bound Bool arithmetic, as the sibling repos filed it).
- 13:45 `chore` Saga step search completed.
- 13:35 `lib` Search (`sr:`): `p_osition`, `m_erge`, `t_opAt`, `t_op`, `k_th`, `r_ank` (ties averaged), `d_enseRank`, `n_earest`, `b_etween`; tests (against sorting, with Check), the exam demo, page.
- 13:34 `chore` Saga step csv completed.
- 13:05 `lib` Csv (`cs:`): `f_ields` (quoted fields by quote parity, a whole line at once), `r_ows`, `c_olumn`, `f_ield`, `n_umbers`, `t_ext` (quoting where needed); tests (round trips with Check), the cities demo (with Statistics and Format), page.
- 12:44 `chore` Saga step grouping completed.
- 12:35 `lib` Grouping (`gr:`): `g_roups`, `b_y` (any function per key, as a quoted operand), `c_ount`, `s_um`, `m_ean`, `l_east`, `g_reatest`; tests (seven with Check), the sales demo (with Format and Plot), page.
- 12:29 `chore` Saga step polynomials completed.
- 12:10 `lib` Polynomials (`py:`): `a_t` (a power table and an inner product), `p_lus`, `t_imes` (an outer product summed by power), `d_erivative`, `i_ntegral`, `r_oots` (Newton from 64 starts at once), `t_ext`; tests (identities at eleven points with Check), the curve demo (fitted with Matrix), page; ask X9 (`d_ecode` on Floats).
- 11:40 `plan` Saga applied archived; saga more (5) started: polynomials, grouping, csv, search, geometry, release-3.
- 11:30 `docs` Plan: the saga 3 retrospective's export counts corrected (48 in saga 3, 128 in all).
- 10:13 `chore` Saga step release-2 completed.
- 11:20 `release` Release 2: fourteen libraries; the live demo reviewed in the browser (every demo runs on the published site); `p:l_ine!` spreads x so a chart is about twice as wide as high (`[]P_ATH` keeps one scale); asks' upstream queue positions updated; README status, saga 3 retrospective, saga 5 candidates in the plan.
- 09:54 `chore` Saga step bits completed.
- 10:40 `lib` Bits (`b:`): `b_its`, `v_alue`, `p_opcount`, `a_nd`, `o_r`, `x_or`, `s_hl`, `s_hr`, `b_it?`, `m_ask`, `g_ray`, `u_ngray`; tests (bitwise laws and all 256 Gray codes, with Check), the Nim demo, page.
- 09:47 `chore` Saga step graphs completed.
- 10:05 `lib` Graphs (`g:`): `a_djacency`, `w_eighted`, `u_ndirected`, `o_utDegree`, `i_nDegree`, `r_each` (Warshall by Boolean products), `s_hortest` (min-plus products), `l_evels` (breadth-first), `c_omponents`; tests (a ring and a chain, with Check), the subway demo, page.
- 09:35 `docs` Asks: macros (Saga 19) are now 4th in X_eTaL's queue, after the terminal (25) and the new course (28).
- 09:20 `build` `just upstream` (scripts/upstream.sh): X_eTaL's active saga and queue, and for each ask whether its feature shows in X_eTaL's HEAD and in the vendored copy; the asks record their upstream saga and queue position; plan saga 4 follows X_eTaL's Saga 19 (starts once its macro engine is vendored).
- 08:56 `chore` Saga step statistics completed.
- 09:05 `lib` Statistics (`sx:`): `q_uantile` (R type 7), `m_edian`, `f_ive`, `z_scores`, `c_ovariance`, `c_orrelation`, `f_it`, `b_ins`, over the standard Stats; tests (known values with Check), the heights demo, page.
- 08:53 `chore` Saga step dates completed.
- 08:35 `lib` Dates (`d:`): `d_ays` and `c_ivil` (Hinnant's algorithms, whole-array), `w_eekday`, `l_eap?`, `d_aysIn`, `i_so`, `c_alendar`, `m_onth`; tests (round trips over 22476 dates with Check), the calendar demo, page; ask X4 names `[]TS`.
- 08:41 `chore` Saga step plot completed.
- 08:00 `lib` Plot (`p:`): `b_ars`, `s_park`, `h_istogram`, `s_catter`, `l_ine!` (a picture); tests (eight checks with Check), the weather demo, page. Strings gains `t:m_ix` (a list of texts as a character matrix). `scripts/xt` writes pictures to work/draw/ (they had landed in tests/); the site's demo test ignores the command line's "drawn" lines.
- 08:27 `chore` Saga step format completed.
- 07:30 `lib` Format (`f:`): `f_ixed`, `t_housands`, `a_mount`, `p_ercent`, `c_olumn`, `t_able` (numbers right-aligned with their header, a rule); tests (read-back checks with Check), the invoice demo, page; ask X8 (formatting with width and precision).
- 06:50 `plan` Saga core archived; saga applied started (format, plot, dates, statistics, graphs, bits, release-2).
- 06:40 `fix` Live demo: X_eTaL is shown in its rendered form everywhere (the user's review): demos, library source, types and the import line drawn decorated with X_eTaL's own renderer (xetal-view) and token colours; the reference pages' session examples, X_eTaL blocks and inline X_eTaL rendered at build time (types, paths, commands stay as typed); Edit opens the ASCII editor beside a live Rendered pane, as X_eTaL's live demo does. A test fails if a page shows typed X_eTaL.

## 2026-10-02

- 06:07 `chore` Saga step live-demo completed.
- 20:30 `feat` The live demo: site/ (Yew on the vendored xetal-play, built with trunk) embeds every library (build.rs: source, rendered reference, demos, pinned types) in an in-memory store, so `u_se<` finds them in the browser; per library: demos editable and runnable (seed, pictures), reference, source, types; addresses `#Library/demo`, back and forward, reference links to demos. Native tests run every demo as recorded; the gate checks the tests, the wasm32 build and that pages/ is current (pages/INPUTS). `just pages`, `serve`, `serve-pages`; .github/workflows/pages.yml publishes pages/.
- 19:38 `chore` Saga step release-1 completed.
- 19:55 `release` Release 1: eight libraries, every page example recorded output (scripts/check-examples.py in the gate; two examples added to tests), README status, saga 2 retrospective, asks reviewed.
- 19:40 `lib` Matrix: `mx:t_ranspose` removed (X_eTaL's built-in `o_\` replaces it, and the name now belongs to the built-in dyadic `t_ranspose`); Combinatorics uses `o_\` too; outputs unchanged. Ask X7 narrowed to matrix divide.
- 19:30 `vendor` X_eTaL 8eb3de2 vendored (transpose and its retrofit); every baseline unchanged.
- 17:20 `plan` Control macro library restored to research.txt's set: `x:i_f<`, `x:u_nless<`, `x:e_ach<` (X_eTaL keeps `u_` for system macros and leaves macro libraries to this repo, its saga 19), with a design sketch; the live demo inserted as saga 2 step 9 (after release-1), absorbing saga 3's reference site; A12 revised.
- 17:05 `docs` Asks: X1 filed (decided upstream as MC10 and MC11, not yet implemented; MC11 loads Name.xtl and Name.xtlm together, which suits each library's src/); X7 transpose landed upstream, taken at the next vendor refresh. Plan A9 cites MC10/MC11.
- 19:06 `chore` Saga step random completed.
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
