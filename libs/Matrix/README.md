# Matrix

matrices -- transpose, identity, diagonal, trace, product, determinant, inverse, solving linear systems.

```
"mx:" u_se< "Matrix"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the library, `Matrix.xtl` |
| [`docs/`](docs/README.md) | the reference: every function, its type, examples, provenance |
| [`demos/`](demos/) | programs that use it: `line-fit.xtl`, a least-squares line through noisy points |
| [`tests/`](tests/) | reg-rs baselines: the test programs, the pinned export types (`types.rgt`) and the demos (`demo-*.rgt`) |

```bash
just demo Matrix         # run its demos
just run Matrix          # run its test programs
just test-lib Matrix     # check every baseline
```
