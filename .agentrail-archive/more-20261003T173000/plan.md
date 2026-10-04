# more

Saga 5 of X_eTaL-libraries (docs/plan.md): libraries that work with
today's X_eTaL, built while saga 4 (macro libraries) waits for
X_eTaL's macro support. Each in its own libs/<Name>/ (src, reg-rs tests
using Check, docs, demos, README), in the live demo, with asks for
what is missing.

Rules as before (CLAUDE.md). Every step: `just pages`, `just gate`,
docs (README, CHANGES.md, plan, asks, the library's README, docs and
demos), a detailed commit to main including .agentrail/, `agentrail
complete`, push. Check `just upstream` at each step's start.

## Steps

1. polynomials -- Polynomials (py:): evaluation (Horner by d_ecode),
   sum, product (convolution by an outer product), derivative,
   integral, roots by Newton's method, text.
2. grouping -- Grouping (gr:): APL's key until X_eTaL has it: groups,
   counts, sums, means, minimum and maximum per key.
3. csv -- Csv (cs:): lines to fields (quoted fields kept whole),
   columns to numbers, a table back to text.
4. search -- Search (sr:): sorted search, merge of sorted lists,
   top-k, ranks (ties averaged or dense), nearest.
5. geometry -- Geometry (ge:): points as 2-row matrices, distances,
   polygon area and centroid (shoelace), rotations and scaling as
   matrices, a convex hull.
6. release-3 -- catalog, pages and the live demo reviewed, asks
   against upstream, retrospective.
