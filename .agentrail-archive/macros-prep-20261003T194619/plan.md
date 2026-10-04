# macros-prep

Saga 6 of X_eTaL-libraries (docs/plan.md): ready for user macro
libraries before X_eTaL runs .xtlm files (ask X1). X_eTaL now has the
system macros i_f<, u_nless<, e_ach< and xetal expand (vendored
5dccb9b), so Control is redesigned around macros X_eTaL lacks, its
bodies tested now, and the live demo shows macros and expansions.

Rules as before (CLAUDE.md, plan A9: macro syntax is never emulated
for users; bodies are tested as text-to-text functions). Every step:
just pages, just gate, docs, a detailed commit to main with
.agentrail/, agentrail complete, push.

## Steps

1. control-redesign -- Control.xtlm: x:c_ase<, x:w_hen<, x:l_et<;
   expansions type-checked at compile time like written code;
   malformed calls fail at compile time; check.sh cases (expansions,
   results, compile-time errors) and the system macros' expansions.
2. expand-in-site -- the live demo shows a program's expansion
   (system macros now, Control's when .xtlm lands) beside it.
