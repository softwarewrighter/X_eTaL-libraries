# Control: the first user macro library, ready to ship

Control is X_eTaL-libraries' first macro library: control syntax
written in X_eTaL itself, by a user, as a library. It waits for X_eTaL
to run `.xtlm` files (ask X1); this page and `docs/control/` hold
everything needed to ship it the day that lands.

X_eTaL now has three system macros of its own, built in (MC14-MC17,
vendored 5dccb9b): `"c" i_f< "a; b"`, `"c" u_nless< "b"` and `"w1 w2"
e_ach< "template with $w"`, and `xetal expand` to see any expansion.
Control adds the ones X_eTaL does not have, written the way any user
would write a macro.

## The library

[`docs/control/Control.xtlm`](control/Control.xtlm) is the source,
as it will be in `libs/Control/src/`. Under X_eTaL's MC10 a macro is
an `m:` name ending in `<`: a function from the source text written
left and right of the call (two strings) to the source that replaces
the call.

| Macro | Call | Expands to |
| ----- | ---- | ---------- |
| `x:c_ase<` | `"n" x:c_ase< "0: \"zero\"; 1: \"one\"; \"many\""` | `{ @ -> caseSubject := (n); caseSubject m_atch (0) ? "zero"; caseSubject m_atch (1) ? "one"; "many" } @` |
| `x:w_hen<` | `"n > 2" x:w_hen< "p_rint! 7"` | `{ @ -> n_ot (n > 2) ? @; p_rint! 7; @ } @` |
| `x:l_et<` | `"a := 2; b := 3" x:l_et< "a * b"` | `{ @ -> a := 2; b := 3; a * b } @` |

- `x:c_ase<`: a multi-way choice on one value. The subject is
  evaluated once; values are matched with `m_atch`, so numbers,
  characters and texts all work; the last clause, without a colon, is
  the default.
- `x:w_hen<`: run statements when a condition holds; its value is `@`
  either way, the dual of the system `u_nless<`.
- `x:l_et<`: bindings local to one expression.

## Types: checked when the program is compiled

A macro only writes source. X_eTaL expands macros before it reads
names and types, so an expansion is type-checked with the rest of the
program, before anything runs, exactly as if it had been typed by
hand: the branches of `x:c_ase<` must share one type, a binding's type
is inferred, a name used outside `x:l_et<` is not defined. A malformed
call expands to code that fails that check: `x:c_ase<` without a
default names `noDefaultInCase`, which does not exist. Nothing is
left to run time that the type checker can see; what only running can
tell (which branch a value chooses) is decided by guards, as in code
written by hand. The macros themselves are checked too: as plain
functions their types are text to text (`Char -> Char -> Char`), and
X_eTaL plans to check each `.xtlm` macro's type when it loads one.

## Tested today

[`docs/control/check.sh`](control/check.sh) runs in the gate. A macro
body is an ordinary function from text to text, so it loads
`Control.xtlm` as a plain library (`m:name< :=` read as `l:name :=`),
calls each macro on its example texts, compares the expansion with
the expected one, then runs the expansion as X_eTaL:

| Case | Shows |
| ---- | ----- |
| case-number, case-text | a choice on a number and on a text |
| case-once | the subject evaluated once (`p_rint! 2` prints once) |
| case-types | branches of two types: a type error before anything runs |
| case-no-default | no default: an error at compile time, nothing runs |
| when-true, when-false | statements run, or not; the value `@` |
| let, let-local | local bindings; a binding used outside: a compile-time error |
| system i_f, u_nless, e_ach | X_eTaL's own macros expand as this page says (`xetal expand`) |

Nothing here gives users macro syntax: the macros are not emulated
(plan A9), only their bodies are tested.

## The day `.xtlm` lands

1. `just upstream` and `just asks-upstream` show X1 fixed; refresh the
   vendor (its own commit), run X1's repro.
2. Move `docs/control/Control.xtlm` to `libs/Control/src/` (no edits
   expected); `libs/Control/` gets its README, page, demo and tests.
3. Tests: the cases above as reg-rs baselines of real calls, and each
   expansion as a baseline of `xetal expand`.
4. The live demo: `.xtlm` files in its store, so a program in the
   browser can import Control (its Expand button already shows the
   expansion of the system macros, and will show Control's).
5. README and the landing page: Control moves from "coming" to ready.

## Drafts

The demo, `libs/Control/demos/shop.xtl`:

```
"x:" u_se< "Control"
item := "pear"
"item" x:c_ase< "\"apple\": 0.5; \"pear\": 0.75; 1.0"    # 0.75
stock := 3
"stock < 5" x:w_hen< "p_rint! \"reorder\""                # reorder, then @
"price := 0.75; qty := 12" x:l_et< "price * f_loat qty"  # 9.0
```

## Test, the second macro library (sketch)

`Test.xtlm` turns a check into a line that reads as the code it
checks, built on Check: `"'+ r_/ 1 2 3" test:e_xpect< "6"` expands to
`"'+ r_/ 1 2 3" k:t_est 6 k:i_s '+ r_/ 1 2 3`, so the report names the
expression it checked without writing it twice. Its open question for
when X1 lands: whether a macro library may import a library (Check)
that its expansions use under the importer's alias.
