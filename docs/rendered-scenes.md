# Rendered scenes

The live demos have two image sizes. The recorded presentation image
appears immediately, with its native resolution and sample count in its
caption. The landing page shows a scene gallery before the introductory
code and catalog. Graphics libraries open on their presentation-backed
example; explicit diagnostic links retain a clearly labeled reference.

The polished reference stays visible while editing and after Run. Open
Explore the program to read the source. Run quick preview executes the
small demo, with its low-resolution image inside a closed Show the quick
render panel. Open that panel when inspecting test output. Reset restores
the original program and clears the quick output.

The larger image uses the same geometry, materials, camera and rendering
functions as the demo. It traces new rays at the stated resolution;
it does not enlarge the quick render. Original polygonal letter shapes
and hard point-light shadow boundaries remain geometric features.

These are the published presentation settings. A diagnostic without its
own presentation shows a clearly labeled reference from the library's
default scene. Low-resolution output remains opt-in. Each presentation
states its native resolution and sample count in its caption.

| Demo | Presentation pixels | Samples per pixel |
| ---- | ------------------- | ----------------- |
| Scene/logo | 640 by 320 | 4 |
| Extrusion/logo | 800 by 200 | 4 |
| RayTrace/diagnostic | 640 by 426 | 4 |
| Glass/example | 640 by 360 | 64 |

The glass presentation selects the top 360 rows of its 640 by 480
camera raster, retaining the complete sphere, panel and shadow while
omitting extra lower foreground. Ray coordinates and samples are
unchanged; this is a native camera window, with no image scaling.
The manifest records both camera dimensions and output dimensions.

Glass/example is the presentation-backed lens/area scene. The former
basic example is now Glass/cap-convergence, a numerical diagnostic. A partial
64-sample presentation exposed spatial bands from its legacy path-key
mapping, so that image is held back for a sampling correction. The
Philox-based default example is the presentation scene for glass. Older
links to #Glass/lens-area still open that same scene.

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
just presentation-scene Glass/example
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

For a real-browser check, build the site and run `just serve-pages` in
one terminal and `chromedriver --port=9461` in another. Then run:

```sh
just browser-scenes
```

Chrome/Chromium and a matching ChromeDriver must be installed. The client
uses Python's standard library; `--browser PATH` selects another browser
binary if automatic discovery does not find it. This optional check
verifies desktop/mobile first views, direct Glass/example and older
lens-area links, compact navigation, and reference persistence across
editing, Run and Reset. Screenshots are saved in `work/browser-scenes/`.
