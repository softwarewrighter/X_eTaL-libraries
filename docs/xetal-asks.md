# Asks for X_eTaL

Features the libraries need that X_eTaL does not have yet, and bugs
the libraries uncovered. This repo does not change X_eTaL: each ask is
filed here (and taken to `../X_eTaL`), the library uses the workaround
noted below or waits, and the workaround is removed when the ask
lands in a vendored release (`vendor/xetal/VENDORED`).

Each entry: status (open, filed, landed, dropped), kind (feature, bug
or speed), which library or libraries need it, why, a minimal repro
or example, and the workaround in use.

| # | Status | Kind | Ask | Libraries | Workaround |
| - | ------ | ---- | --- | --------- | ---------- |
| X1 | open | feature | `.xtlm` macro libraries: user-defined macros `m:n_ame< := ...`, `(String, String) -> String`, imported with `u_se<` and invoked as `"l" x:n_ame< "r"` (MC10, in progress upstream) | Control, Test (saga 4) | none: those libraries wait (plan A9, saga 4) |
| X2 | open | feature | `xetal --expand FILE`: the source after macro expansion, and a bounded expansion depth | Control, Test | none: waits with X1 |
| X3 | open | feature | Stopping with an error of one's own (an `a_ssert`, or a `[]S_IGNAL`-like raise) and catching errors (`t_ry`) | Check | a check is a line of text (`ok` / `FAIL: ...`); `k:r_eport` counts the failures; nothing stops |
| X4 | open | feature | Character codes: `[]U_CS` (and the quad values `[]A`, `[]D`), decided (QD2, QD3) but not implemented in the vendored X_eTaL | Strings (`u_pper`, `l_ower`) | map through two alphabet strings with `i_ndexOf`; ASCII letters only |
| X5 | open | bug | An empty Char vector is drawn with the numbers mark `~` (`d_isplay ""`, and the empty piece of `"," t:s_plit "a,,b"`); APL2 marks characters with a plain line | Strings (pages and goldens show it) | none: noted on the page |
| X6 | open | feature | Big whole numbers (or exact rationals): Ints overflow at 64 bits (`-1 t_ake n:f_ib 93` is `error[integer-overflow]`); on the upstream wish list | Numbers (and Combinatorics next) | compute in Floats where a polymorphic function allows (`0.0 + n:f_ib 100`), losing exactness |
| X7 | open | feature | Transpose (`o_\`, reserved and planned upstream) and matrix divide (APL's domino) | Matrix, Combinatorics | Matrix and Combinatorics transpose by `(r_ev s_hape m) r_eshape r_avel_2 m`; Matrix solves by Gauss-Jordan in X_eTaL |

Asks already filed by the sibling repos
(`../X_eTaL-demos/docs/xetal-asks.md`,
`../X_eTaL-games/docs/xetal-asks.md`) that a library also hits are
copied here with the library named, so this list stands on its own.

## Details

### X1: `.xtlm` macro libraries

X_eTaL has one macro, `u_se<`, built into the macro phase (MC1-MC9);
users cannot define macros. The design this repo plans against is
`docs/research.txt`'s, as X_eTaL is settling it (MC10, being written
upstream; plan A9):

- A file with the extension `.xtlm` is a macro library. It defines
  macros under `m:` with the macro suffix: `m:u_nless< := { cond body
  -> ... }`. A macro is an ordinary X_eTaL function of the source
  text written left and right of the call (two strings) whose result,
  a string of X_eTaL source, replaces the call and goes back through
  the parser.
- `"x:" u_se< "Control"` finds `Control.xtlm` as it finds
  `Control.xtl` (MC4); the macro library is compiled and run before
  the importing file is expanded, so a file never uses a macro it
  defines itself.
- A call is written like a dyadic function with the macro suffix,
  under the importer's alias: `"n = 0" x:u_nless< "100 / n"`.
  `u_` stays X_eTaL's own: `u_se<` built in, and `u_if<` / `u_each<`
  planned as X_eTaL's standard macro library (research.txt).
- Expansion is recursive but bounded (for example 32 levels), and
  errors point at both the call and the macro's definition.

Minimal example of what should work:

```
# Control.xtlm
m:u_nless< := { cond body -> "{ @ -> (" c_at cond c_at ") ? 0.0; " c_at body c_at " } @" }
```

```
# program.xtl
"x:" u_se< "Control"
n := 4
"n = 0" x:u_nless< "100 / n"     # expands to { @ -> (n = 0) ? 0.0; 100 / n } @, which is 25.0
```

Today: `x:u_nless<` is `error: unknown macro` (MC8 row 14) and a
`.xtlm` file is not looked for.

Workaround: none. The macro libraries are not emulated with functions
(a function cannot choose what source is compiled); they wait in
saga 4.

### X2: seeing expansions

For a teaching language, macro expansion should be visible: `xetal
--expand FILE` printing the program after expansion (and perhaps
`--expand-macro FILE:LINE`, the call, its expansion and where the
macro is defined). Needed to test macro libraries by golden
(the expansion, not only the result).

### X3: assertions and errors of one's own

A program cannot stop with an error it chooses, nor catch one: the
only errors are the interpreter's (`error[domain]`, `error[index]`,
...), and every one ends the program. A test library would like
`k:a_ssert c "message"` to stop with that message (and a non-zero
exit status, so a script or CI fails), and a program would like to
recover from a failing `[]N_GET`. The upstream wish list has both
("Error handling", "Tests in XeTaL").

Minimal example of what should work (spelling to be decided
upstream):

```
"k:" u_se< "Check"
k:a_ssert 6 = '+ r_/ 1 2 3      # nothing
k:a_ssert 5 = '+ r_/ 1 2 3      # error[assert]: ..., exit status 1
```

Workaround in Check: a check is a value, the line `ok` or `FAIL:
expected ..., got ...`; `k:r_eport` adds a summary and `k:p_assed?`
says whether all passed. Tests here are goldens, so a `FAIL` line
still fails `just test`.

### X4: character codes

`[]U_CS "A"` (65) and `[]U_CS 65` (`"A"`), with `[]A` and `[]D`, are
decided in lang-choices (QD2, QD3) and planned in X_eTaL's quads saga,
but the vendored X_eTaL answers `error[unknown-builtin]: there is no
built-in []U_CS`. Strings needs them for case conversion beyond ASCII
(and for character classes such as digits and letters).

Workaround: `t:u_pper` and `t:l_ower` map each character through the
strings `"abc...z"` and `"ABC...Z"` with `i_ndexOf`; other characters
are unchanged. Removed when X4 lands (and, if `[]U_CS` handles
Unicode case, the limit is lifted).

### X5: an empty Char vector is drawn as numbers

```
      d_isplay ""
.O.
| |
'~'
```

APL2's DISPLAY marks a character array with a plain bottom line and
numbers with `~`; an empty Char vector should draw as `.O.`, `| |`,
`'-'`. Seen in Strings' split results (`"," t:s_plit "a,,c"`), where
the empty piece looks like an empty number vector. The value is
right (its type is `Char`); only the picture is wrong.

Workaround: none; the page says so.

