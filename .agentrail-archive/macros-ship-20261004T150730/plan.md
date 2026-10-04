# macros-ship

Saga 8 of X_eTaL-libraries (docs/plan.md): ship the domain macros now
that X_eTaL main runs macro libraries (6239aad: asks X1, X12, X13, X14
landed).

## Steps

1. vendor-macros -- vendor X_eTaL 6239aad (its own commit); every
   baseline re-run.
2. rewrite-macros -- d_ate<, p_oly<, g_raph< with @ for no argument,
   []R_EJECT messages, Dates' arithmetic from Dates.xtl by path.
3. macros-in-tests -- the macros/ programs into the ordinary reg-rs
   tests and demos; check-xtlm with the @ side and xetal type X.xtlm;
   just macros retired or kept for lanes.
4. macros-in-site -- the live demo loads .xtlm files; a program in the
   browser uses d:d_ate<; Expand shows their expansions.
