# RayTrace

Ordinary X_eTaL triangle tracing with pinhole rays, ambient/diffuse
point lighting, hard shadows, and one bounded mirror reflection.
Import with `"rt:" u_se< "RayTrace"`; put its source directory and
Vector3 and Matrix on `XETAL_PATH` (`just path`).

See the [reference](docs/README.md), [diagnostic](demos/diagnostic.xtl)
and [tests](tests/). Run `just demo RayTrace` or `just test-lib RayTrace`.
The diagnostic prints raw linear and display RGB; a host can encode it.
