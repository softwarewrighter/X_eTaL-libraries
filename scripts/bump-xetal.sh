#!/usr/bin/env bash
# Move to a newer X_eTaL: resolve a COMMITTED ref of ../X_eTaL to its
# full SHA, write it to XETAL_COMMIT and build it (scripts/xetal.sh).
# Then run just gate and commit XETAL_COMMIT with what the new version
# changed (baselines, types, pages).
#   scripts/bump-xetal.sh            # HEAD of ../X_eTaL
#   scripts/bump-xetal.sh REF        # any ref git rev-parse accepts
#   XETAL_REPO=/path scripts/bump-xetal.sh
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
repo="${XETAL_REPO:-$root/../X_eTaL}"
sha="$(git -C "$repo" rev-parse "${1:-HEAD}^{commit}")"
echo "$sha" > "$root/XETAL_COMMIT"
echo "XETAL_COMMIT: ${sha:0:7} ($(git -C "$repo" log -1 --format=%s "$sha"))" >&2
XETAL_SOURCE="${XETAL_SOURCE:-$repo}" "$root/scripts/xetal.sh"
