# X_eTaL-libraries -- Implementation Plan

Libraries written in X_eTaL (the eXperimental eXtensible Typed Array
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

X_eTaL's "eXtensible" has two axes (research.txt):

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
| A1 | X_eTaL is **vendored** into `vendor/xetal/` as a source snapshot of a committed ref of `../X_eTaL` (`just vendor [REF]`, default `HEAD`), recorded in `vendor/xetal/VENDORED`. Uncommitted work in `../X_eTaL` is never vendored. Same scripts as the sibling repos. | X_eTaL moves fast; libraries need a recent but stable interpreter, refreshed deliberately, never mid-step. |
| A2 | The vendored CLI builds into `target/xetal/` (`just xetal`); every recipe runs that binary, not one on the PATH. | Goldens and pinned types are tied to `VENDORED`. |
| A3 | **One flat `lib/` directory** holds every library, `lib/<Name>.xtl` (later `lib/<Name>.xtlm`). It is the one directory a user puts on `XETAL_PATH` (`just path` prints it). Libraries import each other by name and find one another beside the importing file, with no path set. | X_eTaL looks for `Name.xtl` beside the importing file, in `userlibs/`, in each `XETAL_PATH` directory, then among its standard libraries (MC4): a flat directory is the simplest thing that works everywhere. |
| A4 | **Tests per library** in `tests/<Name>/`: `*.xtl` programs that import the library, each with an expected output (`expected/NAME.out`, and `expected/NAME.err` when it should fail), run with `--seed 1` and `XETAL_PATH=lib` from a scratch directory (no stray `userlibs/`); plus `expected/types.out`, the output of `xetal type lib/<Name>.xtl`, which **pins every export's type**. `XETAL_BLESS=1` rewrites goldens (review the diff). | Goldens show behavior; pinned types catch an interface change, as X_eTaL pins the birds' types (CB1). |
| A5 | **A page per library**, `docs/libs/<Name>.md`: what it is for, the import line and recommended alias, every export with its type and an example (taken from the tests), and the provenance of each function. The README's catalog links to it. | Users read the page, not the source; examples come from tested programs so they cannot drift. |
| A6 | **Library conventions** follow X_eTaL's style guide (lang-choices section 16): file `UpperCamel.xtl`; exports under `l:`, private helpers without a namespace; function-first operand order (`'f_ x_y_z data`); counts, indices and keys on the left; predicates end `?`, effects `!`; no top-level expressions (MC8 row 16); a header comment with the import line and recommended alias; a short comment per export. No export shadows a built-in. A library name never shadows a standard one (`Stats`, `Maybe`, `Combinators`, `TTTML`, `Turtle`): an extension of one imports it. | Consistent with the language and the standard libraries, so the libraries teach the style. |
| A7 | **Ported, not copied.** A function ported from another array language's library (Dyalog's dfns workspace, J's addons, BQN's bqn-libs, APL2 workspaces, X_eTaL's own demos) is reimplemented from its documented behavior and cited in the source and on the page ("after dfns `ss`"). No code is copied from sources whose licenses differ. | Credit and lineage without license entanglement. |
| A8 | A missing X_eTaL feature or a bug a library uncovers is **not** fixed here nor hidden: it goes in `docs/xetal-asks.md` (status, kind, libraries, why, minimal repro, workaround) and on the library's page. A library that cannot be built waits in the deferred saga. | X_eTaL owns its language decisions; this repo is a consumer. |
| A9 | **Macro libraries (`.xtlm`) wait for X_eTaL.** The design they target is research.txt's, as X_eTaL is settling it (MC10, in progress upstream): a `.xtlm` file defines macros under `m:` with the macro suffix, `m:u_nless< := { cond body -> ... }`, each a function `(String, String) -> String` (the left and right source text written at the call in, X_eTaL source out); a macro library is compiled before the file that imports it (a file never uses a macro it defines), imported with `u_se<` under an alias like any library and invoked as `"left" x:u_nless< "right"`; expansion is recursive but bounded (about 32 levels) and visible (`xetal --expand`). `u_` names stay X_eTaL's own: `u_se<` is built in, and research.txt's `u_if<` and `u_each<` are to ship as X_eTaL's standard macro library, not here. This repo's macro libraries are the user-extension samples research.txt names (`unless`, test-style macros). Until X_eTaL has `.xtlm` (ask X1), they are designed here on paper only (saga 4), never emulated. | Follows research.txt and the X_eTaL decision; avoids building on a guess. |
| A10 | **Native code is out of scope here.** Libraries that wrap C-ABI or Rust code (`[]S_VO`, `u_native<`) belong in `../X_eTaL-extensions`; a library here may later re-export one. | Keeps this repo pure X_eTaL, runnable anywhere xetal runs (including the browser). |
| A11 | **Names, not homes.** A library is identified by its name (`Strings`), never by a GitHub coordinate; docs say "put `lib/` on `XETAL_PATH`", not a URL. | The repos may move to an organization (`sw-array-languages`, research.txt); nothing here should need rewriting when they do. |
| A12 | `just` is the entry point (recipes call `scripts/*.sh`); `CHANGES.md` gets a line for every commit, as in `../X_eTaL`; docs are ASCII-only markdown (`sw-markdown-checker`). No web pages for now: a browsable library reference may come later (saga 3). | Same process as the sibling repos. |

## Layout

```
lib/                     the libraries: put this directory on XETAL_PATH
  Check.xtl
  Strings.xtl
  ...
tests/<Name>/            one directory per library
  *.xtl                  test programs (each imports the library)
  expected/NAME.out      expected output (NAME.err when it should fail)
  expected/types.out     pinned export types (xetal type lib/Name.xtl)
docs/libs/<Name>.md      the library's page
templates/               what just new-lib copies
scripts/                 the logic behind the just recipes
vendor/xetal/            the vendored X_eTaL (never edited)
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
| Control (`.xtlm`) | `x:` | `x:u_nless<` (research.txt's user-macro example) and `x:w_hen<`: new control syntax written as a library, the user-side counterpart of X_eTaL's standard `u_if<` | research.txt | 4 (blocked) |
| Test (`.xtlm`) | `test:` | `test:e_xpect<` and test blocks expanding to Check calls, so a test reads as the code it checks (research.txt's `test:...<`) | research.txt | 4 (blocked) |

Alias note: an alias is per file and the importer's choice (MC6).
The recommended ones are distinct from each other and from the
letters the X_eTaL docs use for the standard libraries (`c:`
Combinators, `m:` Maybe, `s:` Stats), so any set of them can be
imported together as written on the pages. An alias may be several
letters (`se:`).

## Saga 1 -- foundation

| # | Step slug | Delivers |
| - | --------- | -------- |
| 1 | scaffold | the agentrail saga; CLAUDE.md (AGENTS.md a symlink); README; COPYRIGHT; LICENSE; CHANGES.md; .gitignore; justfile; the gate (markdown); this plan; docs/xetal-asks.md |
| 2 | vendor-xetal | `just vendor [REF]`, `vendor/xetal/VENDORED`, `just xetal`, `xetal-version`, `eval`; `scripts/check-vendor.sh` in the gate; the snapshot in its own commit |
| 3 | library-layout | `lib/`, `tests/<Name>/` with goldens and pinned types, `docs/libs/`, `templates/`, `scripts/libs.py`, `scripts/test-libs.sh` (and its self-test in the gate), `new-lib`, `run`, `types`, `path` recipes |
| 4 | check | the Check library; its tests and page; the assert ask |
| 5 | strings | the Strings library; its tests and page; asks it uncovers |

## Saga 2 -- core libraries

| # | Step slug | Delivers |
| - | --------- | -------- |
| 1 | sets | Sets |
| 2 | numbers | Numbers |
| 3 | combinatorics | Combinatorics |
| 4 | lists | Lists |
| 5 | matrix | Matrix |
| 6 | random | Random |
| 7 | release-1 | catalog and pages reviewed, examples re-run, asks reviewed, retrospective in this plan |

## Saga 3 -- applied libraries

| # | Step slug | Delivers |
| - | --------- | -------- |
| 1 | format | Format |
| 2 | plot | Plot |
| 3 | dates | Dates |
| 4 | statistics | Statistics |
| 5 | graphs | Graphs |
| 6 | bits | Bits |
| 7 | reference-site | optional: a generated library reference (from the pages), published like the sibling repos' pages |
| 8 | release-2 | catalog, docs, retrospective |

## Saga 4 -- macro libraries and deferred (blocked)

Blocked on ask X1 (`.xtlm` macro libraries in X_eTaL). Started when a
vendored X_eTaL supports them; until then only the designs below are
kept current.

| # | Step slug | Delivers |
| - | --------- | -------- |
| 1 | macro-survey | refresh the vendor; read what X_eTaL implemented (MC10 and after); confirm A9 and the designs below against it |
| 2 | control | `lib/Control.xtlm`: `m:u_nless<` and `m:w_hen<` (the condition and its branches as source; expanded into a guarded lambda); tests of the expansion (`--expand`) and of the result |
| 3 | test | `lib/Test.xtlm`: `m:e_xpect<` and test blocks expanding to Check calls; its tests |
| 4 | deferred | any library waiting on another ask, as its ask lands |
| 5 | release-3 | catalog, docs, retrospective |

Macro library design (research.txt, MC10; for reference when X1
lands). A macro gets the source text written left and right of the
call and returns source; here the right text holds two branches
separated by `;`, as research.txt writes `u_if<`:

```
# Control.xtlm (a macro library): m: names ending in < are macros,
# (String, String) -> String, run before the importing file is parsed.
"t:" u_se< "Strings"
m:u_nless< := { cond body ->
  b := ";" t:s_plit body                      # "then ; else", two boxes
  "{ @ -> (" c_at cond c_at ") ? " c_at (d_isclose 2 s_elect b) c_at "; " c_at (d_isclose 1 s_elect b) c_at " } @"
}
```

```
# a program
"x:" u_se< "Control"
n := 4
"n = 0" x:u_nless< "100 / n ; 0.0"       # expands to { @ -> (n = 0) ? 0.0; 100 / n } @
```

## Cross-cutting

- Refresh the vendored X_eTaL (`just vendor`) at a saga start or when
  an ask has landed upstream; never mid-step; its own commit, goldens
  and pinned types re-run.
- When an ask lands, remove its workaround in the step that refreshes
  the vendor, and mark the ask landed.
- A library that turns out to belong in X_eTaL's standard libraries
  (or a function that should be a built-in) is proposed as an ask,
  not moved silently.
