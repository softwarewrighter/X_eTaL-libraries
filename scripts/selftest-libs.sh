#!/usr/bin/env bash
# Test the library tooling itself in a scratch root: new-lib makes a
# library that passes; a wrong expected output fails; an unexpected
# stderr fails and blessing repairs it; a changed export type fails;
# an undocumented export fails; a library named like a standard one
# and one without its import line are rejected.
#   scripts/selftest-libs.sh
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
XETAL_LIBS_ROOT="$(mktemp -d)"; export XETAL_LIBS_ROOT
trap 'rm -rf "$XETAL_LIBS_ROOT"' EXIT
t="$root/scripts/test-libs.sh"
r="$XETAL_LIBS_ROOT"
expect() { # expect pass|fail DESCRIPTION
  if "$t" Probe >/dev/null 2>&1; then got=pass; else got=fail; fi
  [ "$got" = "$1" ] || { echo "selftest: $2: expected $1, got $got" >&2; "$t" Probe || true; exit 1; }
}
"$root/scripts/new-lib.sh" Probe pr: "A probe & co" >/dev/null
grep -q '^# Probe: A probe & co$' "$r/lib/Probe.xtl"
expect pass "a fresh library"
echo 56 > "$r/tests/Probe/expected/basics.out"
expect fail "a wrong expected output"
XETAL_BLESS=1 "$t" Probe >/dev/null
expect pass "after blessing"
printf '"pr:" u_se< "Probe"\n1 +\n' > "$r/tests/Probe/basics.xtl"
expect fail "an unexpected error"
XETAL_BLESS=1 "$t" Probe >/dev/null
[ -s "$r/tests/Probe/expected/basics.err" ]
expect pass "an expected error"
sed -i.bak 's/{ x -> x }/{ x -> x + 1 }/' "$r/lib/Probe.xtl" && rm "$r/lib/Probe.xtl.bak"
expect fail "a changed export type"
XETAL_BLESS=1 "$t" Probe >/dev/null
printf 'l:t_wice := { x -> x * 2 }\n' >> "$r/lib/Probe.xtl"
XETAL_BLESS=1 "$t" Probe >/dev/null
expect fail "an undocumented export"
printf '\n`pr:t_wice`\n' >> "$r/docs/libs/Probe.md"
expect pass "once documented"
sed -i.bak '/u_se</d' "$r/lib/Probe.xtl" && rm "$r/lib/Probe.xtl.bak"
expect fail "no import line in the header"
if "$root/scripts/new-lib.sh" Stats st: "x" >/dev/null 2>&1; then
  echo "selftest: new-lib made a library named like a standard one" >&2; exit 1
fi
echo "selftest-libs: ok"
