#!/usr/bin/env bash
# Run a library's test program as the tests do (from tests/Name/, with
# lib/ on XETAL_PATH, --seed 1), default all of them; --echo shows
# each statement before its output (a notebook).
#   scripts/run-lib.sh [--echo] Name [program]
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo=(); [ "${1:-}" = --echo ] && { echo=(--echo); shift; }
name="${1:?usage: run-lib.sh [--echo] Name [program]}"
d="$root/tests/$name"
[ -d "$d" ] || { echo "run: no tests/$name" >&2; exit 1; }
xetal="$("$root/scripts/build-xetal.sh")"
if [ -n "${2:-}" ]; then progs=("${2%.xtl}.xtl"); else progs=(); for p in "$d"/*.xtl; do progs+=("$(basename "$p")"); done; fi
for p in "${progs[@]}"; do
  [ ${#progs[@]} -gt 1 ] && echo "== $name/$p"
  (cd "$d" && XETAL_PATH=../../lib "$xetal" run --seed 1 ${echo[@]+"${echo[@]}"} "$p")
done
