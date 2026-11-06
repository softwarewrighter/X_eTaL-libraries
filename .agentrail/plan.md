## GPU ray libraries (2026-11-06, user priority)

Requests RL1-RL4 in `../X_eTaL-gpu/docs/xetal-libraries-ask.md` are
accepted for implementation here. Order: RL1 Vector3, RL4 diagnostic
renderer (including shadows and one reflection bounce), RL2 extrusion
and original glyphs, RL3 scene constructors and scene DSL. These steps
preempt the remaining Matrix shipping step; that step stays queued.
GPU lowering, device validation, image encoding and benchmark harnesses
remain the consumer's responsibility. No sibling ledger is edited here.

RL1 delivers Vector3 as a 3D companion, preserving Geometry's 2D
layout and reusing Matrix products. Ordinary functions suffice; no macro
is warranted. The subsequent geometry macro must earn its place through
named bindings and early diagnostics, rather than constant folding alone.

### Accepted v1 numeric contract

Adopt the GPU request's proposed v1 contract without changes. Float
arrays use right-handed xyz, y up, radians, and N by 3 point rows.
Rigid matrices act on column vectors; homogeneous rows multiply their
transpose. Positive pi/2 about y sends (1,0,0) to (0,0,-1).

| Array | Shape and meaning |
| ----- | ----------------- |
| triangles | T by 3 by 3 Float: triangle, vertex, xyz; declaration order |
| materialids | T Int: one-based material row |
| groupids | T Int: one-based transform group |
| materials | M by 4 Float: linear RGB and reflection weight, each 0..1 |
| transforms | G by 4 by 4 Float: row-major rigid matrices |
| pivots | G by 3 Float: local pivots in scene units |
| camera | 10 Float: eye xyz, target xyz, up xyz, vertical fov radians |
| lights | L by 6 Float: point-light position xyz and linear RGB intensity |

Group row 1 is reserved identity. Names are compile-time metadata;
IDs remain Int, separate from masks, distances and colors. Mesh normals
come from transformed edges with outward winding documented by extrusion.
Resolution, near/far clipping, sampling and bounce count are separate
render parameters. Backend, precision and scheduling stay outside scene
semantics. RL2 and RL3 must produce this same contract. No language pin
change is required for RL1 (abdd371d). The legacy upstream summary was
run; its heuristic yes/no table is not evidence against the pinned
language's working features.


## Preserved Matrix work

## Saga 27 -- matrix-subspaces (planned; next, ahead of 19-25)

`../X_eTaL-fine-tuning/docs/xetal-libraries-asks.md` FL2 and FL3
(filed 2026-11-05 for its LoRA lessons: lora-vs-fa projects each
learned update onto the frozen A's row space and compares it with the
Eckart-Young optimum; its Saga 3 measures angles between subspaces).
Both go into Matrix (`mx:`), one saga, because FL3's principal angles
are the singular values FL2 asks for. Taken ahead of Sagas 19-25 by
the user (2026-11-05). Every iteration has a stated tolerance and a
stated cap on its sweeps; every result is checked against a matrix
built with known values (a rotation times a known diagonal), not only
against itself.

FL3's workaround, `M '+ '* i_nner (o_\ B) '+ '* i_nner (mx:i_nverse B
'+ '* i_nner o_\ B) '+ '* i_nner B`, is right but inverts `B B'`,
which loses digits as B's rows approach dependence; the library
projects through an orthonormal basis instead (`M Q' Q`), and its test
shows the difference on a nearly dependent B. FL2's workaround, power
iteration with deflation on `M' M`, squares the condition number; the
library's SVD is one-sided Jacobi on M itself.

| Step | Slug | Content |
| ---- | ---- | ------- |
| 1 | subspace-basis | at saga start `just upstream`; `mx:o_rthonormal B`: an orthonormal basis of B's rows by modified Gram-Schmidt (twice, for orthogonality to the last digits), dropping a row whose remainder is below a stated relative tolerance, so the result has as many rows as B's rank; `mx:r_ank B` its count (X_eTaL-ML's `lo:r_ank` keeps only that); tests on independent, dependent and nearly dependent rows, `Q Q'` against the identity |
| 2 | subspace-projection | `B mx:p_roject M` (each row of M projected onto the span of B's rows, through `mx:o_rthonormal`), `B mx:r_emainder M` (M minus it, orthogonal to every row of B), and the change of basis, `B mx:c_oordinates M` (each row's coordinates in B's rows, B independent: solved, so B need not be orthonormal); tests: idempotence, the remainder orthogonal to B, project + remainder = M, FL3's own workaround as a differential test where B is well conditioned and its loss shown where B is not |
| 3 | symmetric-eigen | `mx:e_igenvalues S` and `mx:e_igenvectors S` (cyclic Jacobi on a symmetric S, descending values, vectors as rows, signs fixed by a stated rule so goldens are stable); a non-symmetric S refused with `p_anic<`, not quietly symmetrized; the tolerance and sweep cap on the page; tests against `R D R'` with known D and R, `S v = lambda v` for each pair, repeated eigenvalues; whether one tuple-returning export reads better than two is decided here (the user's rule: currying unless a tuple reads better) |
| 4 | svd-truncate | `mx:s_ingular M` (singular values, descending, by one-sided Jacobi on M) and `k mx:t_runcate M` (the best rank-k approximation, Eckart-Young), with the factors behind them exported if the lessons need them (`mx:s_vd`: U, s, V); tests against `U diag(s) V'` built with known values, the rank-k error equal to the dropped singular values (Frobenius and spectral), a rank-deficient M, a wide and a tall M |
| 5 | principal-angles-ship | `A mx:a_ngles B`: the principal angles between the row spaces of A and B, the arc cosines of the singular values of `Q_A Q_B'` clamped to 1 (radians, ascending; Trig's `tr:a_cos`, or the small-angle form from the sines where the cosine loses digits, decided and stated on the page); tests: equal spaces (all 0), orthogonal ones (pi/2), a known rotation; then ship: Matrix's docs page (every new export, accuracy and limits), a demo (a LoRA-sized toy: a learned update projected onto a frozen basis, its best rank-k, and the angle between the two), the catalog row, `CHANGES.md`; the peer's ledger is that repository's to update |


## RL4 implementation and compatible glass requests

RL4 RayTrace now supplies the opaque v1 diagnostic renderer, with
finite t/u/v outputs, separate Int mask/nearest IDs, point lighting,
hard shadows, one bounded reflection and shared sRGB conversion.
45 analytical/pixel checks and 27 refusal cases cover its contracts.
Pixel chunks reproduce raw arrays exactly; a T-step primitive sweep
holds one candidate face per ray without a full pixels-by-triangles
matrix. The world-space v1 mesh contract remains unchanged.

The new peer ledger asks RL5-RL7 are accepted as follow-ons after the
already queued v1 work and Matrix shipping: RL6 geometry plus explicit
v2 schema/adapter finalization first, then RL5 dielectric transport,
then RL7 deterministic sampling, lens and emitter support. The peer's
v2 schema remains a proposal until that step tests/finalizes it.
Preserve all v1 meanings and baselines. RL8 caustics and RL9 dispersion
and bloom stay deferred; neither has an implementation step queued.
The GPU owner updates its own ledger and pins delivered commits.


## RL2 extrusion implementation

Extrusion supplies validated simple Geometry-layout contours, deterministic
Int ear-clipping indices and outward symmetric meshes in the shared v1
triangle contract. Original open-counter block glyphs cover X_eTaL with
fixed advances. The named geometry statement macro reuses the same
ordinary functions and emits self-contained numeric depth/contour/mesh
or depth/advance/mesh bindings, with compile-time refusals.

52 geometric/glyph/macro-equivalence checks cover rectangle volume,
normals and edge pairing; concave X volume, cap area and ray-traced
notches; every glyph and deterministic word assembly; either winding,
straight boundary vertices, scaling and translation; macro/direct exact
agreement. Runtime and macro refusal cases, complete expansions, types
and the six-letter demo are pinned. RL3 Scene is next; no language pin
change or sibling edits are needed.
