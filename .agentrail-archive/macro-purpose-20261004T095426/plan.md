# macro-purpose

Saga 7 of X_eTaL-libraries (docs/plan.md): the user's rule for macros:
use a macro only where it solves a problem a function or a guard
cannot, and demo that purpose. Gratuitous uses go; the planned macro
libraries are chosen by the problem they solve.

## Steps

1. no-gratuitous-macros -- remove the heights demo's i_f< (a guarded
   function does it); audit every demo and test; the rule in CLAUDE.md
   and the plan.
2. test-first -- Control (conveniences) set aside; Test.xtlm, whose
   e_xpect< names the expression it checks (a function never sees its
   argument's source), designed on paper, its bodies tested in the
   gate like Control's were.
3. macro-roadmap -- docs/macros.md: the problems that warrant a macro,
   the planned macro libraries (Test; Format strings checked at compile
   time; conditional compilation), what each needs from X_eTaL (a new
   ask for compile-time information), README and live demo updated.
