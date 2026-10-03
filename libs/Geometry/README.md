# Geometry

plane geometry -- points as 2-row matrices, distances, polygon area and centroid, rotation, scaling and moves, convex hulls, pictures.

```
"ge:" u_se< "Geometry"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the library, `Geometry.xtl` |
| [`docs/`](docs/README.md) | the reference: every function, its type, examples, provenance |
| [`demos/`](demos/) | programs that use it: `hull.xtl`, a fence round random trees |
| [`tests/`](tests/) | reg-rs baselines: the test programs, the pinned export types (`types.rgt`) and the demos (`demo-*.rgt`) |

```bash
just demo Geometry         # run its demos
just run Geometry          # run its test programs
just test-lib Geometry     # check every baseline
```
