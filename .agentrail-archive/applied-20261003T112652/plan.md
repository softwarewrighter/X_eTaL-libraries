# applied

Saga 3 of X_eTaL-libraries (docs/plan.md): the applied libraries,
each in its own libs/<Name>/ (src, reg-rs tests using Check, docs,
demos, README), in the live demo, with asks for what is missing.

Rules as before (CLAUDE.md): ported, not copied; X_eTaL only through
vendor/xetal/ (refresh only at a saga start or when an ask has
landed); asks in docs/xetal-asks.md; X_eTaL shown in rendered form on
the site. Every step: `just pages` (pages/ committed), `just gate`,
docs (README, CHANGES.md, plan, asks, the library's README, docs and
demos), .gitignore sane, a detailed commit to main including
.agentrail/, `agentrail complete`, push.

## Steps

1. format -- Format (f:): fixed decimals, padded and aligned columns,
   a text table from a matrix, thousands separators.
2. plot -- Plot (p:): text charts: horizontal bars, sparklines,
   histograms, a scatter on a character grid; pictures by []G_RID and
   []P_ATH where they fit.
3. dates -- Dates (d:): day numbers from civil dates and back, day of
   week, leap years, days between, a month calendar as a matrix.
4. statistics -- Statistics (sx:): median, mode, quantiles, z-scores,
   covariance, correlation, a linear fit, histogram counts; imports
   the standard Stats.
5. graphs -- Graphs (g:): adjacency matrices: degrees, reachability
   (Warshall), shortest paths (min-plus), BFS levels, components.
6. bits -- Bits (b:): to and from binary, popcount, xor, and, or,
   shifts and masks by e_ncode/d_ecode.
7. release-2 -- catalog, pages and site reviewed, asks reviewed, the
   vendored X_eTaL refreshed if an ask landed, retrospective.
