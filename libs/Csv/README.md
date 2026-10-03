# Csv

comma-separated values -- lines to fields (quoted fields kept whole), a table of texts, columns by number or name, numbers, and back to text.

```
"cs:" u_se< "Csv"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the library, `Csv.xtl` |
| [`docs/`](docs/README.md) | the reference: every function, its type, examples, provenance |
| [`demos/`](demos/) | programs that use it: `cities.xtl`, a CSV dataset summarized and set as a table |
| [`tests/`](tests/) | reg-rs baselines: the test programs, the pinned export types (`types.rgt`) and the demos (`demo-*.rgt`) |

```bash
just demo Csv         # run its demos
just run Csv          # run its test programs
just test-lib Csv     # check every baseline
```
