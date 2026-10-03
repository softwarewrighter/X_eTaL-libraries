# Geometry

Plane geometry: points as 2-row matrices, distances, polygon area and
centroid, rotation, scaling and moves, convex hulls, pictures.

```
"ge:" u_se< "Geometry"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `ge:` is the
recommended alias.

Points are a matrix of 2 rows, x over y, one point per column, as
X_eTaL's `[]P_ATH` takes them, so any set of points can be drawn; a
polygon is its corners in order. Results are Floats.

## Functions

| Function | Type | What |
| -------- | ---- | ---- |
| `ge:d_istances p` | `Num a => a -> Float` | the distance between every pair of points |
| `ge:a_rea p` | `Num a => a -> Float` | the polygon's area (the shoelace formula) |
| `ge:c_entroid p` | `Num a => a -> Float` | the polygon's centre of mass, x and y |
| `angle ge:r_otate p` | `(Num a, Num b) => a -> b -> Float` | the points turned anticlockwise about the origin (radians) |
| `f ge:s_cale p` | `(Num a, Num b) => a -> b -> Float` | the points scaled about the origin by one factor or two (x and y) |
| `d ge:m_ove p` | `(Num a, Num b) => a -> b -> Float` | the points moved by `dx dy` |
| `ge:h_ull p` | `Num a => a -> a` | the convex hull: its corners in order, clockwise from the lowest of the leftmost points |
| `ge:s_how! p` | `Num a => a -> Char` | the polygon, closed, as a picture shown with `[]S_HOW` |

## Examples

From `../tests/basics.xtl`, with the square `sq := 2 4 r_eshape 0 2 2
0  0 0 2 2`:

```
      ge:a_rea sq
4.0
      ge:c_entroid sq
1.0 1.0
      (10 -1) ge:m_ove sq
10.0 12.0 12.0 10.0
-1.0 -1.0  1.0  1.0
      tri := 2 3 r_eshape 0 4 0  0 0 3
      ge:a_rea tri
6.0
      pts := 2 9 r_eshape 0 4 4 0 2 1 3 2 1  0 0 4 4 2 1 3 4 2
      ge:h_ull pts
0 0 4 4
0 4 4 0
```

`../tests/checks.xtl` checks with the Check library: a 3-4-5
triangle's area and longest side, rotation keeping areas and
distances, scaling by 2 making the area four times, a move moving
the centroid, a hull holding the extreme points with the right area.

## Demos

- [`demos/hull.xtl`](../demos/hull.xtl): a fence round 40 random trees:
  the convex hull, its corners, area and centre, and its picture
  (`just demo Geometry`).

## Limits

- `ge:h_ull` wraps the hull one corner at a time, testing every point
  against every candidate (gift wrapping): fine for hundreds of
  points.
- `ge:s_how!` draws the outline only; `[]P_ATH` has no markers for
  single points.

## Provenance

| Function | After |
| -------- | ----- |
| `a_rea`, `c_entroid` | the shoelace formula, with rotate (`1 o_-`) pairing each corner with the next |
| `d_istances` | outer products of the coordinate differences |
| `r_otate`, `s_cale`, `m_ove` | the 2-D transforms, written on whole rows of coordinates |
| `h_ull` | Jarvis's gift-wrapping march, each step a whole-array cross-product table |
