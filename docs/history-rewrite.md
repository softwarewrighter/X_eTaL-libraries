# History rewrite (2026-10-05)

Before the X_eTaL repositories sync their tags, this repository's
history was rewritten to drop two directories that no longer belong in
git: `pages/` (the built site, now published as the `gh-pages` branch
by `just publish`) and `vendor/` (a copy of X_eTaL's source, now
pinned by `XETAL_COMMIT`). The user authorized the rewrite and the
force-push; nobody else had a copy to keep.

What changed:

- `git filter-repo --invert-paths --path pages/ --path vendor/` over
  `main` and the tags; the tree of every commit is otherwise the same
  (the tip's tree did not change).
- Three commits touched only those directories and were dropped.
- Every commit ID changed. Tags `v0.3.0` and `v0.4.0` were moved to the
  rewritten commits (their messages are unchanged) and force-pushed
  with `main`. The `gh-pages` branch was not touched.
- The packed history went from about 5 MB (36 MB on disk) to under
  1 MB.

Commit IDs named in older records (the saga's `step.toml` files and
trajectories, `.agentrail-archive/`, commit messages and `CHANGES.md`)
are the old ones; those records are append-only and are not edited.
`docs/history-rewrite-map.txt` maps each old ID to its new one.

Any other clone made before the rewrite must be cloned again (or
reset: `git fetch --force --tags origin && git reset --hard
origin/main`). A backup of the old history was kept outside the
repository as a git bundle.
