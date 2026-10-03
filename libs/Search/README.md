# Search

searching and ranking -- positions in sorted lists, merges, the k largest, ranks with ties, nearest items, order statistics, ranges.

```
"sr:" u_se< "Search"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the library, `Search.xtl` |
| [`docs/`](docs/README.md) | the reference: every function, its type, examples, provenance |
| [`demos/`](demos/) | programs that use it: `exam.xtl`, top three, ranks, grades, a band |
| [`tests/`](tests/) | reg-rs baselines: the test programs, the pinned export types (`types.rgt`) and the demos (`demo-*.rgt`) |

```bash
just demo Search         # run its demos
just run Search          # run its test programs
just test-lib Search     # check every baseline
```
