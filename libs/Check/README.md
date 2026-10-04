# Check

Assertions that report as text, for tests and teaching.

```
"k:" u_se< "Check"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the library, `Check.xtl`, and its macro library, `Check.xtlm` (`k:c_ases<`) |
| [`docs/`](docs/README.md) | the reference: every function, its type, examples, provenance |
| [`demos/`](demos/) | programs that use it: `grading.xtl`, a student's median graded by four checks (one fails on purpose); `table.xtl`, table-driven checks named by their source (the macro) |
| [`tests/`](tests/) | reg-rs baselines: the test programs (`basics.xtl`, `report.xtl`), the pinned export types (`types.rgt`) and the demos (`demo-*.rgt`) |

```bash
just demo Check         # run its demos
just run Check          # run its test programs
just test-lib Check     # check every baseline
```
