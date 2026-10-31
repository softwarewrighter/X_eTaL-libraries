# X_eTaL-libraries -- Implementation Plan

Libraries written in X_eTaL (the eXperimental Extensible Typed Array
Language, developed in `../X_eTaL`): ordinary `.xtl` libraries that
any program imports with `u_se<`, and `.xtlm` macro libraries that
extend the language itself, beside six of the `.xtl` libraries where a
macro solves a problem a function or a guard cannot (`docs/macros.md`).
The source of the ideas is `docs/research.txt` (archival, not
normative); this plan turns it, and the user's later additions, into
sagas and steps.

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
| what programs can **say** | macro libraries (`.xtlm`): functions `(String, String) -> String` run before parsing | this repo, beside six libraries (`docs/macros.md`) |

This repo's job is to show both axes working well: a library earns
its place when it is something everyday programs need and the
language does not have as a built-in (text, sets, number theory,
combinatorics, matrices, randomness, formatting, dates), or when it
shows an array idea worth teaching; a macro earns its place only
where a function or a guard cannot do the job (`docs/macros.md`'s
rule). Each library is small, typed, tested, and documented with its
provenance.

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
| A13 | **Tuples only where they add value over an array** (`docs/tuples.md`, decided 2026-10-08): type safety, convenience or notation a tuple gives that an array cannot, most of all different-typed parts; never a same-typed grouping that is itself computed on, concatenated or vectorized further (the array idiom used everywhere here). Audited against every export: no heterogeneous case yet; two same-typed candidates found (`Strings.r_eplace`'s pair, `Statistics.f_it`'s result), not yet implemented. | A Typed Array language defaults to the array; a tuple is reached for only when the array would lose or hide something real. |
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
| Check | `ch:` | assertions that report as text (ok / FAIL, expected and got), a summary; tests and teaching | J's `assert`, BQN's `!`, xUnit habits | 1 |
| Strings | `t:` | case, trim, words, split and join, starts/ends/contains, find, replace, pad, repeat | J strings addon, BQN `strings.bqn`, dfns `ss`, `words`, `dlb`/`dtb` | 1 |
| Equations | `e:` | sums as printed in papers: the CNN layer's cross-correlation (`e:c_orrelate`), then the equation macros `e:e_q<`, `e:t_ex<`, `e:b_oth<` | the textbook cross-correlation of CNN layers; X_eTaL `docs/spatial.md` (D154) | 12 |
| Parsing | `pa:` | total parsers for macro authors (split outside brackets, groups, chains, bindings, functions applied, references, a whole-text check), each using all of its text or refusing the call | Equations' own helpers, generalized; X_eTaL `docs/type-check-macros.md` approach 9 | 13 |
| Sets | `se:` | union, intersection, difference, symmetric difference, subset and equality as sets, counts of each item | APL idioms, dfns | 2 |
| Numbers | `n:` | gcd, lcm, primes (sieve), prime?, factors, divisors, digits, integer square root, Fibonacci | dfns `gcd`, `sieve`, `factors`, `pco` ideas | 2 |
| Combinatorics | `cb:` | factorial, binomial, combinations (dfns `cmat`), permutations (`pmat`), subsets by `e_ncode`, Cartesian product | dfns `cmat`, `pmat`, APL2 idioms | 2 |
| Lists | `li:` | differences, moving windows and averages, run-length encoding, counts, interleave, binary search, rotate-to, chunks | dfns `bsearch`, APL idioms, X_eTaL classics | 2 |
| Matrix | `mx:` | transpose (until the built-in lands), identity, diagonal, trace, matrix product, determinant, inverse and solve (Gauss-Jordan) | APL2 `domino` behavior, dfns | 2 |
| Random | `r:` | shuffle, deal (k of n without repeats), choice, uniform and normal floats | APL `?` deal, BQN `random.bqn` | 2 |
| Format | `f:` | fixed decimals, padded columns, a text table from a matrix, thousands separators | APL dyadic format behavior | 3 |
| Plot | `p:` | text charts: horizontal bars, sparkline, histogram, scatter on a character grid | APL PLOT workspace ideas | 3 |
| Dates | `d:` | days from civil and back, day of week, leap years, a month calendar as a matrix | Hinnant's civil algorithms, APL `cal` | 3 |
| Statistics | `sx:` | median, mode, quantiles, z-scores, covariance, correlation, linear fit, histogram counts; imports the standard `Stats` | J stats addon | 3 |
| Graphs | `g:` | adjacency matrices: degrees, reachability (Warshall), shortest paths (min-plus product), BFS levels, components | X_eTaL classics (graphs by inner product) | 3 |
| Bits | `b:` | to and from binary, popcount, xor, shifts and masks by `e_ncode`/`d_ecode` | APL idioms | 3 |
| Dates, Polynomials, Graphs (`.xtlm` beside each) | `d:`, `pl:`, `g:` | `d:d_ate<` (date literals checked at compile time), `pl:p_oly<` (maths notation compiled), `g:g_raph<` (a graph's node names defined): domain macros where a function cannot do the job (docs/macros.md) | research.txt; the user's rule (saga 7) | built; ship with X1 |
| Tags (`.xtlm` only) | `tg:` | `tg:e_num<` (constants for choices, codes that index tables) and `tg:p_arts<` (a tagged tuple's constructor, test, getters, setters and rows): records and enumerations by macro and naming convention, no new language (the user, 2026-10-10; X_eTaL docs/adt.md) | Julia `@enum`, Erlang tagged tuples, TypeScript discriminated unions, APL inverted tables | built (2026-10-10) |
| Test (`.xtlm`) | `test:` | `test:e_xpect<` and test blocks expanding to Check calls, so a test reads as the code it checks (research.txt's `test:...<`) | research.txt | 4 (blocked) |
| Trig | `tr:` | what the builtins leave out in closed form: `t_an`, `a_sin`, `a_cos`, `a_tan2`, the hyperbolics, `d_egrees`/`r_adians`, `h_ypot` | X_eTaL-ML docs/xetal-libraries-asks.md E4 | 18 (planned) |
| Special | `sp:` | functions with no closed form: `e_rf`/`e_rfc`, `g_amma`/`l_gamma`, `b_eta`, the standard normal CDF and quantile | X_eTaL-ML docs/xetal-libraries-asks.md E5; Abramowitz and Stegun, Lanczos | 19 (planned) |

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

## Reprioritized (2026-10-03, research4; satisfied, see CLAUDE.md "Priorities")

`../X_eTaL/docs/research4.txt` reviewed the whole ecosystem for a
wider launch: the remaining work is "stabilize, synchronize, explain,
give people one obvious path", not more features. For this repo, as
it stood then:

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

## Planned work

Asked by the blog's agent (2026-10-19, writing about continuous
equations; relayed by X_eTaL's local session):

- **Equations: numerical diagnostics.** An error estimate for an
  `integral` from the difference between `n` and `2n` steps (Richardson
  style, the rule's order known), reported with the value or on
  request; a warning when the integrand jumps inside the interval (a
  sample policy already decides what a jump takes), since the quadrature
  then converges slowly without saying so. A saga step after Saga 14;
  test first against the box-function convolution and `1/x` near 0.
- **Equations: the notations already planned.** The grammar words
  decided for X_eTaL Saga 42 and not yet read here: the convolution and
  correlation forms as `sum`/`integral` lowering with the window modes,
  2-D convolution with the bias on the first axis checked; each as a
  step with the oracle's numbers before the code. (The `## draws:`
  notation, MC32, landed in Saga 15.)

- **Equations' grammar, from the catalog** (Saga 14 step 5,
  2026-10-19), what the continuous equations could not write yet,
  each a grammar decision for the user: a step or indicator function
  (`step(x)`, 1 for x >= 0, or `box`), so the continuous convolution
  of two boxes (the triangle, X_eTaL-ML's Integrals demo) can be an
  integral here; `float(e)`, so an Int index can scale a Float
  integral (`(i + 1) * (integral ...)` is a type error, as X_eTaL's
  arithmetic is, B8); `tanh(x)` once X_eTaL has `t_anh` (ask X22; the
  catalog builds it from `exp`); Greek names with a subscript
  (`phi_1` as `\phi_1`; today only an exact name converts).
- **Doctests** (`docs/doctest-plan.md`, 2026-10-08): `## >>` runnable
  examples under every export and macro, so `xetal doc --test` checks
  them and `/doc/` shows a worked example, as `../X_eTaL`'s own
  libraries do. Not started; the plan has open questions for the user
  (order, whether `@ p_anic<` guards get a doctest too, `.xtl`
  `check-examples.py`'s fate) before it becomes a saga.
- **Tuples** (`docs/tuples.md`, A13, 2026-10-08): `Strings.r_eplace`'s
  `pair` parameter as `(Char, Char)` (today a `Box Char` lets the
  wrong arity through silently: `"a" "b" "c" t:r_eplace "abc"` gives
  `bbc`, not an error) and `Statistics.f_it`'s result as `(Float,
  Float)` (today untyped as to its arity). Not started: `r_eplace`'s
  calling convention changes (strand notation to a tuple literal) for
  every call site, the page, the tests and the baselines together.

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

## Saga 12 -- equations (done, archived)

The user (2026-10-16): the spatial-equations library moves here from
`../X_eTaL` (its Saga 41 decided the design; the user chose this
repository and named it `Equations`). A sum as an ML paper prints it,
written in one macro call, gives the array computation, its LaTeX or
both; a library on the language as it is, with no compiler change.
The design is X_eTaL's: `../X_eTaL/docs/spatial.md` (the call, the
lowering, the errors, the expected outputs), `docs/eq-rationale.md`
(why per-sum bindings), `docs/type-check-macros.md` (what a macro must
check), decision D154. The proof of concept, 142 lines that already
lower correctly, is `../X_eTaL/docs/spatial-poc/Spatial.xtlm`.

```
"e:" u_se< "Equations"
Y := "Y[o,h,w] | O Ho Wo" e:e_q< "sum c:=0..C - 1, sum r:=0..Kh - 1, sum s:=0..Kw - 1 | X[c,h+r,w+s] * W[o,c,r,s]"
```

`e:e_q<` gives the value, `e:t_ex<` the LaTeX, `e:b_oth<` the pair.
A macro is warranted (CLAUDE.md "Macros"): it reads an embedded
language (the equation) and checks it when the program is compiled.
Later: the left-to-right pipeline macro goes to `../X_eTaL-ML` (it
needs `nn:` functions), integrals and numerical methods follow
(`../X_eTaL/docs/convolutions/integrals.md`), and a future
X_eTaL-Math repository may take this library over.

| Step | Slug | Content |
| ---- | ---- | ------- |
| 1 | equations-pin | XETAL_COMMIT to X_eTaL main (`just bump`: `[]G_ENSYM`, raw strings, bound-once names), its own commit, every golden and pinned type re-run |
| 2 | equations-oracle | `libs/Equations` from the template; the independent oracle (valid cross-correlation by rotations, a transpose and one inner product) as a test program; fixtures A (all ones: 8 everywhere, shape 1 3 3), B (560 596 632 / 704 740 776 / 848 884 920) and C (2 output channels, 3 input channels, a 2 by 3 kernel on 5 by 6 pictures: shape 2 4 4) as goldens |
| 3 | equations-capture | `Equations.xtlm` parses the call: the left's result, free indices and extents; each sum's operator word, index and inclusive range; the summand with math precedence; `[]R_EJECT` at the argument for every malformed call (a range without `..`, an index bound twice, a summand index neither summed nor free, a free index without an extent, two indices for a rank-3 array where the rank is written); rejection goldens first |
| 4 | equations-lowering | `e:e_q<`: coordinate grids, a gather per array reference by Horner's rule with a bounds check per axis (`error[index]` naming the array, axis, index and expression), one reduction per sum; fresh names by `[]G_ENSYM`; equal to the oracle on A, B and C; `xetal expand` goldens |
| 5 | equations-latex | `e:t_ex<` and `e:b_oth<` from the same parse; LaTeX goldens; the library's README, docs page, a demo (the CNN layer), the catalog row; publish |
| 6 | equations-notation | Done (2026-10-17, decided with the user after the blog's #11 found three silent wrong answers): one grammar read three ways (value, LaTeX, a reprint compared with the text at every call); sums as parenthesized terms of a larger expression, `prod` `max` `min`, the functions `exp log sqrt abs max min`, `^`; a differential test against Python and a catalog of ten ML equations checked against plain X_eTaL |

## Saga 25 -- latex-in (planned)

`../X_eTaL-ML/docs/xetal-libraries-asks.md` E11 (filed 2026-10-28
from its Pipelines page and composer): LaTeX in, `e:f_romTex<`, the
inverse of `e:t_ex<` -- the LaTeX `e:t_ex<` writes (subscripts as
indices, `\sum_{i=0}^{n-1}`, `\frac`, `\sqrt`, `\exp`, `\log`,
`\max`, `\left( \right)`, Greek names, `\,` and `\cdot` as products)
read into the grammar's text, so an equation from a paper or from
OCR (which gives LaTeX) is used as typed instead of typed again. The
input is the subset `e:t_ex<` writes, not LaTeX at large: anything
else is refused by name, as the grammar refuses a function it lacks
(`\tanh` until Saga 20, `\operatorname` beyond `erf`, a `\sum` with
no bounds, an index set like `\sum_{i \in S}`), never guessed. The
reader is a Parsing grammar of its own (the precedent: Equations'
reader, Saga 13), with the whole-text rule. Independent of Saga 24;
each word Sagas 17, 20 and 21 add to the grammar gets its LaTeX read
here when it lands.

| Step | Slug | Content |
| ---- | ---- | ------- |
| 1 | tex-reader | The accepted subset written down as a table on the page from what `h:t_ex` emits (every row a construct, its LaTeX and its grammar text); the reader over Parsing: `_{...}` subscripts as indices (`X_{c,h+r}` to `X[c,h+r]`; a bare one-character subscript `W_i` too), `\sum_{i=0}^{n-1}` (and `\prod`, `\max`, `\min`) to `sum i:=0..n-1 |`, `\int_{a}^{b} ... \, d\tau` to `integral`, `\frac{a}{b}`, `\sqrt{}`, `\exp \log \sin \cos`, `\left( \right)` and braces as grouping, `\,` and `\cdot` and juxtaposition as `*`, a Greek command as its name; whitespace, `{}` that group nothing and spacing-only commands (`\!`, `\;`, `\quad`, common in OCR output) ignored (decided with the user, 2026-10-29), anything that could change the meaning refused; refusals first, as goldens: an unknown command named with its place in the text, a sum without bounds, an index set, unbalanced braces |
| 2 | tex-roundtrip | `e:f_romTex<` exported; the test the ask names: `e:t_ex<` of what it reads gives back the LaTeX, on every equation the demos and the catalog (Saga 12 step 6, Saga 14 step 5) draw; and the other direction, the grammar text read back equal after `t_ex` then `f_romTex`; a macro, as the reader is the macro file's (decided with the user, 2026-10-29); how the round trip runs at compile time decided here |
| 3 | tex-ship | A few LaTeX lines as papers set them (spacing commands, `\left[`, `^{T}`) on the page: what is read and what is refused, so a reader knows to tidy OCR output; the library's README, docs page, a demo (a paper's LaTeX to its value), `docs/xetal-asks.md` if the reader finds a gap in X_eTaL; publish |

## Saga 24 -- equation-stages (planned)

`../X_eTaL-ML/docs/xetal-libraries-asks.md` E10 (filed 2026-10-28
from its Pipelines page): an equation read as a pipeline of stages.
`"Y[o,h,w] | O Ho Wo" e:s_tages< "max((sum r:=0..2, sum s:=0..2 |
P[h+r,w+s] * F[o,r,s]) + B[o], 0)"` gives the pipeline's text,
inside out turned left to right: each sum and each function applied
over the indices a stage that is an equation of its own, named
(`C[o,h,w] | O Ho Wo`), `|>` between stages and the earlier stages'
values by label, as X_eTaL-ML's Flow reads it (`flow:p_ipe<`,
`flow:m_ath<`); and with each stage the span of the original text it
came from (start and end), so a page highlights the part of the
original a stage computes. Today X_eTaL-ML writes each pipeline by
hand beside its equation and checks the two equal (`equations.xtl`,
`rosetta.xtl`, `diffusion.xtl`). Equations does not import Flow
(Flow lives in X_eTaL-ML and imports Equations): the output is text
in Flow's syntax, and the value check that runs the pipeline through
Flow is X_eTaL-ML's; here each stage runs as its own `e:e_q<`. The
sampler's equation needs Saga 17 (a scan and named functions) before
it can be staged; the CNN layer's needs nothing new.

| Step | Slug | Content |
| ---- | ---- | ------- |
| 1 | stages-design | Decided with the user (2026-10-29): a stage is a run of sums written together, or a function applied around what came before (`max`, `exp`, ...); plain arithmetic (`+ B[o]`) belongs to the stage around it, and a term over fewer indices than the result (`B[o]`) is never a stage of its own -- the ask's two stages for the CNN layer, the sums then `max(C[o,h,w] + B[o], 0)`; two exports, `e:s_tages<` the pipeline text and `e:s_pans<` each stage's start and end, as `e:e_q<` and `e:t_ex<` split the readings; macros, since the reader is the macro file's. Still to settle here, goldens first: a stage's free indices and extents (those of the result's indices its text uses, the extents taken from the left; a stage over fewer indices than the result, `B[o]`, is not a stage of its own); stage names (fresh, never a name the equation already uses, as `[]G_ENSYM` names the lowering's; the last stage named as the left names the result); the spans (offsets into the right string, half-open, measured on the text as written, not the trimmed or reprinted one) |
| 2 | stages-split | The split over the parse Equations already makes (the reader records each node's place in the text, which it does not today: the one change to the shared reader, every existing golden unchanged); the stages' text; refusals as goldens (an equation with nothing to split is one stage, not an error) |
| 3 | stages-check | The test the ask names, without Flow: each stage run as an `e:e_q<` in turn, its label a variable, the last equal to the whole equation's `e:e_q<`, on the Saga 12 catalog and X_eTaL-ML's CNN layer; a span golden per example (the stage, its span, the substring the span covers) |
| 4 | stages-ship | The library's README and docs page (what a stage is, a drawn example), a demo; publish; a note to X_eTaL-ML that its Flow-side check (`flow:p_ipe<` of the text equal to `e:e_q<`) can replace the hand-written pipelines |

## Saga 23 -- indexed-gradients (planned)

`../X_eTaL-ML/docs/xetal-libraries-asks.md` E9 (filed 2026-10-23,
planning that repo's `Activations` library): indexed gradients,
`e:g_rad< "dL/dW[i,j] | N K" "L"`, the derivative of a scalar equation
with respect to an array element by the Kronecker-delta rules of
index notation (a reference `W[i,j]` differentiated gives
`delta_{i,i'} delta_{j,j'}`, the deltas contracted against the sums
that touch them), so backpropagation is written from the loss instead
of by hand. The ask itself calls this "the ambitious one: a step of
its own after E8" -- it needs Saga 22's derivative rules and
simplifier as a foundation, so it stays a one-row placeholder until
that saga lands; X_eTaL-ML's `backprop`, `train-live`, `cnn-backprop`
and `Net` keep writing gradients by hand and checking them against
finite differences until then.

| Step | Slug | Content |
| ---- | ---- | ------- |
| 1 | gradient-design | Blocked on Saga 22. Once `e:d_iff<`'s per-function derivative table and simplifier exist: design the index-notation delta rules (a free index of the target differentiates to `1`, any other reference's matching index to `delta`, contracted against an enclosing `sum`'s range), a minimal repro from X_eTaL-ML's `backprop` demo as the first goldens, and whether the result is itself an equation string (reusable by `e:e_q<`) or a new export shape |

## Saga 22 -- symbolic-diff (planned)

`../X_eTaL-ML/docs/xetal-libraries-asks.md` E8: symbolic
differentiation, a fourth reading of the grammar Equations already
parses through Parsing (value, LaTeX, the whole-text check, now a
derivative) -- `e:d_iff< "y | x" "x^2 * exp(x)"` writes the
derivative's X_eTaL, `e:d_tex<` its LaTeX. Needs Saga 21's numeric
derivative as the differential-test oracle (E7 is filed as this
saga's precedent); Polynomials' `d_erivative` is the precedent for
doing this termwise over a known grammar rather than by a general
rewrite engine.

| Step | Slug | Content |
| ---- | ---- | ------- |
| 1 | diff-rules | One rule per grammar function: sum, product, quotient and chain rules over `+ - * /`; `^` with a constant exponent by the power rule (the general case, a variable exponent, goes through `exp` and `log` instead of a special case); a derivative per function of the table (`exp` to itself, `log` to `1/x`, `sqrt` to `1/(2 sqrt)`, `cos` to `-sin`, `sign` for `abs`, a selection rule for `max`/`min`); `sum` differentiated termwise; `integral` by the fundamental theorem when differentiating with respect to a bound, or under the integral sign otherwise; rejection goldens for a variable the body does not use |
| 2 | diff-activations | The derivative rules Saga 20 adds words for: `1 - tanh(x)^2`, erf's `2/sqrt(pi) exp(-x^2)`, `sigmoid(x) * (1 - sigmoid(x))` |
| 3 | simplifier | A small simplifier so a derivative reads instead of growing a dead `0 * e` or `e + 0` on every product and sum rule application: `0 * e -> 0`, `1 * e -> e`, `e + 0 -> e`, `e - 0 -> e`, applied until none fire |
| 4 | diff-tex-and-test | `e:d_tex<`; a differential test against Saga 21's `derivative` at random points through Check, over the equation catalog from Saga 12 step 6 and Saga 20's activation formulas; the library's docs page, a demo, the catalog row |

## Saga 21 -- derivative (planned)

`../X_eTaL-ML/docs/xetal-libraries-asks.md` E7: a numeric derivative
word in Equations' grammar, in the shape Saga 14 step 3 already gave
`integral` -- `derivative x:=x0 by central 1e-5 | body` (central
differences at `x0`, the default rule; `forward` as an option word,
with the step's default stated on the page), `\frac{d}{dx}` in
LaTeX, the usual written-back reprint check. Evaluation only: any
body the grammar already reads has a numeric derivative today without
new rules, so this is a straightforward sibling of `integral`, not a
new reading. It is also the differential-test oracle Saga 22 needs
(E7 is filed in the ask as "the oracle for E8"), and it covers what
X_eTaL-ML's `Activations` library needs today, written out as a
finite-difference lambda in every test (and in `backprop`'s own
`u:b_ump`).

| Step | Slug | Content |
| ---- | ---- | ------- |
| 1 | derivative-word | `derivative x:=x0 by RULE STEP | body` as an operator word: `central` (the default) and `forward`, a stated default step; a vector `x0` gives the derivative at each of its points; infinite or missing bounds do not apply here (no range), so the refusals are a malformed binding and an unknown rule word; rejection goldens first |
| 2 | derivative-latex | `\frac{d}{dx}` in LaTeX from the same parse; the written-back reprint check; a differential test against hand-written finite differences on the equation catalog; the docs page, a demo, the catalog row |

## Saga 20 -- equations-activations (planned)

`../X_eTaL-ML/docs/xetal-libraries-asks.md` E6: Equations' function
table widened with `tanh`, `erf`, `sigmoid` and `softplus` as words of
the grammar (drawn `\tanh`, `\operatorname{erf}`, `\sigma`), each
written through Saga 18's Trig and Saga 19's Special (or straight
through the builtin, the day X22 or M19 lands: plan A7's "a library
function wraps a builtin the day it exists" applies to the grammar's
words too, not only to a library's own exports). Needs Sagas 18 and
19 first. Once this lands, X_eTaL-ML's `Activations` library writes
its reference formulas (`x * sigmoid(1.702 * x)`, `0.5 * x * (1 +
erf(x / sqrt(2)))`) as one equation string each, value and LaTeX from
the same reading, instead of a `$$` line typed by hand beside X_eTaL
code.

| Step | Slug | Content |
| ---- | ---- | ------- |
| 1 | activation-words | `tanh`, `sigmoid`, `softplus` added to the function table (through Trig's `t_anh` and a library sigmoid built from it, since Trig has no sigmoid of its own); `erf` added through Special's `e_rf`; each with a value and LaTeX golden; `sigmoid` note on the page: X_eTaL-ML's workaround (`2 sigmoid(2x) - 1` reading as `tanh`) is retired once this lands |
| 2 | activation-catalog | The GELU and Mish formulas from the equation catalog (Saga 12 step 6, Saga 14 step 5) rewritten through the new words; `e:b_oth<` goldens showing value and LaTeX from one string |

## Saga 19 -- special (planned)

`../X_eTaL-ML/docs/xetal-libraries-asks.md` E5: a `Special` library
(`sp:`) of the functions with no closed form -- `e_rf`, `e_rfc` (a
rational approximation, Abramowitz and Stegun 7.1.26, at least
1.5e-7), `g_amma` and `l_gamma` (Lanczos), `b_eta`, and the *standard
normal* CDF and its inverse. The last two are named carefully on the
page to avoid reading like Statistics' `sx:q_uantile`: that is the
empirical quantile of a data vector; this library's is the quantile
function (inverse CDF) of the fixed normal(0,1) distribution -- two
different things that happen to share a common statistics-textbook
word. Each function wraps the matching builtin the day M19 lands
(plan A7), so a caller already on this library sees no change.

Revisit before it starts (Saga 18's decision, 2026-10-30): `e_rf` and
`e_rfc` are in X_eTaL's B20 builtins (uncommitted on that date), so
Special uses them and keeps no approximation of its own; step 2
shrinks to the oracle test, or goes.

| Step | Slug | Content |
| ---- | ---- | ------- |
| 1 | special-scaffold | `libs/Special` from the template; provenance note (Abramowitz and Stegun for `e_rf`/`e_rfc`, Lanczos for `g_amma`/`l_gamma`); the accuracy of each approximation stated on the page, each tested against a table of known values |
| 2 | special-erf | `e_rf`, `e_rfc`; a test against X_eTaL-ML's `Integrals` oracle (`libs/Integrals/demos/gelu.xtl`'s simpson quadrature of the error function's integral), the comparison itself becoming this library's differential test |
| 3 | special-gamma | `g_amma`, `l_gamma`, `b_eta` (through `l_gamma`, for the large-argument case) |
| 4 | special-normal | the standard normal CDF and its inverse (quantile), named to read apart from Statistics' `q_uantile` (see above); a test against a published table (the 68-95-99.7 rule, and a few quantile landmarks: 0.5 -> 0.0, 0.975 -> about 1.96) |
| 5 | special-ship | demo, docs page, catalog row, README's library count |

## Saga 18 -- trig (in progress)

`../X_eTaL-ML/docs/xetal-libraries-asks.md` E4: a `Trig` library
(`tr:`) of what X_eTaL's builtins (`s_in`, `c_os`, `a_tan`, `e_xp`,
`l_og`, `p_i @`) leave out and a library can write in closed form:
`t_an`, `a_sin`, `a_cos`, `a_tan2` (the sign cases), `s_inh`, `c_osh`,
`t_anh`, `a_sinh`, `a_cosh`, `a_tanh`, `d_egrees`, `r_adians`,
`h_ypot`. Each with a doc example and a test against a known value,
the range and accuracy limits of each form stated on the page: `tanh`
built from `e_xp` cancels badly near 0 at the extremes, so it wraps
`u:t_anh`'s shape from `docs/xetal-asks.md` X22 (NN's workaround,
`2 s_igmoid(2x) - 1`, about 1e-6 relative error at 1e-10) until X22
lands a builtin, the day it wraps that instead (plan A7). What stays
in the base language versus a library here is the settled question in
the ask (2026-10-23): nothing leaves `s_in`, `c_os`, `a_tan`, `e_xp`,
`l_og`; everything derivable from them is a library.

**Decided with the user (2026-10-30): one implementation, in the base
language.** Where X_eTaL has (or is landing) a builtin, Trig uses it
and has no copy of its own, not even a workaround to retire later:
`../X_eTaL`'s B20 group (`t_anh`, `s_qrt`, `e_xpm1`, `l_og1p`, `e_rf`,
`e_rfc`, "the libm functions a library cannot write as well") is in
its working tree, not yet committed, on 2026-10-30. Step 3 therefore
waits for that commit and a `just bump` to it (its own commit, before
the step begins), then: no `tr:t_anh` (the builtin is the function;
an export of that name would shadow it, rule 2, and a bare alias adds
nothing), the page points to it; `s_inh`, `a_sinh`, `a_tanh` and
friends are written on `e_xpm1`/`l_og1p` so they keep their digits
near 0; `a_sin`/`a_cos` move from `^ 0.5` to `s_qrt` if its domain
refusal is as clear. The X22 shape above is superseded.

| Step | Slug | Content |
| ---- | ---- | ------- |
| 1 (done) | trig-scaffold | `libs/Trig` from the template; the header, recommended alias `tr:` (free: not `t:` Strings, `s:` Stats) |
| 2 (done) | trig-circular | `t_an`, `a_sin`, `a_cos`, `a_tan2` (all four quadrant signs tested, including the axes); domain refusals where the builtins already refuse (`a_sin`/`a_cos` outside -1..1) documented, not re-implemented |
| 3 | trig-hyperbolic | (waits for X_eTaL's B20 builtins in a committed ref, then `just bump`) `s_inh`, `c_osh`, `a_sinh`, `a_cosh`, `a_tanh` on `e_xpm1`/`l_og1p`; `t_anh` is the builtin, not an export (see above); each tested near 0 and near its domain edge for the stated accuracy |
| 4 | trig-units-and-ship | `d_egrees`, `r_adians`, `h_ypot`; demo, docs page, catalog row, README's library count |

## Saga 17 -- equations-grammar (done)

`../X_eTaL-ML/docs/xetal-libraries-asks.md` E1-E3 (filed 2026-10-20
from the diffusion sampler of `demos/pipelines/diffusion.xtl`, a
paper's equation for `X0`): three gaps in Equations' grammar, found by
a real paper's notation rather than invented. Equations' rule is
deliberate (a fixed table of functions, every rule uses all of its
text or refuses it, plan A8's "not a bug, an ask"), so each of these
is a grammar change weighed on its own, not a patch.

| Step | Slug | Content |
| ---- | ---- | ------- |
| 1 (done) | descending-range (E1) | A descending range, `sum t:=T..1 | ...`, died inside the lowering with `error[domain]: a count cannot be -1`, naming no rule -- a bug (A8). The range's low and high are the caller's own values (`h:b_ound`), not known until the program runs, so this cannot be caught at macro-expansion time either -- same reason the rank and index checks are runtime, not compile-time. Fixed in `h:q_uadrature`: a sum/prod/max/min's span is now a self-checking expression, `({ v -> (0 <= v) ? v; "bad-equation" []S_IGNAL "..." } (1 + hi - lo))`, naming the word and the range as written (`"sum's range runs low..high: T..1"`) instead of falling through to the array machinery's count error; a range landing on exactly one below its low (the empty sum, `0..N-1` at `N` = 0) still passes through unchanged -- refuse rather than guess, but not refuse what is legitimately empty. Every existing `expand-*` golden across the library rebased (cosmetic: the span text is now wrapped, no value or error baseline changed); `../tests/reject-descending-range.xtl` the new rejection golden; the library's docs page gets the rule and an example |
| 2 (done) | scan-word (E2) | `scan t:=T..1 by seed | body` (either direction: `start..end`, not `sum`'s `low..high`), the previous term named by the reserved word `prev`, decided with the user as a clean binding over index arithmetic or declining E2. A genuine fold, not a reduction (the array machinery's `r_/`/`s_\` are a right fold, only the same as a running accumulation when the step is associative, B6): built from `p_ower`, one state-threading step applied once per point of the range (X_eTaL's own precedent for a state threaded through a repeated application, `n 'f p_ower x`). `prev` has no value before the first term without a seed -- a scan whose body uses it is refused rather than guessing one, matching the ask's own workaround's shape (one step applied repeatedly, not a plain `sum`'s independent terms); `prev` is reserved everywhere else, refused even inside a plain sum. A scan must be its term's only binding. `h:r_enamed`/`h:w_ordLen`/`h:h_asPrev?` (word-boundary text substitution, since a scan's index and prev are plain generated names, not grid cells the shared env looks up); LaTeX draws `\operatorname{scan}`; rejection and value goldens, `../tests/scan.xtl` and three `reject-*` |
| 3 (done, unplanned) | svg-function-plots | Inserted mid-saga at the user's direct request (`docs/research2.txt`, a design discussion on graphing activation functions): independent of E1-E3 and of this saga's own theme, tracked here rather than as a separate saga since `agentrail` holds one saga per checkout. `Plot` already imports X_eTaL's own standard `Svg` and already draws real SVG line charts (`l_ine!`, `l_ines!`, `c_hart!`); a new SVG-primitives or plotting library would have duplicated it. The actual gap: those charts place a series by position (1 to its length), with no real x-axis -- there was no way to draw `y = f(x)` over a range with the axis reading `x`'s own values. Added to `Plot`, not a new library: `l_inspace` (n evenly spaced Floats lo..hi inclusive), `f_unction!`/`f_unctions!`/`f_unctionChart!` (an (x over y) pair per curve, mirroring `l_ine!`/`l_ines!`/`c_hart!` with a value-ticked horizontal axis instead of a position-ticked one). `../tests/functions.xtl` (Check) and a general demo, `../demos/functions.xtl` (a sine wave and a parabola -- never an activation function here: X_eTaL-ML owns that explorer once it has an activations library, this library knows nothing of neural nets). The docs page notes NaN and infinite values are not specially handled (a known limit, not hidden) |
| 4 (done) | named-functions (E3) | The caller's own functions by name inside an equation (`D(z[k])`, `eps_theta(z[k], t, c)`), refused before as `... is not a function of an equation`. `h:f_n?` no longer refuses an unknown name (it checks only `pa:a_pplied?`'s shape now); any name that is not one of the six fixed functions is read as `u:name(args)` in the lowering, applied to however many arguments it is given -- the arity check in `h:f_nParts` runs only for a fixed function, so a named one is trusted with any count. A bad name or the wrong count is not caught at the macro call: `error[undefined-name]` or a type error from the expanded code itself, naming the call. A fixed function always wins over a same-named `u:` one (unchanged -- checked first in `h:v_alueFn`). LaTeX draws `\operatorname{name}(...)`, never a bare `\name` (an undefined command for most names); the fixed functions keep their own backslash commands. `../tests/named-function.xtl` (one argument, several, nested in a sum, a fixed function's priority, the LaTeX) and `../tests/reject-undefined-function.xtl` (replacing `reject-unknown-function.xtl`, whose scenario -- an unknown name refused at the macro call -- this step removes); the docs page states the tradeoff |

## Saga 16 -- parsing-guide (done)

Saga 13 landed `libs/Parsing` itself (total parsers for macro
authors) and moved Equations and Tags onto it, but closed with no
user-facing teaching material: `libs/Parsing/docs/` has only its
reference README, and `libs/Parsing/demos/` has one program
(`pieces.xtl`) that is not a worked example of writing a notation
macro. The blog agent found this while fact-checking a draft post
against current main and proposed five pieces of teaching material;
this saga builds them (the user, 2026-10-21). Steps 2-7, added the
same day: dogfooding -- the six macro libraries that do not yet
import Parsing (Bits, Check, Csv, Dates, Graphs, Polynomials) read
their own notations through it where it fits. Checked first: none of
the six has Equations' bug (a recursive reader stopping early); each
already validates its text completely (an exhaustive character-class
check, or an exact-count position search), so this is consistency and
defense-in-depth -- sharing one set of tools instead of six private
copies, and `pa:w_hole`'s formal guarantee against a future edit
reintroducing that bug -- not a fix for a live one.

| Step | Slug | Content |
| ---- | ---- | ------- |
| 1 (done) | guide | `libs/Parsing/docs/guide.md`: a `for<` notation macro (stepped ranges, `for i:=0..10 by 2`) built step by step, using each of Parsing's tool groups in turn, with the where tag explained as its own section, every example run against a working `ForRange.xtlm` and checked; linked from `libs/Parsing/README.md` and `docs/macros.md` |
| 2 (done) | migrate-bits | `libs/Bits`' field split onto `pa:a_t` (the colon) and `pa:n_ame?` (the name check, byte for byte the same rule); the width's digit check and the exactly-one-colon count stay bespoke (no Parsing primitive fits "exactly one occurrence"); no behavior change |
| 3 (done) | migrate-check | `libs/Check`'s row split onto `pa:a_t` (`->`) and `pa:s_plit` (`;`, bracket-aware, though no row can use that headroom without also tripping the exactly-one-arrow rule); no behavior change |
| 4 (done) | migrate-csv | `libs/Csv`'s schema split onto `pa:a_t` (the colon) and `pa:n_ame?` (its own `h:n_ame?` removed, byte for byte the same rule); no behavior change |
| 5 (done, no change) | migrate-dates | Surveyed: `pa:c_haracters` is a refusing function with its own generic message; Dates' `h:f_ormed?` already refuses with its own specific one ("... is not a date: write it yyyy-mm-dd"), and nothing fits without changing it. Left as is (the user, 2026-10-21) |
| 6 (done) | migrate-graphs | `libs/Graphs`' path split onto `pa:s_plit` (comma and dash, bracket-awareness unused since a station name has none) and `pa:n_ame?` (its own `h:n_ame?` removed, byte for byte the same rule); no behavior change |
| 7 (done, no change) | migrate-polynomials | Surveyed: `pa:c_haracters`' wording problem (step 5) again, plus `pa:p_arts` would need `h:t_erms`' sign-attached-to-term shape rebuilt from its (parts, ops, neg) for no practical gain (a polynomial has no brackets, so `pa:p_arts`' bracket-awareness buys nothing); `pa:n_umber?` is not `h:n_umeral?` (it also requires starting and ending on a digit, rejecting `2.` and `.5`, which Polynomials accepts) -- a real behavior change, not a style one. Left as is (the user, 2026-10-21) |
| 8 (done) | ranges-library | `libs/Ranges` (full structure, catalog row, `GROUPS`), `rg:f_or<` exactly the guide's worked example; a good-input test and demo, and five rejection tests, one per mistake the guide shows. Named `rg:`, not `r:` (Random already has it) |
| 9 (done) | before-after | `libs/Parsing/demos/before-after.xtl`: a naive group check beside `pa:g_roup?`'s, the wrong value it implies (`y - p`) next to the right one (`(y - p) ^ 2`); a real refusal needs a macro and a demo must run clean, so that side points to `libs/Ranges`' own rejection tests instead |
| 10 (done) | doc-site-check | `just doc` confirms Ranges and the before-after demo indexed; both spot-checked running live in the browser (`sampled.xtl`, `before-after.xtl`); no gap found; `just publish`, the live INPUTS fingerprint matching the local build |

## Saga 15 -- notation (done)

X_eTaL step 154 (MC32, D178) landed at d5d54ae8: a macro side declared
`notation` is drawn by the `## draws:` macro of its library wherever a
program is drawn. One step, one PR from main: the pin moved (its own
commit); Equations declares `## takes: notation notation` on `e_q<`
and `b_oth<` (`## draws: t_ex<`) and on `c_onvolve<` and `c_orrelate<`
(`## draws: c_onvolveTex<`, `c_orrelateTex<`, two new exports giving
the textbook sum in LaTeX; a drawer may not name itself, so `t_ex<`
stays `text text`); the test harness pins a program marked `# drawn`
as `xetal render --html` draws it (`drawn-NAME`); the live demo draws
a program through `xetal_play::decorated` and X_eTaL's `xetal-katex`
(a `c-notation` box typeset by the page's KaTeX); ask X21 landed.

## Saga 14 -- integrals (done)

X_eTaL's Saga 42 (integrals; its decisions 1 to 8 with the user,
2026-10-17) sends two pieces here: decision 1, `integral` in
Equations' grammar (one grammar, one reader through `pa:`; the
quadrature rules beside it), and decision 5, `convolve` and
`correlate` as library macros expanding to `sum`, not parser words.
X_eTaL-ML's `Integrals` library (its `integ:i_ntegral<`, the same call
standing alone) is the oracle and retires once Equations takes over.
First the pin moves to X_eTaL main (step 112: code strings and
`## takes:` contracts) and every macro declares its contract; `##
draws:` (MC32) waits for X_eTaL step 154. Each step is a PR from main.

| Step | Slug | Content |
| ---- | ---- | ------- |
| 1 | pin-bump | `XETAL_COMMIT` to X_eTaL main (f7848d00); every baseline whose error text moved to X_eTaL's located form rebased (stderr only) |
| 2 | contracts | `## takes:` on every macro of every `.xtlm`, the string-kind lint over the demos; `## draws:` noted as waiting (X_eTaL step 154) |
| 3 (done) | integral-in-equations | `integral tau:=a..b by trapezoid 64 \| body` as an operator word of the grammar: the value by the written rule (trapezoid, simpson), `\int_{a}^{b}` in LaTeX, the reading written back; infinite bounds refused; X_eTaL-ML's Integrals tests as goldens |
| 4 (done) | convolve-correlate | `e:c_onvolve<`, `e:c_orrelate<` over `sum`, modes full, same, valid (none implicit), the asymmetric fixture |
| 5 (done) | equation-catalog | about ten ML equations, each with an independent answer; what cannot be written yet filed as asks |

## Saga 13 -- parsing (done, archived)

The user (2026-10-17): a parsing library for macro authors, so that
no macro parses part of its argument and drops the rest (the class of
error Equations had, X_eTaL docs/type-check-macros.md approach 9),
started now and folded into the integrals work later. `Parsing`
(`pa:`; named so, not Reading, since a Lisp reader macro changes how
source is read and these cannot: a notation lives inside its string)
is a plain `.xtl` library of total parsers for `.xtlm` files: the
pieces every notation needs (split at a separator outside brackets, a
balanced group and its inside, a chain and its operators with a
leading minus, a name, a number, a binding `i:=a..b`, a function
applied, a reference), each either using all of its text or refusing
it with `[]R_EJECT` at a given place, and a whole-text check that
writes a parse back to compare with its text. Equations and Tags then
parse through it; the pipeline macro (X_eTaL-ML) and the integral
macros are its next users.

| Step | Slug | Content |
| ---- | ---- | ------- |
| 1 | parsing-library | `libs/Parsing`: the parsers above, generalized from Equations' helpers, each with a rejection test and a doc example; the catalog row and the macros page (done) |
| 2 | equations-on-parsing | Equations parses through Parsing (no behavior change: every golden, the differential test and the catalog unchanged); also `## uses: parsed` on every macro, the result held to the whole-text rule (done) |
| 3 | tags-on-parsing | Tags' `e_num<` and `p_arts<` parse through Parsing, with a whole-text check; their goldens unchanged (done) |

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
fields), Csv `cs:c_olumns<` (typed named columns), Check `ch:c_ases<`
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

## Saga 4 -- macro libraries and deferred (superseded; never started -- see sagas 6-9)

X1 landed (vendored 6239aad); this saga's own plan (a standalone
`Control` library) was superseded by what sagas 6-9 actually built:
domain macros beside six existing libraries (`docs/macros.md`), not a
Control library of its own. Left below as the record of the plan as
it stood before X1 landed.

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
  an absolute tolerance near zero in `ch:n_ear`.
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
