# Eigencube

a Rubik's cube as rotation matrices -- turns as matrix products, stickers read back from the matrices, a layer-by-layer search that solves it.

```
"ec:" u_se< "Eigencube"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the library, `Eigencube.xtl` |
| [`docs/`](docs/README.md) | the reference: every function, its type, examples, provenance |
| [`demos/`](demos/) | programs that use it: `solve.xtl`, a random scramble solved |
| [`tests/`](tests/) | reg-rs baselines: the test programs, the pinned export types (`types.rgt`) and the demos (`demo-*.rgt`) |

```bash
just demo Eigencube        # run its demos
just run Eigencube         # run its test programs
just test-lib Eigencube    # check every baseline
```
