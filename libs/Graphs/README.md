# Graphs

graphs as adjacency matrices -- from edges, degrees, reachability, shortest paths, breadth-first levels, connected components.

```
"g:" u_se< "Graphs"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the library, `Graphs.xtl`, and its macro library, `Graphs.xtlm` (`g:g_raph<`) |
| [`docs/`](docs/README.md) | the reference: every function, its type, examples, provenance |
| [`demos/`](demos/) | programs that use it: `subway.xtl`, travel times, stops and a closure on a small subway map |
| [`macros/`](macros/) | programs that use the macro: a subway map by station names, and a bad name stopped at compile time (`just macros`) |
| [`tests/`](tests/) | reg-rs baselines: the test programs, the pinned export types (`types.rgt`) and the demos (`demo-*.rgt`) |

```bash
just demo Graphs         # run its demos
just run Graphs          # run its test programs
just test-lib Graphs     # check every baseline
```
