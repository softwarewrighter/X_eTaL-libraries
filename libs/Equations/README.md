# Equations

sums as printed in papers: the valid 2-D cross-correlation of a CNN layer, as array code

```
"e:" u_se< "Equations"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the library, `Equations.xtl` |
| [`docs/`](docs/README.md) | the reference: every function, its type, examples, provenance |
| [`demos/`](demos/) | programs that use it: `cnn.xtl`, one CNN layer by hand |
| [`tests/`](tests/) | reg-rs baselines: the test programs, the pinned export types (`types.rgt`) and the demos (`demo-*.rgt`) |

```bash
just demo Equations         # run its demos
just run Equations          # run its test programs
just test-lib Equations     # check every baseline
```
