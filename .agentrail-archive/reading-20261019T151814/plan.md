## Saga 13 -- reading (in progress)

The user (2026-10-17): a reading library for macro authors, so that
no macro reads part of its argument and drops the rest (the class of
error Equations had, X_eTaL docs/type-check-macros.md approach 9),
started now and folded into the integrals work later. `Reading`
(`rd:`) is a plain `.xtl` library of total text readers for `.xtlm`
files: the pieces every notation needs (split at a separator outside
brackets, a balanced group and its inside, a chain and its operators
with a leading minus, a name, a number, a binding `i:=a..b`, a
function applied), each either using all of its text or refusing it
with `[]R_EJECT` at a given place, and a reprint check that writes a
reading back to compare with its text. Equations and Tags then read
through it; the pipeline macro (X_eTaL-ML) and the integral macros
are its next users.

| Step | Slug | Content |
| ---- | ---- | ------- |
| 1 | reading-library | `libs/Reading`: the readers above, generalized from Equations' helpers, each with a rejection test and a doc example; the catalog row and the macros page |
| 2 | equations-on-reading | Equations reads through Reading (no behavior change: every golden, the differential test and the catalog unchanged) |
| 3 | tags-on-reading | Tags' `e_num<` and `p_arts<` read through Reading, with a whole-text check; their goldens unchanged |

## Saga 5 -- more libraries (done, archived; release 0.3.0)
