# Statistics

statistics -- median, quantiles, five-number summaries, z-scores, covariance, correlation, a least-squares line, binned counts; builds on the standard Stats.

```
"sx:" u_se< "Statistics"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the library, `Statistics.xtl` |
| [`docs/`](docs/README.md) | the reference: every function, its type, examples, provenance |
| [`demos/`](demos/) | programs that use it: `heights.xtl`, summaries, correlation, a fitted line, outliers |
| [`tests/`](tests/) | reg-rs baselines: the test programs, the pinned export types (`types.rgt`) and the demos (`demo-*.rgt`) |

```bash
just demo Statistics         # run its demos
just run Statistics          # run its test programs
just test-lib Statistics     # check every baseline
```
