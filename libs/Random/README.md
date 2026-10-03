# Random

randomness -- shuffles, deals, choices, uniform and normal samples, weighted picks.

```
"r:" u_se< "Random"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the library, `Random.xtl` |
| [`docs/`](docs/README.md) | the reference: every function, its type, examples, provenance |
| [`demos/`](demos/) | programs that use it: `dice.xtl`, two dice thrown 6000 times |
| [`tests/`](tests/) | reg-rs baselines: the test programs, the pinned export types (`types.rgt`) and the demos (`demo-*.rgt`) |

```bash
just demo Random         # run its demos
just run Random          # run its test programs
just test-lib Random     # check every baseline
```
