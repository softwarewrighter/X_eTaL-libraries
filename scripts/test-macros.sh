#!/usr/bin/env bash
# Run the libraries' macro programs (libs/<Name>/macros/*.xtl, which
# use the library's .xtlm macros) with an xetal that runs .xtlm files,
# built from a committed ref of ../X_eTaL (default the macros lane,
# XETAL_MACROS_REF overrides; once X_eTaL main has them and they are
# vendored, these move into the ordinary tests). For each program its
# output (stdout and stderr) must equal macros/expected/NAME.out and
# its expansion (xetal expand) macros/expected/NAME.expand.
# XETAL_BLESS=1 rewrites them (review the diff!).
#   scripts/test-macros.sh [REF] [Name...]
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ref="${1:-${XETAL_MACROS_REF:-origin/pr/macros-example}}"
shift || true
XETAL_BIN="$("$root/scripts/build-upstream.sh" "$ref")"; export XETAL_BIN
if [ $# -gt 0 ]; then names=("$@"); else names=(); for d in "$root"/libs/*/macros; do [ -d "$d" ] && names+=("$(basename "$(dirname "$d")")"); done; fi
fail=0; n=0
for name in ${names[@]+"${names[@]}"}; do
  d="$root/libs/$name/macros"
  for p in "$d"/*.xtl; do
    [ -e "$p" ] || continue
    b="$(basename "$p" .xtl)"; n=$((n + 1)); mkdir -p "$d/expected"
    out="$(cd "$d" && "$root/scripts/xt" run "$b.xtl" 2>&1)" || true
    exp="$(cd "$d" && "$root/scripts/xt" expand "$b.xtl" 2>&1)" || true
    if [ "${XETAL_BLESS:-}" = 1 ]; then
      printf '%s\n' "$out" > "$d/expected/$b.out"; printf '%s\n' "$exp" > "$d/expected/$b.expand"
      echo "blessed: $name/macros/$b"; continue
    fi
    ok=1
    [ "$(printf '%s\n' "$out")" = "$(cat "$d/expected/$b.out" 2>/dev/null)" ] || { echo "FAIL: $name/macros/$b output:"; diff <(cat "$d/expected/$b.out" 2>/dev/null) <(printf '%s\n' "$out") || true; ok=0; }
    [ "$(printf '%s\n' "$exp")" = "$(cat "$d/expected/$b.expand" 2>/dev/null)" ] || { echo "FAIL: $name/macros/$b expansion:"; diff <(cat "$d/expected/$b.expand" 2>/dev/null) <(printf '%s\n' "$exp") || true; ok=0; }
    [ $ok = 1 ] && echo "ok: $name/macros/$b" || fail=1
  done
done
echo "test-macros: $n program(s) with X_eTaL $ref$([ $fail = 0 ] && echo ', all passed' || echo ', FAILURES')"
exit $fail
