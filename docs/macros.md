# Macros in X_eTaL-libraries

A macro is a function from the source text written left and right of
its call to the source that replaces the call, run before the program
is compiled (X_eTaL MC10). This page says when a macro is warranted,
which macros belong to X_eTaL and which here, and what is built.

## The rule

Use a macro only where a function or a guard cannot do the job, and
when a demo uses one, it demonstrates that purpose (the user's rule).
An if/else is a guard; a family of values is a function of a
parameter; neither needs a macro. A macro is warranted to:

1. **use an argument's source text** (a function sees only the value):
   a check named by its own expression, a debug print;
2. **check an embedded notation when the program is compiled** (a
   function parses its text when the program runs): date literals,
   maths notation, format strings;
3. **choose what is compiled** (a guard type-checks both branches):
   conditional compilation for a platform or a flag;
4. **create names** (a function computes values, never definitions):
   a variable per node of a graph, generated bindings.

## Which macros go where (decided with the user)

General-purpose macros are X_eTaL's own, system macros: format strings
and printing (Rust's `format!`, `println!`), `dbg!`, `assert!` and
`assert_eq!`, `include_str!`, `cfg!` and `env!`, the source location
(`file!`, `line!`), and a way for a macro to report its own compile
error (`compile_error!`). They need knowledge a `.xtlm` text-to-text
function lacks (files, the platform, locations) or are wanted by every
program. Proposed to X_eTaL from here: `"label" d_bg< "expr"` (prints
`label expr = value` and gives the value back; tried on X_eTaL's macros
lane as a `.xtlm`: `"dbg:" t:d_bg< "y"` prints `dbg: y = 6`) and
`"expr" e_xpect< "want"` (a check named by its expression).

This repository's macro libraries are domain macros, each beside its
library in `libs/<Name>/src/<Name>.xtlm` (X_eTaL MC11 loads both under
one alias), each solving one of the problems above for its domain.

## Built (running on X_eTaL's macros lane)

| Library | Macro | Purpose (from the rule) | Example |
| ------- | ----- | ----------------------- | ------- |
| Dates | `d:d_ate<` | 2: a date literal checked, its day number written in | `"" d:d_ate< "2026-10-03"` becomes `20729`; `"2026-02-30"` stops the compiler |
| Polynomials | `py:p_oly<` | 2: maths notation compiled | `"" py:p_oly< "3x^2 - 2x + 1"` becomes `3.0 -2.0 1.0` |
| Graphs | `g:g_raph<` | 4: names created | `"town" g:g_raph< "airport-bridge-centre"` defines `airport`, `bridge`, `centre` and `town` |

Each library's `macros/` programs use them, with their output and
their expansion (`xetal expand`) as expected files: `just macros` runs
them with X_eTaL's macros lane (`origin/pr/macros-example`, built from
a snapshot by `scripts/build-upstream.sh`), since the vendored X_eTaL
(its main) does not run `.xtlm` files yet. The gate checks with the
vendored X_eTaL that every `.xtlm` type-checks and each macro is text
to text (`scripts/check-xtlm.sh`). When the lane is merged and
vendored, the `macros/` programs join the ordinary tests and the live
demo.

Candidates for later, by the same rule: Csv typed named columns from a
schema (4), Bits named bit fields (4), Check table-driven tests named
by their source (1), a Strings regular expression compiled (2).

Set aside: Control (`x:c_ase<`, `x:w_hen<`, `x:l_et<`): conveniences a
guarded function already gives; its design is in the git history
(before this page).

## Upstream (2026-10-04, X_eTaL 6239aad on its main)

X_eTaL merged its macros lane: `.xtlm` libraries run (X1; all six of
our `macros/` programs pass on it), `@` stands for no argument (X12),
a macro reports its own error with the `[]R_EJECT` hook (X13), a
`.xtlm` imports its own `.xtl` by path (X14), and the system macros
live in `lib/System.xtlm` (MC18-MC24), which plans `f_ormat<`,
`d_bg<`, `a_ssert<`, `i_nclude<`, `c_fg<`, `f_ile<`, `l_ine<`,
`e_rror<` as system macros, as proposed here. Next here: vendor it,
then rewrite the macros with these (`@ d:d_ate< "..."`, real error
messages, Dates' arithmetic from `Dates.xtl`) and move them into the
ordinary tests, demos and the live demo.

## What the macros taught (asks for X_eTaL)

Found by running these macros on the lane, filed in
[`xetal-asks.md`](xetal-asks.md):

- X11: what a macro may know while expanding (the platform, flags),
  and an include macro; needed for conditional compilation.
- X12: a call with nothing on the left: `@ d_bg< "x"` or
  `d_bg< "x"` are `bad-macro-call`; `""` on the left works.
- X13: a macro reporting its own compile error: a bad literal today
  expands to an undefined name (`noSuchDate20260230`) or the body fails
  (`the macro ... failed: division by zero`).
- X14: a `.xtlm` cannot call its own library's functions (`l:` is
  refused, importing itself is a cycle) nor name the importer's alias
  in what it writes, so `d_ate<` repeats Dates' day arithmetic.
