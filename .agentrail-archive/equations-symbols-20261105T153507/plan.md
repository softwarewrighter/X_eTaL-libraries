## Saga 26 -- equations-symbols (planned; ahead of 27 and 19-25)

`../X_eTaL-fine-tuning/docs/xetal-libraries-asks.md` FL1 (filed
2026-11-05): Equations' LaTeX (`e:t_ex<`, and X_eTaL-ML's
`flow:m_ath<` through it) does not mark the symbols it draws, so a
page cannot tell which glyphs are `A`, `x` or `s` and cannot highlight
a symbol together with its matrix. Asked: an option of the macro (no
new syntax) wrapping each array reference and each named scalar in a
class naming it, as KaTeX's `\htmlClass{sym sym-A}{A_{k,j}}`. Its
workaround wraps names in the LaTeX by text, with a test that fails
loudly when the spelling changes. Needed by its lora-lab Saga 1 step
3, so taken first (the user, 2026-11-05). The macro already parses
every symbol, so the classes come from the same parse as the LaTeX,
never from the text.

| Step | Slug | Content |
| ---- | ---- | ------- |
| 1 | symbols-design | at saga start `just upstream`; decide, and record here: the option's form (a new export beside `e:t_ex<`, such as `e:t_exSymbols<`, or a word in the existing left argument; never new syntax), the class names (`sym sym-NAME`; what a name a CSS class cannot hold becomes), what is wrapped (an array reference with its subscripts; a named scalar; not an index, a bound variable or a function name -- or yes, decided here), that `\htmlClass` needs KaTeX's `trust` (so `scripts/check-latex.sh` and the site's KaTeX need it for these goldens only); goldens first, failing |
| 2 | symbols-latex | the option implemented in `Equations.xtlm` from the parse `e:t_ex<` already makes (`e:b_oth<` too, if decided); every equation in the catalog and the CNN demo through it, each symbol found once per occurrence; the plain `e:t_ex<` output unchanged, byte for byte (every existing LaTeX golden passes without a rebase) |
| 3 | symbols-ship | the docs page (the option, the class names, the KaTeX `trust` note), a demo whose page highlights a symbol (or the LaTeX golden that a page would use), `CHANGES.md`; the peer's workaround can then go, at its next re-pin |
