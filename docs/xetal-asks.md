# Asks for X_eTaL

Features the libraries need that X_eTaL does not have yet, and bugs
the libraries uncovered. This repo does not change X_eTaL: each ask is
filed here (and taken to `../X_eTaL`), the library uses the workaround
noted below or waits, and the workaround is removed when the ask
lands in the known-good commit (`XETAL_COMMIT`, now 512b3ee, X_eTaL v0.1.0).

Each entry: status (open, filed, landed, dropped), kind (feature, bug
or speed), which library or libraries need it, why, a minimal repro
or example, and the workaround in use.

| # | Status | Kind | Ask | Libraries | Workaround |
| - | ------ | ---- | --- | --------- | ---------- |
| X1 | landed (6239aad, vendored) | feature | `.xtlm` macro libraries: user-defined macros `m:n_ame< := ...`, `(String, String) -> String`, imported with `u_se<` and invoked as `"l" x:n_ame< "r"` (decided upstream as MC10 and MC11, not yet implemented) | Control (`i_f<`, `u_nless<`, `e_ach<`), Test (saga 4) | none: those libraries wait (plan A9, saga 4) |
| X2 | landed (5c0319f, vendored 5dccb9b) | feature | `xetal --expand FILE`: the source after macro expansion, and a bounded expansion depth (X_eTaL now has `xetal expand`, with the system macros of MC14-MC17) | the domain macros' expansions (`just macros`) | none needed |
| X3 | landed (`p_anic<`, `a_ssert<` in 4abe761; catching in v0.1.0: `[]S_IGNAL`, `[]T_RAP`, `[]R_ECOVER`) | feature | Stopping with an error of one's own (an `a_ssert`, or a `[]S_IGNAL`-like raise) and catching errors (`t_ry`) | Check | none needed: Check keeps its lines by choice (goldens read them; a check that stops would hide the ones after it) |
| X4 | landed (512b3ee, v0.1.0: `[]U_CS`, `[]U_CHAR` for codes 0 to 127, `[]A`, `[]D`, `[]TS`) | feature | Character codes: `[]U_CS` (and the quad values `[]A`, `[]D`, `[]TS`), decided (QD2, QD3) but not implemented in the vendored X_eTaL | Strings (`u_pper`, `l_ower`), Dates (no today without `[]TS`) | removed: case by `[]U_CS`/`[]U_CHAR` (ASCII still, X16) |
| X5 | landed (d8b32e6) | bug | An empty Char vector is drawn with the numbers mark `~` (`d_isplay ""`, and the empty piece of `"," t:s_plit "a,,b"`); APL2 marks characters with a plain line | Strings (pages and goldens show it) | none: noted on the page |
| X6 | open | feature | Big whole numbers (or exact rationals): Ints overflow at 64 bits (`-1 t_ake n:f_ib 93` is `error[integer-overflow]`); on the upstream wish list | Numbers (and Combinatorics next) | compute in Floats where a polymorphic function allows (`0.0 + n:f_ib 100`), losing exactness |
| X7 | open | feature | Matrix divide (APL's domino); transpose landed (`o_\`, vendored 8eb3de2) | Matrix | Matrix solves by Gauss-Jordan in X_eTaL; its own transpose and Combinatorics' were replaced by `o_\` |
| X8 | open | feature | Number formatting with width and precision (APL's dyadic format; on the upstream wish list) | Format | Format builds the text from the digits (`f:f_ixed`, `f:a_mount`) |
| X9 | landed (512b3ee, v0.1.0: `d_ecode` is `Num a => a -> a -> a`, Horner on any numbers) | feature | `d_ecode` (and `e_ncode`) on Floats: APL's decode is Horner's rule for any numbers (`2.0 d_ecode 3 -2 1` is a type error today) | Polynomials | removed: `py:a_t` decodes (Horner) |
| X10 | landed (081fb3f) | bug | A comparison bound to a top-level name cannot be used in arithmetic (`up := 1 -2 3 > 0` then `up * 10` is a type error; inline, or inside a function, it works), though T1 says a Bool converts to Int in arithmetic. Also filed by X_eTaL-demos and X_eTaL-ML (M9) | Lists (the temperatures demo) | none now: the demo multiplies by the mask again |
| X11 | landed (4abe761: `@ c_fg< "cli"`, `@ i_nclude< "file"`, `--cfg NAME`) | feature | What a macro may know while it expands (the platform, flags) and an include macro (Rust's `cfg!`, `env!`, `include_str!`): conditional compilation | conditional compilation (docs/macros.md) | none: waits |
| X12 | landed (6239aad, vendored) | feature | A macro call with nothing on the left: `@ d_bg< "x"` or `d_bg< "x"` (today `bad-macro-call`) | the proposed `d_bg<` | `""` on the left |
| X13 | landed (6239aad, vendored) | feature | A macro reporting its own compile error at the call, with its own message (Rust's `compile_error!`) | Dates `d_ate<`, Polynomials `p_oly<`, Graphs `g_raph<` | expand to an undefined name that says what is wrong (`noSuchDate20260230`, `notAPolynomial`, `notAGraph`) |
| X14 | landed (6239aad, vendored; MC23: a `.xtlm` imports its own `.xtl` by path); the expansion still cannot name the importer's alias | feature | A `.xtlm` calling its own library's functions, or naming the importer's alias in its expansion (on the lane, `l:` in a `.xtlm` is refused and importing itself is a cycle) | Dates `d_ate<` (repeats the day arithmetic) | macros write self-contained code; logic repeated privately |
| X15 | open | bug | An error a macro reports with `[]R_EJECT` is located by byte range only (`error[bad-date]: ... at 199..211`), where other errors name the file, line and column (`impossible.xtl:6:13`) | Dates, Polynomials, Graphs macros | none: the message names the bad text |
| X16 | open | feature | `[]U_CHAR` beyond ASCII: it takes codes 0 to 127 (`[]U_CHAR 200` is `error[domain]`), so text outside ASCII cannot be made from codes, nor its case changed | Strings (`u_pper`, `l_ower`) | case for ASCII letters only (by code since v0.1.0) |
| X17 | open | question | A comparison's result has an open numeric type in v0.1.0 (`(Num b, Truthy b)`), so an export built on one infers a result type the caller must fix: Bits' `a_nd` (`2 d_ecode (c_ols a) & c_ols b`) became `(Num a, Truthy a) => Int -> Int -> a` | Bits | Int arithmetic on the 0/1 digits (`m_in`, `m_ax`, `a_bs` of the difference): `Int -> Int -> Int` |
| X18 | open | bug | A library that does not lex or parse is reported as exporting nothing (`library-exports-nothing`, PN4) by `u_se<`, hiding the real error (`bad-string`, `adjacent-values`, ...) and its place; seen at d8b32e6 while extending Plot | any library being edited | `xetal type libs/Name/src/Name.xtl` shows the real error |

## Promotion blockers (research4)

Re-audited 2026-10-03 by running every ask's repro (`scripts/asks.sh`,
and `scripts/asks.sh --upstream` against X_eTaL's committed HEAD built
from a snapshot): at release 3 (vendored 081fb3f) X10 has landed and
every other ask is still open.

| Priority | Asks | Why |
| -------- | ---- | --- |
| P0, launch gate | X1 and X2 landed (vendored 6239aad) | `.xtlm` and seeing expansions: the proof of "Extensible"; three repos wait (here Control and Test; X_eTaL-ML M1, a network macro; X_eTaL-extensions E2, binding macros) |
| P0, correctness | X5 landed (an empty text keeps its kind, X_eTaL T9) | X10 (a bound mask refusing arithmetic) landed in 081fb3f |
| after launch | X6, X7, X8 | features with working workarounds here (Floats, elimination, digit-built formatting); X3, X4 and X9 landed in v0.1.0 |

 (`just upstream` reports it from
`../X_eTaL`: its saga queue, and signs of each feature in its
committed code and in the vendored copy; checked at each saga start
and step):

| Ask | Upstream saga | Queue position (2026-10-03, release 2) |
| --- | ------------- | --------------------------- |
| X1, X2 | Saga 19, macros (9 steps: long prefixes, `.xtlm` lookup, macro calls, the engine, the expand tool, examples, user macros, retrofit, release) | 5th: after Saga 30 (a speed regression), 25 (the terminal, active) and 28 (the course) |
| X3 | Saga 21, errors of one's own | landed (v0.1.0) |
| X4 | Saga 13, quads | landed (v0.1.0) |
| X5 | Saga 20, array kinds (empty arrays remember their kind) | 8th |
| X6, X8 | the wish list (no saga) | -- |
| X9 | decided as B18 | landed (v0.1.0) |
| X7 | none (transpose landed; matrix divide not planned) | -- |

Asks already filed by the sibling repos
(`../X_eTaL-demos/docs/xetal-asks.md`,
`../X_eTaL-games/docs/xetal-asks.md`) that a library also hits are
copied here with the library named, so this list stands on its own.

## Details

### X1: `.xtlm` macro libraries

X_eTaL has one macro, `u_se<`, built into the macro phase (MC1-MC9);
users cannot define macros. The design this repo plans against is
`docs/research.txt`'s, as X_eTaL decided it (MC10 and MC11 in
`../X_eTaL/docs/lang-choices.md`, 2026-10-02, not yet implemented;
plan A9):

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
  `u_` stays X_eTaL's own system macros (`u_se<`); research.txt's
  `u_if<` and `u_each<` live here as the Control library's `x:i_f<`
  and `x:e_ach<`.
- `"x:" u_se< "Control"` loads `Control.xtl` and `Control.xtlm` from
  the same directory together, under the one alias (MC11): functions
  as `x:f_`, macros as `x:f_<`. A library here keeps both in its
  `src/`.
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
are unchanged. Removed when X4 landed (v0.1.0): case is now by code,
`[]U_CS` and `[]U_CHAR`; the ASCII limit stays (X16).

### X5: an empty Char vector is drawn as numbers (landed)

Landed in X_eTaL Saga 20 (T9, empty arrays keep their kind); seen here
when XETAL_COMMIT moved to d8b32e6, and the goldens re-blessed.

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

### X16: `[]U_CHAR` beyond ASCII

```
      []U_CHAR 72 105
Hi
      []U_CHAR 233
error[domain]: []U_CHAR takes codes 0 to 127, got 233
```

Strings changes case by code (`[]U_CS`, the two cases 32 apart), so
it covers ASCII letters only; an e with an acute accent (code 233) stays as it is. Wanted: codes of
all of Unicode, and ideally case mapping as a built-in (Unicode case
is not a fixed offset).

### X17: an open numeric type from a comparison

```
"b:" u_se< "Bits"
# Before (4abe761): l:a_nd : Int -> Int -> Int
# v0.1.0, the same source:
l:a_nd := { a b -> 2 d_ecode (c_ols a + 0 * b) & c_ols b + 0 * a }
# l:a_nd : (Num a, Truthy a) => Int -> Int -> a
```

A comparison (or `&`, `|`) now gives a number of any type the context
wants, and `d_ecode` (now on any numbers, X9) passes that type
through, so the export's result type is free: the caller fixes it.
Values are right; only the pinned interface widened. A question for
X_eTaL: is a free result type intended for library exports, or
should the type default to Int (as a literal does)?

Workaround in Bits: `m_in`, `m_ax` and `a_bs` of the difference on
the 0/1 digits (Int arithmetic), so the types stay `Int -> Int -> Int`.

### X18: a library that does not parse "exports nothing"

```
# Bad.xtl
l:f_ := { x -> "\q" }
# use.xtl
"b:" u_se< "Bad"
b:f_ 1
```

`xetal run use.xtl` says `error[library-exports-nothing]: library Bad
exports nothing; mark its exports with l:`, while `xetal type Bad.xtl`
gives the real error, `error[bad-string]: unknown escape` at 16..18.
The check that a library exports something (PN4) runs on a library
whose parse failed, and its error replaces the parse error. Expected:
the library's own error, with its file and place, as before PN4.
