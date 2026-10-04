#!/usr/bin/env bash
# The pre-commit gate: the vendored X_eTaL (scripts/check-vendor.sh),
# the library tooling (scripts/selftest-libs.sh), every library's tests
# (scripts/test-libs.sh, reg-rs), the pages' examples against the
# baselines (scripts/check-examples.py), the live demo (site/: its
# tests, its wasm32 build, pages/ current), then ASCII-only markdown for the docs we own.
#   scripts/gate.sh
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
"$root/scripts/check-vendor.sh"
"$root/scripts/selftest-libs.sh"
"$root/scripts/test-libs.sh"
"$root/scripts/check-examples.py"
# The live demo (site/): every demo through xetal-play as recorded, natively; the wasm32 build checks.
(cd "$root/site" && cargo test -q >/dev/null 2>&1 && cargo check -q --target wasm32-unknown-unknown) \
  || { (cd "$root/site" && cargo test -q); echo "FAIL: site"; exit 1; }
echo "ok: site"
"$root/scripts/check-pages.sh"
# Every macro library (.xtlm) type-checks, its macros text to text.
"$root/scripts/check-xtlm.sh" >/dev/null || { "$root/scripts/check-xtlm.sh"; exit 1; }
echo "ok: macro libraries"
# Control.xtlm's macro bodies (docs/control.md), until X_eTaL runs .xtlm.
"$root/docs/control/check.sh" >/dev/null || { "$root/docs/control/check.sh"; exit 1; }
echo "ok: control bodies"
md=(README.md CHANGES.md docs/plan.md docs/xetal-asks.md docs/control.md)
for f in libs/*/README.md libs/*/docs/README.md; do [ -e "$f" ] && md+=("$f"); done
for f in "${md[@]}"; do sw-markdown-checker -f "$f" >/dev/null || { sw-markdown-checker -f "$f"; exit 1; }; done
echo "gate: ok"
