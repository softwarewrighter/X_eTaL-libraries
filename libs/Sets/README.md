# Sets

Vectors as sets -- union, intersection, difference, subset, and how often each item occurs.

```
"se:" u_se< "Sets"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the library, `Sets.xtl` |
| [`docs/`](docs/README.md) | the reference: every function, its type, examples, provenance |
| [`demos/`](demos/) | programs that use it: `clubs.xtl`, who is in which club, as sets of names |
| [`tests/`](tests/) | reg-rs baselines: the test programs (`basics.xtl`, `checks.xtl`), the pinned export types (`types.rgt`) and the demos (`demo-*.rgt`) |

```bash
just demo Sets         # run its demos
just run Sets          # run its test programs
just test-lib Sets     # check every baseline
```
