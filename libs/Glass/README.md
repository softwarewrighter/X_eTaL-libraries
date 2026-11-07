# Glass

Bounded dielectric tracing with exact Fresnel/Snell interfaces, absorption,
explicit object medium IDs, and deterministic per-sample continuation.
Import with `"gl:" u_se< "Glass"`. Dependencies include Scene, RayTrace,
Vector3, Random and their dependencies; `just path` prints their source paths.

The [reference](docs/README.md) specifies the separate v2 arrays, shared
preflight and state tuples. The [CPU demo](demos/example.xtl) renders a
sphere/floor fixture and reports interaction-cap convergence. Run
`just demo Glass` or `just test-lib Glass`.

Glass volumes require disjoint conservative bounding boxes. Glass blocks
point-light shadows; this renderer does not approximate refracted caustics.
RayTrace's original opaque one-reflection renderer remains available.

Counter-sampled area transport uses Random's Philox identities and matches
sampled rectangles to visible emissive triangles. The
[film/lens/area demo](demos/lens-area.xtl) combines these arrays in X_eTaL.
