# core

Saga 2 of X_eTaL-libraries (docs/plan.md): the core libraries every
program reaches for, each a pure X_eTaL file in lib/ with tests (using
Check), pinned types, a page with provenance, and asks for what is
missing.

Rules as in saga 1 (CLAUDE.md): lib/<Name>.xtl, tests/<Name>/,
docs/libs/<Name>.md; ported, not copied; X_eTaL only through
vendor/xetal/ (refresh at the saga start only if a needed ask has
landed); asks in docs/xetal-asks.md. Every step: `just gate`, docs
(README, CHANGES.md, plan, asks, page), .gitignore sane, a detailed
commit to main including .agentrail/, `agentrail complete`, push.

## Steps

1. sets -- Sets (se:): union, intersection, difference, symmetric
   difference, subset?, same set?, counts of each item.
2. numbers -- Numbers (n:): gcd, lcm, primes (sieve), prime?,
   factors, divisors, digits, integer square root, Fibonacci.
3. combinatorics -- Combinatorics (cb:): factorial, binomial,
   combinations (dfns cmat), permutations (pmat), subsets, product.
4. lists -- Lists (q:): differences, windows, moving averages, run
   lengths, counts, interleave, binary search.
5. matrix -- Matrix (mx:): transpose, identity, diagonal, trace,
   product, determinant, inverse and solve (Gauss-Jordan).
6. random -- Random (r:): shuffle, deal, choice, uniform and normal.
7. release-1 -- catalog and pages reviewed, examples re-run, asks
   reviewed, retrospective in docs/plan.md.
