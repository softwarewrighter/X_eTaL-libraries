# Parsing

total parsers for macro authors: a notation in a string in, its pieces out or a refusal, nothing dropped

```
"pa:" u_se< "Parsing"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the library, `Parsing.xtl` |
| [`docs/`](docs/README.md) | the reference: every function, its type, examples, provenance |
| [`demos/`](demos/) | programs that use it |
| [`tests/`](tests/) | reg-rs baselines: the test programs, the pinned export types (`types.rgt`), the demos (`demo-*.rgt`), and `Probe.xtlm`, macros that show what each parser gives and refuses |

```bash
just demo Parsing         # run its demos
just run Parsing          # run its test programs
just test-lib Parsing     # check every baseline
```
