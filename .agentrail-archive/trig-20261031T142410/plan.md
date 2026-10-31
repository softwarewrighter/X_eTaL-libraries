## Saga 18 -- trig (planned)

`../X_eTaL-ML/docs/xetal-libraries-asks.md` E4: a `Trig` library
(`tr:`) of what X_eTaL's builtins (`s_in`, `c_os`, `a_tan`, `e_xp`,
`l_og`, `p_i @`) leave out and a library can write in closed form:
`t_an`, `a_sin`, `a_cos`, `a_tan2` (the sign cases), `s_inh`, `c_osh`,
`t_anh`, `a_sinh`, `a_cosh`, `a_tanh`, `d_egrees`, `r_adians`,
`h_ypot`. Each with a doc example and a test against a known value,
the range and accuracy limits of each form stated on the page: `tanh`
built from `e_xp` cancels badly near 0 at the extremes, so it wraps
`u:t_anh`'s shape from `docs/xetal-asks.md` X22 (NN's workaround,
`2 s_igmoid(2x) - 1`, about 1e-6 relative error at 1e-10) until X22
lands a builtin, the day it wraps that instead (plan A7). What stays
in the base language versus a library here is the settled question in
the ask (2026-10-23): nothing leaves `s_in`, `c_os`, `a_tan`, `e_xp`,
`l_og`; everything derivable from them is a library.

| Step | Slug | Content |
| ---- | ---- | ------- |
| 1 | trig-scaffold | `libs/Trig` from the template; the header, recommended alias `tr:` (free: not `t:` Strings, `s:` Stats) |
| 2 | trig-circular | `t_an`, `a_sin`, `a_cos`, `a_tan2` (all four quadrant signs tested, including the axes); domain refusals where the builtins already refuse (`a_sin`/`a_cos` outside -1..1) documented, not re-implemented |
| 3 | trig-hyperbolic | `s_inh`, `c_osh`, `t_anh` (the X22 shape, cited above), `a_sinh`, `a_cosh`, `a_tanh`; each tested near 0 and near its domain edge for the stated accuracy |
| 4 | trig-units-and-ship | `d_egrees`, `r_adians`, `h_ypot`; demo, docs page, catalog row, README's library count |

