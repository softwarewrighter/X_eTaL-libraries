#!/usr/bin/env bash
# Build xetal from a committed ref of ../X_eTaL (default HEAD; a lane's
# branch, say origin/pr/macros-example) from a git archive snapshot
# under target/upstream/ (nothing in ../X_eTaL is touched), and print
# the binary's path. Each commit is built once.
#   scripts/build-upstream.sh [REF]
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
repo="${XETAL_REPO:-$root/../X_eTaL}"
ref="${1:-HEAD}"
sha="$(git -C "$repo" rev-parse --short=7 "$ref^{commit}")"
src="$root/target/upstream/$sha"
if [ ! -d "$src" ]; then
  mkdir -p "$src"
  git -C "$repo" archive --format=tar "$sha" -- components lib userlibs .cargo | tar -x -C "$src"
fi
(cd "$src/components/cli" && CARGO_TARGET_DIR="$root/target/upstream/build-$sha" cargo build -q --release -p xetal-cli >&2)
echo "$root/target/upstream/build-$sha/release/xetal"
