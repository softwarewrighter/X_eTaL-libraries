# Scene

Scene turns a small named scene declaration into ordinary numeric arrays.
Its functions also validate dynamic data and animate transform groups.
Import with `"sc:" u_se< "Scene"`. Dependencies are Extrusion, Geometry,
Vector3, Matrix, RayTrace, Parsing and Strings; put all eight libraries'
source directories on `XETAL_PATH` (`just path`). Importing by name loads
both the ordinary functions and macro. There is no native rendering code.

## The v1 contract

The macro creates these eight bindings under its left prefix. All arrays
are separate; names exist only while compiling. IDs remain Int throughout.
Coordinates are right-handed xyz, y up, with scalar angles in radians.

| Suffix | Shape/type | Meaning |
| ------ | ---------- | ------- |
| triangles | T by 3 by 3 Float | triangle, vertex, xyz; object declaration order |
| materialids | T Int | one-based material row per triangle |
| groupids | T Int | one-based transform group per triangle |
| materials | M by 4 Float | linear RGB albedo and opaque reflection weight |
| transforms | G by 4 by 4 Float | proper rigid column-vector transforms |
| pivots | G by 3 Float | pivots in each group's local mesh coordinates |
| camera | 10 Float | eye xyz, target xyz, up xyz, vertical fov |
| lights | L by 6 Float | point position xyz and linear RGB radiant intensity |

Group row 1 is always the reserved identity, with zero pivot. Declared
groups start at row 2 in declaration order. An unassigned object uses
row 1. Materials follow material declaration order. Each object's complete
triangle block follows object declaration order, preserving Extrusion's
face order. No Float color or distance column carries an ID.

## Scene macro

The statement call `"logo" sc:s_cene< TEXT` creates `logotriangles`,
`logomaterialids`, `logogroupids`, `logomaterials`, `logotransforms`,
`logopivots`, `logocamera` and `logolights`. Reserve those eight names
in the calling scope. The prefix must be a nonempty lowercase variable
name: lowercase first letter, then letters/digits. Different prefixes
coexist; the compiler rejects collisions with existing bindings or a
reused prefix. The macro cannot inspect caller bindings or types.

The [logo demo](../demos/logo.xtl) uses declarations of this form:

```text
group fixed objects x
group vane objects tail pivot 1.2 0 0
object x extrude X depth .3 material silver
object tail extrude _eTaL depth .2 material copper position 1.2 0 0
material copper color .8 .3 .1 reflection .2
material silver color .8 .8 .85 reflection .3
light key position 2 5 8 color 200 200 200
camera eye 3.3 .4 10 target 3.3 .4 0 up 0 1 0 fov .18
```

There is one declaration per line; spaces and tabs separate words.
Blank lines are allowed, and # begins a comment through the end of that
line. Every line and token is consumed. Keywords appear in exactly the
order shown. Extra tokens, missing values, unknown keywords or kinds,
invalid labels/numbers and bad references refuse with `error[bad-scene]`.
Diagnostics name the offending declaration and token or reference.

Exactly one camera is required. All other lists may be empty. References
are resolved after parsing, so objects may precede their materials and
groups may precede their objects. Labels for materials, lights, objects
and groups share one namespace and must be unique. Grammar keywords and
`identity` are reserved labels. An object may belong to at most one group;
a group needs at least one distinct known object. Groups are flat.

Object syntax is `object LABEL extrude WORD depth NUMBER material LABEL`
with an optional final `position X Y Z`. WORD uses Extrusion's supported
original glyphs. Position is baked into that object's local mesh before
group animation. Without it, the first glyph begins at x=0. Depth and
all glyph geometry are checked by the ordinary Extrusion implementation.

Group syntax is `group LABEL objects LABEL ...` with an optional final
`pivot X Y Z`. The default pivot is zero. All initial transforms are
identity. An object's baked position and its group's pivot use the same
local mesh coordinate system; no nested hierarchy is implied.

Signed decimal literals, leading/trailing decimal points, and signed
decimal exponents are accepted if they contain digits and are finite.
Numbers are data rather than embedded expressions. The macro reuses
Parsing's name/number predicates and the same ordinary Scene/Extrusion
constructors used by direct callers. It emits only literal arrays and
bindings: no injected imports, caller helper aliases, runtime parser,
frame loop, renderer or device call. Mixed compile-time records used to
resolve names do not appear in the runtime data contract.

## Ordinary constructors

| Function | Input and result |
| -------- | ---------------- |
| `sc:c_amera data` | validated length-10 Float camera; reuses RayTrace's basis and fov checks |
| `sc:m_aterials rows` | M by 4 Float; every RGB/reflection value in 0..1 |
| `sc:l_ights rows` | L by 6 Float; finite positions and nonnegative RGB intensity |
| `count sc:i_ds ids` | rank-1 one-based Int IDs in 1..count; empty vectors allowed |
| `sc:t_riangles mesh` | finite T by 3 by 3 Float; arbitrary v1 triangle mesh |
| `sc:i_dentities count` | count identity matrices, G by 4 by 4 Float, count >= 1 |
| `sc:p_ivots rows` | G by 3 Float, at least one row, first pivot exactly zero |
| `sc:t_ransforms data` | G by 4 by 4 Float, at least one row, proper rigid matrices and identity row 1 |
| `((depth sc:o_bject word)_ offset)` | Extrusion letter mesh moved by a length-3 xyz offset |

Numeric inputs become Float except counts and IDs, which are Int. Camera
validation rejects coincident eye/target, zero or parallel up, and fov
outside (0, pi), using RayTrace's normalized-basis threshold of 1e-12.
Light intensities may exceed 1; material values may not. Nonfinite inputs
and results refuse. Matrix validation uses Vector3's 1e-10 orthogonality,
determinant and homogeneous-row tolerance; identity row 1 is checked to
absolute 1e-10. It is not repaired or normalized.

Constructors validate individual arrays. A direct caller uses matching
row counts and one material/group ID per triangle, as the macro does.
`sc:a_pplyGroups` additionally checks the per-triangle group count;
RayTrace checks material ID counts when rendering. There is no implicit
record or tuple holding all eight scene arrays.

## Runtime animation

`(((pivots sc:r_otateGroup group)_ angle)_ transforms)` returns transforms
with exactly one declared group changed. Group must be an Int scalar
from 2 through G; row 1 cannot be rotated. Pivot and transform counts
must match. It composes on the right:

```text
new[group] = base[group] * T(pivot) * Ry(angle) * T(-pivot)
```

Call it with the original base matrices for each absolute animation
frame. Calling it on already rotated matrices composes another local
rotation. All other group rows stay unchanged. A positive pi/2 y turn
sends (1,0,0) to (0,0,-1) relative to the pivot.

`((triangles sc:a_pplyGroups groupids)_ transforms)` applies each
triangle's group matrix and preserves triangle order. It uses homogeneous
row points multiplied by the column-vector matrix transpose through
Vector3. The output stays T by 3 by 3 Float; metadata arrays stay separate.
Each group is applied to original vertices, not the prior group's result.
This simple reference performs O(G*T) point work with group-count-bounded
recursion. Supply modest group counts and bounded downstream ray batches;
no GPU eligibility or performance is promised here.

Tests check angles 0, pi/2 and 2*pi: the fixed X remains exactly unchanged,
all vane pivot distances are preserved within tolerance, and a full turn
returns to the base mesh. A known point turns about a nonzero pivot, and
composed quarter turns agree with a half turn. Empty meshes remain valid.

## CPU logo rendering

The [demo](../demos/logo.xtl) declares the complete X_eTaL scene with
fixed and vane groups, rotates the vane by 0.35 radians, then calls the
ordinary RayTrace camera and renderer at 32 by 8 pixels. Its ASCII mask
comes from actual primary hits, followed by mean raw linear RGB and
selected sRGB pixels. No host computes geometry, shading or animation.
Resolution, ray clipping, ambient/background and exposure are supplied
separately as render parameters. The scene macro does not render.

Tests pin the expansion and compare all eight arrays with ordinary
construction, including a camera-only empty scene and multiple prefixes.
Forward references, declaration order, comments, whitespace, identity
defaults and malformed-input diagnostics are covered. GPU pinning,
lowering, precision comparisons and image-file encoding belong to the
consumer; the CPU source and data contract are the reusable deliverable.

## Export types

Each numeric input is independently polymorphic where indicated. Shapes
and units are checked at runtime; counts and IDs stay statically Int.

```text
sc:c_amera : Num a => a -> Float
sc:m_aterials : Num a => a -> Float
sc:l_ights : Num a => a -> Float
sc:i_ds : Int -> Int -> Int
sc:t_riangles : Num a => a -> Float
sc:i_dentities : Int -> Float
sc:p_ivots : Num a => a -> Float
sc:t_ransforms : Num a => a -> Float
sc:o_bject : (Num a, Num b) => a -> Char -> b -> Float
sc:r_otateGroup : (Num a, Num b, Num c) => a -> Int -> b -> c -> Float
sc:a_pplyGroups : (Num a, Num b) => a -> Int -> b -> Float
sc:s_cene< : Char -> Char -> Char
```

## Limits and provenance

This is the opaque v1 scene contract. There is no glass, analytic sphere,
area emitter, lens, nested scene graph, external asset format, arbitrary
font, expression evaluator or geometry scripting language in this grammar.
Future versioned extensions must preserve these arrays and semantics.

Original MIT implementation composing this repository's Extrusion,
Vector3, Matrix and RayTrace APIs. Glyph provenance is documented on the
Extrusion page. The numeric token grammar follows Extrusion's original
MIT macro parser and reuses Parsing predicates. No external renderer
implementation, asset or native library is used. No language pin change
or workaround is required.
