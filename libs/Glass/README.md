# Glass

Bounded dielectric tracing with exact Fresnel/Snell interfaces, absorption,
explicit object medium IDs, and deterministic per-sample continuation.
Import with `"gl:" u_se< "Glass"`. Dependencies include Scene, RayTrace,
Vector3, Random and their dependencies; `just path` prints their source paths.

Start with the [glass scene](demos/example.xtl): a thin lens, visible
area-light panel, refraction and soft shadows. The live demo opens its
antialiased presentation immediately; quick output is available on request.

The [reference](docs/README.md) specifies the separate v2 arrays, shared
preflight and state tuples. The [cap-convergence diagnostic](demos/cap-convergence.xtl) renders a
sphere/floor fixture and reports interaction-cap convergence. Run
`just demo Glass` or `just test-lib Glass`.

Glass volumes require disjoint conservative bounding boxes. Glass blocks
point-light shadows; this renderer does not approximate refracted caustics.
RayTrace's original opaque one-reflection renderer remains available.

Counter-sampled area transport uses Random's Philox identities and matches
sampled rectangles to visible emissive triangles. The
[film/lens/area demo](demos/example.xtl) combines these arrays in X_eTaL.
