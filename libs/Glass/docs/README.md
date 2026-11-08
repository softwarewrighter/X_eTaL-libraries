# Glass

Glass traces one bounded sampled mirror/refraction path per ray, with
exact unpolarized Fresnel interfaces, Snell transmission, total internal
reflection, Beer-Lambert absorption, direct diffuse lighting and
surface emission. Import with `"gl:" u_se< "Glass"`. Put Scene, RayTrace,
Vector3 and their transitive dependencies on `XETAL_PATH` (`just path`).
The [cap-convergence diagnostic](../demos/cap-convergence.xtl) constructs named Scene v2 arrays,
validates world geometry, and records a small image at increasing caps.
The default [example](../demos/example.xtl) instead opens the antialiased
lens/area scene. The former basic example is retained under its diagnostic
name, and older lens-area links continue to select the default scene.

## Scene construction and shared preflight

Use the [v2 numeric contract](../../../docs/scene-v2.md). Apply the scene's
rigid groups to original triangle vertices and sphere centers first.
Then assemble three readable tuples of separate arrays:

```text
geometry = (triangles, spheres)
links = (triangleids, sphereids, triangleobjectids, sphereobjectids,
         materialids, spherematerialids)
shading = (materials, materialkind, optics, emission, lights)
```

`(geometry gl:p_reflight links)_ shading` returns a scene bundle:
`(geometry, links, shading, glassobjectids, objectmaterialids, bounds)`.
The final three fields are derived caches: positive Int object IDs,
corresponding Int material IDs, and K by 2 by 3 Float low/high bounds.
The renderer and `gl:m_ediums` revalidate the first three fields and
recompute caches, so a forged/stale cache cannot bypass preflight.
Tuples group related arrays without encoding any ID inside Float data.

Preflight checks the constructors' shapes, finite values and material
ranges, one ID per primitive, unique positive global primitive IDs, and
valid material references. Dielectric primitives require positive object
IDs. All primitives with one glass object ID must have one material;
they must form either exactly one sphere or one convex closed outward
mesh, never a mixture. Mesh closure, winding, degeneracy and convexity
use `sc:c_losed`. Two volumes may share a material and still have distinct
object identities. Opaque surfaces may use object ID zero.

Glass bounds must have a gap greater than 1e-10 scene units along at
least one coordinate axis for each pair of objects. This conservative
AABB test rejects nested, interpenetrating and touching volumes. It
also rejects some disjoint shapes whose bounds overlap. It does not
silently support those shapes with guessed medium transitions. Rotate
and separate geometry before preflight; meshes/spheres are world-space.
Opaque geometry may intersect glass; direct opaque hits terminate or
reflect while preserving the current volume identity.

## Interface and absorption functions

| Function | Inputs and outputs |
| -------- | ------------------ |
| `(((ni gl:i_nterface nt)_ normals)_ directions)` | N-vectors of positive IORs and N by 3 unit vectors; tuple `(reflected, transmitted, valid, fresnel)` |
| `sigma gl:a_bsorb distances` | N by 3 nonnegative absorption coefficients and N nonnegative physical lengths to N by 3 transmittance |
| `((seed gl:u_niform interaction)_ sampleids)` | Int scalar seed, Int scalar interaction, N Int keys to N Float samples strictly inside (0,1) |
| `(geometry gl:p_reflight links)_ shading` | validate separate scene arrays and derive the scene bundle |
| `scene gl:m_ediums origins` | N by 3 initial origins to N Int object medium IDs, zero for air |
| `(((((((scene gl:t_race clip)_ environment)_ origins)_ directions)_ mediumids)_ sampleids)_ controls)` | bounded radiance and final per-ray diagnostics |
| `(((((((scene gl:r_ender clip)_ environment)_ origins)_ directions)_ mediumids)_ sampleids)_ controls)` | the same arguments, returning N by 3 linear radiance |

Interface normals point against incident directions. Both vector batches
must be unit length within 1e-10, with matching shapes; opposing cosine
roundoff within 1e-10 is clamped to 0..1. Snell uses ni/nt and computes
transmitted cosine from max(0,1-sin-squared). A negative radicand marks
TIR, with zero transmitted vector, Int validity zero, and Fresnel one.
There is no square root of a negative number or invalid division.
Equal IOR has zero reflection, including at grazing incidence. Otherwise
the squared s/p amplitude coefficients average to exact unpolarized
Fresnel reflectance. Its only output clamp allows 1e-12 roundoff.
Reflected/transmitted directions are N by 3; validity is N Int;
reflectance is N Float. Reflected direction remains available during TIR.

Absorption is exp(-sigma*d), independently per RGB component; sigma has
units of inverse scene length. It includes no surface tint or IOR factor.
All public numeric inputs and final results must be finite. Shapes and
ranges refuse explicitly. Extreme Float scales can underflow or lose
resolution; choose units that keep geometric/quadratic products usable.

## Bounded tracing and radiance convention

`clip` is the v1 four-vector: positive near, far, intersection epsilon
and outgoing origin offset, with near < far and epsilon <1.
`environment` is 2 by 3 nonnegative Float ambient/background RGB.
Origins and directions are matching N by 3 batches. Initial directions
must be nonzero and are normalized, so hit t is physical scene distance.

Provide N Int `mediumids` from `gl:m_ediums` and N stable Int `sampleids`.
Initial containment is checked again: zero is air, and a positive ID
identifies the actual containing glass object, never its material row.
Starting within relative 1e-10 of a glass boundary refuses. Origins inside
a sphere or convex glass mesh are supported when their medium IDs match.

`controls` is Int [seed,cap]. Seed and sample IDs lie in 0..2147483645;
cap lies in 0..64. Each iteration follows at most one continuation per
ray. It does not recursively split reflection/transmission branches.
Cap zero returns black with active paths. A background miss requires
an iteration after the last surface interaction, although only surface
hits increment the returned interaction counts.

For dielectric transmission weight w, opaque reflection r, and Fresnel F:

| Contribution | Weight |
| ------------ | ------ |
| direct diffuse | (1-w)*(1-r) |
| mirror continuation | (1-w)*r + w*F |
| transmitted continuation | w*(1-F), zero during TIR |

Opaque material tags force w=0 and retain their v1 reflection meaning.
Surface emission is added outward only, without an albedo multiplier;
its radiance may exceed one. Direct diffuse uses ambient plus inverse-square
Lambertian point lighting, with two-sided incident-oriented normals.
Point-light shadow rays treat every surface, including glass, as opaque.
This is conservative visibility, not transparent shadow attenuation or
refracted caustic illumination. No caustics, dispersion or bloom is added.

Let R and T be the mirror/transmission continuation weights and C=R+T.
Sample mirror with probability R/C, transmission with T/C. The throughput
multiplier is the selected weight divided by that probability: C for a
mirror, C*(ni/nt)^2 for transmission. The squared ratio is the radiance
transport factor, not a sampling probability. Entry and exit factors
cancel on an outside-to-outside lossless path; a path initialized inside
a higher-IOR medium has the corresponding inside-to-air radiance factor.
The lossless dielectric Fresnel weights sum to one; there is no additional
full-strength mirror contribution on top of transmission.

A transmitted entry records the hit object ID; an exit resets it to air.
A reflected/TIR path preserves the medium. Entry/exit inconsistent with
the current object identity refuses. Tangencies with geometric cosine
magnitude <=1e-10 do not change the medium. Origin offsets advance along
the selected normalized outgoing direction. The next absorbing segment
includes that skipped offset distance, avoiding systematic lost absorption.
Features smaller than near/offset can still be clipped; choose both
parameters below the scene's relevant geometric scales.

## Returned state and truncation

`gl:t_race` returns this tuple of separate arrays:

| Field | Shape/type | Meaning |
| ----- | ---------- | ------- |
| radiance | N by 3 Float | accumulated linear RGB |
| origins | N by 3 Float | final outgoing or terminated origin |
| directions | N by 3 Float | normalized direction |
| throughput | N by 3 Float | remaining/current path multiplier |
| mediumids | N Int | final object ID, zero air |
| active | N Int | unresolved continuation at the interaction cap |
| counts | N Int | completed surface interactions |
| clipped | N Int | unresolved interior path whose exit missed the clip interval |

Missing continuation contributions remain black. A miss while still in
a medium does not invent background radiance or reset the medium: it
sets clipped, terminates the path, and retains the unresolved medium ID.
A miss in air adds background and terminates. A cap-limited path stays
active; the returned state exposes this truncation. `gl:r_ender` returns
only the radiance field. Start each trace from its original rays; returned
diagnostics do not provide a resume operation. A larger cap follows identical sample paths and
can add previously missing contributions, but is not a convergence proof
for every scene or a substitute for increasing the number of samples.

In the demo's 8 by 6 fixed-seed fixture, caps 1,2,4,8,16 leave 24,15,0,0,0
active paths. Mean linear components are approximately 0.40712746,
0.45046079, and 0.63024276 from cap 4 onward. Full arrays at 4,8,16 agree
exactly, as do ray chunks with the same sample IDs. Analytical sphere,
slab, mixed-lobe, TIR and white-furnace tests check the transport separately.

## Deterministic samples and limits

`gl:u_niform` starts at x=1+((sampleid+seed) modulo 2147483646), then applies
x=(48271*x) modulo 2147483647 for interaction+2 steps. It returns
(x+0.5)/2147483647. Interaction is 0..63. Products fit Int64; keys never
become floating-point identities. This minimal-standard pseudo-random
stream has no global state and replays the same prefix for any ray chunk.
It is a diagnostic sampler, with no promise of independent streams or
low-discrepancy pixel/lens samples. Changing seed changes the paths.

Preflight and mixed primitive lookup are CPU reference operations, not
an acceleration structure. State memory stays bounded by input scene
arrays and per-ray arrays. Work scales with cap, ray/primitive/light
counts; replaying sample prefixes adds up to quadratic work in the cap.
Completed batches skip further path calculations. The original
`rt:r_ender` remains the separate v1 one-reflection renderer, including
its existing last-bounce behavior and goldens.

## Provenance

Original MIT array implementation from the optical equations, with no
external renderer code copied. PBRT documents
[dielectric sampling and radiance transport](https://www.pbr-book.org/4ed/Reflection_Models/Dielectric_BSDF).
The sampling recurrence uses the C++ standard draft's
[minstd_rand parameters](https://eel.is/c%2B%2Bdraft/rand.predef).
Geometry and closure reuse this repository's Scene, RayTrace and Vector3.

## Counter-sampled area transport

The existing APIs above retain their sequences and outputs. New APIs
use Random's pure Philox counter sampler with separate pixel, sample,
interaction, dimension and seed words. The legacy effectful Random draws
cannot supply order-independent identities, and the earlier minimal
stream remains a compatibility/diagnostic API. The new implementation
reuses the shared Random sampler rather than embedding a second copy.

| Function | Contract |
| -------- | -------- |
| `(scene gl:p_reflightArea emitters)_ radiance` | validated world scene, E rectangles and E by 3 radiance to `(scene,emitters,radiance)` |
| `((((area gl:a_reaLight clip)_ points)_ normals)_ squares)` | area bundle, N by 3 points/unit normals and explicit E by N by 2 square samples to N by 3 unit-albedo Lambertian outgoing radiance |
| `(((((((area gl:t_raceArea clip)_ environment)_ origins)_ directions)_ mediumids)_ identities)_ controls)` | final diagnostics as `gl:t_race`, with N by 2 Int [pixel,sample] identities and Int [uint32 seed,cap] controls |
| `(((((((area gl:r_enderArea clip)_ environment)_ origins)_ directions)_ mediumids)_ identities)_ controls)` | the same arguments, returning linear RGB |

Area preflight revalidates the world and every rectangle/radiance row.
Each rectangle must match exactly the two visible opaque triangles
produced by `sc:r_ectangle`, with material emission equal to its radiance.
Triangle row order and cyclic vertex order may differ; reversed winding,
missing/ambiguous faces, different radiance and duplicate descriptors
refuse. Matching tolerance is 1e-10 times the larger of one and coordinate
or radiance magnitude. Transform geometry and descriptors together before
preflight. The Scene emitter declaration constructs a matching pair and
material automatically. Ordinary emissive panels also remain visible in
reflections when they are not listed as sampled emitters.

Each emitter contributes one uniform area sample per surface/ray per
interaction. For direction wi from surface to sample, distance d,
positive surface/emitter cosines cs/ce, and area density pA=1/area, the
unit-albedo Lambertian estimate is Le*cs*ce/(pi*d*d*pA). Summing one sample
for every listed emitter needs no emitter-selection PDF. The equivalent
solid-angle density is pA*d*d/ce. Zero distance and back-facing emission
contribute zero. The renderer multiplies this estimate by the surface
albedo and its existing diffuse mixture weight, while emissive hits add
outward radiance directly. Mirror/refraction paths and radiance IOR factors
reuse the same bounded kernel as the earlier entry point.

Visibility traces the entire finite segment to the sampled point,
extending the shadow far bound when needed. The final origin-offset
interval is tolerated at the endpoint so the visible light does not
self-occlude. Glass blocks these shadow rays, consistent with the earlier
conservative policy. This produces geometric soft shadows; it does not
approximate refracted caustics. Area descriptors themselves do not form
extra intersection primitives; their visible triangles carry all hits.

Sampling uses interaction 0..63, dimension 0 for lobe choice and two
subsequent dimensions per emitter. Pixel/sample IDs and seed are uint32;
cap stays 0..64. The domain mapping and canonical binary32/64 Float
conversion are in [Random](../../Random/docs/README.md). Camera film/lens
sampling reserves interaction 4294967295. These APIs accept explicit
arrays or generate samples in ordinary X_eTaL; no host rendering code or
effect-order RNG is used. Input permutation/chunking preserves the result.

The [area tests](../tests/areas.xtl) check constant-radiance/PDF weights,
one-sided visibility, matching geometry, chunks/order, and a bright panel
seen through a sampled glass reflection without bloom. Uniform area
quadrature for an occluded rectangle converges at 4,16,64 strata per axis
against the analytical rectangle form factor. A separate Philox sample
estimate checks the same soft-shadow reference. See the
[film/lens/area demo](../demos/example.xtl) for a small one-sample live test,
a thin lens, visible HDR panel, soft shadows and separate path diagnostics.
No caustics, dispersion or bloom is added by these APIs.

Area radiance/sidedness follow the documented equations in PBRT's
[Area Lights](https://www.pbr-book.org/4ed/Light_Sources/Area_Lights).
The estimator is an original array implementation; no renderer code is copied.


## Reviewable rendered scenes

The [cap-convergence diagnostic](../demos/cap-convergence.xtl) also shows a color image with
an orange strip behind the sphere, so refraction can be judged directly.
Its pixel colors average two sampled paths. The
[lens/area demo](../demos/example.xtl) shows a glass sphere, visible
bright panel and geometric soft shadows. These are CPU reference renders
with finite sample counts: the one-sample area test is visibly noisy.
Increase `spp` for a smoother image at a higher computation cost. They do
not add caustics or bloom.

Both use RayTrace's SVG pixel display and the existing picture channel.
The website keeps the antialiased reference visible before the source and
after Run. Quick low-resolution output is opt-in, inside a closed panel.
Small image snapshots are compared with the native program's actual
picture output in the site tests.


## Presentation images

The live site also records larger antialiased images, separate from the
small runnable demos. Captions state native resolution and sample count.
See [rendered scenes](../../../docs/rendered-scenes.md) for offline
rendering, resumable chunks and provenance validation.
