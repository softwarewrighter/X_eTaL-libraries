# Combinatorics

Counting and listing -- factorials, binomials, combinations, permutations, subsets, Cartesian products.

```
"cb:" u_se< "Combinatorics"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the library, `Combinatorics.xtl` |
| [`docs/`](docs/README.md) | the reference: every function, its type, examples, provenance |
| [`demos/`](demos/) | programs that use it: `lottery.xtl`, lottery odds and a round-robin schedule |
| [`tests/`](tests/) | reg-rs baselines: the test programs (`basics.xtl`, `checks.xtl`), the pinned export types (`types.rgt`) and the demos (`demo-*.rgt`) |

```bash
just demo Combinatorics         # run its demos
just run Combinatorics          # run its test programs
just test-lib Combinatorics     # check every baseline
```
