## Saga 12 -- equations (in progress)

The user (2026-10-16): the spatial-equations library moves here from
`../X_eTaL` (its Saga 41 decided the design; the user chose this
repository and named it `Equations`). A sum as an ML paper prints it,
written in one macro call, gives the array computation, its LaTeX or
both; a library on the language as it is, with no compiler change.
The design is X_eTaL's: `../X_eTaL/docs/spatial.md` (the call, the
lowering, the errors, the expected outputs), `docs/eq-rationale.md`
(why per-sum bindings), `docs/type-check-macros.md` (what a macro must
check), decision D154. The proof of concept, 142 lines that already
lower correctly, is `../X_eTaL/docs/spatial-poc/Spatial.xtlm`.

```
"e:" u_se< "Equations"
Y := "Y[o,h,w] | O Ho Wo" e:q_< "sum c:=0..C - 1, sum r:=0..Kh - 1, sum s:=0..Kw - 1 | X[c,h+r,w+s] * W[o,c,r,s]"
```

`e:q_<` gives the value, `e:t_ex<` the LaTeX, `e:b_oth<` the pair.
A macro is warranted (CLAUDE.md "Macros"): it reads an embedded
language (the equation) and checks it when the program is compiled.
Later: the left-to-right pipeline macro goes to `../X_eTaL-ML` (it
needs `nn:` functions), integrals and numerical methods follow
(`../X_eTaL/docs/convolutions/integrals.md`), and a future
X_eTaL-Math repository may take this library over.

| Step | Slug | Content |
| ---- | ---- | ------- |
| 1 | equations-pin | XETAL_COMMIT to X_eTaL main (`just bump`: `[]G_ENSYM`, raw strings, bound-once names), its own commit, every golden and pinned type re-run |
| 2 | equations-oracle | `libs/Equations` from the template; the independent oracle (valid cross-correlation by rotations, a transpose and one inner product) as a test program; fixtures A (all ones: 8 everywhere, shape 1 3 3), B (560 596 632 / 704 740 776 / 848 884 920) and C (2 output channels, 3 input channels, a 2 by 3 kernel on 5 by 6 pictures: shape 2 4 4) as goldens |
| 3 | equations-capture | `Equations.xtlm` parses the call: the left's result, free indices and extents; each sum's operator word, index and inclusive range; the summand with math precedence; `[]R_EJECT` at the argument for every malformed call (a range without `..`, an index bound twice, a summand index neither summed nor free, a free index without an extent, two indices for a rank-3 array where the rank is written); rejection goldens first |
| 4 | equations-lowering | `e:q_<`: coordinate grids, a gather per array reference by Horner's rule with a bounds check per axis (`error[index]` naming the array, axis, index and expression), one reduction per sum; fresh names by `[]G_ENSYM`; equal to the oracle on A, B and C; `xetal expand` goldens |
| 5 | equations-latex | `e:t_ex<` and `e:b_oth<` from the same parse; LaTeX goldens; the library's README, docs page, a demo (the CNN layer), the catalog row; publish |

