# Numbers

Number theory -- gcd and lcm, primes, factors, divisors, digits, integer square roots, Fibonacci numbers.

```
"n:" u_se< "Numbers"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the library, `Numbers.xtl` |
| [`docs/`](docs/README.md) | the reference: every function, its type, examples, provenance |
| [`demos/`](demos/) | programs that use it: `primes.xtl`, twin primes, Goldbach counts, perfect numbers |
| [`tests/`](tests/) | reg-rs baselines: the test programs (`basics.xtl`, `checks.xtl`, `overflow.xtl`), the pinned export types (`types.rgt`) and the demos (`demo-*.rgt`) |

```bash
just demo Numbers         # run its demos
just run Numbers          # run its test programs
just test-lib Numbers     # check every baseline
```
