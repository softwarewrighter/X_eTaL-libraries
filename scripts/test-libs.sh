#!/usr/bin/env bash
# Test the libraries (every lib/<Name>.xtl), or the named ones:
#   - scripts/libs.py check: each is complete (header, tests, page);
#   - "xetal type lib/<Name>.xtl" must equal tests/<Name>/expected/types.out
#     (the exports' types, pinned);
#   - each tests/<Name>/*.xtl runs with the vendored xetal from
#     tests/<Name>/ (--seed 1, --ascii, XETAL_PATH=../../lib, empty
#     standard input) and its stdout must equal expected/<prog>.out and
#     its stderr expected/<prog>.err (empty when there is no .err file).
# XETAL_BLESS=1 rewrites the expected files instead (review the diff!).
# XETAL_LIBS_ROOT overrides the repository root (scripts/selftest-libs.sh).
#   scripts/test-libs.sh [Name...]
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
base="${XETAL_LIBS_ROOT:-$root}"
xetal="$("$root/scripts/build-xetal.sh")"
bless="${XETAL_BLESS:-}"
[ "$bless" = 1 ] || "$root/scripts/libs.py" check
if [ $# -gt 0 ]; then names=("$@"); else
  names=(); while IFS= read -r s; do [ -n "$s" ] && names+=("$s"); done < <("$root/scripts/libs.py" list)
fi
# same EXPECTED_STEM DIR: DIR/out and DIR/err match the expected files;
# the differences go to DIR/diff.
same() {
  local ok=0
  diff -u "$1.out" "$2/out" > "$2/diff" || ok=1
  if [ -f "$1.err" ]; then
    diff -u "$1.err" "$2/err" >> "$2/diff" || ok=1
  elif [ -s "$2/err" ]; then
    { echo "unexpected stderr:"; cat "$2/err"; } >> "$2/diff"; ok=1
  fi
  return $ok
}
# record EXPECTED_STEM LABEL: bless, or compare and report.
record() {
  if [ "$bless" = 1 ]; then
    mkdir -p "$(dirname "$1")"; cp "$tmp/out" "$1.out"
    if [ -s "$tmp/err" ]; then cp "$tmp/err" "$1.err"; else rm -f "$1.err"; fi
    echo "blessed: $2"
  elif [ ! -f "$1.out" ]; then
    echo "FAIL: $2: no $(basename "$1").out (XETAL_BLESS=1 to create)"; fail=1
  elif same "$1" "$tmp"; then
    echo "ok: $2"
  else
    echo "FAIL: $2"; cat "$tmp/diff"; fail=1
  fi
}
fail=0; n=0
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
for name in ${names[@]+"${names[@]}"}; do
  [ -f "$base/lib/$name.xtl" ] || { echo "test: no library lib/$name.xtl" >&2; exit 1; }
  d="$base/tests/$name"
  n=$((n + 1))
  (cd "$base" && "$xetal" type "lib/$name.xtl" >"$tmp/out" 2>"$tmp/err") || true
  record "$d/expected/types" "$name types"
  for prog in "$d"/*.xtl; do
    [ -e "$prog" ] || continue
    p="$(basename "$prog" .xtl)"
    (cd "$d" && XETAL_PATH=../../lib "$xetal" run --seed 1 --ascii --draw "$tmp/draw" "$p.xtl" \
      </dev/null >"$tmp/out" 2>"$tmp/err") || true
    record "$d/expected/$p" "$name/$p"
  done
done
echo "test-libs: $n librar$([ $n = 1 ] && echo y || echo ies)$([ $fail = 0 ] && echo ', all passed' || echo ', FAILURES')"
exit $fail
