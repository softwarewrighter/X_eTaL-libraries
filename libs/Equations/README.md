# Equations

sums as printed in papers, written in one macro call: `e:q_<` gives the array computation; the CNN layer's cross-correlation checks it

```
"e:" u_se< "Equations"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the library, `Equations.xtl`, and its macro library, `Equations.xtlm` |
| [`docs/`](docs/README.md) | the reference: every function, its type, examples, provenance |
| [`demos/`](demos/) | programs that use it: `cnn.xtl`, one CNN layer as the paper writes it |
| [`tests/`](tests/) | reg-rs baselines: the test programs, the pinned export types (`types.rgt`) and the demos (`demo-*.rgt`) |

```bash
just demo Equations         # run its demos
just run Equations          # run its test programs
just test-lib Equations     # check every baseline
```
