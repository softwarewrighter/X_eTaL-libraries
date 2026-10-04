#!/usr/bin/env bash
# Every macro library (libs/<Name>/src/<Name>.xtlm) type-checks, and each
# of its macros is a function from text to text (Char -> Char -> Char),
# checked with the vendored xetal by reading the file as a plain
# library (m:name< := read as l:name :=), until the vendored X_eTaL
# loads .xtlm files itself.
#   scripts/check-xtlm.sh
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
work="$root/target/xtlm"; rm -rf "$work"; mkdir -p "$work"
fail=0; n=0
for f in "$root"/libs/*/src/*.xtlm; do
  [ -e "$f" ] || continue
  name="$(basename "$f" .xtlm)"; n=$((n + 1))
  sed -E 's/^m:([a-z]_[A-Za-z0-9?!]*)< :=/l:\1 :=/' "$f" > "$work/${name}Macros.xtl"
  types="$(cd "$work" && "$root/scripts/xt" type "${name}Macros.xtl" 2>&1)" || { echo "FAIL: $name.xtlm: $types"; fail=1; continue; }
  bad="$(printf '%s\n' "$types" | grep -v ': Char -> Char -> Char$' || true)"
  if [ -n "$bad" ]; then echo "FAIL: $name.xtlm: a macro is not text to text:"; echo "$bad"; fail=1; else echo "ok: $name.xtlm ($(printf '%s\n' "$types" | wc -l | tr -d ' ') macros)"; fi
done
echo "check-xtlm: $n macro librar$([ $n = 1 ] && echo y || echo ies)$([ $fail = 0 ] && echo ', all text to text' || echo ', FAILURES')"
exit $fail
