# Control: the first macro library, ready to ship

Control is X_eTaL-libraries' first macro library: new control syntax
written in X_eTaL itself. It proves the "Extensible" in X_eTaL's name
the way the ordinary libraries prove the rest. It waits for X_eTaL to
run `.xtlm` files (ask X1, X_eTaL's Saga 19); this page and
`docs/control/` hold everything needed to ship it the day that lands.

## Superseded in part: X_eTaL's system macros (2026-10-03)

X_eTaL's macros lane, step 1 (5c0319f, not yet vendored), made
research.txt's three macros built-in system macros, with no import
(MC14-MC17): `"c" i_f< "a; b"` (the same expansion as `x:i_f<` below),
`"c" u_nless< "b"` (statements run unless `c`, value `@`: not the
`then ; else` form below) and `"w1 w2" e_ach< "template"` (with `$w`,
not `#`), and `xetal expand` (ask X2). User macro libraries (`.xtlm`,
ask X1) are still to come.

So Control as written below would only repeat the system macros
under an alias. Proposed instead (for the user to confirm): Control
keeps the role of the first user-written macro library, with macros
X_eTaL does not have, shown beside the system ones:

| Macro | Call | Expands to |
| ----- | ---- | ---------- |
| `x:c_ase<` | `"x" x:c_ase< "0: \"zero\"; 1: \"one\"; \"many\""` | `{ @ -> (x) = 0 ? "zero"; (x) = 1 ? "one"; "many" } @`: a multi-way choice on one value |
| `x:w_hen<` | `"c" x:w_hen< "b"` | `{ @ -> n_ot (c) ? @; b; @ } @`: the dual of the system `u_nless<` |
| `x:l_et<` | `"a := 2; b := 3" x:l_et< "a * b"` | `{ @ -> a := 2; b := 3; a * b } @`: bindings local to one expression |

The bodies stay tested by `docs/control/check.sh` the same way; the
three cases of `i_f<`, `u_nless<` and `e_ach<` move to checking that
the system macros expand as this page expected.

## The library (first design, superseded in part)

[`docs/control/Control.xtlm`](control/Control.xtlm) is the source,
as it will be in `libs/Control/src/`. Under X_eTaL's MC10 a macro is
an `m:` name ending in `<`: a function from the source text written
left and right of the call (two strings) to the source that replaces
the call.

| Macro | Call | Expands to |
| ----- | ---- | ---------- |
| `x:i_f<` | `"cond" x:i_f< "then ; else"` | `{ @ -> (cond) ? then; else } @` |
| `x:u_nless<` | `"cond" x:u_nless< "then ; else"` | `{ @ -> (cond) ? else; then } @` |
| `x:e_ach<` | `"a b c" x:e_ach< "template"` | the template once per word, `#` replaced by it, a line each |

A guard inside a lambda (X_eTaL's G1) evaluates only the branch
chosen, so `x:i_f<` is a real conditional, not a function of two
evaluated values. `x:e_ach<` writes a family of definitions once:
`"2 3 10" x:e_ach< "u:t_imes# := { _r * # }"` defines `u:t_imes2`,
`u:t_imes3` and `u:t_imes10`.

## Tested today

[`docs/control/check.sh`](control/check.sh) runs in the gate. A macro
body is an ordinary function from text to text, so it loads
`Control.xtlm` as a plain library (`m:name< :=` read as `l:name :=`),
calls each macro on its example texts, compares the expansion with
the expected one, then runs the expansion as X_eTaL and compares the
result:

| Case | Call | Result |
| ---- | ---- | ------ |
| if-true | `"n = 4" x:i_f< "10 ; 20"` with `n := 4` | 10 |
| if-false | `"n = 0" x:i_f< "0.0 ; 100 / n"` with `n := 4` | 25.0 |
| unless | `"n = 0" x:u_nless< "100 / n ; 0.0"` with `n := 4` | 25.0 |
| if-lazy | `"n = 0" x:i_f< "0 ; 1 d_iv n"` with `n := 0` | 0 (the division never runs) |
| each | `"2 3 10" x:e_ach< "u:t_imes# := { _r * # }"`, then `u:t_imes10 u:t_imes3 7` | 210 |

Nothing here gives users macro syntax: the macros are not emulated
(plan A9), only their bodies are tested.

## The day `.xtlm` lands

1. `just upstream` and `just asks-upstream` show X1 fixed; refresh the
   vendor (its own commit), run X1's repro.
2. Move `docs/control/Control.xtlm` to `libs/Control/src/` (no edits
   expected); `libs/Control/` gets its README, page, demo and tests.
3. Tests: the cases above as reg-rs baselines of real calls; the
   expansions themselves as baselines once X_eTaL's expand tool (ask
   X2) exists.
4. The live demo: `.xtlm` files in its store, so a program in the
   browser can import Control; show an expansion beside the program.
5. README and the landing page: Control moves from "coming" to ready;
   the three ways X_eTaL extends now all have a live example.

## Drafts

The demo, `libs/Control/demos/guards.xtl`:

```
"x:" u_se< "Control"
balance := 120
withdraw := 150
"withdraw <= balance" x:i_f< "balance - withdraw ; balance"   # 120: refused
"0 > n_eg withdraw" x:u_nless< "0 ; withdraw"                 # 150
"2 3 10" x:e_ach< "u:t_imes# := { _r * # }"                    # three definitions
u:t_imes10 u:t_imes3 7                                         # 210
```

The page's first lines: "Control: control syntax as a macro library.
Its three macros are functions from source text to source text,
written in X_eTaL, run before your program is parsed."

## Test, the second macro library (sketch)

`Test.xtlm` turns a check into a line that reads as the code it
checks, built on Check: `"'+ r_/ 1 2 3" test:e_xpect< "6"` expands to
`"'+ r_/ 1 2 3" k:t_est 6 k:i_s '+ r_/ 1 2 3`, so the report names the
expression it checked without writing it twice. Its open question for
when X1 lands: whether a macro library may import a library (Check)
that its expansions use under the importer's alias.
