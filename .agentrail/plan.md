# more-macros

Saga 9 of X_eTaL-libraries (docs/plan.md, docs/macros.md): more
domain macros, each beside its library, each solving what a function
cannot, each with a demo of that purpose and a test of its
compile-time error. Expansions use built-ins only (an expansion
cannot name the importer's alias for the library: the open part of
ask X14).

## Steps

1. bits-fields -- Bits: @ b:f_ields< "flag:1 mode:3 count:12" defines
   a getter and a setter per field (u:m_ode, u:s_etMode), offsets
   computed and widths checked when the program is compiled.
2. csv-columns -- Csv: "name:text age:number" cs:c_olumns< "t" defines
   a variable per column of table t, texts or numbers as declared.
3. check-cases -- Check: "u:s_quare" k:c_ases< "2 -> 4; 3 -> 9" one
   check per row, each labelled by its own source text.
4. release -- docs/macros.md, README, live demo reviewed; asks.
