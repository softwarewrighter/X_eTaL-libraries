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
| X1 | open | feature | `.xtlm` macro libraries: user-defined macros, `(String, String) -> String`, imported with `u_se<` and invoked as `"l" a:n_ame< "r"` | Control, Assert (saga 4) | none: those libraries wait (plan A9, saga 4) |
| X2 | open | feature | `xetal --expand FILE`: the source after macro expansion, and a bounded expansion depth | Control, Assert | none: waits with X1 |

Asks already filed by the sibling repos
(`../X_eTaL-demos/docs/xetal-asks.md`,
`../X_eTaL-games/docs/xetal-asks.md`) that a library also hits are
copied here with the library named, so this list stands on its own.

## Details

### X1: `.xtlm` macro libraries

X_eTaL has one macro, `u_se<`, built into the macro phase (MC1-MC9);
users cannot define macros. The design this repo plans against
(`docs/research.txt`, plan A9):

- A file with the extension `.xtlm` is a macro library. Its `l:`
  functions are ordinary X_eTaL functions read as macros: the left
  and right arguments are the source text written at the call (two
  strings), and the result is a string of X_eTaL source that replaces
  the call and goes back through the parser.
- `"x:" u_se< "Control"` finds `Control.xtlm` as it finds
  `Control.xtl` (MC4); the macro library is compiled and run before
  the importing file is expanded, so a file never uses a macro it
  defines itself.
- A call is written like a dyadic function with the macro suffix:
  `"n = 0" x:u_nless< "p_rint! 100 / n"`. `u_` stays reserved for the
  built-in macros.
- Expansion is recursive but bounded (for example 32 levels), and
  errors point at both the call and the macro's definition.

Minimal example of what should work:

```
# Control.xtlm
l:u_nless := { cond body -> "{ @ -> (" c_at cond c_at ") ? @; " c_at body c_at " } @" }
```

```
# program.xtl
"x:" u_se< "Control"
n := 4
"n = 0" x:u_nless< "p_rint! 100 / n"     # prints 25.0
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
