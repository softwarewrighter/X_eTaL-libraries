# Rendered scenes

The live demos have two image sizes. The recorded presentation image
appears immediately above the editable program. Its caption states its
native resolution and samples per pixel. Run executes the small demo
and replaces that preview with freshly computed output. Reload the demo
to return to the recorded presentation image.

The larger image uses the same geometry, materials, camera and rendering
functions as the demo. It traces new rays at the stated resolution;
it does not enlarge the quick render. Original polygonal letter shapes
and hard point-light shadow boundaries remain geometric features.

These are the offline quality targets. While a render is pending, the
site labels its smaller fallback image as a quick reference. A completed
presentation has its native resolution and sample count in its caption.

| Demo | Presentation pixels | Samples per pixel |
| ---- | ------------------- | ----------------- |
| Scene/logo | 640 by 320 | 4 |
| Extrusion/logo | 800 by 200 | 4 |
| RayTrace/diagnostic | 640 by 426 | 4 |
| Glass/lens-area | 640 by 480 | 64 |

Glass/example remains a small cap-convergence diagnostic. A partial
64-sample presentation exposed spatial bands from its legacy path-key
mapping, so that image is held back for a sampling correction. The
Philox-based lens/area scene is the presentation example for glass.

Film samples use a centered square subpixel grid. X_eTaL averages
linear RGB before RayTrace applies exposure and the sRGB transfer.
The lens/area program retains deterministic Philox lens and transport
samples. The legacy basic-glass diagnostic is unchanged.
The presentation lens/area path cap is 16, versus 4 in the quick demo.
This does not add caustics, dispersion or bloom. Finite sampling can
still leave noise, especially around glass and soft shadows.

## Reproduce

From the repository root, with the pinned evaluator built:

```sh
just xetal
just presentation-scene Scene/logo
just presentation-scene Extrusion/logo
just presentation-scene RayTrace/diagnostic
just presentation-scene Glass/lens-area
just check-presentations --require-all
```

The default renderer uses eight worker processes, launched by a Python
thread pool. Use `--jobs 4` to reduce CPU use. Set `--chunk 1024` for
opaque scenes or `--chunk 128` for glass to bound evaluator batches.
These are offline CPU renders. High-sample glass images can take hours;
they are deliberately outside the regression test time limit.

Interrupted jobs resume verified chunks under `work/presentation/`.
New invocations freeze their template and copy library sources into a
content-addressed snapshot there, so unrelated workspace edits cannot
change a running job's implementation.
Each chunk records its exact executed X_eTaL source, dependency/source
hashes, RGB bytes and elapsed time. Global pixel and sample identities
are independent of chunk size and worker scheduling. The host launches
the evaluator, rounds returned display RGB to RGB8, concatenates chunks
and writes lossless PNG; it does no geometry, shading or interpolation.

The final PNG is embedded in `libs/NAME/docs/presentation-DEMO.html`
with a quality caption. Its companion JSON records dimensions, sample
count, seed, language pin, library/source hashes and every chunk's pixel
range and hashes. The PNG master and exact chunk programs stay under
`work/presentation/`; the embedded PNG is the published master too.
Avoid editing generated snapshots by hand.

## Validation

`just gate` runs small native comparisons that split real opaque/glass
ray batches at different pixel boundaries. It checks unchanged sample
identities and output, and independently decodes the lossless PNG.
Recorded images are checked for native dimensions, captions, PNG CRCs,
pixel coverage, chunk hashes and current source/dependency provenance.
Pending offline images are reported explicitly. Before the presentation
work is complete, `just check-presentations --require-all` must pass for
all four scenes in the table.

The existing small SVG pictures remain exact native/browser regression
fixtures. The site tests execute these small demos and compare their
actual output with the recorded SVGs. Large presentation frames are
validated from recorded pixels rather than recomputed inside the gate.
