# Scene v2 numeric contract

Scene and RayTrace use this explicit extension of the v1 contract.
`sc:s_cene2<` opts in; `sc:s_cene<` keeps its eight v1 bindings and
expansion behavior. V1 arrays keep every original shape and meaning.
Coordinates are right-handed xyz, y up, radians, linear RGB, scene units.
Rigid matrices act on column vectors; row points multiply the transpose.

| Added suffix | Shape/type | Meaning |
| ------------ | ---------- | ------- |
| sceneversion | scalar Int | exactly 2 |
| materialkind | M Int | `sc:o_paque @` = 0, `sc:d_ielectric @` = 1 |
| optics | M by 5 Float | transmission weight, IOR, absorption RGB per scene unit |
| emission | M by 3 Float | nonnegative emitted radiance, may exceed 1 |
| spheres | S by 4 Float | center xyz, strictly positive radius |
| spherematerialids | S Int | one-based material rows |
| spheregroupids | S Int | one-based rigid group rows |
| triangleobjectids | T Int | closed-object identity, zero for an open surface |
| sphereobjectids | S Int | closed-object identity |
| triangleids | T Int | unique positive global primitive IDs |
| sphereids | S Int | unique positive global primitive IDs, shared namespace |
| lens | 2 Float | nonnegative aperture radius, positive focus distance |
| emitters | E by 3 by 3 Float | rectangle origin, span u, span v |
| emitterradiance | E by 3 Float | nonnegative linear RGB radiance |

All numeric fields must be finite. Transmission lies in 0..1; IOR is
strictly positive; absorption and emission are nonnegative. V1 material
RGB and reflection remain in 0..1. Shapes and corresponding row counts
must match, with Int IDs separate from all floating-point fields.

Object IDs identify volumes, independently of materials: two glass
spheres sharing one material have different object IDs. A crystal's
faces share one object ID. IDs follow object declaration order; a floor
has object ID zero. Global primitive IDs follow the combined source
order of objects of both kinds, then each mesh's face order. Their
values can have gaps within either per-kind array. Runtime users may
supply arbitrary unique positive global IDs. Compare distance first,
then the smallest global ID on an exact tie. Kind tags (0 miss, 1
triangle, 2 sphere) and local indices are separate Int arrays, never
substituted for global IDs. Ray chunks do not change the comparison.

Group 1 remains identity, pivot zero. Proper rigid transforms preserve
sphere radius. Scale, shear and reflection matrices refuse. A caller
can bake positive static uniform scale into center/radius before
construction; there is no implicit radius conversion for affine matrices.

## Opaque adapter and current construction

Passing a v1 declaration to `sc:s_cene2<` is the explicit text adapter:
its original eight arrays match `sc:s_cene<`, and the additional arrays
supply opaque tags, optics [0,1,0,0,0], zero emission, lens [0,1], no
spheres and no emitters. An opaque closed mesh may carry an object ID;
the opaque renderer ignores that identity. Existing numeric callers can
use `sc:o_paqueOptics materials`, M Int zeros for materialkind, M by 3
Float zeros for emission, T Int zeros for triangleobjectids, `r_ange T`
for triangleids, and the same empty/pinhole defaults. This fieldwise
adapter preserves separate arrays and does not reinterpret old columns.

The current v2 macro adds sphere, box, octahedron, floor and dielectric
material declarations. It emits literal arrays after ordinary runtime
constructors validate the same geometry. It retains pinhole, zero-emission
and empty-emitter defaults unless the caller adds lens, emission or
emitter declarations. Glass transport is available through the [Glass library](../libs/Glass/docs/README.md).
Pure counter sampling lives in Random, film/thin-lens rays in RayTrace,
and sampled area transport in Glass. The opaque v1 renderer retains its
original arguments and opaque semantics.

## Material and light semantics for consumers

For transmission w, v1 reflection r and Fresnel F, the agreed material
blend is (1-w) times the opaque mixture [(1-r) diffuse + r mirror], plus
w times [F mirror + (1-F) refracted transport], plus emission. Thus the
lossless dielectric interface weights sum to one; an extra full-strength
reflection is never added. Absorption applies over physical distance,
which is t times the ray direction's length. Glass applies the radiance
factor (ni/nt)^2 on transmission and compensates the selected lobe by its
sampling probability; see its reference.

Zero aperture is the v1 pinhole camera; positive focus distance is
measured along the camera forward axis. Rectangle normal is normalized
u cross v; emission is one-sided toward that normal. Numeric emitter arrays are sampling descriptors. A visible emitter also
has coincident triangle geometry with its material's emission set to the
same radiance. Scene emitter declarations create both; ordinary callers
provide both. Glass area preflight validates that correspondence and uses
the same visible geometry. Spans must be perpendicular within normalized
1e-10, with finite nonzero area.

No runtime state is stored in the scene colors: origins, directions,
medium IDs (zero for air), throughput, hit kinds/local indices and sample
identity remain separate arrays. Unsupported nested/interpenetrating
glass is rejected by Glass's shared preflight. Geometry construction
alone does not certify non-overlap or execute glass transport.
