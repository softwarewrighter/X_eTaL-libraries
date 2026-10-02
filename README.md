# X_eTaL libraries

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
| Check | `k:` | assertions that report as text, for tests and teaching | planned |
| Strings | `t:` | case, trim, words, split and join, find, replace, pad | planned |
| Sets | `se:` | union, intersection, difference, subset | planned |
| Numbers | `n:` | gcd, lcm, primes, factors, digits | planned |
| Combinatorics | `cb:` | factorial, binomial, combinations, permutations, subsets | planned |
| Lists | `q:` | differences, windows, run lengths, binary search | planned |
| Matrix | `mx:` | identity, transpose, determinant, inverse, solve | planned |
| Random | `r:` | shuffle, deal, choice, normal samples | planned |
| Format | `f:` | fixed decimals, columns, text tables | planned |
| Plot | `p:` | text charts: bars, sparklines, histograms | planned |
| Dates | `d:` | day numbers, weekdays, leap years, calendars | planned |
| Statistics | `sx:` | median, quantiles, correlation, linear fit | planned |
| Graphs | `g:` | reachability, shortest paths, components | planned |
| Bits | `b:` | binary digits, popcount, xor, masks | planned |
| Control (`.xtlm`) | `x:` | `x:u_nless<`: new control syntax written as a library | waiting on X_eTaL |
| Test (`.xtlm`) | `test:` | `test:e_xpect<`: tests that read as the code they check | waiting on X_eTaL |

The alias is your choice; the recommended ones do not clash with each
other or with the standard libraries, so they can be used together.

## Using the libraries

Put this repository's `lib/` directory on `XETAL_PATH`:

```bash
export XETAL_PATH=/path/to/X_eTaL-libraries/lib
xetal run my-program.xtl
```

X_eTaL looks for a library named in `u_se<` beside the importing
file, then in `userlibs/` in the current directory, then in each
directory of `XETAL_PATH`, then among its standard libraries. You can
also copy a single `lib/Name.xtl` into your own `userlibs/`.

## Adding and testing libraries

```bash
just libs                            # the libraries, with their aliases
just types Strings                   # each export and its type
just run Strings                     # run its test programs
just show Strings                    # the same as a notebook
just test-lib Strings                # its pinned types and expected outputs
just new-lib Sets se: "set functions"   # start a library from templates/
just bless Sets                      # rewrite its expected outputs (review the diff)
```

Each library is one file and has two companions:

| Path | What it is |
| ---- | ---------- |
| `lib/Name.xtl` | the library; its header names it, says what it is, and gives the import line with the recommended alias |
| `tests/Name/*.xtl` | programs that use it, each with its expected output in `tests/Name/expected/` (`.out`, and `.err` when it should fail) |
| `tests/Name/expected/types.out` | every export's type, as `xetal type` prints it: an interface change shows as a test failure |
| `docs/libs/Name.md` | the library's page: every function, its type, examples, where it was ported from |

Tests run from `tests/Name/` with `lib/` on `XETAL_PATH`, `--seed 1`
and `--ascii`.

## Build

Prerequisites: [Rust](https://rustup.rs) (stable) and
[`just`](https://github.com/casey/just); for the gate (maintainers),
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

Early. The project process and plan are in place, and the bundled
X_eTaL builds and is checked by the gate, and the library layout and
its test runner are in place; the first libraries (Check, Strings)
come next.
See [`docs/plan.md`](docs/plan.md) for the roadmap.

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
