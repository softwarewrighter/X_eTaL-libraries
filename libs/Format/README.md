# Format

number formatting -- fixed decimals, thousands separators, percentages, aligned columns, text tables.

```
"f:" u_se< "Format"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the library, `Format.xtl` |
| [`docs/`](docs/README.md) | the reference: every function, its type, examples, provenance |
| [`demos/`](demos/) | programs that use it: `invoice.xtl`, an invoice as a table with money and tax |
| [`tests/`](tests/) | reg-rs baselines: the test programs, the pinned export types (`types.rgt`) and the demos (`demo-*.rgt`) |

```bash
just demo Format         # run its demos
just run Format          # run its test programs
just test-lib Format     # check every baseline
```
