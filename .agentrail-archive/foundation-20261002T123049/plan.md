# foundation

Saga 1 of X_eTaL-libraries (docs/plan.md): the process, the vendored
interpreter, the library layout (lib/ on XETAL_PATH, tests/ goldens
with pinned export types), and the first libraries published end to
end.

Model: ../X_eTaL-games and ../X_eTaL-demos (same vendoring scripts,
gate and process), ../X_eTaL (CHANGES.md, lib/ conventions).

Rules: libraries are plain X_eTaL (.xtl) in lib/; X_eTaL only through
the vendored snapshot in vendor/xetal/; missing features and bugs go
in docs/xetal-asks.md, workarounds named; macro libraries (.xtlm)
wait until X_eTaL supports them. Every step: `just gate` passes, docs
(README, CHANGES.md, plan, asks, the library's page) updated,
.gitignore sane, a detailed commit to main including .agentrail/,
`agentrail complete`, push.

## Steps

1. scaffold -- process, CLAUDE.md/AGENTS.md, README, COPYRIGHT,
   LICENSE, CHANGES.md, justfile, gate, docs/plan.md,
   docs/xetal-asks.md.
2. vendor-xetal -- `just vendor [REF]`, vendor/xetal/VENDORED,
   `just xetal`, `just eval`, gate check.
3. library-layout -- lib/, tests/<Name>/ goldens (programs and
   pinned export types), docs/libs/<Name>.md, template, new-lib,
   test runner with self-test, recipes, XETAL_PATH helper.
4. check -- the Check library: assertions that report as text, for
   tests and teaching; used by the other libraries' tests from here on.
5. strings -- the Strings library (case, trim, split, join, search,
   replace, pad), ported from J strings, BQN strings.bqn and dfns.
