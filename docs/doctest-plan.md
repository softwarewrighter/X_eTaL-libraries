# Doctest plan

Status: not started. This is a plan, not a saga yet; `docs/plan.md`
gets a saga entry when work on it begins.

## Why

`xetal doc` (the cross-reference at `/doc/`) runs `## >>` examples as
doctests (`xetal doc --test FILE`): a transcript under a doc comment,
checked against what the program actually prints. `../X_eTaL`'s own
standard libraries all have them (`lib-Macros.xtlm.html`, linked by
the user 2026-10-07, has one under every macro); ours have none --
`xetal doc --test` finds 0 examples anywhere in this repository
(checked 2026-10-08, X_eTaL 96060b5). A page's prose now explains what
a function does (`##`, `###`, done 2026-10-08); a worked example,
run and checked, is the next thing a reference page is missing.

## The mechanics (verified against 96060b5)

- `## >> expression` is one line of a transcript; the plain `##` lines
  directly under it (no blank line) are what it prints. Several `## >>`
  lines in one doc comment are one session: state from an earlier line
  (`## >> t := 5`) is visible to a later one, as a REPL carries state.
- The `## >>` lines go **last** in the doc block, after the prose, not
  before it: prose that follows a `## >>` example (inside the same
  block, no blank line) is parsed as more of that example's expected
  output, not as a separate paragraph, and the test fails (verified by
  misplacing one in `Dates.xtlm`: "1 passed; 1 failed", the second
  failure's "expected" text was the prose paragraph). Every example in
  `../X_eTaL`'s own libraries already follows this order; follow it.
- An assignment or import line (`## >> t := 5`, `## >> "x:" u_se< "X"`)
  prints nothing of its own; it still counts as one of the file's
  examples, and still has to run without error.
- An expected error is written as `## error[code]` in place of the
  printed value (`System.xtlm`'s `p_anic<`: `## >> 1 + @ p_anic<
  "no {1 + 1}"` then `## error[panic]`); a prefix match, not the full
  message.
- `xetal doc --test FILE` takes exactly one file (not `MORE`, unlike
  `--out`): checked directly -- `--test` refuses with more than one
  file. Each library and macro library is tested on its own; a loop
  (as `scripts/check-xtlm.sh` already loops per `.xtlm` file) is
  needed to cover the repository.
- A doctest needs the functions it uses on `XETAL_PATH`, same as any
  other program here: run through `scripts/xt doc --test FILE`, not
  `xetal doc --test FILE` directly (as every other script in this
  repository does).

## Scope

168 `l:` exports (`libs/*/tests/types.out`, counted 2026-10-08) across
the 19 `.xtl` libraries, and the 6 macros in the `.xtlm` files
(`f_ields<`, `d_ate<`, `c_olumns<`, `g_raph<`, `c_ases<`, `p_oly<`):
174 candidate doctests. `h:` private definitions do not need one
(`../X_eTaL`'s own libraries never doctest a private helper; its doc
comment is enough).

Per library (exports, from `libs/*/tests/types.out`):

| Library | Exports | Library | Exports |
| ------- | ------- | ------- | ------- |
| Strings | 21 | Statistics | 8 |
| Bits | 12 | Geometry | 8 |
| Numbers | 10 | Random | 7 |
| Lists | 10 | Polynomials | 7 |
| Sets | 9 | Plot | 7 |
| Search | 9 | Matrix | 7 |
| Graphs | 9 | Grouping | 7 |
| Dates | 9 | Combinatorics | 7 |
| Check | 9 | Format | 6 |
| | | Csv | 6 |

## Where the examples come from

Not invented fresh: every library's `docs/README.md` already has an
"Examples" section, run from its `tests/basics.xtl` (or another test
program) and checked against the recorded baseline by
`scripts/check-examples.py`. That is the same content a doctest needs
-- a short session, its real output -- in a different place and a
different, weaker check (textual presence in a baseline file, not a
run of the example itself). The plan is to move these into the source
as `## >>` examples (adapted: a doctest is per function, the page's
examples are often a short program using several functions together),
not to write 174 new ones from nothing.

Once a library's exports all have doctests, `check-examples.py`'s job
for that library is covered more strongly by `xetal doc --test`
(an example that stops matching is caught by running it, not by
grep); whether to then simplify or retire `check-examples.py` for that
library is a decision for the step that gets there, not this plan.

## Gate integration

A new `scripts/check-doctests.sh`, modeled on `scripts/check-xtlm.sh`:
loop `libs/*/src/*.xtl` and `libs/*/src/*.xtlm`, `scripts/xt doc --test
FILE` on each, fail the gate on the first failure. Added to
`scripts/gate.sh` after `check-examples.py`. Until every library has
doctests, the script only checks the files that have at least one
`## >>` (a library with none is not a failure, just not started yet --
`grep -l` for `## >>` first, skip files without it), so the gate does
not block the rest of this repository while doctests are added
library by library.

## Open questions (for the user, before starting)

1. **Order.** Smallest libraries first (Format, Csv: 6 exports each)
   to settle the convention cheaply, or by what a reader is most
   likely to open first (the front door's groups in `README.md`)?
2. **Panics.** Eleven libraries have a `@ p_anic<` guard (saga 10,
   `panic-messages`) with its own `tests/panic-*.xtl`. Worth a doctest
   per guard (`## error[panic]`), or is the existing test enough and a
   doctest should stick to the ordinary case?
3. ~~**Macros.**~~ Resolved 2026-10-08: `xetal doc --test` runs a
   macro's own `## >>` example correctly (checked on a scratch copy of
   `Dates.xtlm`'s `d_ate<`, removed after). The ordering rule above
   (`## >>` last) is what made the first attempt fail.
4. **`check-examples.py`.** Retire it library by library as doctests
   land, keep it as a second check, or leave it only for libraries
   with no doctests yet? (Leaning: keep it until every library is
   covered, then decide once, not library by library.)

## Suggested steps (once the open questions are answered)

1. One library, start to finish: doctests for every export, verify
   `xetal doc --test` catches a deliberately wrong one before fixing
   it, `scripts/check-doctests.sh` added to the gate (skipping
   libraries with none yet), docs/plan.md records the convention
   settled.
2. The rest of the `.xtl` libraries, a few at a time, each its own
   commit (168 exports total; the step list is not fixed in advance --
   add steps as the work is sized after step 1).
3. The 6 macro doctests.
4. Retire or scale back `check-examples.py` per the decision in open
   question 4; `scripts/check-doctests.sh` covers every library
   unconditionally (drop the `## >>`-presence skip); `/doc/` rebuilt
   and published; retrospective.
