# Check

Assertions that report as text, for tests and teaching. A check is a
line, `ok` or `FAIL: ...` with what was expected and what came; it
prints when written as a statement, and checks join into a report
with a count of failures.

```
"k:" u_se< "Check"
```

Put this repository's `lib/` directory on `XETAL_PATH` (see the
[README](../../README.md)); `k:` is the recommended alias.

X_eTaL has no assertion that stops a program and no way to catch an
error yet, so a failed check does not stop anything: it is a value
(the line), and the report counts the lines that start with `FAIL`.
See ask X3 in [`docs/xetal-asks.md`](../xetal-asks.md).

## Functions

| Function | Type | What |
| -------- | ---- | ---- |
| `want k:i_s got` | `Eq a => a -> a -> Char` | ok when `got` has `want`'s shape and items (`m_atch`) |
| `want k:n_ear got` | `Num a => a -> a -> Char` | ok when the shapes match and every item is equal within `e_q~`'s tolerance |
| `k:t_rue c` | `Truthy a => a -> Char` | ok when every item of the condition is true |
| `name k:t_est line` | `Char -> Char -> Char` | the check's line, named: `ok: name` or `FAIL: name: ...` |
| `a k:a_nd b` | `Char -> Char -> Char` | two checks (or reports) as one text, a line each |
| `k:c_ount t` | `Char -> Int` | how many checks a text holds (its lines) |
| `k:f_ailures t` | `Char -> Int` | how many of them failed (lines starting `FAIL`) |
| `k:p_assed? t` | `Truthy a => Char -> a` | whether every check passed |
| `k:r_eport t` | `Char -> Char` | the checks, then a summary line |

Both sides of `k:i_s` must have the same type: `1 k:i_s "1"` is a type
error before anything runs, not a failed check. In a message a value
is shown on one line, its rows separated by `;`; a value longer than
60 characters is shown by its start and its shape:

```
      (r_ange 100) k:i_s r_ange 101
FAIL: expected 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19  ... (shape 100), got 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19  ... (shape 101)
```

## Examples

From `tests/Check/basics.xtl`:

```
      6 k:i_s '+ r_/ 1 2 3
ok
      5 k:i_s '+ r_/ 1 2 3
FAIL: expected 5, got 6
      (2 2 r_eshape 1) k:i_s 2 2 r_eshape 2
FAIL: expected 1 1;1 1, got 2 2;2 2
      0.3 k:n_ear 0.1 + 0.2
ok
      0.3 k:i_s 0.1 + 0.2
FAIL: expected 0.3, got 0.30000000000000004
      k:t_rue 1 > 1 2
FAIL: expected true, got 0 0
      "sum" k:t_est 5 k:i_s '+ r_/ 1 2 3
FAIL: sum: expected 5, got 6
```

From `tests/Check/report.xtl`:

```
      a := "sum" k:t_est 6 k:i_s '+ r_/ 1 2 3
      bad := "sort" k:t_est 1 2 3 k:i_s s_ort 3 1 2 0
      c := "mean" k:t_est 2 k:n_ear ('+ r_/ 1 2 3) / 3
      k:r_eport a k:a_nd bad k:a_nd c
ok: sum
FAIL: sort: expected 1 2 3, got 0 1 2 3
ok: mean
3 checks, 1 FAILED
      k:p_assed? bad
0
```

Read right to left, `"sum" k:t_est 5 k:i_s '+ r_/ 1 2 3` is the sum,
checked against 5, named "sum"; `a k:a_nd b k:a_nd c` joins three
lines.

## Provenance

The shape of an xUnit assertion (expected first, then actual, as
JUnit's `assertEquals`), reporting as text in the way J's test
scripts and APL test workspaces print their results. Written for
X_eTaL-libraries.
