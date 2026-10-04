#!/usr/bin/env bash
# Every macro library (libs/<Name>/src/<Name>.xtlm) type-checks with the
# vendored xetal (xetal type X.xtlm), and each of its macros takes text
# or @ (Unit) on the left and text on the right and gives text:
# Char -> Char -> Char or Unit -> Char -> Char.
#   scripts/check-xtlm.sh
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
work="$root/target/xtlm"; rm -rf "$work"; mkdir -p "$work"
fail=0; n=0
for f in "$root"/libs/*/src/*.xtlm; do
  [ -e "$f" ] || continue
  name="$(basename "$f" .xtlm)"; n=$((n + 1))
  types="$(cd "$(dirname "$f")" && "$root/scripts/xt" type "$name.xtlm" 2>&1)" || { echo "FAIL: $name.xtlm: $types"; fail=1; continue; }
  bad="$(printf '%s\n' "$types" | grep -vE ': (Char|Unit) -> Char -> Char$' || true)"
  if [ -n "$bad" ]; then echo "FAIL: $name.xtlm: a macro is not text to text:"; echo "$bad"; fail=1; else echo "ok: $name.xtlm ($(printf '%s\n' "$types" | wc -l | tr -d ' ') macros)"; fi
done
echo "check-xtlm: $n macro librar$([ $n = 1 ] && echo y || echo ies)$([ $fail = 0 ] && echo ', all text to text' || echo ', FAILURES')"
exit $fail
