# X_eTaL-libraries -- Implementation Plan

Libraries written in X_eTaL (the eXperimental Extensible Typed Array
Language, developed in `../X_eTaL`): ordinary `.xtl` libraries that
any program imports with `u_se<`, and, once X_eTaL supports them,
`.xtlm` macro libraries that extend the language itself. The source
of the ideas is `docs/research.txt` (archival, not normative); this
plan turns it, and the user's later additions, into sagas and steps.

Development is driven by agentrail sagas (one active saga in
`.agentrail/`, finished sagas archived to `.agentrail-archive/`), as in
`../X_eTaL`, `../X_eTaL-demos` and `../X_eTaL-games`. Every step ends
with the gate (`just gate`), docs updated (`README.md`, `CHANGES.md`,
this plan, `docs/xetal-asks.md`, the library's page), a sane
`.gitignore`, a detailed commit to `main` (with the `.agentrail/`
changes), `agentrail complete`, and a push.

## Guiding principle

X_eTaL's "Extensible" has two axes (research.txt):

| Axis | Mechanism | Lives in |
| ---- | --------- | -------- |
| what programs can **do** | libraries of functions (`.xtl`), later native code behind them (`[]S_VO`, C ABI) | this repo (`.xtl`); native wrappers in `../X_eTaL-extensions` |
| what programs can **say** | macro libraries (`.xtlm`): functions `(String, String) -> String` run before parsing | this repo, once X_eTaL has `.xtlm` |

This repo's job is to show the first axis working well today and to
be ready with the second the day X_eTaL supports it. A library
earns its place when it is something everyday programs need and the
language does not have as a built-in (text, sets, number theory,
combinatorics, matrices, randomness, formatting, dates), or when it
shows an array idea worth teaching. Each library is small, typed,
tested, and documented with its provenance.

## Architecture decisions

| # | Decision | Why |
| - | -------- | --- |
| A1 | X_eTaL is **pinned, not copied** (revised 2026-10-05, after `../X_eTaL/docs/vendoring.md`): `XETAL_COMMIT` holds the known-good commit (a full SHA); `just xetal` clones X_eTaL into `work/xetal/` (gitignored), checks that commit out and builds it; `just bump [REF]` moves the pin to a committed ref of `../X_eTaL`. Until 2026-10-05 a source snapshot was tracked in `vendor/xetal/` (646 files, binaries among them). | X_eTaL moves fast; libraries need a recent but stable interpreter, refreshed deliberately, never mid-step. |
| A2 | The CLI builds into the clone's `target/`, reached through the symlink `bin/xetal` (gitignored); every recipe runs that binary, not one on the PATH. | Goldens and pinned types are tied to `XETAL_COMMIT`. |
| A3 | **Every library is its own directory**, `libs/<Name>/` (the user's decision, saga 2): `src/` holds `<Name>.xtl` and/or `<Name>.xtlm` and nothing else, `tests/` its reg-rs baselines, `docs/` its reference page, `demos/` programs that use it, and a short `README.md`. A user puts each `libs/<Name>/src` on `XETAL_PATH` (`just path` prints them, colon-joined), or copies one `src/<Name>.xtl` into their own `userlibs/`; libraries that import each other find one another through `XETAL_PATH`. | One place per library for its code, tests, docs and demos; a library can be lifted out whole. |
| A4 | **Tests are reg-rs baselines** in `libs/<Name>/tests/` (that directory is the library's `REG_RS_DATA_DIR`, as X_eTaL keeps its in `reg/`): each test program `NAME.xtl` has `NAME.rgt` (the command) with `NAME.out` and `NAME.err`; `types.rgt` pins `xetal type ../src/<Name>.xtl`, so an interface change fails; `demo-D.rgt` runs `demos/D.xtl`. Commands run `scripts/xt` (the known-good xetal, every `libs/*/src` on `XETAL_PATH` as paths relative to the test directory, `--seed 1 --ascii`), so baselines do not depend on the checkout. A missing or stale baseline fails, and so does a `FAIL` line from Check unless the program says `# shows failures`. `XETAL_BLESS=1` (`just bless Name`) creates and rebases (review the diff); `.tdb*` caches are ignored. | Same tool and habits as X_eTaL's own goldens; pinned types catch an interface change, as X_eTaL pins the birds' types (CB1). |
| A5 | **Docs and demos per library**: `libs/<Name>/docs/README.md` (what it is for, the import line and recommended alias, every export with its type and an example taken from the tests, the demos, limits, the provenance of each function) and `libs/<Name>/demos/*.xtl` (short narrative programs that use the library for something recognizable; at least one each, run by the tests). The README's catalog links to each library. | Users read the page and the demos, not the source; examples come from tested programs so they cannot drift. |
| A6 | **Library conventions** follow X_eTaL's style guide (lang-choices section 16): file `UpperCamel.xtl`; exports under `l:`, private helpers under `h:` (bare top-level functions are deprecated since X_eTaL PN2); function-first operand order (`'f_ x_y_z data`); counts, indices and keys on the left; predicates end `?`, effects `!`; no top-level expressions (MC8 row 16); doc comments (`##`, X_eTaL S9, added 2026-10-07): the file's header (every doc line `##`, a blank line before the first code line -- without it X_eTaL attaches the header to whatever follows instead of to the file) and a short `##` comment directly above every export and private definition, so `xetal doc` (the cross-reference, `/doc/`) shows more than a signature. No export shadows a built-in. A library name never shadows a standard one (`Stats`, `Maybe`, `Combinators`, `TTTML`, `Turtle`): an extension of one imports it. | Consistent with the language and the standard libraries, so the libraries teach the style. |
| A7 | **Ported, not copied.** A function ported from another array language's library (Dyalog's dfns workspace, J's addons, BQN's bqn-libs, APL2 workspaces, X_eTaL's own demos) is reimplemented from its documented behavior and cited in the source and on the page ("after dfns `ss`"). No code is copied from sources whose licenses differ. | Credit and lineage without license entanglement. |
| A8 | A missing X_eTaL feature or a bug a library uncovers is **not** fixed here nor hidden: it goes in `docs/xetal-asks.md` (status, kind, libraries, why, minimal repro, workaround) and on the library's page. A library that cannot be built waits in the deferred saga. | X_eTaL owns its language decisions; this repo is a consumer. |
| A9 | **Macro libraries (`.xtlm`) wait for X_eTaL.** The design they target is research.txt's, as X_eTaL decided it (MC10 and MC11, 2026-10-02, not yet implemented): a `.xtlm` file defines macros under `m:` with the macro suffix, `m:u_nless< := { cond body -> ... }`, each a function `(String, String) -> String` (the left and right source text written at the call in, X_eTaL source out); a macro library is compiled before the file that imports it (a file never uses a macro it defines), imported with `u_se<` under an alias like any library (a `Name.xtl` and `Name.xtlm` in one directory load together under that alias, MC11, so a library's `src/` may hold both) and invoked as `"left" x:u_nless< "right"`; expansion is recursive but bounded (about 32 levels) and visible (`xetal expand`). X_eTaL's own system macros need no library (`u_se<`; and since 5dccb9b `i_f<`, `u_nless<`, `e_ach<`, MC14-MC17, research.txt's built-in macros); this repo's macro libraries add what users would write themselves: Control (`x:c_ase<`, `x:w_hen<`, `x:l_et<`) and Test. Expansions are type-checked with the program at compile time. Until X_eTaL has `.xtlm` (ask X1), they are designed here on paper only (saga 4), never emulated. | Follows research.txt and the X_eTaL decision; avoids building on a guess. |
| A10 | **Native code is out of scope here.** Libraries that wrap C-ABI or Rust code (`[]S_VO`, `u_native<`) belong in `../X_eTaL-extensions`; a library here may later re-export one. | Keeps this repo pure X_eTaL, runnable anywhere xetal runs (including the browser). |
| A11 | **Names, not homes.** A library is identified by its name (`Strings`), never by a GitHub coordinate; docs say "put `lib/` on `XETAL_PATH`", not a URL. | The repos may move to an organization (`sw-array-languages`, research.txt); nothing here should need rewriting when they do. |
| A12 | `just` is the entry point (recipes call `scripts/*.sh`); `CHANGES.md` gets a line for every commit, as in `../X_eTaL`; docs are ASCII-only markdown (`sw-markdown-checker`). Web pages come with the live demo (saga 2 step 9): built locally into `pages/`, never tracked (revised 2026-10-05, as X_eTaL-games did): `just publish` makes them the only commit of the `gh-pages` branch, which GitHub Pages serves. Beside the live demo, at `/doc/`, a cross-reference site (added 2026-10-07, as `../X_eTaL`'s own live demo does): `scripts/doc-site.sh` runs `xetal doc --out pages/doc` over every library, macro library and demo; `scripts/build-pages.sh` builds it as a normal part of `pages/`. | Same process as the sibling repos. |

## Layout

```
libs/<Name>/             one directory per library
  README.md              what it is, the import line, its directories
  src/<Name>.xtl         the library (and/or <Name>.xtlm, macros)
  tests/                 reg-rs: NAME.xtl programs with NAME.rgt,
                         NAME.out, NAME.err; types.rgt; demo-D.rgt
  docs/README.md         the reference page
  demos/*.xtl            programs that use it
templates/Library/       what just new-lib copies
scripts/                 the logic behind the just recipes (xt runs
                         the known-good xetal with every library on
                         XETAL_PATH)
XETAL_COMMIT             the known-good X_eTaL commit (tracked)
work/xetal/, bin/xetal   its clone and binary (gitignored, just xetal)
```

## The catalog

Ranked by usefulness to everyday programs, then by what they teach.
Aliases are recommendations: the alias is the importer's choice.

| Library | Alias | What | Ported from | Saga |
| ------- | ----- | ---- | ----------- | ---- |
| Check | `k:` | assertions that report as text (ok / FAIL, expected and got), a summary; tests and teaching | J's `assert`, BQN's `!`, xUnit habits | 1 |
| Strings | `t:` | case, trim, words, split and join, starts/ends/contains, find, replace, pad, repeat | J strings addon, BQN `strings.bqn`, dfns `ss`, `words`, `dlb`/`dtb` | 1 |
| Sets | `se:` | union, intersection, difference, symmetric difference, subset and equality as sets, counts of each item | APL idioms, dfns | 2 |
| Numbers | `n:` | gcd, lcm, primes (sieve), prime?, factors, divisors, digits, integer square root, Fibonacci | dfns `gcd`, `sieve`, `factors`, `pco` ideas | 2 |
| Combinatorics | `cb:` | factorial, binomial, combinations (dfns `cmat`), permutations (`pmat`), subsets by `e_ncode`, Cartesian product | dfns `cmat`, `pmat`, APL2 idioms | 2 |
| Lists | `q:` | differences, moving windows and averages, run-length encoding, counts, interleave, binary search, rotate-to, chunks | dfns `bsearch`, APL idioms, X_eTaL classics | 2 |
| Matrix | `mx:` | transpose (until the built-in lands), identity, diagonal, trace, matrix product, determinant, inverse and solve (Gauss-Jordan) | APL2 `domino` behavior, dfns | 2 |
| Random | `r:` | shuffle, deal (k of n without repeats), choice, uniform and normal floats | APL `?` deal, BQN `random.bqn` | 2 |
| Format | `f:` | fixed decimals, padded columns, a text table from a matrix, thousands separators | APL dyadic format behavior | 3 |
| Plot | `p:` | text charts: horizontal bars, sparkline, histogram, scatter on a character grid | APL PLOT workspace ideas | 3 |
| Dates | `d:` | days from civil and back, day of week, leap years, a month calendar as a matrix | Hinnant's civil algorithms, APL `cal` | 3 |
| Statistics | `sx:` | median, mode, quantiles, z-scores, covariance, correlation, linear fit, histogram counts; imports the standard `Stats` | J stats addon | 3 |
| Graphs | `g:` | adjacency matrices: degrees, reachability (Warshall), shortest paths (min-plus product), BFS levels, components | X_eTaL classics (graphs by inner product) | 3 |
| Bits | `b:` | to and from binary, popcount, xor, shifts and masks by `e_ncode`/`d_ecode` | APL idioms | 3 |
| Dates, Polynomials, Graphs (`.xtlm` beside each) | `d:`, `py:`, `g:` | `d:d_ate<` (date literals checked at compile time), `py:p_oly<` (maths notation compiled), `g:g_raph<` (a graph's node names defined): domain macros where a function cannot do the job (docs/macros.md) | research.txt; the user's rule (saga 7) | built; ship with X1 |
| Test (`.xtlm`) | `test:` | `test:e_xpect<` and test blocks expanding to Check calls, so a test reads as the code it checks (research.txt's `test:...<`) | research.txt | 4 (blocked) |

Alias note: an alias is per file and the importer's choice (MC6).
The recommended ones are distinct from each other and from the
letters the X_eTaL docs use for the standard libraries (`c:`
Combinators, `m:` Maybe, `s:` Stats), so any set of them can be
imported together as written on the pages. An alias may be several
letters (`se:`).

## Saga 1 -- foundation (done, archived)

| # | Step slug | Delivers |
| - | --------- | -------- |
| 1 | scaffold | the agentrail saga; CLAUDE.md (AGENTS.md a symlink); README; COPYRIGHT; LICENSE; CHANGES.md; .gitignore; justfile; the gate (markdown); this plan; docs/xetal-asks.md |
| 2 | vendor-xetal | `just vendor [REF]`, `vendor/xetal/VENDORED`, `just xetal`, `xetal-version`, `eval`; `scripts/check-vendor.sh` in the gate; the snapshot in its own commit |
| 3 | library-layout | a flat `lib/` with `tests/<Name>/` goldens and pinned types, `docs/libs/` pages, tooling (replaced in saga 2 by one directory per library, A3) |
| 4 | check | the Check library; its tests and page; the assert ask |
| 5 | strings | the Strings library; its tests and page; asks it uncovers |

## Saga 2 -- core libraries (done, archived)

| # | Step slug | Delivers |
| - | --------- | -------- |
| 1 | sets | Sets |
| 2 | numbers | Numbers |
| 3 | combinatorics | Combinatorics |
| 4 | library-dirs | inserted at the user's request: every library its own directory (`src/`, reg-rs `tests/`, `docs/`, `demos/`, README), a demo for each, `scripts/xt`, the tooling moved to reg-rs (A3-A5) |
| 5 | lists | Lists |
| 6 | matrix | Matrix |
| 7 | random | Random |
| 8 | release-1 | catalog and pages reviewed, examples re-run, asks reviewed, the vendored X_eTaL refreshed (transpose), retrospective in this plan |
| 9 | live-demo | a Rust/WASM live demo on the vendored `xetal-play`, as in X_eTaL-demos: a page per library (its reference, its demos runnable and editable in the browser, its types), every library embedded; built locally into `pages/`, published by GitHub Pages (A12 revised) |

## Saga 3 -- applied libraries (done, archived)

| # | Step slug | Delivers |
| - | --------- | -------- |
| 1 | format | Format |
| 2 | plot | Plot |
| 3 | dates | Dates |
| 4 | statistics | Statistics |
| 5 | graphs | Graphs |
| 6 | bits | Bits |
| 7 | reference-site | folded into the live demo (saga 2 step 9) |
| 8 | release-2 | catalog, docs, retrospective |

## Reprioritized (2026-10-03, research4)

`../X_eTaL/docs/research4.txt` reviewed the whole ecosystem for a
wider launch: the remaining work is "stabilize, synchronize, explain,
give people one obvious path", not more features. For this repo:

- **Freeze ordinary library expansion.** Seventeen libraries are
  enough; Geometry (planned, cheap) is the last. No new `.xtl`
  library until `.xtlm` exists, except one a launch blocker needs.
- **Control.xtlm is the next library that matters**: it proves the
  "Extensible" in the name. Make it ready to ship the day X_eTaL's
  macro engine lands (control-ready).
- **Promotion blockers first**: the small correctness bugs outside
  programmers notice (empty Char display, bound Bool arithmetic, ...)
  marked P0 in the asks, workarounds named (promotion-blockers).
- **A front door**: the README and the live demo say in 30 seconds
  what this is, how to use a library now, and how it fits the three
  ways X_eTaL extends (start-here).
- **Release 3 is a known-compatible snapshot**: the asks audited
  against upstream, the vendored X_eTaL recorded, a version tag for
  the six-repo snapshot (with the user's approval).
- Upstream order research4 recommends (X_eTaL's decision, recorded
  here because three repos wait on macros): HOF speed regression,
  the terminal, a minimal Start Here, `.xtlm` macros, then the
  broader course.

## Sibling requests (2026-10-07)

X_eTaL-ML draws its training curves with Plot (its plan A14, step
plot-curves) and asked for four things in `p:l_ine!`; done here, with
no saga (a library extension, not a new library):

- axes and labels: `p:l_ine!` draws axes with three ticks on the
  vertical axis and the first and last positions; `labels p:c_hart!
  series` adds a title and the axes' names;
- several lines in one chart: `names p:l_ines! series` (boxed vectors,
  each its own length, in six colors in turn, with a legend);
- no minimum range of 1 on the vertical axis: it spans the values,
  and a flat series gets a range around its value;
- a single point is drawn as a point.

At the same time XETAL_COMMIT moved to X_eTaL main (the user's choice)
and every library's private helpers were written `h:` (X_eTaL PN2,
`xetal migrate`).

## Saga 5 -- more libraries (done, archived; release 0.3.0)

Chosen by the user after release 2: libraries that work with today's
X_eTaL, built while saga 4 waits, then release 3:

Done: Polynomials, Grouping, Csv, Search. Then, reprioritized:
Geometry (the last ordinary library), promotion-blockers,
start-here, control-ready, release-3 (a tagged compatible snapshot).

| Library | What |
| ------- | ---- |
| Polynomials | evaluation (Horner by `d_ecode`), sums, products, derivatives, roots by Newton |
| Grouping | key-style grouping: counts, sums and means per key (APL's key, until X_eTaL has it) |
| Csv | splitting lines into fields, columns to numbers, a table back to text |
| Search | sorted search, merge, top-k, ranking |
| Geometry | points, distances, polygons' areas and centroids, rotations as matrices |

## Saga 11 -- xetal-0.1.0 (done, archived; release 0.5.0)

Build against X_eTaL v0.1.0 (512b3ee), the tag the sibling repos pin
to, and retire the workarounds for the asks it landed.

| # | Slug | What |
| - | ---- | ---- |
| 1 | bump-0.1.0 | XETAL_COMMIT 512b3ee; Check's expansions rebased (hygienic macros rename lambda parameters); Bits' and/or/xor by Int arithmetic to stay Int; asks re-audited: X4 and X9 landed (done) |
| 2 | retire-workarounds | Strings' case by `[]U_CS`/`[]U_CHAR`; Polynomials' evaluation by `d_ecode`; asks X16 (`[]U_CHAR` beyond ASCII) and X17 (a comparison's open numeric type) filed (done) |
| 3 | today | (inserted, the user's request) Dates' `t_oday @` from `[]TS` (done) |
| 4 | release | tag v0.5.0 of this repo (the user approved), built against X_eTaL v0.1.0 (done) |

## Saga 10 -- system-macros (done, archived)

X_eTaL's system macros where they solve a real problem, and the repo
made light before tags are synced across the X_eTaL repositories.

| # | Slug | What |
| - | ---- | ---- |
| 1 | include-data | Csv's demo data read from `cities.csv` by `i_nclude<` (done) |
| 2 | panic-messages | misuse in eleven libraries stops with a `p_anic<` message; a test per message (done) |
| 3 | untrack-pages | (inserted) `pages/` no longer tracked: the gate builds it, `just publish` makes it the `gh-pages` branch, which GitHub Pages now serves; follows the switch from `vendor/xetal` to `XETAL_COMMIT` (done) |
| 4 | purge-history | (inserted) `pages/` and `vendor/` purged from every past commit, force-pushed with the tags moved (the user's authorization, before launch; `docs/history-rewrite.md`) (done) |
| 5 | format-text | Format's invoice (the tax line) and Random's dice (each row) use `f_ormat<` for text of several pieces; docs/macros.md lists the system macros used and why the others are not (done) |

## Saga 9 -- more-macros (done, archived)

Three more domain macros by the rule: Bits `b:f_ields<` (named bit
fields), Csv `cs:c_olumns<` (typed named columns), Check `k:c_ases<`
(table-driven checks named by their source); each with a demo of its
purpose and tests of its compile-time errors. X_eTaL 4abe761 vendored
(its system macros; X3 in part, X11).

## Saga 8 -- macros-ship (done, archived)

X_eTaL main ran macro libraries (6239aad): vendored; the domain macros
rewritten with `@`, `[]R_EJECT` and path imports; their programs moved
into the ordinary tests and demos (expansions pinned); the live demo
serves each library's `.xtlm`, runs the macro demos, highlights their
expansions.

## Saga 7 -- macro-purpose (done, archived)

The user's rule: a macro only where it solves a problem a function or
a guard cannot, and a demo that uses one demonstrates that purpose.
The heights demo's `i_f<` (an if/else a guard already is) is gone;
Control (`x:c_ase<`, `x:w_hen<`, `x:l_et<`: conveniences) is set
aside. General macros (format, dbg, assert, include, cfg) are X_eTaL's
system macros (the user's decision); this repo's are domain macros
beside their libraries: Dates `d_ate<`, Polynomials `p_oly<`, Graphs
`g_raph<`, built and running on X_eTaL's macros lane
(docs/macros.md).

## Saga 6 -- macros-prep (done, archived)

Control redesigned around macros X_eTaL lacks, typed at compile time,
its bodies tested in the gate (twelve cases); the live demo's Expand
button shows the system macros' expansions. Next: saga 4 when X_eTaL
runs `.xtlm` files (`just asks-upstream` shows X1 fixed).

## Saga 4 -- macro libraries and deferred (blocked)

Update (2026-10-03): X_eTaL made `i_f<`, `u_nless<` and `e_ach<` system
macros and added `xetal expand` (X2 landed upstream); `.xtlm` (X1) is
still to come. Control is redesigned around macros X_eTaL lacks
(`x:c_ase<`, `x:w_hen<`, `x:l_et<`: docs/control.md), confirmed by the
user, with expansions type-checked at compile time like written code.

Upstream, X_eTaL's Saga 19 delivers the macro support in order:
long prefixes (MC13), `.xtlm` lookup (MC11), macro calls (MC10, MC12),
the engine, the expand tool (X2), its own small example, user macros,
a retrofit and a release. This saga starts when a vendored X_eTaL has
at least the engine (its step 4); `just upstream` shows where it
stands. Upstream's plan names the libraries here "Control, Assert":
Assert is this plan's Test.

Blocked on ask X1 (`.xtlm` macro libraries in X_eTaL). Started when a
vendored X_eTaL supports them; until then only the designs below are
kept current.

| # | Step slug | Delivers |
| - | --------- | -------- |
| 1 | macro-survey | refresh the vendor; read what X_eTaL implemented (MC10 and after); confirm A9 and the designs below against it |
| 2 | macros-ship | the domain macros (Dates, Polynomials, Graphs) ship: their `macros/` programs join the ordinary tests and demos, the live demo's store carries `.xtlm` files so a program in the browser uses them, Expand shows their expansions |
| 3 | more-macros | candidates by the rule (docs/macros.md): Csv named columns, Bits named fields, Check table-driven tests, a Strings regex |
| 4 | deferred | any library waiting on another ask, as its ask lands |
| 5 | release-3 | catalog, docs, retrospective |

Macro libraries: [`docs/macros.md`](macros.md) (the rule, system or
here, the domain macros built, the asks they raised).

## Saga 1 retrospective

- The vendored X_eTaL (0caf584) carried both libraries with no
  workaround in the logic, only in reach: `[]U_CS` is decided but not
  implemented (X4), so case is ASCII-only; there is no assert or error
  of one's own (X3), so Check reports as text.
- Calling conventions to remember when writing libraries: a function
  of two data arguments is called dyadically (`w f_ail g`, never
  `f_ail w g`, which is two values side by side); one of three data
  arguments is called as `(a f_ b)_ c`.
- The macro design was corrected against research.txt and X_eTaL's
  MC10 (`m:u_nless< :=` in a `.xtlm`; `u_if<`/`u_each<` are X_eTaL's
  own standard macro library).
- The runner refuses a blessed `FAIL` line unless the program says
  `# shows failures`, so a broken library cannot be locked in by
  `just bless`.

## Saga 2 retrospective (release 1)

- Eight libraries (Check, Strings, Sets, Numbers, Combinatorics,
  Lists, Matrix, Random), 70 exports, each with property checks
  written with Check, a demo and a page; every page example is
  recorded output (`scripts/check-examples.py` in the gate).
- The layout changed mid-saga at the user's request: one directory per
  library with reg-rs tests, docs and demos (A3-A5). Every baseline
  was compared with the old goldens when moved.
- The vendored X_eTaL went from 0caf584 to 8eb3de2 with every
  baseline unchanged; transpose landed, so `mx:t_ranspose` was removed
  for the built-in `o_\` before the release.
- Most bugs were right-to-left reading (`k - 1 + x`, `n * a d_iv b`,
  `(n - j + 1)`), a 1-item vector used as a scalar, Int and Float
  mixed without `f_loat`, and Bool variables in arithmetic (T5). Check
  grew two fixes from use: long values shown by start and shape, and
  an absolute tolerance near zero in `k:n_ear`.
- Process: a commit chain that kept going after a failed command
  pushed a step's completion before its files; commit, complete and
  push now run from one script that stops at the first failure.
- Asks open: X1/X2 macro libraries (decided upstream as MC10/MC11), X3
  assert and errors of one's own, X4 `[]U_CS`, X5 empty Char display,
  X6 big integers, X7 matrix divide.

## Saga 3 retrospective (release 2)

- Six libraries (Format, Plot, Dates, Statistics, Graphs, Bits), 48
  exports; fourteen in all, 128 exports, every one in the live demo.
  Strings gained `t:m_ix` (a list of texts as a character matrix),
  needed by Plot.
- Libraries now build on each other through `XETAL_PATH`: Format uses
  Strings and Lists, Plot uses Strings and Format, Statistics the
  standard Stats.
- The live demo was reviewed in the browser: every library's demo
  runs without error on the published site; one fix came from it
  (`p:l_ine!` spreads x, since `[]P_ATH` keeps one scale for x and y).
- Right-to-left slips stayed the commonest bug (`(from - 1) * n + to`,
  `m_od`'s order, a quantile's upper index); most were caught by
  reading the formula before running it, the rest by the Check
  properties. Two checks of mine were wrong, not the libraries.
- Process: commit, pages, gate, complete and push run from one script
  that stops at the first failure; pictures go to work/draw/.
- Upstream: no ask landed; X_eTaL's queue now has macros (Saga 19)
  5th. `just upstream` tracks it.

## Saga 5 retrospective (release 3)

- Five libraries (Polynomials, Grouping, Csv, Search, Geometry), then
  the freeze research4 asked for: nineteen libraries, 165 exports, all
  in the live demo. No new ordinary library until `.xtlm`.
- Readiness work instead of breadth: every ask's repro runnable
  (`just asks`, `just asks-upstream`), promotion blockers marked; the
  front door (README and the live demo's Start here, grouped); Control
  ready to ship, its macro bodies tested in the gate.
- X10 landed upstream: the vendor was refreshed to 081fb3f (every
  baseline unchanged) and its workaround removed.
- The commonest bug stayed the same: reading right to left
  (`(n - j + 1)`, `14 * 15 d_iv 2`, `-1 o_-` for the next item);
  reading each formula right to left before running it caught most.
- Release 3 is tag `v0.3.0` (this repo only, at the user's word),
  known compatible with X_eTaL 081fb3f; the six repos sync their tags
  around 1.0.0-rc.

## Sagas 10 and 11 retrospective (release 0.5.0)

- System macros where they solve a problem: `i_nclude<` builds Csv's
  data into its demo, `p_anic<` gives misuse in eleven libraries a
  message at the library's line, `f_ormat<` lays out text of several
  pieces in two demos; the others are not used, and docs/macros.md
  says why.
- The repository got light before tags sync: X_eTaL pinned by one
  line (`XETAL_COMMIT`, cloned and built into `work/xetal`), the site
  published as the `gh-pages` branch, and `pages/` and `vendor/`
  purged from history (36 MB to about 1 MB; docs/history-rewrite.md).
- X_eTaL v0.1.0 (512b3ee) landed X3, X4 and X9: Strings' case by code,
  Polynomials' evaluation by decode, Dates' `t_oday`; hygienic macros
  changed only expansion text; a comparison's open numeric type would
  have widened Bits' exports (kept Int by Int arithmetic; X17 asks).
- Lessons: stage everything a bump changes (the site's Cargo.lock was
  left out once); the gate's ASCII check catches non-ASCII in asks.
- Release 0.5.0 is tag `v0.5.0`, built against X_eTaL v0.1.0
  (512b3ee): nineteen libraries, 166 exported functions, six domain
  macros.

## Cross-cutting

- Move the known-good X_eTaL (`just bump`) at a saga start or when
  an ask has landed upstream; never mid-step; its own commit, goldens
  and pinned types re-run.
- When an ask lands, remove its workaround in the step that moves
  `XETAL_COMMIT`, and mark the ask landed.
- A library that turns out to belong in X_eTaL's standard libraries
  (or a function that should be a built-in) is proposed as an ask,
  not moved silently.
