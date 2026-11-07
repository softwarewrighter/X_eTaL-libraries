# Scene

A small scene DSL creates eight named numeric arrays for the opaque v1
triangle renderer. Ordinary constructors validate the same data, and
runtime functions animate rigid transform groups without reparsing text.

Import with `"sc:" u_se< "Scene"`. Put Scene, Extrusion, Geometry,
Vector3, Matrix, RayTrace, Parsing and Strings source directories on
`XETAL_PATH` (`just path`). Importing by name loads the macro too.

See the [reference](docs/README.md), [CPU logo demo](demos/logo.xtl), and
[tests](tests/). Run `just demo Scene` or `just test-lib Scene`.

Opt into `sc:s_cene2<` for analytic spheres, closed boxes/octahedra, finite
floors and dielectric material data, with separate object and global
primitive IDs. See the [solids demo](demos/solids.xtl) and
[v2 contract](../../docs/scene-v2.md). Glass transport is separate.

V2 declarations also support a shared lens, material emission, and visible
rectangular area emitters with matching sampling descriptors.
