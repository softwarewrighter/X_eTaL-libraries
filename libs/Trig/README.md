# Trig

Trigonometric and hyperbolic functions not in the base language: `t_an`, `a_sin`, `a_cos`, `a_tan2`, `s_inh`, `c_osh`, `a_sinh`, `a_cosh`, `a_tanh` (the hyperbolic tangent is the builtin `t_anh`).

```
"tr:" u_se< "Trig"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the library, `Trig.xtl` |
| [`docs/`](docs/README.md) | the reference: every function, its type, examples, provenance |
| [`demos/`](demos/) | programs that use it |
| [`tests/`](tests/) | reg-rs baselines: the test programs, the pinned export types (`types.rgt`) and the demos (`demo-*.rgt`) |

```bash
just demo Trig         # run its demos
just run Trig          # run its test programs
just test-lib Trig     # check every baseline
```
