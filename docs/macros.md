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

## Built

| Library | Macro | Purpose (from the rule) | Example |
| ------- | ----- | ----------------------- | ------- |
| Dates | `d:d_ate<` | 2: a date literal checked, its day number written in | `@ d:d_ate< "2026-10-03"` becomes `20729`; `"2026-02-30"` stops the compiler (`error[bad-date]`) |
| Polynomials | `py:p_oly<` | 2: maths notation compiled | `@ py:p_oly< "3x^2 - 2x + 1"` becomes `3.0 -2.0 1.0` |
| Bits | `b:f_ields<` | 4 (and 2): named getters and setters, the layout checked and compiled in | `@ b:f_ields< "on:1 mode:3 level:8"` defines `u:m_ode`, `u:s_etMode`, ... |
| Check | `k:c_ases<` | 1: checks named by their own source text | `"u:c_lamp" k:c_ases< "5 -> 5; 42 -> 10"` writes `ok: u:c_lamp 5`, ... |
| Tags | `tg:e_num<`, `tg:p_arts<` | 4: names created (a macro-only library) | `@ tg:e_num< "Color: black red green"` defines `BLACK`, `RED`, `GREEN`, `COLOR`; `@ tg:p_arts< "State: w k"` defines `STATE`, `u:s_tate`, `u:s_tateW`, `u:s_etStateW`, ... |
| Csv | `cs:c_olumns<` | 4: a variable per column, its kind type-checked | `"city:text population:number" cs:c_olumns< "t"` defines `city`, `population` |
| Graphs | `g:g_raph<` | 4: names created | `"town" g:g_raph< "airport-bridge-center"` defines `airport`, `bridge`, `center` and `town` |

They use what X_eTaL 6239aad gives macro libraries: `@` on a side
that takes no argument (MC22), errors of their own with `[]R_EJECT`
(MC20), their own library's functions imported by path (MC23).
Each has a demo of its purpose (`demos/literals.xtl`,
`demos/notation.xtl`, `demos/stations.xtl`, in the live demo too,
where Expand shows the expansion) and a test of the compile-time error
(`tests/impossible.xtl`, `tests/malformed.xtl`, `tests/badname.xtl`);
every program that calls a library's macro also pins its expansion
(`expand-*.rgt`, `xetal expand`). The gate checks every `.xtlm` with
`xetal type` (each macro `Char -> Char -> Char` or
`Unit -> Char -> Char`). `just asks-upstream REF` still builds any ref
of `../X_eTaL` to try a lane.

Not here: regular expressions. A regex engine is a large standard
with a long tail of semantics (Unicode classes, case folding, match
order, captures) and performance guarantees (linear time); a
reimplementation in X_eTaL would be a new, untested dialect. It belongs
in X_eTaL-extensions on the Rust `regex` crate, where it is already
planned (`Regex`, `rx:`; the crate builds for wasm32, so it can run in
the browser too). A macro checking a pattern when the program is
compiled would go beside that facade there, if a macro body may call
an extension while expanding; otherwise the crate reports a bad
pattern at first use.

Set aside: Control (`x:c_ase<`, `x:w_hen<`, `x:l_et<`): conveniences a
guarded function already gives; its design is in the git history
(before this page).

## Upstream (X_eTaL v0.1.0, 512b3ee, the known-good commit)

X_eTaL runs macro libraries (`.xtlm`, X1) with `@` for no argument
(X12), errors of their own by `[]R_EJECT` (X13) and imports of their
own `.xtl` by path (X14); its system macros, in `lib/System.xtlm`, are
the general ones this page proposed: `f_ormat<` (interpolation),
`d_bg<`, `a_ssert<`, `p_anic<`, `i_nclude<`, `c_fg<` (conditional
compilation, X11), `l_ine<`, `f_ile<`, `e_rror<`, besides `i_f<`,
`u_nless<`, `e_ach<` and `u_se<`. The domain macros here use only what
they need; none of them repeats a system macro.

## The system macros used here, and why

Each where it solves a problem a function cannot, and nowhere else:

| Macro | Where | The problem it solves |
| ----- | ----- | --------------------- |
| `i_nclude<` | Csv's `cities` demo: `data := @ i_nclude< "cities.csv"` | the data file is built into the program when it is compiled, so it runs with no file access, in a terminal or the browser (a function cannot read the source tree at compile time) |
| `p_anic<` | guards in eleven libraries (a singular matrix, a month of 13, dealing more than there are, ...) | misuse stops with a message naming the bad value, located at the library's line, instead of an obscure error from deep inside (X_eTaL has no raise of its own otherwise) |
| `f_ormat<` | Format's `invoice` (the tax line) and Random's `dice` (each row) | text of several pieces written as it reads, each value in braces, instead of a chain of `c_at`; the format string is checked before the program runs. A label and one value stay `"label " c_at value` |

Not used: `d_bg<` and `a_ssert<` (debugging aids; the tests are
goldens and Check's lines, and a demo has nothing to debug), `c_fg<`
(nothing here differs between the terminal and the browser), `l_ine<`,
`f_ile<` and `e_rror<` (the domain macros refuse calls with
`[]R_EJECT`, which names the code; `e_rror<` would add nothing).

## What the macros taught (asks for X_eTaL)

Found by running these macros on the lane, filed in
[`xetal-asks.md`](xetal-asks.md):

- X11: what a macro may know while expanding (the platform, flags),
  and an include macro; needed for conditional compilation.
- X12 (landed, 6239aad: `@`): a call with nothing on the left: `@ d_bg< "x"` or
  `d_bg< "x"` are `bad-macro-call`; `""` on the left works.
- X13 (landed, 6239aad: `[]R_EJECT`): a macro reporting its own compile error: a bad literal today
  expands to an undefined name (`noSuchDate20260230`) or the body fails
  (`the macro ... failed: division by zero`).
- X14 (landed, 6239aad: import by path): a `.xtlm` cannot call its own library's functions (`l:` is
  refused, importing itself is a cycle) nor name the importer's alias
  in what it writes, so `d_ate<` repeated Dates' day arithmetic.
- X15 (open): an error from `[]R_EJECT` is located by byte range only,
  not file, line and column.
