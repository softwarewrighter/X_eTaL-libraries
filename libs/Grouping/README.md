# Grouping

grouping by key -- the groups, and counts, sums, means, least and greatest per key, or any function per key.

```
"gr:" u_se< "Grouping"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the library, `Grouping.xtl` |
| [`docs/`](docs/README.md) | the reference: every function, its type, examples, provenance |
| [`demos/`](demos/) | programs that use it: `sales.xtl`, sales by region as a table and bars |
| [`tests/`](tests/) | reg-rs baselines: the test programs, the pinned export types (`types.rgt`) and the demos (`demo-*.rgt`) |

```bash
just demo Grouping         # run its demos
just run Grouping          # run its test programs
just test-lib Grouping     # check every baseline
```
