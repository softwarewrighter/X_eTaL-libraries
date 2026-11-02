# reg-rs baselines: an audit and the improvements it asks for

An audit of this repository's reg-rs baselines (315 at 27478ec,
2026-11-02, in 24 libraries' `tests/`), asked for by the user: do they
test something, or are some contrived, going through the motions, or
of little value? This file lists what was found and the fix for each
item. Nothing here has been changed yet.

## How it was audited

- **Read review.** Every `tests/*.xtl` program and demo with its
  `.out` and `.err`, and a sample of the `expand-` goldens; many pinned
  values were recomputed by hand.
- **Mechanical checks.** Over all baselines: empty or tiny output,
  masked commands, FAIL lines, identical commands and outputs.
- **Mutation testing.** For each top-level definition of a library (up
  to 30 a file; 15 for Equations), one small change that still
  type-checks (`+` to `-`, `<` to `<=`, `m_ax` to `m_in`, a literal
  plus one, ...), then `scripts/test-libs.sh <Name>`: a mutant no
  baseline notices "survives". Results below cover Bits, Check,
  Combinatorics, Csv, Dates, Eigencube (in part), Lists, Matrix and
  Numbers; the rest of the run is recorded at the end when it finishes.
  Trig was skipped: its baselines already fail here (section 6).
- Claims marked (verified) were rerun by hand.

## Verdict

Most tests test something. Every library has a basics golden and
almost every one a `checks.xtl` of real laws or known values; every
value recomputed by hand was right (Bits, C(60,30), the lottery's
13983816, Dates' day numbers and Friday the 13ths, Graphs' shortest
paths, Statistics' type-7 quantiles, Polynomials' roots, the Equations
oracle's 560 and 520, Trig's hyperbolic edge cases, ...). The panic-,
bad- and reject- tests pin each library's own rule, with the exceptions
below. No golden pins a FAIL outside the Check library's own
deliberately failing programs, or a NaN.

Mutation testing so far: 82 of 101 mutants caught. About half the
survivors are equivalent changes (subtracting `0 * b` instead of adding
it, a parity flip under `m_od 2`, a sieve that stops later, `n >= 0` to
`n > 0` where both branches agree at 0); the others are gaps listed
below.

## 1. Bugs found

| Where | What | Fix |
| ----- | ---- | --- |
| Ranges' reader, `h:a_tom` (verified) | a bound written with spaces is refused: `@ rg:f_or< "for i:=0..n - 1"` is `error[bad-range]: the parser did not use all of the text`, while `n-1` works. `h:a_tom` takes any text as a bare name, and the whole-text check fails only because the reprint keeps the spaces. Every test writes `len(v)-1`, so it was never seen | squeeze or reprint the parsed bounds, refuse a bare name holding a space, and add a test with spaced bounds |
| `tests/reject-extra` (Ranges) | it passes for the reason above, not because the leftover-text rule fires: the message claims the parser read `fori:=0..10 extra` | fixed with the bug; then the refusal is the rule it names |
| `tests/reject-word` (Ranges) | the pinned message is garbled: `a binding starts with a loop variable (for) (for): while` | pass "a loop word" as the kind |

## 2. Tests that do not reach the rule they name

- `libs/Equations/tests/reject-no-summand`: the comment says a missing
  `|` and summand, the pinned error is the generic term error (`not a
  name, number, A[i,j], function or (sum ...)`, input cut to `sum
  c:=0..C`). Add the specific rule or rename the test; it also hits the
  same message as `reject-empty` / `reject-sum-no-body`.
- `libs/Trig/tests/domain-*` (5) pin X_eTaL's own errors from inside the
  library (`tr:a_cos -1.5` gives `s_qrt needs a number at least 0` at
  `../src/Trig.xtl:25:56`). The comments say so deliberately, but the
  other 19 panic tests follow the opposite convention (the library's
  own message). Add `p_anic` guards.

## 3. Weak checks: would pass for a broken function

From mutants that survived (each behavior verified correct today, but
no golden pins it):

| Where | Untested case | Fix |
| ----- | ------------- | --- |
| Csv `h:u_nquote` | an empty quoted field `""` (exactly 2 characters) | add `cs:f_ields "a,\"\",b"` |
| Check `l:n_ear` | the tolerance branch: Check's own tests never compare values near but not equal under `e_q~` | add a near-but-unequal case, and one just outside the tolerance |
| Check `m:c_ases<` | empty rows are dropped; no test has one | add a case table with a blank row |
| Bits `.xtlm` `h:f_ield?` | a field of width zero (`a:` with no digits) | add a refusal test |
| Numbers `l:i_sqrt` | the correction step; only values where it is not needed are pinned | pin 0..25 and 99, 100 |
| Numbers `l:p_rimes` | the boundary `p_rimes 2` (which gives `2`) | pin it |
| Numbers `l:l_cm` | `0 nb:l_cm 0` (the guard against dividing by 0) | pin it |
| Dates `l:t_oday` | changing `3 t_ake []TS` to `4` survives: today.xtl checks little | see below |
| Eigencube `dir`, `M` | literals in the tables changed without a test failing | look at whether the changed rows are used |

From the read review:

- `libs/Format/tests/checks.xtl` c4 "a column is one width" checks only
  that the result is a matrix: check every row's width and the
  alignment.
- `libs/Plot/tests/checks.xtl` c8 "histogram counts" counts bars, not
  counts: check 3 1 1.
- `libs/Plot/tests/basics.xtl` pins `s_hape svg` (`1349`): only the
  SVG's length, which changes with any formatting edit. Drop it
  (`chart-svg` pins a whole SVG) or check substrings.
- `libs/Plot/tests/demo-functions.out` is empty: the demo only draws.
- `libs/Dates/tests/today.xtl` prints `1 1 1`: line 2 (today's day
  number converts back to the clock's date) is real; line 1 (`t >=
  2026-10-05`) is weak; line 3 (a weekday is 1..7) holds for any
  integer. Keep line 2 as a labeled check, drop line 3.
- `libs/Equations/tests/differential.xtl`: 13 of 40 cases have trivial
  expected values (`"w[i] - (w[i])"` is 0 0 0, `"1"` is 1), and four
  lines repeat. Have `gen-equations-differential.py` reject constant or
  zero results and duplicates.
- Minor: Lists c5/c6 use a window of 1 (the identity); Bits c1 "xor
  twice" passes for an `x_or` returning its left argument (c3 rescues
  it); Dates c4 sorts the weekdays, so any permutation passes.

## 4. Bare 1 and 0

`test-libs.sh` refuses a FAIL line in a golden, but programs that print
a bare `1` bypass it: a re-record (`XETAL_BLESS=1`) would accept a `0`
silently. These are `libs/Eigencube/tests/checks.xtl`,
`libs/Equations/tests/differential.xtl` (40 lines of `1`), the
`m_atch` lines of `libs/Equations/tests/cnn.xtl` and `latex.xtl` and of
the catalog and cnn demos, `libs/Dates/tests/today.xtl`, and the
unlabeled truths in `libs/Parsing/tests/basics.xtl`. Fix: Check's
`k:t_est ... k:i_s` with labels.

## 5. Tautological

- `libs/Grouping/tests/checks.xtl` c6 "b_y with the sum is s_um": `l:s_um`
  is that expression; c4 "mean is sum over count": `l:m_ean` is that
  formula. Replace both with the values basics already verifies
  (10 7 4; 3.33 3.5 4.0).
- `libs/Equations/tests/cnn.xtl`, `latex.xtl` and the cnn demo compare
  `e:e_q<` with the same library's `e:c_orrelate`: two implementations,
  so acceptable, and `oracle.out` has hand-checked values; Fixture C in
  cnn.xtl is only checked against the library.

## 6. Redundant and brittle

- **52 `expand-` refusal goldens** are byte-identical to their run
  twins (`.err` the same, `.out` empty): Equations 30, Parsing 9,
  Ranges 5, Tags 2, and one each in Bits, Check, Csv, Dates, Graphs and
  Polynomials. `xt expand` stops at the same macro error. Fix: in
  `scripts/test-libs.sh`, skip the `expand-` baseline when the program
  fails at expansion.
- **Gensym-laden expansions.** Equations' 21 successful `expand-`
  goldens total about 200 KB with names up to `g176:` and its generated
  helpers in full; Tags' 9 pin `g1:tag`. Any code-generation change
  rebases them all, inviting a blind rebase, and the run goldens already
  pin behavior. Keep one or two representative expansions (Bits'
  `expand-demo-record` is the model) or normalize `gN:` before
  comparing.
- **Library line numbers.** All 19 `panic-*.err` and the 5 Trig
  `domain-*.err` pin `../src/<Lib>.xtl:LINE:COL` and the source line:
  any edit above it rebases them. Compare the message line only.
- **Float noise pinned to the last digit**, which differs by platform:
  `libs/Trig/tests/basics` and `demo-catenary` fail on Linux (verified:
  `-0.5493061443340549` against `-0.5493061443340548`,
  `11.430695811131049` against `11.43069581113105`). Also Matrix basics
  (`-0.9999999999999998`, `-0.0`, `3.0000000000000004`), Geometry basics
  (`0.00000000000000006123233995736766`), Polynomials demo-curve,
  Equations demo-catalog. Round printed values or use `k:n_ear`.
- Repeats: Fixture B's 560..920 is pinned four times (oracle, cnn,
  latex, demo-cnn); `reject-empty` and `reject-sum-no-body` hit the same
  rule.
- Seeded random streams (Random basics, demo-dice, Eigencube's solver
  string) are deliberate; any RNG change rebases them.

## 7. Coverage gaps

Every export is used by some test or demo except Equations'
`c_orrelateTex<` (`c_onvolveTex<` only indirectly) and Eigencube's
`faces`; Geometry's `s_how!` is drawn but never checked; Dates'
`t_oday` only in the weak test above. Missing edge cases: spaced
Ranges bounds (section 1), Csv with CRLF or no final newline,
`c_hoose` with k > n, `n_ear` on large magnitudes.

## Library verdicts

| Library | Verdict |
| ------- | ------- |
| Bits | solid; `expand-demo-record` a model expansion golden; zero-width field untested |
| Check | solid self-tests; the tolerance branch and empty case rows untested |
| Combinatorics | solid (all mutants caught) |
| Csv | solid round trips; empty quoted field untested |
| Dates | solid except today.xtl |
| Eigencube | good identities; bare 1s, a brittle solver string, `faces` untested |
| Equations | strong behavior and an independent Python differential; 30 duplicate refusal goldens, about 200 KB of gensym expansions, `reject-no-summand` off target |
| Format | good basics; checks c4 vacuous |
| Geometry | solid invariants; float noise pinned |
| Graphs | solid, algorithms cross-checked |
| Grouping | basics verified; c4 and c6 tautological |
| Lists | solid laws |
| Matrix | solid algebra laws (all mutants caught); float noise pinned |
| Numbers | solid; boundaries of `i_sqrt`, `p_rimes`, `l_cm` untested; the primes demo comment says 4..40, it computes 6..40 |
| Parsing | adequate; unlabeled truths, 9 duplicate refusal goldens |
| Plot | lines, functions, chart-svg good; basics' length pin, c8 and demo-functions vacuous |
| Polynomials | solid |
| Random | solid statistics; seeded streams brittle by design |
| Ranges | weakest: a real bug hidden by `reject-extra`, a garbled message |
| Search, Sets, Statistics, Strings | solid |
| Tags | solid, with good type refusals; gensym expansions |
| Trig | strongest numerically; fails on Linux by float noise; domain tests pin internal errors |

## Suggested order

1. The Ranges bug and its two tests (section 1), and the off-target
   tests (section 2).
2. Turn the bare 1s into labeled checks (section 4), and the weak and
   tautological checks (sections 3, 5).
3. Drop the 52 duplicate expansion goldens; normalize gensyms, library
   line numbers and float noise (section 6).
4. The coverage gaps as the libraries are next touched.
