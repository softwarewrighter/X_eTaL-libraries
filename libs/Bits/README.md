# Bits

bits -- binary digits and back, popcount, and, or, xor on whole numbers, shifts, single bits, Gray codes.

```
"b:" u_se< "Bits"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the library, `Bits.xtl` |
| [`docs/`](docs/README.md) | the reference: every function, its type, examples, provenance |
| [`demos/`](demos/) | programs that use it: `nim.xtl`, the winning move in Nim by xor |
| [`tests/`](tests/) | reg-rs baselines: the test programs, the pinned export types (`types.rgt`) and the demos (`demo-*.rgt`) |

```bash
just demo Bits         # run its demos
just run Bits          # run its test programs
just test-lib Bits     # check every baseline
```
