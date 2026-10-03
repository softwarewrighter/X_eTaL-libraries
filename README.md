# X_eTaL libraries

<p align="center">
  <img src="images/xetal-logo.jpg" alt="X_eTaL: eXperimental Extensible Typed Array Language" width="480">
</p>

<p align="center">
  <b><a href="https://softwarewrighter.github.io/X_eTaL-libraries/">The live demo</a></b>
  -- every library's demos, editable and runnable in your browser (WebAssembly)
</p>

Libraries for [X_eTaL](https://github.com/softwarewrighter/X_eTaL),
the eXperimental Extensible Typed Array Language: text, sets, number
theory, combinatorics, matrices, randomness, formatting, dates and
more, each written in X_eTaL itself, typed, tested and documented.

## What this is

X_eTaL's standard libraries (`Combinators`, `Maybe`, `Stats`,
`Turtle`) are built into the interpreter. The libraries here are
ordinary X_eTaL files that any program can import the same way:

```
"t:" u_se< "Strings"
t:u_pper "hello"            # HELLO
```

The "Extensible" in X_eTaL has two sides. Libraries of functions
extend what programs can **do**; that is what this repository holds
today. Macro libraries (`.xtlm` files, functions from source text to
source text run before a program is parsed) will extend what programs
can **say**; they are designed in [`docs/plan.md`](docs/plan.md) and
wait until X_eTaL supports them. Libraries that wrap native code
belong in X_eTaL-extensions.

Many functions are ported from the libraries of other array
languages (Dyalog APL's dfns workspace, J's addons, BQN's bqn-libs):
reimplemented from their documented behavior, and credited on each
library's page.

## Libraries

| Library | Alias | What | Status |
| ------- | ----- | ---- | ------ |
| [Check](libs/Check/README.md) | `k:` | assertions that report as text, for tests and teaching | ready |
| [Strings](libs/Strings/README.md) | `t:` | case, trim, words, split and join, find, replace, pad | ready |
| [Sets](libs/Sets/README.md) | `se:` | union, intersection, difference, subset, counts | ready |
| [Numbers](libs/Numbers/README.md) | `n:` | gcd, lcm, primes, factors, digits | ready |
| [Combinatorics](libs/Combinatorics/README.md) | `cb:` | factorial, binomial, combinations, permutations, subsets | ready |
| [Lists](libs/Lists/README.md) | `q:` | differences, windows, run lengths, binary search | ready |
| [Matrix](libs/Matrix/README.md) | `mx:` | identity, trace, determinant, inverse, solve | ready |
| [Random](libs/Random/README.md) | `r:` | shuffle, deal, choice, normal samples | ready |
| [Format](libs/Format/README.md) | `f:` | fixed decimals, thousands, money, columns, text tables | ready |
| Plot | `p:` | text charts: bars, sparklines, histograms | planned |
| Dates | `d:` | day numbers, weekdays, leap years, calendars | planned |
| Statistics | `sx:` | median, quantiles, correlation, linear fit | planned |
| Graphs | `g:` | reachability, shortest paths, components | planned |
| Bits | `b:` | binary digits, popcount, xor, masks | planned |
| Control (`.xtlm`) | `x:` | `x:i_f<`, `x:u_nless<`, `x:e_ach<`: new syntax written as a library | waiting on X_eTaL |
| Test (`.xtlm`) | `test:` | `test:e_xpect<`: tests that read as the code they check | waiting on X_eTaL |

The alias is your choice; the recommended ones do not clash with each
other or with the standard libraries, so they can be used together.

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
just serve            # the site, rebuilt on change: http://127.0.0.1:8095/
just pages            # build it into pages/ (commit pages/)
just serve-pages      # preview pages/ at http://127.0.0.1:8097/X_eTaL-libraries/
```

The site (`site/`, a Rust app in WebAssembly built with
[trunk](https://trunkrs.dev)) embeds every library at build time: for
each one its demos, runnable in the browser on the bundled X_eTaL and
editable (the ASCII editor beside the rendered form, as in X_eTaL's
live demo; any library can be imported with `u_se<`), its reference
page, its source and its exported types. All X_eTaL there is shown in
its rendered form, drawn by X_eTaL's own renderer. A page's address
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

Release 1: eight libraries are ready -- Check, Strings, Sets, Numbers,
Combinatorics, Lists, Matrix and Random -- each with tests, a demo and
a reference page, against the bundled X_eTaL 8eb3de2, and all of them
run in the live demo. Saga 3, the applied libraries, has begun:
Format is ready; Plot, Dates, Statistics, Graphs and Bits come next. The macro libraries (Control with
`x:i_f<`, `x:u_nless<`, `x:e_ach<`, and Test) wait until X_eTaL
implements `.xtlm` files. See [`docs/plan.md`](docs/plan.md) for the
roadmap.

## Documentation

- [`docs/plan.md`](docs/plan.md) -- architecture decisions, the
  catalog, the roadmap (including the macro library design)
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
