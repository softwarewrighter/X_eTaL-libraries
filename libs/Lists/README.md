# Lists

list functions -- differences, windows, moving means, run lengths, chunks, shifts, interleaving, binary search, raze.

```
"q:" u_se< "Lists"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the library, `Lists.xtl` |
| [`docs/`](docs/README.md) | the reference: every function, its type, examples, provenance |
| [`demos/`](demos/) | programs that use it |
| [`tests/`](tests/) | reg-rs baselines: the test programs, the pinned export types (`types.rgt`) and the demos (`demo-*.rgt`) |

```bash
just demo Lists         # run its demos
just run Lists          # run its test programs
just test-lib Lists     # check every baseline
```
