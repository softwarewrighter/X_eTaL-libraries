# xetal-0.1.0

Saga 11 of X_eTaL-libraries: build against X_eTaL v0.1.0 (512b3ee), the
tag the sibling repos pin to, and retire the workarounds for the asks
it landed (X4 character codes, X9 decode on any numbers).

## Steps

1. bump-0.1.0 -- XETAL_COMMIT 512b3ee; baselines reviewed and rebased
   (Check's expansions: hygienic macros rename lambda parameters;
   Bits: comparisons now leave their numeric type open, so a_nd, o_r,
   x_or use Int arithmetic to stay Int -> Int -> Int); asks re-audited
   (X4, X9 landed).
2. retire-workarounds -- Strings' u_pper and l_ower by []U_CS and
   []U_CHAR (ASCII still: []U_CHAR takes 0 to 127); Polynomials'
   evaluation by d_ecode (Horner) instead of a table of powers; asks
   X4 and X9 marked landed with the workaround removed; pages updated.
3. release -- a tag of this repo (v0.5.0, after the user approves),
   its notes saying it is built against X_eTaL v0.1.0; retrospective.
