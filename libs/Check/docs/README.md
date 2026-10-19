# Check

Assertions that report as text, for tests and teaching. A check is a
line, `ok` or `FAIL: ...` with what was expected and what came; it
prints when written as a statement, and checks join into a report
with a count of failures.

```
"ch:" u_se< "Check"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `ch:` is the recommended alias.

X_eTaL has no assertion that stops a program and no way to catch an
error yet, so a failed check does not stop anything: it is a value
(the line), and the report counts the lines that start with `FAIL`.
See ask X3 in [`docs/xetal-asks.md`](../../../docs/xetal-asks.md).

## Functions

| Function | Type | What |
| -------- | ---- | ---- |
| `want ch:i_s got` | `Eq a => a -> a -> Char` | ok when `got` has `want`'s shape and items (`m_atch`) |
| `want ch:n_ear got` | `Num a => a -> a -> Char` | ok when the shapes match and every item is equal within `e_q~`'s relative tolerance, or within 1e-12 (so a computed `1e-17` is near an exact 0) |
| `ch:t_rue c` | `Truthy a => a -> Char` | ok when every item of the condition is true |
| `name ch:t_est line` | `Char -> Char -> Char` | the check's line, named: `ok: name` or `FAIL: name: ...` |
| `a ch:a_nd b` | `Char -> Char -> Char` | two checks (or reports) as one text, a line each |
| `ch:c_ount t` | `Char -> Int` | how many checks a text holds (its lines) |
| `ch:f_ailures t` | `Char -> Int` | how many of them failed (lines starting `FAIL`) |
| `ch:p_assed? t` | `Truthy a => Char -> a` | whether every check passed |
| `ch:r_eport t` | `Char -> Char` | the checks, then a summary line |

Both sides of `ch:i_s` must have the same type: `1 ch:i_s "1"` is a type
error before anything runs, not a failed check. In a message a value
is shown on one line, its rows separated by `;`; a value longer than
60 characters is shown by its start and its shape:

```
      (r_ange 100) ch:i_s r_ange 101
FAIL: expected 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19  ... (shape 100), got 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19  ... (shape 101)
```

## Examples

From `../tests/basics.xtl`:

```
      6 ch:i_s '+ r_/ 1 2 3
ok
      5 ch:i_s '+ r_/ 1 2 3
FAIL: expected 5, got 6
      (2 2 r_eshape 1) ch:i_s 2 2 r_eshape 2
FAIL: expected 1 1;1 1, got 2 2;2 2
      0.3 ch:n_ear 0.1 + 0.2
ok
      0.3 ch:i_s 0.1 + 0.2
FAIL: expected 0.3, got 0.30000000000000004
      ch:t_rue 1 > 1 2
FAIL: expected true, got 0 0
      "sum" ch:t_est 5 ch:i_s '+ r_/ 1 2 3
FAIL: sum: expected 5, got 6
```

From `../tests/report.xtl`:

```
      a := "sum" ch:t_est 6 ch:i_s '+ r_/ 1 2 3
      bad := "sort" ch:t_est 1 2 3 ch:i_s s_ort 3 1 2 0
      c := "mean" ch:t_est 2 ch:n_ear ('+ r_/ 1 2 3) / 3
      ch:r_eport a ch:a_nd bad ch:a_nd c
ok: sum
FAIL: sort: expected 1 2 3, got 0 1 2 3
ok: mean
3 checks, 1 FAILED
      ch:p_assed? bad
0
```

Read right to left, `"sum" ch:t_est 5 ch:i_s '+ r_/ 1 2 3` is the sum,
checked against 5, named "sum"; `a ch:a_nd b ch:a_nd c` joins three
lines.

## Demos

- [`demos/grading.xtl`](../demos/grading.xtl): a student's median graded by four checks; the even-count case fails, as it should (`just demo Check`).

## Macros

`src/Check.xtlm` beside the functions holds one macro, imported with
them under the same alias. It solves a problem a function cannot:

| Macro | Call | What it does when the program is compiled |
| ----- | ---- | ---------------------------------------- |
| `ch:c_ases<` | `c"u:c_lamp" ch:c_ases< "5 -> 5; -3 -> 0; 42 -> 10"` | writes one check per row, each named by its own source text |

A function sees values, never the text that produced them, so
`ch:t_est` needs every check named by hand. `ch:c_ases<` reads the
table's text: each row is the function applied to an input and
compared with the expected value, and its line names the case as
written (`ok: u:c_lamp 5`, `FAIL: u:c_lamp 11: expected 11, got 10`).
The expected and actual values must share a type: a mismatch is a
type error before anything runs. A row without `->` stops the
compiler at the call (`error[bad-cases]`). The call stands as a
statement of its own. The demo [`demos/table.xtl`](../demos/table.xtl)
uses it (`just demo Check table`, or in the live demo, where Expand
shows what it becomes); `../tests/badcases.xtl` and
`../tests/casetypes.xtl` show the compile-time errors.

## Provenance

The shape of an xUnit assertion (expected first, then actual, as
JUnit's `assertEquals`), reporting as text in the way J's test
scripts and APL test workspaces print their results. Written for
X_eTaL-libraries.
