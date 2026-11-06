# Matrix

Matrices -- identity, diagonal, trace, product, determinant, inverse, solving linear systems, orthonormal bases and rank, projection and coordinates, symmetric eigenvalues and eigenvectors, singular values, the SVD and the best rank-k approximation and principal angles between row spaces.

```
"mx:" u_se< "Matrix"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the library, `Matrix.xtl` |
| [`docs/`](docs/README.md) | the reference: every function, its type, examples, provenance |
| [`demos/`](demos/) | programs that use it: `line-fit.xtl`, a least-squares line and a frozen-basis/low-rank update comparison |
| [`tests/`](tests/) | reg-rs baselines: the test programs, the pinned export types (`types.rgt`) and the demos (`demo-*.rgt`) |

```bash
just demo Matrix         # run its demos
just run Matrix          # run its test programs
just test-lib Matrix     # check every baseline
```
