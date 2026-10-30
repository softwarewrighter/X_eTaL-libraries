# Plot

text charts -- bars, sparklines, histograms, scatter plots on a character grid -- line charts as pictures, with axes, labels and several lines; and function plots, a picture whose horizontal axis reads a real range, not a position.

```
"p:" u_se< "Plot"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the library, `Plot.xtl` |
| [`docs/`](docs/README.md) | the reference: every function, its type, examples, provenance |
| [`demos/`](demos/) | programs that use it: `weather.xtl`, a year of weather as bars, a sparkline, a scatter and line pictures; `functions.xtl`, a sine wave and a parabola plotted over their own ranges |
| [`tests/`](tests/) | reg-rs baselines: the test programs, the pinned export types (`types.rgt`) and the demos (`demo-*.rgt`) |

```bash
just demo Plot         # run its demos
just run Plot          # run its test programs
just test-lib Plot     # check every baseline
```
