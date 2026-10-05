# X_eTaL libraries

<p align="center">
  <img src="images/xetal-logo.jpg" alt="X_eTaL: eXperimental Extensible Typed Array Language" width="480">
</p>

<p align="center">
  <b><a href="https://softwarewrighter.github.io/X_eTaL-libraries/">The live demo</a></b>
  -- every library's demos, editable and runnable in your browser (WebAssembly)
</p>

Libraries for [X_eTaL](https://github.com/softwarewrighter/X_eTaL),
the eXperimental Extensible Typed Array Language: nineteen of them, from
text and dates to matrices, statistics and graphs, each written in
X_eTaL itself, typed, tested, documented and runnable in the browser.

## Start here

**Try one now**, nothing to install: open
[the live demo](https://softwarewrighter.github.io/X_eTaL-libraries/),
pick a library, press Run, then Edit the program. Every library here
can be imported by any program there.

**Use one** in your own program: one line imports it, with an alias
of your choice; its functions then read like the built-ins.

```
"t:" u_se< "Strings"
t:u_pper "hello"            # HELLO
```

**How this fits.** X_eTaL extends in three ways:

| Extends | With | Where |
| ------- | ---- | ----- |
| the vocabulary | `.xtl` libraries: functions written in X_eTaL | **this repository** |
| the language | `.xtlm` macro libraries: source in, source out, before the program runs | this repository too: domain macros beside their libraries (Dates, Polynomials, Graphs) |
| the machine | native code behind typed X_eTaL facades | [X_eTaL-extensions](https://github.com/softwarewrighter/X_eTaL-extensions) |

The rest of the ecosystem: the language itself and its live demo
([X_eTaL](https://github.com/softwarewrighter/X_eTaL)), visual demos
([X_eTaL-demos](https://github.com/softwarewrighter/X_eTaL-demos)),
machine learning ([X_eTaL-ML](https://github.com/softwarewrighter/X_eTaL-ML)),
games ([X_eTaL-games](https://github.com/softwarewrighter/X_eTaL-games)).

Many functions are ported from the libraries of other array languages
(Dyalog APL's dfns workspace, J's addons, BQN's bqn-libs):
reimplemented from their documented behavior and credited on each
library's page.

## Libraries

| Group | Library | Alias | What |
| ----- | ------- | ----- | ---- |
| Foundations | [Check](libs/Check/README.md) | `k:` | assertions that report as text, for tests and teaching |
| | [Strings](libs/Strings/README.md) | `t:` | case, trim, words, split and join, find, replace, pad |
| | [Lists](libs/Lists/README.md) | `q:` | differences, windows, run lengths, chunks, binary search |
| | [Sets](libs/Sets/README.md) | `se:` | union, intersection, difference, subset, counts |
| Data | [Csv](libs/Csv/README.md) | `cs:` | comma-separated values: fields, tables, columns, back to text |
| | [Grouping](libs/Grouping/README.md) | `gr:` | counts, sums, means and any function per key |
| | [Search](libs/Search/README.md) | `sr:` | positions, merges, top k, ranks with ties, nearest |
| | [Statistics](libs/Statistics/README.md) | `sx:` | median, quantiles, z-scores, correlation, linear fit |
| | [Dates](libs/Dates/README.md) | `d:` | day numbers, weekdays, leap years, ISO dates, calendars |
| Mathematics | [Numbers](libs/Numbers/README.md) | `n:` | gcd, lcm, primes, factors, digits |
| | [Combinatorics](libs/Combinatorics/README.md) | `cb:` | factorial, binomial, combinations, permutations, subsets |
| | [Matrix](libs/Matrix/README.md) | `mx:` | identity, trace, determinant, inverse, solve |
| | [Polynomials](libs/Polynomials/README.md) | `py:` | evaluate, add, multiply, differentiate, integrate, real roots |
| | [Geometry](libs/Geometry/README.md) | `ge:` | distances, areas, centroids, transforms, convex hulls |
| | [Graphs](libs/Graphs/README.md) | `g:` | adjacency matrices, reachability, shortest paths, components |
| | [Bits](libs/Bits/README.md) | `b:` | binary digits, popcount, and, or, xor, Gray codes |
| | [Random](libs/Random/README.md) | `r:` | shuffle, deal, choice, uniform and normal samples |
| Output | [Format](libs/Format/README.md) | `f:` | fixed decimals, thousands, money, columns, text tables |
| | [Plot](libs/Plot/README.md) | `p:` | text charts (bars, sparklines, histograms, scatter), line pictures |
| Macros | Dates | `d:` | `d:d_ate<`: date literals checked when the program is compiled |
| | Polynomials | `py:` | `py:p_oly<`: maths notation, `3x^2 - 2x + 1`, compiled |
| | Graphs | `g:` | `g:g_raph<`: a graph written by its node names, the names defined |
| | Bits | `b:` | `b:f_ields<`: named bit fields, a getter and setter each, offsets compiled in |
| | Csv | `cs:` | `cs:c_olumns<`: a table's columns as named, typed variables |
| | Check | `k:` | `k:c_ases<`: table-driven checks, each named by its own source text |

The alias is your choice; the recommended ones do not clash with each
other or with the standard libraries, so any of them can be used
together.

## Using the libraries

Each library is a directory, `libs/<Name>/`, whose `src/` holds the
library file. Put the `src/` directories on `XETAL_PATH` (`just path`
prints them, joined with `:`):

```bash
export XETAL_PATH="$(cd /path/to/X_eTaL-libraries && just path)"
xetal run my-program.xtl
```

X_eTaL looks for a library named in `u_se<` beside the importing
file, then in `userlibs/` in the current directory, then in each
directory of `XETAL_PATH`, then among its standard libraries. You can
also copy a single `libs/Name/src/Name.xtl` into your own `userlibs/`
(with any library it imports).

## Adding and testing libraries

```bash
just libs                            # the libraries, with their aliases
just types Strings                   # each export and its type
just demo Strings                    # run its demos
just show Strings word-count         # a demo as a notebook: each statement, then its output
just expand Statistics heights       # a demo's macro calls and what each became (xetal expand)
just run Strings                     # run its test programs
just test-lib Strings                # check its reg-rs baselines
just new-lib Lists q: "list functions"   # start a library from templates/Library
just bless Lists                     # create or accept its baselines (review the diff)
just eval '"t:" u_se< "Strings"
t:u_pper "hi"'                       # try an expression with every library available
```

Each library is its own directory:

| Path | What it is |
| ---- | ---------- |
| `libs/Name/README.md` | what it is, the import line, its directories |
| `libs/Name/src/Name.xtl` | the library (later also `Name.xtlm`, macros); its header names it, says what it is, and gives the import line with the recommended alias |
| `libs/Name/docs/README.md` | the reference: every function, its type, examples, demos, limits, where it was ported from |
| `libs/Name/demos/*.xtl` | programs that use it for something recognizable |
| `libs/Name/tests/` | reg-rs baselines: each test program `NAME.xtl` with `NAME.rgt`, `NAME.out` and `NAME.err`; `types.rgt`, every export's type (an interface change fails); `demo-D.rgt` for each demo |

Baselines run from `tests/` through `scripts/xt`: the bundled xetal
with every library on `XETAL_PATH`, `--seed 1` and `--ascii`. Tests
use the Check library: a line of output starting with `FAIL` fails
the test even if it was blessed, unless the program says it shows
failures on purpose (`# shows failures`).

## The live demo

```bash
just serve            # the site, rebuilt on change: http://127.0.0.1:8459/
just pages            # build it into pages/ (commit pages/)
just serve-pages      # preview pages/ at http://127.0.0.1:8459/X_eTaL-libraries/
```

The site (`site/`, a Rust app in WebAssembly built with
[trunk](https://trunkrs.dev)) embeds every library at build time: for
each one its demos, runnable in the browser on the bundled X_eTaL and
editable (the ASCII editor beside the rendered form, as in X_eTaL's
live demo; any library can be imported with `u_se<`), its reference
page, its source and its exported types. All X_eTaL there is shown in
its rendered form, drawn by X_eTaL's own renderer; a program that uses
macros (X_eTaL's system macros `i_f<`, `u_nless<`, `e_ach<`) can be
expanded beside it, as `xetal expand` prints it. A page's address
names what it shows (`#Strings/word-count`). `pages/` is built
locally and committed; pushing it to `main` runs a workflow
(`.github/workflows/pages.yml`) that only publishes the folder. The
gate fails when `pages/` is older than the libraries.

## Build

Prerequisites: [Rust](https://rustup.rs) (stable),
[`just`](https://github.com/casey/just) and Python 3; for the tests,
`reg-rs`; for the live demo, `rustup target add wasm32-unknown-unknown`
and [trunk](https://trunkrs.dev); for the gate (maintainers),
`sw-markdown-checker`.

```bash
just                                 # list the tasks
just xetal                           # build the bundled X_eTaL interpreter
just eval "'+ r_/_2 2 3 r_eshape r_ange 6"   # try it: row sums, 6 15
just gate                            # the pre-commit gate
```

The libraries are tested against a copy of X_eTaL kept in this
repository under `vendor/xetal/` (a snapshot of a known-good commit,
recorded in `vendor/xetal/VENDORED`), so they do not change under you
as X_eTaL develops. `just xetal-version` shows which commit it is.
Maintainers refresh it from a sibling checkout with `just vendor`
(the latest commit of `../X_eTaL`) or `just vendor REF`; only
committed X_eTaL work is ever copied, and the refresh is committed on
its own after `just gate` passes. The libraries themselves work with
any X_eTaL at least as new as the vendored one.

## Status

Release 0.3.0 (tag `v0.3.0`). Nineteen libraries are ready, each with
tests, demos and a reference page, all runnable in the live demo,
against the bundled X_eTaL 4abe761. Six of them have macros beside
them, used where a macro solves what a function cannot
([`docs/macros.md`](docs/macros.md)): Dates' date literals and
Polynomials' maths notation checked at compile time, Graphs' named
nodes, Bits' named bit fields, Csv's typed columns, Check's
table-driven checks; their demos run in the live demo too. `just upstream` shows where X_eTaL
stands, `just asks` which asks are open.

## Documentation

- [`docs/plan.md`](docs/plan.md) -- architecture decisions, the
  catalog, the roadmap (including the macro library design)
- [`docs/macros.md`](docs/macros.md) -- when a macro is warranted,
  which belong to X_eTaL, the macros built here
- [`docs/xetal-asks.md`](docs/xetal-asks.md) -- features and fixes the
  libraries need from X_eTaL
- [`CHANGES.md`](CHANGES.md) -- every change, newest first
- `docs/research.txt` -- the archival design discussion
- [`CLAUDE.md`](CLAUDE.md) (also `AGENTS.md`) -- the agent workflow
  (agentrail sagas) and rules

## Development

Development is tracked with agentrail sagas, as in X_eTaL: `agentrail
status` shows the current step, `agentrail next` its instructions.
Every step ends with the gate passing, docs updated, a commit to `main`
and a push.

## Related Projects

- [X_eTaL](https://github.com/softwarewrighter/X_eTaL) -- the language
  ([try it live](https://softwarewrighter.github.io/X_eTaL/))
- [X_eTaL-demos](https://github.com/softwarewrighter/X_eTaL-demos) --
  visual demos in X_eTaL
  ([live](https://softwarewrighter.github.io/X_eTaL-demos/))
- [X_eTaL-games](https://github.com/softwarewrighter/X_eTaL-games) --
  small games in X_eTaL
- [sw-mlpl](https://github.com/sw-ml-study/sw-mlpl) -- Software
  Wrighter's Machine Learning Programming Language, a Rust array
  language inspired by APL, APL2, J, and BQN.

## Links

- Blog: [Software Wrighter Lab](https://software-wrighter-lab.github.io/)
- Discord: [Join the community](https://discord.com/invite/Ctzk5uHggZ)
- YouTube: [Software Wrighter](https://www.youtube.com/@SoftwareWrighter)

## Copyright

Copyright (c) 2026 Michael A Wright

## License

MIT. See [`LICENSE`](LICENSE) and [`COPYRIGHT`](COPYRIGHT).
