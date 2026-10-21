# Saga 16 -- parsing-guide

Saga 13 landed `libs/Parsing` itself (total parsers for macro authors)
and moved Equations and Tags onto it, but closed with no user-facing
teaching material: `libs/Parsing/docs/` has only its reference
README, and `libs/Parsing/demos/` has one program (`pieces.xtl`) that
is not a worked example of writing a notation macro. The blog agent
found this while fact-checking a draft post against current main and
proposed five pieces of teaching material; this saga builds them.
Each step is its own commit to `main`, gated, with `CHANGES.md` and
`docs/plan.md` updated.

| Step | Slug | Content |
| ---- | ---- | ------- |
| 1 | guide | `libs/Parsing/docs/guide.md`: writing one small notation macro step by step, using each of Parsing's tool groups in turn (split outside brackets, a balanced group, a chain with a leading minus, a binding `i:=a..b`, a function applied, a reference, the whole-text check); linked from `libs/Parsing/README.md` and `docs/macros.md` |
| 2 | ranges-library | A tiny new library, `libs/Ranges` (full structure: `src/`, `tests/`, `docs/README.md`, `demos/`, catalog row, `GROUPS` in `site/src/lib.rs`), whose one macro is exactly the guide's worked example (a range-with-step notation, `0..10 by 2`, or a short declaration list -- whichever reads better in one sitting) over Parsing; a good-input demo with its `xetal expand` pinned, and a set of bad-input demos, one file per mistake, each with its pinned `[]R_EJECT` baseline |
| 3 | before-after | A before-and-after demo program (`libs/Parsing/demos/`): a naive hand-rolled reader of `(y[i] - p[i])^2` beside the Parsing version, showing the naive one's silent wrong answer next to Parsing's refusal -- the motivating case for the library |
| 4 | where-tag | A section of the guide (step 1) explaining the where tag: how a string such as `"bad-equation right"` maps to `[]R_EJECT`'s error code and the position it reports, traced through one concrete call |
| 5 | doc-site-check | Confirm the guide and every new demo appear on the cross-reference site (`xetal doc --out`) and in the live demo (`Ranges` in a `GROUPS` row, its demos as chips); spot-check in the browser; fix any gap found, then `just publish` |
