# system-macros

Saga 10 of X_eTaL-libraries: X_eTaL's system macros (vendored 4abe761)
used where they solve a real problem here, by the rule in
docs/macros.md, and nowhere else.

## Steps

1. include-data -- the Csv demos' data as .csv files beside them, built
   into the program with @ i_nclude< "cities.csv" (no long escaped
   string; the browser needs no file access); the live demo's store
   serves demo data files.
2. panic-messages -- library functions whose misuse fails with an
   obscure built-in error (a singular matrix dividing by zero, an empty
   list with no identity, ...) say what is wrong with @ p_anic< "..."
   instead; each message tested.
3. format-text -- demos that build text with long c_at chains use
   @ f_ormat< "... {expr} ..." where it reads better; d_bg<, a_ssert<
   and c_fg< not used (no problem here they solve); docs/macros.md.
