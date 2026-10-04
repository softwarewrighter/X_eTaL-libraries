# Polynomials

polynomials -- evaluation, sums, products, derivatives, integrals, real roots, text.

```
"py:" u_se< "Polynomials"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the library, `Polynomials.xtl`, and its macro library, `Polynomials.xtlm` (`py:p_oly<`) |
| [`docs/`](docs/README.md) | the reference: every function, its type, examples, provenance |
| [`demos/`](demos/) | programs that use it: `curve.xtl`, a curve through five points, its roots, turns and picture |
| [`tests/`](tests/) | reg-rs baselines: the test programs, the pinned export types (`types.rgt`) and the demos (`demo-*.rgt`) |

```bash
just demo Polynomials         # run its demos
just run Polynomials          # run its test programs
just test-lib Polynomials     # check every baseline
```
