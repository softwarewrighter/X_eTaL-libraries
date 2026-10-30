## Saga 17 -- equations-grammar (planned)

`../X_eTaL-ML/docs/xetal-libraries-asks.md` E1-E3 (filed 2026-10-20
from the diffusion sampler of `demos/pipelines/diffusion.xtl`, a
paper's equation for `X0`): three gaps in Equations' grammar, found by
a real paper's notation rather than invented. Equations' rule is
deliberate (a fixed table of functions, every rule uses all of its
text or refuses it, plan A8's "not a bug, an ask"), so each of these
is a grammar change weighed on its own, not a patch.

| Step | Slug | Content |
| ---- | ---- | ------- |
| 1 | descending-range (E1) | A descending range, `sum t:=T..1 | ...`, dies today inside the lowering with `error[domain]: a count cannot be -1`, naming no rule -- a bug (A8): the capture step must refuse it itself, `error[bad-equation]` saying a sum's range runs low..high, located at the range text, not let it fall through to a runtime count error. Decided here, not left to the next session: refuse rather than read it as an empty sum -- Equations already refuses rather than guesses (the whole-text rule, Saga 13), and a silently-empty sum is exactly the class of silent wrong answer this library exists to avoid; rejection golden first |
| 2 | scan-word (E2) | A recurrence word for a sum whose term uses the one before (the sampler's sum from `T` down to 1, a scan): `scan t:=T..1 | ...` with the previous term named by a new reserved word, `prev` (decided with the user, 2026-10-23: a clean binding the macro introduces, read as the paper does, over index arithmetic on an already-materialized array -- not every scan has one -- or declining E2 and keeping the `p_ower`-applied-T-times workaround); `prev` refused outside a `scan` body; rejection and value goldens |
| 3 | named-functions (E3) | The caller's own functions by name inside an equation (`D(z[k])`, `eps_theta(z[k], t, c)`), refused today (`... is not a function of an equation`): decided with the user, 2026-10-23, to trust the program's own names -- any name applied in the equation that is not one of the fixed math functions is read as `u:name(args)` directly, no declared table argument; a bad name or arity is not caught at macro-expansion time, only when the expanded code fails to compile, and that tradeoff is stated on the library's page; value and LaTeX goldens |

