# RayTrace

Pure X_eTaL CPU triangle tracing, with pinhole rays, two-sided hits,
ambient and diffuse point lighting, hard shadows and one reflection.
Import with `"rt:" u_se< "RayTrace"`; Vector3 and Matrix are dependencies.
Put their `src` directories on `XETAL_PATH` (`just path`).

## Arrays and parameters

Coordinates are right-handed xyz, y up, in scene units. Angles are
radians. Numeric inputs are converted to Float; IDs and pixel indices
are Int. There is no implicit broadcasting of ray batches.

| Input | Shape and meaning |
| ----- | ----------------- |
| clip | 4 Float: positive near, far, relative intersection epsilon, origin offset; near < far, epsilon < 1 |
| triangles | T by 3 by 3: triangle, vertex, xyz; declaration order |
| origins, directions | N by 3 matching ray rows; directions must be nonzero |
| materialids | T Int: one-based rows of materials |
| materials | M by 4: linear RGB albedo and reflection weight, each 0..1 |
| lights | L by 6: position xyz and nonnegative linear RGB radiant intensity |
| environment | 2 by 3: nonnegative ambient illumination RGB, then background radiance RGB |
| camera | 10: eye xyz, target xyz, up xyz, vertical field of view |
| size | 2: positive integer width, height |
| pixels | N Int: one-based row-major pixel indices within size |

A suitable starting clip is `1e-6 100.0 1e-10 1e-5`. Near and far
are ray parameters t in `origin + t * direction`; they are distances
only for unit directions. Camera rays are unit vectors. Secondary and
shadow origins move by offset in scene units along the oriented normal.
Shadow directions are unit length. Choose far large enough to include
the scene and lights, and near/offset small relative to scene geometry.
The implementation refuses nonfinite inputs and arithmetic overflow.

This is the opaque v1 contract. Transform scene triangles with ordinary
Vector3 functions before tracing; this library consumes world-space
triangles. Empty meshes, ray batches and light lists are supported.
Degenerate faces always miss. Colors stay linear until display conversion.

## Camera and intersections

`camera rt:o_rigins count` returns count eye rows. Count must be a
nonnegative scalar Int. `((camera rt:r_ays size)_ pixels)` returns N
normalized directions through pixel centers: top row first, x increasing
to the right. It checks field of view in (0, pi), distinct eye/target,
and an up direction whose normalized cross with the view has length
above 1e-12. Width/height controls aspect ratio; fov is vertical.

`(((clip rt:i_ntersect triangle)_ origins)_ directions)` intersects
one 3 by 3 triangle with the rays and returns N by 3 Float rows t,u,v.
A miss row is zero. For triangle `(0,0,0),(1,0,0),(0,1,0)`, origin
`(0.25,0.25,1)` and direction `(0,0,-1)`, the result is `(1,0.25,0.25)`.
`rt:m_ask hits` returns a separate N Int 0/1 validity array;
`rt:d_istances hits` returns N Float t values, zero on misses.

The implementation uses Moller-Trumbore equations. Parallel and
degenerate cases miss when the absolute determinant is at most epsilon
times the product of the two edge lengths and direction length. Before
division their determinant is replaced by 1. Edges and vertices are
included with `u >= 0`, `v >= 0`, `u+v <= 1`; clipping includes both
endpoints. This is an exact barycentric boundary rule, not a watertight
predicate or a geometric tolerance repair. Extremely ill-conditioned
or boundary-sensitive input needs precision-appropriate epsilon and
consumer CPU/GPU comparison. Intermediate overflow panics even on a
candidate that would otherwise miss; it never leaks infinity or NaN.

`(((clip rt:n_earest triangles)_ origins)_ directions)` returns N Int
triangle IDs; zero means miss. A strictly nearer candidate replaces the
previous ID, so exact distance ties keep the first declared triangle.
`((((clip rt:h_its triangles)_ ids)_ origins)_ directions)` computes
selected t,u,v rows using the same intersection equations. IDs must come
from nearest for these same rays, mesh and clip; malformed IDs refuse.
It does not search for a replacement if given an unrelated valid ID.

`((triangles rt:n_ormals ids)_ directions)` returns N by 3 unit normals
from `(b-a) cross (c-a)`, oriented against incoming directions, with zero
rows for miss IDs. Both sides shade identically. Winding still defines
the geometric normal before orientation. `normals rt:r_eflect directions`
returns `d - 2(d dot n)n`; normals must be unit (to 1e-10) or zero.
A zero normal leaves its direction unchanged, useful for miss rows.

## Lighting and rendering

Both `rt:s_hade` and `rt:r_ender` take, in order, clip, triangles,
materialids, materials, lights, environment, origins and directions.
The [diagnostic](../demos/diagnostic.xtl) shows the curried call with
explicit arrays. To expose a simpler application interface, wrap the
static scene in a lambda of origin/direction or pixel indices, as the
demo does. A bare partially applied numeric function binding defaults
unresolved numeric inputs to Int; a lambda retains their numeric types.

`rt:s_hade` returns N by 3 linear RGB. For each hit it computes albedo
times ambient plus the sum of visible point-light contributions:
`albedo * intensity * max(0,n dot lightDirection) / (pi * distance^2)`.
Distance is measured from the offset surface point. Light RGB is radiant
intensity in consistent scene units; background RGB is radiance. Ambient
is a simple illumination approximation, not integrated indirect light.
RGB light and background values may exceed 1. A coincident point light
contributes zero using a finite denominator and a dummy shadow direction.

A shadow origin is `point + offset * normal`; occlusion requires a hit
from near through far strictly before `lightDistance - offset`.
Thus geometry at or beyond that endpoint does not occlude. All faces
are opaque, including the material's mirror component. No transparent
shadow approximation is used. Increasing near/offset too far can erase
thin geometry; too small an offset can cause self-intersections.

`rt:r_ender` performs primary shading, then one reflected ray and direct
shading there. It returns `(1-r)*primary + r*secondary` for primary
reflection weight r. A secondary miss sees the background; a secondary
hit terminates with direct shading, ignoring that surface's reflection
weight. Primary misses return the background. There is no growing ray
tree, recursive reflection, stochastic sampling or dependency on a host
renderer. Tests cover background mirrors, a partially reflecting face,
self-hit avoidance and two mirror surfaces proving the one-bounce cap.

## Batching and limits

Call camera/render functions on subsets of pixel indices, then concatenate
the returned rows. Pixel identity, intersection arithmetic and nearest
ties do not depend on ray chunk size; tests compare exact raw Float arrays
for full and irregularly split tiny scenes. Nearest uses a fixed T-step
sweep with one triangle broadcast per step and an Int cursor/ID state.
It recomputes previous selected distances rather than packing IDs into
Float state or requiring a mixed tuple. Working candidate storage is
O(N), plus scene and output arrays, without an N by T pair matrix.

Point lights are accumulated in declaration order by a tail-recursive
sweep bounded by L; each light uses the same one-face-at-a-time nearest
search. This favors a small transparent reference implementation over
speed. No high-resolution performance or GPU eligibility is promised;
GPU lowering and precision checks belong to the consumer. Supply bounded
ray chunks and a sensible finite scene/light count. No BVH is included.

## Display and examples

`exposure rt:s_rgb linear` accepts scalar nonnegative exposure and N
by 3 linear RGB, multiplies by exposure, clips to 0..1 and applies sRGB:
12.92*x through 0.0031308, otherwise 1.055*x^(1/2.4)-0.055. It returns
Float RGB in 0..1. For an integer TIFF channel range K (255 or 65535),
the host can round `K * display` to nearest. Preserve raw linear arrays
for correctness comparisons. This is simple clipping, with no tone map,
image encoder, bloom or gamut conversion.

`tests/camera.xtl` checks transfer breakpoints and clipping. The diagnostic
prints a 4 by 4 triangle-ID tile, then 16 by 3 raw linear RGB and display
RGB. Its output is pinned, alongside types and refusal diagnostics.
`tests/intersections.xtl`, `lighting.xtl` and `pixels.xtl` check the
analytical cases, shadows, reflection and exact chunk agreement.

## Export types

The following are the pinned evaluator types. Numeric arguments are
independently polymorphic; shapes and units are the runtime contracts
above. Int arguments preserve IDs, counts and pixel identity.

```text
rt:o_rigins : Num a => a -> Int -> Float
rt:r_ays : (Num a, Num b) => a -> b -> Int -> Float
rt:i_ntersect : (Num a, Num b, Num c, Num d) => a -> b -> c -> d -> Float
rt:m_ask : Num a => a -> Int
rt:d_istances : Num a => a -> Float
rt:n_earest : (Num a, Num b, Num c, Num d) => a -> b -> c -> d -> Int
rt:h_its : (Num a, Num b, Num c, Num d) => a -> b -> Int -> c -> d -> Float
rt:n_ormals : (Num a, Num b) => a -> Int -> b -> Float
rt:r_eflect : (Num a, Num b) => a -> b -> Float
rt:s_hade : (Num a, Num b, Num c, Num d, Num e, Num f, Num g) => a -> b -> Int -> c -> d -> e -> f -> g -> Float
rt:r_ender : (Num a, Num b, Num c, Num d, Num e, Num f, Num g) => a -> b -> Int -> c -> d -> e -> f -> g -> Float
rt:s_rgb : (Num a, Num b) => a -> b -> Float
```

## Provenance

Original MIT implementation from documented equations, with no renderer
code or assets copied. Algorithm and behavior references:

- Moller and Trumbore, "Fast, Minimum Storage Ray-Triangle Intersection,"
  Journal of Graphics Tools 2(1), 1997, pages 21-28,
  [paper record](https://doi.org/10.1080/10867651.1997.10487468).
- PBRT, [diffuse reflection](https://www.pbr-book.org/4ed/Reflection_Models/Diffuse_Reflection)
  and [point lights](https://www.pbr-book.org/4ed/Light_Sources/Point_Lights),
  for Lambertian normalization and inverse-square intensity behavior.
- W3C, [sRGB conversion](https://www.w3.org/TR/css-color-4/#color-conversion-code),
  for the display transfer constants; equations reimplemented here.

Glass, analytic spheres, thin lenses and area emitters are separate
compatible follow-ons. The current API preserves opaque v1 semantics.

## Analytic spheres and mixed geometry

The [v2 numeric contract](../../../docs/scene-v2.md) extends geometry
without changing the opaque triangle renderer. All inputs and computed
results must be finite; overflow refuses. Ray directions must be nonzero.
The same positive near/far clip and zero-miss conventions apply.

| Function | Arguments and result |
| -------- | -------------------- |
| `rt:s_pheres data` | validate S by 4 center xyz/positive radius; Float output |
| `(((clip rt:s_phereHit sphere)_ origins)_ directions)` | length-4 sphere and N by 3 rays to N by 3 [t,0,0] |
| `sphere rt:s_phereNormals points` | N by 3 surface points to outward unit geometric normals |
| `((((((clip rt:m_ixedNearest triangles)_ spheres)_ triangleids)_ sphereids)_ origins)_ directions)` | global N Int IDs, zero miss |
| `(((((((clip rt:m_ixedHits triangles)_ spheres)_ triangleids)_ sphereids)_ selected)_ origins)_ directions)` | selected N by 3 t,u,v; sphere u/v zero |
| `((triangleids rt:h_itKinds sphereids)_ selected)` | separate N Int tags: 0 miss, 1 triangle, 2 sphere |
| `((triangleids rt:h_itLocals sphereids)_ selected)` | separate N Int one-based local indices, zero miss |

Sphere intersection uses the original analytic ray/quadratic equations:
a=d dot d, b=(o-center) dot d, c=|o-center| squared minus radius squared.
The discriminant uses a*radius squared minus |(o-center) cross d| squared
to avoid cancellation for a distant radial ray. Roots use q/a and c/q,
with q=-b-sign(b)*sqrt(discriminant), sign(0)=1, and a finite masked q.
Negative discriminants miss; tangents hit; the nearest root within the
inclusive near/far interval wins. A ray inside exits through the second
root. t is a ray parameter: physical distance is t*length(direction).
Surface normals require points on the sphere within relative 1e-10;
they remain outward for both entry and exit, unlike incident-oriented
`rt:n_ormals`. See [the sphere demo](../demos/sphere.xtl).

Global primitive IDs must be unique positive Int values across both
geometry kinds, with one per primitive. Exact distance ties choose the
smallest global ID, including across kinds. Reordering primitives with
their IDs or partitioning rays preserves the result. `rt:m_ixedHits`
expects IDs selected for the same scene, rays and clip; unknown IDs and
mismatched counts refuse. Kind/local accessors require known IDs or zero.

The mixed sweep keeps one candidate and one previous selection per ray,
without a pixels-by-primitives hit matrix. ID lookup scans the supplied
ID vectors, so this CPU diagnostic implementation can take quadratic
work in primitive count. It is not a GPU acceleration structure.
`s_hade` and `r_ender` retain their v1 triangle-only opaque semantics;
these hit APIs do not add glass or sampled lighting.

The sphere equations and stable quadratic-root method are documented in
PBRT's [Spheres](https://www.pbr-book.org/4ed/Shapes/Spheres). This is an
original array implementation; no PBRT code is copied. It uses ordinary
Float arithmetic rather than interval arithmetic. Extreme coordinate,
radius or direction scales can lose resolution or underflow; choose
scene units that keep the quadratic products representable.

## Film samples and a thin lens

| Function | Contract |
| -------- | -------- |
| `(((camera rt:r_aysAt size)_ pixels)_ film)` | v1 camera/size/pixel IDs and N by 2 film offsets in 0..1 to N by 3 pinhole directions |
| `(((camera rt:l_ensRays lens)_ pinhole)_ disk)` | length-2 lens, N by 3 unit directions and N by 2 unit-disk coordinates to `(origins,directions)`, both N by 3 |

Film x runs right and y down within the selected pixel. Offsets [0.5,0.5]
match `rt:r_ays` exactly. Existing v1 camera and pixel meanings remain
unchanged, including one-based flat pixel IDs. Random's counter convention
is zero-based; add one only when selecting a RayTrace pixel.

Lens is [nonnegative aperture radius, positive axial focus distance] in
scene units, shared by the ray batch. Focus is measured along the camera
forward axis, not along each oblique ray. Each pinhole ray meets that
plane at eye + direction*focus/(direction dot forward). A disk coordinate
moves the ray origin in the camera's right/up plane, scaled by aperture;
the normalized outgoing direction aims at that focal point. Unit-disk
coordinates are explicit input arrays, for example from `r:d_isk`.

Aperture zero returns the pinhole directions unchanged and exact copies
of the camera eye. Other input validation still applies: unit directions
within 1e-10, positive forward axial component, matching sample counts,
finite data and disk radius <=1 within 1e-10. Numeric collapse of a focal
direction refuses. At focus all aperture rays for one film sample meet;
near/far planes spread in proportion to aperture. Tests pin both behaviors
and exact zero-aperture compatibility. Film and lens samples can be
prepared independently of rendering, using the counter domains described
in [Random](../../Random/docs/README.md).

## Color pictures in Live Demos

`size rt:p_icture displayRGB` packages width*height rows of sRGB values
in 0..1 as square color pixels in SVG. `size rt:s_how! displayRGB` sends
that picture through the language's existing picture channel. The live
site displays it, and the CLI writes it to its --draw directory. Use
`exposure rt:s_rgb linear` first; the display function computes no
geometry, lighting, shadows or reflections of its own. Sizes must be
positive whole dimensions and RGB rows must match. Out-of-range/nonfinite
colors refuse instead of hiding a missing display conversion.

The [diagnostic demo](../demos/diagnostic.xtl) includes a rendered orange
box and blue crystal, with shadows and a reflective floor. Scene's
[logo](../../Scene/demos/logo.xtl) shows the actual extruded glyph mesh,
and Glass supplies sphere/lens/area-light pictures. Recorded SVGs appear
immediately before the demo code; Run recomputes them from that program.

The CPU triangle sweep uses padded bounding boxes to compact candidate
rays and caches hit distances separately from Int IDs. It retains the
original intersection solver and strict declaration-order tie rule.
Distance selection avoids subtractive updates that could lose a tiny
closer distance after a huge one. Tests compare it with an exhaustive
sweep, including that numerical case. State stays bounded by scene and
ray arrays, without a full ray-by-triangle hit matrix.
