# Strings

Text functions -- case, trimming, words, split and join, search, replace, padding.

```
"t:" u_se< "Strings"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the library, `Strings.xtl` |
| [`docs/`](docs/README.md) | the reference: every function, its type, examples, provenance |
| [`demos/`](demos/) | programs that use it: `word-count.xtl`, the most frequent words of a text |
| [`tests/`](tests/) | reg-rs baselines: the test programs (`basics.xtl`, `checks.xtl`, `search.xtl`), the pinned export types (`types.rgt`) and the demos (`demo-*.rgt`) |

```bash
just demo Strings         # run its demos
just run Strings          # run its test programs
just test-lib Strings     # check every baseline
```
