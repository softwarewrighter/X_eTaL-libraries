#!/usr/bin/env bash
# Run each ask's repro (docs/xetal-asks.md) with an xetal binary and
# say whether it still shows the problem. Default: the vendored xetal;
# --upstream builds the committed HEAD of ../X_eTaL, or REF (any
# committed ref: a lane's branch, say), from a git archive snapshot
# under target/upstream/ (nothing in ../X_eTaL is touched).
#   scripts/asks.sh [--upstream [REF]]
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ "${1:-}" = --upstream ]; then
  repo="${XETAL_REPO:-$root/../X_eTaL}"
  ref="${2:-HEAD}"
  xetal="$("$root/scripts/build-upstream.sh" "$ref")"
  echo "X_eTaL $ref $(git -C "$repo" rev-parse --short=7 "$ref^{commit}") (committed), built from a snapshot"
else
  xetal="$("$root/scripts/build-xetal.sh")"
  echo "vendored X_eTaL $(sed -n 's/^commit = "\(.......\).*/\1/p' "$root/vendor/xetal/VENDORED")"
fi
tmp="$root/target/asks"; rm -rf "$tmp"; mkdir -p "$tmp"
# X1: a .xtlm macro library found and expanded.
printf 'm:o_r< := { c b -> "{ @ -> (" c_at c c_at ") ? 0.0; " c_at b c_at " } @" }\n' > "$tmp/Control.xtlm"
printf '"x:" u_se< "Control"\nn := 4\n"n = 0" x:o_r< "100 / n"\n' > "$tmp/x1.xtl"
# check NAME PATTERN-WHEN-OPEN COMMAND...: open while the output matches.
check() {
  local name="$1" pat="$2"; shift 2
  local out; out="$( (cd "$tmp" && "$@") 2>&1 || true)"
  if printf '%s' "$out" | grep -qE -- "$pat"; then printf '  %-4s open    %s\n' "$name" "$(printf '%s' "$out" | head -1 | cut -c1-70)"
  else printf '  %-4s FIXED?  %s\n' "$name" "$(printf '%s' "$out" | head -1 | cut -c1-70)"; fi
}
check X1 "error" "$xetal" run x1.xtl
check X2 "error|unrecognized|unexpected|Usage" "$xetal" expand -e '"1 = 1" i_f< "2; 3"'
check X3 "unknown-macro|unknown-builtin" "$xetal" eval -e '1 + @ p_anic< "stopped"'
check X4 "error" "$xetal" eval -e '[]U_CS "A"'
check X11 "error" "$xetal" eval -e '@ c_fg< "cli"'
check X5 "~" "$xetal" eval --ascii -e 'd_isplay ""'
check X6 "overflow" "$xetal" eval -e '2 ^ 70'
check X8 "error" "$xetal" eval -e '8 2 f_ormat 3.14159'
check X9 "error" "$xetal" eval -e '2.0 d_ecode 3 -2 1'
printf 'up := 1 -2 3 > 0\nup * 10\n' > "$tmp/x10.xtl"
check X10 "error" "$xetal" run x10.xtl
echo "  X7   (no repro: matrix divide has no name yet)"
