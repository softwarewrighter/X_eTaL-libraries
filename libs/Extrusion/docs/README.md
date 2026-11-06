# Extrusion

Ordinary X_eTaL triangulation and symmetric polygon extrusion, original
block-letter outlines, and one macro that creates named geometry bindings.
Import with `"ex:" u_se< "Extrusion"`. Ordinary functions depend on
Geometry and Vector3 (which imports Matrix); the macro also imports
Parsing and Strings. Importing by name loads both files, so put all six
libraries' source directories on `XETAL_PATH` (`just path`).

| Data | Layout | Used by |
| ---- | ------ | ------- |
| contour | 2 by N numeric, x over y | `ex:t_riangulate`, `ex:e_xtrude` |
| cap indices | N-2 by 3 Int, one-based | result of `ex:t_riangulate` |
| mesh | T by 3 by 3 Float, triangle/vertex/xyz | `ex:e_xtrude`, `ex:l_etters`, macro triangle bindings |
| glyph | one-character string | `ex:g_lyph`, `ex:a_dvance` |
| word | nonempty string | `ex:l_etters`, macro letters mode |

## Contours and triangulation

A contour uses Geometry's layout: a 2 by N numeric matrix, x over y.
Closure is implicit: do not repeat the first point at the end. N must
be at least three. Both clockwise and counterclockwise input are accepted.
Only one simple contour is supported, without holes. Straight intermediate
boundary vertices are retained; adjacent backtracking is refused.

`ex:t_riangulate contour` returns an (N-2) by 3 Int matrix of original
one-based vertex indices. Every triangle is counterclockwise in xy.
Ear clipping scans the remaining boundary in order and removes its first
strictly convex ear that contains no other remaining vertex, including
its boundary. A clockwise contour's index order is reversed first.
The order is deterministic, but changing the contour's starting vertex
can change the chosen diagonals.

For `p := 2 4 r_eshape 0 2 2 0 0 0 1 1`, triangulation gives rows
`4 1 2` and `2 3 4`. The original coordinates are never replaced by a
convex hull, snapped, deduplicated or otherwise repaired. Malformed and
tolerance-ambiguous contours panic with an Extrusion diagnostic.

## Tolerance and validation

Predicates subtract the first vertex and divide by the longest bounding
box side. All distances and oriented twice-areas are then dimensionless;
the tolerance is 1e-10. Distinct vertex distances must exceed it. The
absolute polygon twice-area must exceed it, and every ear and final
triangle must have positive oriented twice-area greater than it.

Validation rejects nonfinite coordinates, arithmetic overflow, repeated
vertices, zero-length edges, adjacent edge reversal/overlap, intersections
or touches between nonadjacent edges, and zero-area contours. Segment
checks include collinear overlap and nonadjacent vertex contacts. Bounding
boxes and orientation tests use the same normalized tolerance, so a
contour with nearly touching edges can refuse rather than be guessed valid.
No automatic hole detection or Boolean repair is attempted.

Predicates use ordinary Float arithmetic rather than exact predicates.
Normalization improves translation and scale behavior but cannot recover
coordinates already rounded to the same value or prevent every extreme
intermediate underflow. Keep features well separated relative to the
contour's extent. Very small features and nearly degenerate triangulations
can refuse even when mathematically simple. Runtime and macro construction
use these same checks; there is no weaker macro-only geometry path.

## Extrusion

`depth ex:e_xtrude contour` returns T by 3 by 3 Float triangles, with
triangle, vertex, xyz axes, matching the shared scene mesh contract.
Depth must be a positive finite scalar whose half is representable and
nonzero. The contour stays in xy, centered symmetrically at z=0:
`z=-depth/2` through `+depth/2`. Each face follows the right-hand rule.

The output has `T=4*N-4` triangles in this order:

1. N-2 positive-z cap triangles in ear-clipping order.
2. N-2 negative-z cap triangles with reversed vertex order.
3. Two triangles per counterclockwise boundary edge, in boundary order,
   pointing outward from the side wall.

A 2 by 1 rectangle extruded to depth 0.5 has 12 triangles, bounds
x=0..2, y=0..1, z=-0.25..0.25, and signed volume 1. Tests independently
check volume, positive/negative cap normals, outward side normals, and
exactly one reversed mate for every directed mesh edge. The concave X
also retains its notches when traced with RayTrace.

## Original glyphs and words

`ex:g_lyph text` returns one 2 by N Float outline, where text is a
one-character string from `X`, `_`, `e`, `T`, `a`, `L`. Uppercase glyphs
are one unit high and one unit wide. Lowercase e is 0.8 high/wide; a is
0.8 high and 0.85 wide. The underscore spans x=0..1, y=-0.2..-0.05.
All coordinates are original straight-segment block/stroke drawings.
The lowercase a has a faceted rounded bowl and a right-hand stem; e has
a rounded body and a crossbar. Their counters use narrow openings rather
than polygon holes, preserving the simple-contour API. These are original
logo glyphs, not a font or typographic glyph standard.

`ex:a_dvance text` returns that glyph's width plus a fixed 0.2 gap.
For `X_eTaL`, advances are `1.2 1.2 1.0 1.2 1.05 1.2`.
`depth ex:l_etters text` extrudes a nonempty word in character order,
places its first glyph at x=0, and moves each subsequent glyph by the
sum of preceding advances. The common baseline is y=0. The result is
one triangle array containing separate closed solids. It is not their
Boolean union. A word containing an unsupported character refuses and
names that character. Arbitrary fonts, spaces and unknown glyphs are not
silently replaced. The corrected six-letter logo has 288 triangles; advances and bounds
remain unchanged.

## Named geometry macro

The statement macro `ex:e_xtrude<` creates named numeric bindings and
performs all geometry validation before compilation. It is useful when
source should introduce a contour/mesh or logo assets by name. Ordinary
functions remain the API for runtime data; constant folding alone would
not warrant a macro.

```text
"tile" ex:e_xtrude< "depth .5 contour 0 0; 2 0; 2 1; 0 1"
"logo" ex:e_xtrude< "depth .3 letters X_eTaL"
```

Contour mode generates `tiledepth`, `tilecontour` and `tiletriangles`.
Letter mode generates `logodepth`, `logoadvances` and `logotriangles`.
The left prefix must be a lowercase variable name (letters/digits after
its first lowercase letter). Reserve its generated suffix names in the
calling scope. Two different prefixes coexist; ordinary compiler binding
checks report collisions with existing variables or a reused prefix.
The macro cannot inspect the caller's bindings or types.

The grammar is exactly `depth NUMBER contour X Y; X Y; ...` or
`depth NUMBER letters WORD`. Whitespace separates tokens; semicolons
separate contour points. Signed decimals, leading/trailing decimal
points and signed decimal exponents are accepted, provided the literal
contains digits and produces a finite number. Missing point coordinates,
extra tokens, empty points, trailing semicolons, unknown modes, invalid
numbers and unsupported characters refuse with `error[bad-extrusion]`.
There are no comments, expressions, named contour references or arbitrary
geometry scripting in this grammar.

The macro imports its own ordinary implementation at expansion time,
uses Parsing for names, point splitting and numeric token validation,
and emits only literal arrays and ordinary bindings. It neither injects
imports nor assumes a caller alias. No renderer, device code, runtime
text parser or function call is emitted. Tests pin complete expansions
and compare resulting arrays exactly against direct construction.
See the [logo demo](../demos/logo.xtl).

## Readability regression and preview

`tests/silhouettes.xtl` pins unshaded 32 by 32 primary-hit masks for a
and e, plus known empty-counter and filled-stroke samples. This catches
appearance changes that still pass volume, winding and edge pairing.
The masks come from the exported extruded meshes through RayTrace;
there is no separate glyph bitmap or host geometry implementation.

Run `just glyph-preview` for isolated front views and the full X_eTaL
word at zero and 0.35 radians, keeping X fixed and rotating the tail.
It writes an SVG to `work/glyph-readability/silhouettes.svg`, outside git.
If `rsvg-convert` is installed it also writes a PNG beside it. The host
only packages the numeric hit masks as SVG, without changing glyphs or
repairing rendered pixels. The preview uses the same ray/mesh sources
as the regression and needs no Python package dependency.

## Export types

Numeric arrays are independently polymorphic on input, then converted
to Float; triangle index output remains Int. Shapes are checked at runtime.

```text
ex:t_riangulate : Num a => a -> Int
ex:e_xtrude : (Num a, Num b) => a -> b -> Float
ex:g_lyph : Char -> Float
ex:a_dvance : Char -> Float
ex:l_etters : Num a => a -> Char -> Float
ex:e_xtrude< : Char -> Char -> Char
```

## Limits and provenance

Validation checks all pairs of contour edges and vertices. Ear clipping
uses a simple first-ear search, with up to cubic work and recursion
bounded by N-3 removals; word construction is bounded by its character
count. This is a small CPU reference for modest contours, without a
spatial index or performance promise. GPU integration belongs to the
consumer. Holes, bevels, general solids, fonts and CSG are later features.

All implementation and glyph coordinates are original MIT work for this
library. No font file, POV-Ray code, bundled renderer asset or third-party
implementation was copied. Ear clipping is reimplemented from its
mathematical behavior; the algorithm reference is David Eberly,
[Triangulation by Ear Clipping](https://www.geometrictools.com/Documentation/TriangulationByEarClipping.pdf).
Geometry supplies distance checks; Vector3 supplies runtime mesh moves.
No language workaround or pin change is needed.
