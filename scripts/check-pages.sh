#!/usr/bin/env bash
# Fail when pages/ was built from other libraries, site or X_eTaL than
# the working tree's (run "just pages" and commit pages/).
#   scripts/check-pages.sh
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
want="$("$root/scripts/pages-inputs.sh")"
got="$(cat "$root/pages/INPUTS" 2>/dev/null || true)"
[ "$want" = "$got" ] || { echo "check-pages: pages/ is stale: run just pages and commit pages/" >&2; exit 1; }
echo "check-pages: ok"
