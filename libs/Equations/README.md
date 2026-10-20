# Equations

equations as printed in papers, written in one macro call: `e:e_q<` gives the array computation, `e:t_ex<` its LaTeX, `e:b_oth<` both; where a program is drawn, a call is shown as one typeset math box after the macro's name (X_eTaL MC32); the CNN layer's cross-correlation checks them

```
"e:" u_se< "Equations"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the library, `Equations.xtl`, and its macro library, `Equations.xtlm` |
| [`docs/`](docs/README.md) | the reference: every function, its type, examples, provenance |
| [`demos/`](demos/) | programs that use it: `cnn.xtl`, one CNN layer as the paper writes it, its value and its LaTeX; `catalog.xtl`, ten ML equations checked against plain X_eTaL |
| [`tests/`](tests/) | reg-rs baselines: the test programs, the pinned export types (`types.rgt`) and the demos (`demo-*.rgt`) |

```bash
just demo Equations         # run its demos
just run Equations          # run its test programs
just test-lib Equations     # check every baseline
just tex Equations cnn      # the demo's equation drawn by KaTeX, in your browser
```
