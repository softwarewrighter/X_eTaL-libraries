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
