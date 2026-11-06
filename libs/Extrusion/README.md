# Extrusion

Triangulate simple 2D contours and extrude them into closed, outward-facing
3D meshes. Original block glyphs cover `X_eTaL`. One statement macro
creates named contour or letter meshes with compile-time validation.

Import with `"ex:" u_se< "Extrusion"`; put its `src` directory and
Geometry, Vector3, Matrix, Parsing and Strings on `XETAL_PATH`
(`just path`). Parsing and Strings support the macro loaded by name.

See the [reference](docs/README.md), [logo demo](demos/logo.xtl), and
[tests](tests/). Run `just demo Extrusion` or `just test-lib Extrusion`.
