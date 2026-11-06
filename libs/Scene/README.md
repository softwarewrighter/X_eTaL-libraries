# Scene

A small scene DSL creates eight named numeric arrays for the opaque v1
triangle renderer. Ordinary constructors validate the same data, and
runtime functions animate rigid transform groups without reparsing text.

Import with `"sc:" u_se< "Scene"`. Put Scene, Extrusion, Geometry,
Vector3, Matrix, RayTrace, Parsing and Strings source directories on
`XETAL_PATH` (`just path`). Importing by name loads the macro too.

See the [reference](docs/README.md), [CPU logo demo](demos/logo.xtl), and
[tests](tests/). Run `just demo Scene` or `just test-lib Scene`.
